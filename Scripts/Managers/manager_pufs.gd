class_name ManagerPufs
extends Node2D

signal spawn_puf

@export var limit_spwan_puf: int = 15
@export var spawn_time: int = 15
@export var spawn_initial_pufs: Array = []

# Variables para el spawn
@export var spawn_position: Vector2 = Vector2.ZERO
@export var min_width: float = 100.0
@export var max_width: float = 200.0
@export var min_height: float = 100.0 
@export var max_height: float = 200.0

# Variables para el sistema de selección de pufs
@onready var parent: Node2D = get_node("../")
@onready var selected_pufs: Array = []
@onready var puf: PackedScene = preload("res://Scenes/puf.tscn")
@onready var timer_spawn: Timer = $Timer_spawn
@onready var mouse_position

func _ready():
	timer_spawn.wait_time = spawn_time
	timer_spawn.start()

func _process(delta):
	if spawn_initial_pufs.size() == limit_spwan_puf:
		timer_spawn.stop()

func _input(event):
	if event is InputEventMouseMotion:
		mouse_position = get_viewport().get_mouse_position()
	if event.is_action_pressed("left_click"):
		print(mouse_position)

func _save_selected(selected: Node2D, array: Array):
	array.push_front(selected)

func _is_in_array_selected(selected: Node2D, array: Array) -> bool:
	return array.has(selected)

func _remove_selected(selected: Node2D, array: Array):
	array.erase(selected)

func _deselect_all():
	for selected in selected_pufs:
		_call_to_method(selected, DefinitionsHelper.DESELECT)

func _call_to_method(selected: Node3D, method: String):
	if selected.has_method(method):
		selected.call(method)

func _clean_selecteds():
	_deselect_all()
	selected_pufs.clear()

func _on_timer_spawn_timeout():
	var new_puf = puf.instantiate()
	new_puf.position = get_random_position()
	parent.add_child(new_puf)
	_save_selected(new_puf, spawn_initial_pufs)
	emit_signal("spawn_puf", puf)

func get_random_position():
	var vpr_width = randf_range(min_width, max_width)
	var vpr_height = randf_range(min_height, max_height)
	var top_left = Vector2(spawn_position.x - vpr_width/2, spawn_position.y - vpr_height/2)
	var top_right = Vector2(spawn_position.x + vpr_width/2, spawn_position.y - vpr_height/2)
	var bottom_left = Vector2(spawn_position.x - vpr_width/2, spawn_position.y + vpr_height/2)
	var bottom_right = Vector2(spawn_position.x + vpr_width/2, spawn_position.y + vpr_height/2)
	var pos_side = ["up", "down", "right", "left"].pick_random()
	var spawn_pos1 = Vector2.ZERO
	var spawn_pos2 = Vector2.ZERO
	
	match pos_side:
		"up":
			spawn_pos1 = top_left
			spawn_pos2 = top_right
		"down":
			spawn_pos1 = bottom_left
			spawn_pos2 = bottom_right
		"right":
			spawn_pos1 = top_right
			spawn_pos2 = bottom_right
		"left":
			spawn_pos1 = top_left
			spawn_pos2 = bottom_left
	
	var x_spawn = randf_range(spawn_pos1.x, spawn_pos2.x)
	var y_spawn = randf_range(spawn_pos1.y, spawn_pos2.y)
	return Vector2(x_spawn, y_spawn)

