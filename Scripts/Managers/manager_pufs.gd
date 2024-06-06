class_name ManagerPufs
extends Node2D

signal spawn_puf

@export_range(0, 100) var limit_spawn_puf: int = RandomHelper.get_random_int_in_range(15, 20) ## 0 es equivalente a un número aleatorio entre 15 y 20
@export var spawn_time: float = 15

var spawn_initial_pufs: Array = []
var spawn_cood: Array[Vector2i] = []

# Variables para el sistema de selección de pufs
@onready var parent: Node2D = get_node("../")
@onready var selected_pufs: Array = []
@onready var puf: PackedScene = preload("res://Scenes/puf.tscn")
@onready var timer_spawn: Timer = $Timer_spawn
@onready var tilemap: TileMap = get_node(PathsHelper.TILEMAP_PATH)

func _ready():
	timer_spawn.wait_time = spawn_time

func _process(delta):
	if spawn_initial_pufs.size() == 0:
		timer_spawn.stop()

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
	var random_position = spawn_cood[RandomHelper.get_random_int_in_range(0, spawn_cood.size() - 1)]
	var random_global_position = tilemap.astar_grid.get_point_position(Vector2(random_position.x, random_position.y)) # Transforma las coordenadas locales del grid en globales
	new_puf.position = random_global_position
	spawn_cood.erase(random_position)
	var flip: int = RandomHelper.get_random_int_in_range(0, 1)
	new_puf.get_node("SpritePuf").flip_h = flip # Cambia la dirección hacia la que mira el puf al instanciarse
	_save_puf_in_array(new_puf, spawn_initial_pufs)

func _on_puf_selected(selected_puf):
	_save_puf_in_array(selected_puf, selected_pufs)

func _on_puf_deselected(selected_puf):
	_remove_puf_in_array(selected_puf, selected_pufs)

func _on_tile_map_coordinates_spawn(coordinates_spawn):
	spawn_cood.append_array(coordinates_spawn)
	timer_spawn.start()
	for spawn_limit in limit_spawn_puf:
		_create_initial_pufs()
