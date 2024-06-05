class_name ManagerPufs
extends Node2D

signal spawn_puf

@export var limit_spawn_puf: int = 15
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
@onready var mouse_position: Vector2

func _ready():
	timer_spawn.wait_time = spawn_time
	timer_spawn.start()

func _process(delta):
	if spawn_initial_pufs.size() == limit_spawn_puf:
		timer_spawn.stop()

func _input(event):
	if event is InputEventMouseMotion:
		mouse_position = get_viewport().get_mouse_position()

func _save_selected(selected: Node2D, array: Array):
	array.push_front(selected)

func _is_in_array_selected(selected: Node2D, array: Array) -> bool:
	return array.has(selected)

func _remove_selected(selected: Node2D, array: Array):
	array.erase(selected)

func _deselect_all():
	for selected in selected_pufs:
		_call_to_method(selected, DefinitionsHelper.DESELECT)

func _call_to_method(selected: Node2D, method: String):
	if selected.has_method(method):
		selected.call(method)

func _clean_selecteds():
	_deselect_all()
	selected_pufs.clear()

func _on_timer_spawn_timeout():
	var new_puf = puf.instantiate()
	var random_position: Vector2
	while true:
		random_position = get_random_position()
		if not _is_position_occupied(random_position):
			break
	new_puf.position = random_position
	parent.add_child(new_puf)
	_save_selected(new_puf, spawn_initial_pufs)
	emit_signal("spawn_puf", new_puf)

func get_random_position() -> Vector2:
	var x_spawn = randf_range(spawn_position.x - max_width / 2, spawn_position.x + max_width / 2)
	var y_spawn = randf_range(spawn_position.y - max_height / 2, spawn_position.y + max_height / 2)
	return Vector2(x_spawn, y_spawn)

func _is_position_occupied(random_position: Vector2) -> bool:
	for puf in spawn_initial_pufs:
		if puf != null and puf.position == random_position:
			return true
	return false
