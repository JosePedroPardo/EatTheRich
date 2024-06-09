extends CharacterBody2D

signal puf_selected(puf)
signal puf_deselected(puf)
signal puf_dragging
signal puf_undragging
signal cell_ocuppied(cood_cell)
signal cell_unocuppied(cood_cell)

@export var wait_time_move: float = 0.4 ## Tiempo de espera entre un movimiento y el siguiente
@export var can_assemble: bool = false
@export var move_grid_speed: float = 1 ## Velocidad a la que se desplaza el puf por el grid
@export var move_drag_speed: float = 15 ## Velocidad a la que se desplaza el puf al ser arrastrado

var myself: Puf: 
	get: return myself
	set(_myself):
		myself = _myself
var is_baby: bool = false:
	get: return is_baby
	set(_is_baby):
		is_baby = _is_baby
var is_selected: bool = false:
	get:
		return is_selected
	set(new_bool):
		is_selected = new_bool

var social_class: int = DefinitionsHelper.INDEX_RANDOM_SOCIAL_CLASS:
	set(_social_class):
		social_class = _social_class
var is_dragging: bool = false
var is_can_grid_move: bool = false
var is_your_moving: bool = false
var is_look_to_target_position: bool = false
var initial_grid_cell: Vector2i
var ocuppied_cells: Array[Vector2i]
var current_paths: Array[Vector2i]
var look_at_position: Vector2
var current_clic_position: Vector2
var target_grid_position: Vector2

@onready var sprite_puf: Sprite2D = $SpritePuf
@onready var outline_select_sprite: AnimatedSprite2D = $SelectedPuf
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var wait_timer: Timer = $WaitTime
@onready var assemble_area: CollisionShape2D = $InteractionComponents/AssembleArea/AssembleShape
@onready var repulsion_area: CollisionShape2D = $InteractionComponents/RepulsionArea/RepulsionShape
@onready var shape_puf: CollisionShape2D = $ShapePuf
@onready var manager_puf: Node2D = get_node(PathsHelper.MANAGER_PUF_PATH)
@onready var tilemap: TileMap = get_node(PathsHelper.TILEMAP_PATH)
@onready var astar_grid: AStarGrid2D = tilemap.astar_grid

func _init():
	myself = Puf.new(social_class, is_baby)

func _ready():
	social_class = myself.social_class
	_change_sprite_according_social_class()
	animation_player.play(DefinitionsHelper.ANIMATION_IDLE_PUF)
	initial_grid_cell = tilemap.local_to_map(self.position)
	manager_puf.connect("ocuppied_cells_array", Callable(self, "_on_ocuppied_cells"))
	emit_signal("cell_ocuppied", initial_grid_cell)

func _process(delta):
	if is_selected: 
		if is_your_moving and is_look_to_target_position: _look_to_mouse(look_at_position)
		else: _look_to_mouse(get_local_mouse_position())
		if is_can_grid_move: 
			_move_to_grid_position_through_current_paths()

	if Input.is_action_just_pressed(InputsHelper.ASSEMBLE_PUF) and can_assemble:
		print("se juntan")

func _physics_process(delta):
	if is_dragging:
		current_clic_position = get_global_mouse_position()
		_move_to_clic_position_according_to_speed(current_clic_position, move_drag_speed)
		_look_to_mouse(current_clic_position)
	
	if Input.is_action_just_pressed(InputsHelper.LEFT_CLICK):
		current_clic_position = get_global_mouse_position()
		_to_where_i_look() 
		if is_selected:
			_calculate_current_paths_through_clic_position(current_clic_position)

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_mouse_button_pressed()
			else:
				_mouse_button_released()
			if is_myself_rich():
				_emit_signal_with_when_dragging()

func _to_where_i_look():
	look_at_position = get_local_mouse_position()

func _look_to_mouse(clic_position: Vector2):
	sprite_puf.flip_h = clic_position.x < 0

func _is_position_free(current_position: Vector2i) -> bool:
	current_position = tilemap.map_to_local(current_position)
	return not ocuppied_cells.has(current_position)

func _is_death_position(current_position: Vector2i) -> bool:
	current_position = tilemap.map_to_local(current_position)
	return not tilemap.is_point_death_cells(current_position)

func _move_to_clic_position_according_to_speed(clic_position: Vector2, speed: float):
	_reproduce_animation_according_to_situation(DefinitionsHelper.ANIMATION_DRAG_PUF)
	var direction = (tilemap.map_to_local(tilemap.local_to_map(clic_position)) - self.position).normalized()
	self.velocity = (direction * speed)
	move_and_slide()

