class_name ManagerPufs
extends Node2D

signal spawn_puf
signal mouse_released
signal ocuppied_cells_array(ocuppied_cells)

@export_range(0, 100) var limit_spawn_puf: int = RandomHelper.get_random_int_in_range(15, 20) ## 0 es equivalente a un número aleatorio entre 15 y 20
@export var spawn_time: float = 15

var spawn_initial_pufs: Array
var spawn_cood: Array[Vector2i] 
var ocuppied_cells: Array[Vector2i] 

var is_picked_up: bool = false

# Variables para el sistema de selección de pufs
@onready var parent: Node2D = get_node("../")
@onready var selected_pufs: Array
@onready var rich_pufs: Array 
@onready var poor_pufs: Array 
@onready var puf: PackedScene = preload("res://Scenes/puf.tscn")
@onready var timer_spawn: Timer = $Timer_spawn
@onready var tilemap: TileMap = get_node(PathsHelper.TILEMAP_PATH)

func _ready():
	timer_spawn.wait_time = spawn_time

func _process(delta):
	if Input.is_action_just_pressed("left_click"):
		emit_signal("mouse_released")
	
	if spawn_initial_pufs.is_empty(): timer_spawn.stop()
	is_picked_up = true if selected_pufs.is_empty() else false 

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var mouse_position = event.position
			var space_state = get_world_2d().direct_space_state
			var query = PhysicsPointQueryParameters2D.new()
			query.position = mouse_position
			var result = space_state.intersect_point(query)
			print(result)
			if result.size() > 0:
				for res in result:
					var collider = res.collider
					if collider.has_meta("is_pickeable") and collider.get_meta("is_pickeable"):
						print("Colisionó con (intersect_point):", collider.name)
						# Realizar la acción deseada

			if result.size() > 0:
				var collider = result[0].collider
				if collider.has_meta("is_pickeable") and collider.get_meta("is_pickeable"):
					# El collider tiene la propiedad is_pickeable
					print("Colisionó con:", collider.name)
					# Aquí puedes emitir una señal, llamar a un método, o realizar alguna acción con el collider

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
		puf.connect("cell_ocuppied", Callable(self, "_on_ocupied_cell"))
		puf.connect("cell_unocuppied", Callable(self, "_on_unocupied_cell"))
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
	if new_puf.get_social_class() == DefinitionsHelper.RICH_SOCIAL_CLASS: _save_puf_in_array(new_puf, rich_pufs)
	else: _save_puf_in_array(new_puf, poor_pufs)

func _on_puf_selected(selected_puf):
	_save_puf_in_array(selected_puf, selected_pufs)

func _on_puf_deselected(selected_puf):
	_remove_puf_in_array(selected_puf, selected_pufs)

func _on_tile_map_coordinates_spawn(coordinates_spawn):
	spawn_cood.append_array(coordinates_spawn)
	timer_spawn.start()
	for spawn_limit in limit_spawn_puf:
		_create_initial_pufs()

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
