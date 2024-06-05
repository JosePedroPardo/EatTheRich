class_name BehaviourPuf
extends CharacterBody2D

signal puf_selected
signal puf_deselected

@export var wait_time: int = 15
@export var can_assemble: bool = false
@export var selected: bool = false

var myself: Puf: 
	get: return myself
	set(_myself):
		myself = _myself
var is_baby: bool = false:
	get: return is_baby
	set(_is_baby):
		is_baby = _is_baby
var social_class: int = DefinitionsHelper.RANDOM_SOCIAL_CLASS
var folow_cursor: bool = false
var speed = 50

@onready var sprite_puf: Sprite2D = $SpritePuf
@onready var selected_circle: Sprite2D = $SelectedCircle
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var wait_timer: Timer = $WaitTime
@onready var target = self.position

func _ready():
	myself = Puf.new(social_class, is_baby)
	social_class = myself.social_class
	wait_timer.wait_time = wait_time
	set_selected(selected)
	add_to_group("pufs", true)
	_change_sprite_according_social_class()

func _change_sprite_according_social_class():
	var path_texture: String
	if social_class == DefinitionsHelper.RICH_SOCIAL_CLASS:
		path_texture = RandomHelper.get_random_string_in_array(DefinitionsHelper.texture_rich_pufs)
	elif social_class == DefinitionsHelper.POOR_SOCIAL_CLASS:
		path_texture = RandomHelper.get_random_string_in_array(DefinitionsHelper.texture_poor_pufs)
	sprite_puf.texture = load(path_texture)

func _physics_process(_delta):
	if folow_cursor:
		if selected:
			target = get_global_mouse_position()
			animation_player.play("walk")
		self.velocity = position.direction_to(target) * speed
	if position.distance_to(target) > 10:
		self.move_and_slide()
	else:
		animation_player.stop()

func _input(event):
	if event.is_action_pressed("assemble") and can_assemble:
		print("se juntan")
	if event.is_action_pressed("right_click"):
		folow_cursor = true
	if event.is_action_released("right_click"):
		folow_cursor = false

func set_selected(_selected: bool):
	selected = _selected
	selected_circle.visible = _selected

func get_social_class():
	match(myself.social_class):	
		0: return DefinitionsHelper.POOR
		1: return DefinitionsHelper.RICH
		_: return "null"

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if social_class == DefinitionsHelper.POOR_SOCIAL_CLASS:
				var sig: String = ""
				if selected_circle.visible == false: 
					sig = "puf_selected"
				else: 
					sig = "puf_deselected"
				emit_signal(sig, self)
				selected_circle.visible = !selected_circle.visible

''' Getters del Puf asociado a este CharacterBody2D '''
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