func _calculate_current_paths_through_clic_position(clic_position: Vector2):
	var myself_local_position = tilemap.local_to_map(self.position)
	var current_clic_local_position = tilemap.local_to_map(clic_position)
	if tilemap.is_point_walkable_map_local_position(current_clic_local_position):
		if _is_position_free(current_clic_local_position):
			#if not _is_death_position(current_clic_local_position):
			current_paths = tilemap.get_current_path(myself_local_position, current_clic_local_position).slice(1)
			is_can_grid_move = false if current_paths.is_empty() else true

func _move_to_grid_position_through_current_paths():
	if current_paths.is_empty():
		is_your_moving = false
		is_look_to_target_position = false
		_reproduce_animation_according_to_situation(DefinitionsHelper.ANIMATION_IDLE_PUF)
		return
	var target_position = tilemap.map_to_local(current_paths.front())
	is_look_to_target_position = true
	_reproduce_animation_according_to_situation(DefinitionsHelper.ANIMATION_RUN_PUF)
	_emit_signal_with_ocuppied_grid_position(tilemap.local_to_map(self.global_position), true)
	self.global_position = self.global_position.move_toward(target_position, move_grid_speed)
	await get_tree().create_timer(wait_time_move).timeout
	if self.global_position == target_position:
		is_your_moving = true
		current_paths.pop_front()
		_emit_signal_with_ocuppied_grid_position(target_position, true)

func _reproduce_animation_according_to_situation(situation: String):
	var animation: String = DefinitionsHelper.ANIMATION_IDLE_PUF
	match situation:
		DefinitionsHelper.ANIMATION_SELECTED_PUF: animation = DefinitionsHelper.ANIMATION_SELECTED_PUF
		DefinitionsHelper.ANIMATION_WALK_PUF: animation = DefinitionsHelper.ANIMATION_WALK_PUF
		DefinitionsHelper.ANIMATION_RUN_PUF: animation = DefinitionsHelper.ANIMATION_RUN_PUF
		DefinitionsHelper.ANIMATION_RESET_PUF: animation = DefinitionsHelper.ANIMATION_RESET_PUF
		DefinitionsHelper.ANIMATION_DIE_PUF: animation = DefinitionsHelper.ANIMATION_DIE_PUF
		DefinitionsHelper.ANIMATION_IDLE_PUF: animation = DefinitionsHelper.ANIMATION_IDLE_PUF
		DefinitionsHelper.ANIMATION_SICK_PUF: animation = DefinitionsHelper.ANIMATION_SICK_PUF
		DefinitionsHelper.ANIMATION_DRAG_PUF: animation = DefinitionsHelper.ANIMATION_DRAG_PUF
		DefinitionsHelper.ANIMATION_DROP_PUF: animation = DefinitionsHelper.ANIMATION_DROP_PUF
		DefinitionsHelper.ANIMATION_TERROR_PUF: animation = DefinitionsHelper.ANIMATION_TERROR_PUF
		DefinitionsHelper.ANIMATION_DEATH_BY_FALL_PUF: animation = DefinitionsHelper.ANIMATION_DEATH_BY_FALL_PUF
		DefinitionsHelper.ANIMATION_TO_DIE: animation = DefinitionsHelper.ANIMATION_TO_DIE
		_: animation = DefinitionsHelper.ANIMATION_IDLE_PUF
	if not animation_player.get_queue().has(animation):
		animation_player.play(animation)

func _add_animation_to_queue(animation: String):
	if animation_player.has_animation(animation):
		animation_player.queue(animation)

func _mouse_button_pressed():
	if !is_myself_rich():
		_selectAndDeselect()
	elif is_myself_rich(): 
		is_dragging = true

func _mouse_button_released():
	if is_myself_rich(): 
		is_dragging = false

func _change_sprite_according_social_class():
	var path_texture: String
	if social_class == DefinitionsHelper.INDEX_RICH_SOCIAL_CLASS:
		path_texture = RandomHelper.get_random_string_in_array(DefinitionsHelper.texture_rich_pufs)
	elif social_class == DefinitionsHelper.INDEX_POOR_SOCIAL_CLASS:
		path_texture = RandomHelper.get_random_string_in_array(DefinitionsHelper.texture_poor_pufs)
	sprite_puf.texture = load(path_texture)

func _selectAndDeselect(): 
	is_selected = !is_selected
	outline_select_sprite.visible = is_selected
	var name_signal: String = "puf_selected" if is_selected else "puf_deselected"
	outline_select_sprite.play(DefinitionsHelper.ANIMATION_SELECTED_PUF) if is_selected else outline_select_sprite.stop()
	emit_signal(name_signal, self)

