class_name BehaviourPuf
extends CharacterBody2D

signal puf_selected

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
	animation_player.play("idle")

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
			animation_player.play("Walk")
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
				selected_circle.visible = !selected_circle.visible
				emit_signal("puf_selected", self)

func get_json_serialize():
	return myself.jsonSerialize()

