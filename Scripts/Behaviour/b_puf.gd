class_name BehaviourPuf
extends CharacterBody2D

signal puf_selected
signal puf_deselected

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
var social_class: int = DefinitionsHelper.RANDOM_SOCIAL_CLASS
var is_selected: bool = false
var current_path: Array[Vector2i]
var look_at_position: Vector2i

@onready var sprite_puf: Sprite2D = $SpritePuf
@onready var selected_puf: AnimatedSprite2D = $SelectedPuf
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var wait_timer: Timer = $WaitTime
@onready var assemble_area: CollisionShape2D = $InteractionComponents/InteractArea/AssembleArea
@onready var repulsion_area: CollisionShape2D = $InteractionComponents/InteractArea/RepulsionArea
@onready var shape_puf: CollisionShape2D = $ShapePuf
@onready var tilemap: TileMap = get_node(PathsHelper.SCENARIO_TILEMAP_PATH)
@onready var clic_position: Vector2 = self.position

func _ready():
	myself = Puf.new(social_class, is_baby)
	social_class = myself.social_class
	_change_sprite_according_social_class()
	animation_player.play(DefinitionsHelper.ANIMATION_IDLE_PUF)

func _process(delta):
	if is_selected:
		if !current_path.is_empty():
			sprite_puf.flip_h = look_at_position.x < 0
			var target_position = tilemap.map_to_local(current_path.front())
			self.global_position = self.global_position.move_toward(target_position, move_speed)
			animation_player.play(DefinitionsHelper.ANIMATION_RUN_PUF)
			await get_tree().create_timer(wait_time_move).timeout
			if self.global_position == target_position:
				current_path.pop_front()
		else:  animation_player.play(DefinitionsHelper.ANIMATION_IDLE_PUF)

func _input(event):
	if Input.is_action_just_pressed(InputsHelper.ASSEMBLE_PUF) and can_assemble:
		print("se juntan")

	if Input.is_action_just_pressed(InputsHelper.LEFT_CLICK):
		look_at_position = get_local_mouse_position()
		clic_position = get_global_mouse_position()
		if tilemap.is_point_walkable(clic_position):
			current_path = tilemap.astar_grid.get_id_path(
				tilemap.local_to_map(self.global_position),
				tilemap.local_to_map(clic_position)
			).slice(1)

func _look_at_sprite_to_target(_sprite: Sprite2D, _target: Vector2, block_cood_xy: Array[bool]):
	if !block_cood_xy.is_empty():
		if block_cood_xy[0]:
			_sprite.flip_h = _target.x < 0
		if block_cood_xy[1]: 
			_sprite.flip_v = _target.y < 0
	else:
		_sprite.look_at(_target)

func _change_sprite_according_social_class():
	var path_texture: String
	if social_class == DefinitionsHelper.RICH_SOCIAL_CLASS:
		path_texture = RandomHelper.get_random_string_in_array(DefinitionsHelper.texture_rich_pufs)
	elif social_class == DefinitionsHelper.POOR_SOCIAL_CLASS:
		path_texture = RandomHelper.get_random_string_in_array(DefinitionsHelper.texture_poor_pufs)
	sprite_puf.texture = load(path_texture)

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if social_class == DefinitionsHelper.POOR_SOCIAL_CLASS:
				var signal_selected: String = ""
				if selected_puf.visible == false: 
					signal_selected = "puf_selected"
					selected_puf.play(DefinitionsHelper.ANIMATION_SELECTED_PUF)
				else: 
					signal_selected = "puf_deselected"
					selected_puf.stop()
				is_selected = !is_selected
				selected_puf.visible = !selected_puf.visible
				emit_signal(signal_selected, self)

''' Getters del Puf asociado a este CharacterBody2D '''
func get_social_class():
	match(myself.social_class):	
		0: return DefinitionsHelper.POOR
		1: return DefinitionsHelper.RICH
		_: return "null"

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