''' Métodos de señales '''
func _emit_signal_with_ocuppied_grid_position(current_grid_cell: Vector2, free_or_not: bool):
	var signal_name = "cell_unocuppied" if free_or_not else "cell_ocuppied"  
	emit_signal(signal_name, Vector2i(current_grid_cell))

func _emit_signal_with_when_dragging():
	var signal_name = "puf_dragging" if is_dragging else "puf_undragging"  
	emit_signal(signal_name)

func _on_ocuppied_cells(_ocuppied_cells):
	ocuppied_cells.clear()
	ocuppied_cells.append_array(_ocuppied_cells)

func _on_mouse_entered():
	if is_myself_rich():
		self.position.y += -2
		_reproduce_animation_according_to_situation(DefinitionsHelper.ANIMATION_TERROR_PUF)

func _on_mouse_exited():
	if is_myself_rich():
		self.position.y += +2
		_reproduce_animation_according_to_situation(DefinitionsHelper.ANIMATION_DROP_PUF)
		_add_animation_to_queue(DefinitionsHelper.ANIMATION_IDLE_PUF)

func _on_puf_dragging():
	is_can_grid_move = false

func _on_puf_undragging():
	is_can_grid_move = false

''' Getters del Puf asociado a este CharacterBody2D '''
func get_social_class():
	match(myself.social_class):
		0: return DefinitionsHelper.POOR_SOCIAL_CLASS
		1: return DefinitionsHelper.RICH_SOCIAL_CLASS
		_: return "null"

func is_myself_rich():
	return get_social_class() == DefinitionsHelper.RICH_SOCIAL_CLASS

func get_background() -> String:
	return _get_variable_by_name("background")

func get_name_of_puf() -> String:
	return _get_variable_by_name("name_of_puf")

func get_surname() -> String:
	return _get_variable_by_name("surname")

func get_noble_title() -> String:
	return _get_variable_by_name("noble_title")

func get_profession() -> String:
	return _get_variable_by_name("profession")

func get_place() -> String:
	return _get_variable_by_name("place")

func get_hunger() -> float:
	return _get_variable_by_name("hunger")

func get_thirst() -> float:
	return _get_variable_by_name("thirst")

func get_height() -> float:
	return _get_variable_by_name("height")

func get_birth_year() -> int:
	return _get_variable_by_name("birth_year")

func get_years() -> int:
	return _get_variable_by_name("years")

func get_is_interactive() -> bool:
	return _get_variable_by_name("is_interactive")

func get_constitution() -> Puf.Constitution:
	return _get_variable_by_name("constitution")

func get_mood() -> Puf.Mood:
	return _get_variable_by_name("mood")

func get_health_status() -> Puf.Health_status:
	return _get_variable_by_name("health_status")

func get_ascendant() -> Puf:
	return _get_variable_by_name("ascendant")

func get_descendant() -> Array[Puf]:
	return _get_variable_by_name("descendant")

func get_full_name() -> String:
	return _get_variable_by_name("get_full_name")

func get_percentage_of_thrist() -> String:
	return _get_variable_by_name("get_percentage_of_thrist")

func get_percentage_of_hunger() -> String:
	return _get_variable_by_name("get_percentage_of_hunger")

func get_json_serialize() -> String:
	return _get_variable_by_name("get_json_serialize")

func _get_variable_by_name(name: String):
	match name:
		"background":
			return myself.background
		"name_of_puf":
			return myself.name_of_puf
		"surname":
			return myself.surname
		"noble_title":
			return myself.noble_title
		"profession":
			return myself.profession
		"place":
			return myself.place
		"hunger":
			return myself.hunger
		"thirst":
			return myself.thirst
		"height":
			return myself.height
		"birth_year":
			return myself.birth_year
		"years":
			return myself.years
		"is_interactive":
			return myself.is_interactive
		"constitution":
			return myself.constitution
		"social_class":
			return myself.social_class
		"mood":
			return myself.mood
		"mood":
			return myself.health_status
		"ascendant":
			return myself.ascendant
		"descendant":
			return myself.descendant
		"get_full_name":
			return myself.get_full_name()
		"get_percentage_of_thrist":
			return myself.get_percentage_of_thrist()
		"get_percentage_of_hunger":
			return myself.get_percentage_of_hunger()
		"get_json_serialize":
			return myself.jsonSerialize()		
		_:
			return null
