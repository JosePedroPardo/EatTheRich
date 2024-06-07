extends CharacterBody2D

signal puf_selected(_self)
signal puf_deselected(_self)
signal puf_dragging(_self)
signal puf_undragging(_self)
signal cell_ocuppied(cood_cell)
signal cell_unocuppied(cood_cell)

@export var wait_time_move: float = 0.5 ## Tiempo de espera entre un movimiento y el siguiente
@export var can_assemble: bool = false
@export var move_speed: float = 1 ## Velocidad a la que se desplaza el puf por el grid

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

var social_class: int = DefinitionsHelper.RANDOM_SOCIAL_CLASS:
	set(_social_class):
		social_class = _social_class
var is_can_move: bool = false
var is_dragging: bool = false
var current_path: Array[Vector2i]
var look_at_position: Vector2i
var initial_grid_cell: Vector2i
var current_grid_cell: Vector2i
var next_grid_cell: Vector2i
var ocuppied_cells: Array[Vector2i]

@onready var sprite_puf: Sprite2D = $SpritePuf
@onready var selected_puf: AnimatedSprite2D = $SelectedPuf
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var wait_timer: Timer = $WaitTime
@onready var assemble_area: CollisionShape2D = $InteractionComponents/AssembleArea/AssembleShape
@onready var repulsion_area: CollisionShape2D = $InteractionComponents/RepulsionArea/RepulsionShape
@onready var shape_puf: CollisionShape2D = $ShapePuf
@onready var manager_puf: Node2D = get_node(PathsHelper.MANAGER_PUF_PATH)
@onready var tilemap: TileMap = get_node(PathsHelper.TILEMAP_PATH)
@onready var astar_grid: AStarGrid2D = tilemap.astar_grid
@onready var clic_position: Vector2i = self.position

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
		current_grid_cell = tilemap.local_to_map(self.position)
		
		if next_grid_cell == current_grid_cell:
			emit_signal("cell_ocuppied", current_grid_cell)
		else: 
			emit_signal("cell_unocuppied", current_grid_cell)
		
		if is_can_move:
			if not current_path.is_empty():
				sprite_puf.flip_h = look_at_position.x < 0
				var target_position = tilemap.map_to_local(current_path.front())
				self.global_position = self.global_position.move_toward(target_position, move_speed)
				animation_player.play(DefinitionsHelper.ANIMATION_RUN_PUF)
				await get_tree().create_timer(wait_time_move).timeout
				if self.global_position == target_position:
					current_path.pop_front()
			else:
				is_can_move = false
				animation_player.play(DefinitionsHelper.ANIMATION_IDLE_PUF)
		else: animation_player.play(DefinitionsHelper.ANIMATION_IDLE_PUF)

func _input(event):
	if Input.is_action_just_pressed(InputsHelper.ASSEMBLE_PUF) and can_assemble:
		print("se juntan")

	if Input.is_action_pressed(InputsHelper.LEFT_CLICK):
		look_at_position = get_local_mouse_position()
		clic_position = get_global_mouse_position()
		var clic_position_localmap = tilemap.local_to_map(clic_position)
		
		if not ocuppied_cells.has(clic_position_localmap):
			next_grid_cell = clic_position_localmap
		else: next_grid_cell = Vector2i.ZERO
		
		if tilemap.is_point_walkable_map_local_position(next_grid_cell):
			current_path = tilemap.astar_grid.get_id_path(
				tilemap.local_to_map(self.global_position),
				next_grid_cell
			).slice(1)
			if !ocuppied_cells.is_empty() and !current_path.is_empty():
				if ocuppied_cells.has(current_path.back()): 
					current_path.pop_back()
			is_can_move = true
	else: 
		clic_position = Vector2i.ZERO
		next_grid_cell = Vector2i.ZERO
	
	## Sistema para que el drag and drop
	if event is InputEventMouseMotion:
		if is_myself_rich(): 
			if is_dragging and manager_puf.selected_pufs.is_empty():
				self.global_position = get_global_mouse_position()

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				mouse_button_pressed()
			else:
				mouse_button_released()
			if is_myself_rich():
				var name_signal: String = "puf_dragging" if is_dragging else "puf_undragging"
				emit_signal(name_signal, self)

func mouse_button_pressed():
	if !is_myself_rich():
		_selectAndDeselect()

	elif is_myself_rich(): 
		is_dragging = true

func mouse_button_released():
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
	selected_puf.visible = is_selected
	var name_signal: String = "puf_selected" if is_selected else "puf_deselected"
	selected_puf.play(DefinitionsHelper.ANIMATION_SELECTED_PUF) if is_selected else selected_puf.stop()
	emit_signal(name_signal, self)

''' Métodos de señales '''
func _on_ocuppied_cells(_ocuppied_cells):
	ocuppied_cells.clear()
	ocuppied_cells.append_array(_ocuppied_cells)

func _on_mouse_entered():
	if is_myself_rich():
		self.position.y += -2
		animation_player.play(DefinitionsHelper.ANIMATION_DRAG_PUF)

func _on_mouse_exited():
	if is_myself_rich():
		self.position.y += +2
		animation_player.play(DefinitionsHelper.ANIMATION_DROP_PUF)
		animation_player.queue(DefinitionsHelper.ANIMATION_IDLE_PUF)

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

