class_name ManagerPufs
extends Node2D

signal mouse_released
signal ocuppied_cells_array(ocuppied_cells)
signal born_puf(puf)
signal born_a_rich(puf)
signal born_a_poor(puf)

@export_range(0, 100) var limit_initial_spawn_puf: int = RandomHelper.get_random_int_in_range(15, 20) ## 0 es equivalente a un número aleatorio entre 15 y 20
@export var spawn_time: float = 5
@export var spawn_time_to_rich: float = 30

var spawn_cells: Array[Vector2i] 
var ocuppied_cells: Array[Vector2i] 
var selected_pufs: Array:
	get: 
		return selected_pufs
var rich_pufs: Array 
var poor_pufs: Array 
var all_pufs: Array

var is_picked_up: bool = false
var spawn_initial_pufs: bool = true # Cuando se pone a false, comienzan a spawnear únicamente ricos
var first_puf: bool = true

# Variables para el sistema de selección de pufs
@onready var parent: Node2D = get_node("../")
@onready var dragging_puf: Node2D
@onready var puf: PackedScene = preload("res://Scenes/puf.tscn")
@onready var timer_spawn: Timer = $TimerSpawn
@onready var tilemap: TileMap = get_node(PathsHelper.TILEMAP_PATH)

func _ready():
	timer_spawn.wait_time = spawn_time
	timer_spawn.start()

func _process(delta):
	if Input.is_action_just_pressed("left_click"):
		emit_signal("mouse_released")
	is_picked_up = true if selected_pufs.is_empty() else false
	if spawn_initial_pufs:
		if all_pufs.size() == limit_initial_spawn_puf:
			timer_spawn.stop() 

func _born_a_puf():
	var new_puf: Node2D
	var random_position = spawn_cells[RandomHelper.get_random_int_in_range(0, spawn_cells.size()-1)]
	var flip: int = RandomHelper.get_random_int_in_range(0, 1)
	print("Posición random:" + str(random_position))
	var random_global_position = tilemap.astar_grid.get_point_position(Vector2(random_position.x, random_position.y)) # Transforma las coordenadas locales del grid en globales
	print("Posición random global: " + str(random_global_position))
	new_puf = puf.instantiate()
	if !spawn_initial_pufs:
		new_puf.social_class = DefinitionsHelper.RICH_SOCIAL_CLASS
	new_puf.position = random_global_position
	new_puf.get_node("SpritePuf").flip_h = flip # Cambia la dirección hacia la que mira el puf al instanciarse
	new_puf.connect("puf_selected", Callable(self, "_on_puf_selected"))
	new_puf.connect("puf_deselected", Callable(self, "_on_puf_deselected"))
	new_puf.connect("puf_dragging", Callable(self, "_on_puf_dragging"))
	new_puf.connect("puf_undragging", Callable(self, "_on_puf_undragging"))
	new_puf.connect("cell_ocuppied", Callable(self, "_on_ocupied_cell"))
	new_puf.connect("cell_unocuppied", Callable(self, "_on_unocupied_cell"))
	parent.add_child(new_puf)
	_save_puf_in_array(new_puf, all_pufs)
	_emit_signal_according_born_social_class_puf(new_puf)

func _emit_signal_according_born_social_class_puf(new_puf):
	if new_puf.get_social_class() == DefinitionsHelper.RICH_SOCIAL_CLASS: 
		emit_signal("born_a_rich", new_puf)
		_save_puf_in_array(new_puf, rich_pufs)
	else: 
		emit_signal("born_a_poor", new_puf)
		_save_puf_in_array(new_puf, poor_pufs)

func _finished_spawn_initial_pufs():
	timer_spawn.wait_time = spawn_time_to_rich
	timer_spawn.stop()
	await get_tree().create_timer(spawn_time_to_rich).timeout
	timer_spawn.start()

func _save_puf_in_array(puf: Node2D, array: Array):
	array.push_back(puf)

func _is_in_array(puf: Node2D, array: Array) -> bool:
	return array.has(puf)

func _remove_puf_in_array(puf: Node2D, array: Array):
	if not array.is_empty() and array.has(puf):
		array.erase(puf)

func _on_timer_spawn_timeout():
	_born_a_puf()

func _on_puf_selected(selected_puf):
	_save_puf_in_array(selected_puf, selected_pufs)

func _on_puf_deselected(selected_puf):
	_remove_puf_in_array(selected_puf, selected_pufs)

func _on_camera_2d_selected_pufs(selected_pufs_array):
	print(selected_pufs_array)
	for puf in selected_pufs:
		puf.is_selected = false
	selected_pufs.clear()
	selected_pufs.append_array(selected_pufs_array)
	for puf in selected_pufs:
		puf.is_selected = true

func _on_ocupied_cell(cood_cell):
	ocuppied_cells.append(cood_cell)
	emit_signal("ocuppied_cells_array", ocuppied_cells)

func _on_unocupied_cell(cood_cell):
	if not ocuppied_cells.is_empty():
		if ocuppied_cells.has(cood_cell):
			ocuppied_cells.erase(cood_cell)
			emit_signal("ocuppied_cells_array", ocuppied_cells)

func _on_puf_dragging(_puf):
	dragging_puf = _puf

func _on_puf_undragging(_puf):
	dragging_puf = _puf

func _on_tile_map_ocuppied_coordinates(ocuppied_coordinates):
	ocuppied_cells = ocuppied_coordinates

func _on_tile_map_spawn_coordinates(spawn_coordinates):
	spawn_cells = spawn_coordinates
