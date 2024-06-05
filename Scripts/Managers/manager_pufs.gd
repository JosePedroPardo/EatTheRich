class_name ManagerPufs
extends Node2D

signal spawn_puf

@export var limit_spawn_puf: int = RandomHelper.get_random_int_in_range(15, 20)
@export var spawn_time: int = 15
@export var area_to_spawn: int = 15 ## El área que comprobará antes de spawnear 
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
	for spawn_limit in limit_spawn_puf:
		_create_initial_pufs()
	spawn_initial_pufs.pop_front()

func _process(delta):
	if spawn_initial_pufs.size() == 0:
		timer_spawn.stop()

func _input(event):
	if event is InputEventMouseMotion:
		mouse_position = get_viewport().get_mouse_position()

func _save_puf_in_array(puf: Node2D, array: Array):
	array.push_back(puf)

func _is_in_array(puf: Node2D, array: Array) -> bool:
	return array.has(puf)

func _remove_puf_in_array(puf: Node2D, array: Array):
	array.erase(puf)

func _deselect_all():
	for selected in selected_pufs:
		_call_to_method(selected, DefinitionsHelper.METHOD_DESELECT)

func _call_to_method(selected: Node2D, method: String):
	if selected.has_method(method):
		selected.call(method)

func _clean_selecteds():
	_deselect_all()
	selected_pufs.clear()

func _on_timer_spawn_timeout():
	var puf = spawn_initial_pufs.pop_back()
	if puf != null:
		puf.connect("puf_selected", Callable(self, "_on_puf_selected"))
		puf.connect("puf_deselected", Callable(self, "_on_puf_deselected"))
		parent.add_child(puf)

func _create_initial_pufs():
	var new_puf = puf.instantiate()
	var random_position: Vector2 = Vector2.ZERO
	while true:
		random_position = _get_random_position()
		if not _is_position_occupied(random_position):
			break
	new_puf.position = random_position
	var flip: int = RandomHelper.get_random_int_in_range(0, 1)
	new_puf.get_node("SpritePuf").flip_h = flip # Cambia la dirección hacia la que mira el puf al instanciarse
	_save_puf_in_array(new_puf, spawn_initial_pufs)

func _get_random_position() -> Vector2:
	var x_spawn = randf_range(spawn_position.x - max_width / 2, spawn_position.x + max_width / 2)
	var y_spawn = randf_range(spawn_position.y - max_height / 2, spawn_position.y + max_height / 2)
	return Vector2(x_spawn, y_spawn)

func _is_position_occupied(random_position: Vector2) -> bool:
	for puf in spawn_initial_pufs:
		if puf != null:
			for i in range(-area_to_spawn, area_to_spawn + 1):
				for j in range(-area_to_spawn, area_to_spawn + 1):
					if puf.position == Vector2(random_position.x + i, random_position.y + j):
						return true
	return false

func _on_puf_selected(selected_puf):
	_save_puf_in_array(selected_puf, selected_pufs)

func _on_puf_deselected(selected_puf):
	_remove_puf_in_array(selected_puf, selected_pufs)
