class_name BehaviourPuf
extends Node2D

@export var wait_time: int = 15
@export var can_assemble: bool = false

var myself: Puf: 
	get: return myself
	set(_myself):
		myself = _myself
var is_baby: bool = false:
	get: return is_baby
	set(_is_baby):
		is_baby = _is_baby
var social_class: int = DefinitionsHelper.RANDOM_SOCIAL_CLASS

@onready var sprite_puf: Sprite2D = $SpritePuf
@onready var selected_circle: Sprite2D = $SelectedCircle
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var wait_timer: Timer = $WaitTime

# Variables para el sistema de interaccion entre pufs
@onready var interaction_area: Area2D = $InteractionArea2d
@onready var all_pufs: Array = []
@onready var interact_label: Label = $InteractionComponents/InteractLabel

func _ready():
	myself = Puf.new(social_class, is_baby)
	wait_timer.wait_time = wait_time

func _process(delta):
	can_assemble = true if all_pufs.size() >= 3 else false
	_update_animation_parameters()

func _input(event):
	if event.is_action_pressed("assemble") and can_assemble:
		print("se juntan")

func get_social_class():
	match(myself.social_class):
		0: return DefinitionsHelper.POOR
		1: return DefinitionsHelper.RICH
		_: return "null"

func _update_animation_parameters():
	pass # TODO: Hacer el cambio de animación cuando esté el sistema de movimiento

# Métodos de interacción
func _on_interact_area_area_shape_entered(area):
	print(area)
	print(all_pufs)
	all_pufs.push_front(area)
	update_interactions()

func _on_interact_area_area_shape_exited(area):
	print(area)
	all_pufs.erase(area)
	update_interactions()

func update_interactions():
	if all_pufs:
		interact_label.text = all_pufs[0].interact_label
	else: interact_label.text = ""

func execute_interactions():
	if all_pufs:
		var cur_interaction = all_pufs[0]
		match cur_interaction.interact_type:
			InteractHelper.INTERACTION_PRINT_TEXT: print(cur_interaction)

func _on_rigid_body_2d_body_entered(body):
	print(body)
	all_pufs.push_front(body)
	update_interactions()

func _on_rigid_body_2d_body_exited(body):
	print(body)
	all_pufs.erase(body)
	update_interactions()

func _on_character_body_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			selected_circle.visible = true

