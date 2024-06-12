class_name MouseManager
extends Node2D

signal change_selected_pufs(pufs: Node2D)

@export var wait_time_clean_cursor: float = 2 ## Tiempo hasta limpiar la sangre de forma automática
@export var min_area_selection_size: Vector2 = Vector2(16, 16) ## Tamaño de área mínima para la selección de los puf
@export var max_area_selection_size: Vector2 = Vector2(128, 128) ## Tamaño de área máxima para la selección de los puf
@export var increment_decrement_area: Vector2 = Vector2(8, 8) ## Incremento en el eje x e y del area de selección de Pufs
@export var max_area_sprite: Vector2 = Vector2(max_area_selection_size.x / min_area_selection_size.x, max_area_selection_size.x / min_area_selection_size.x) ## Tamaño de área máxima mostrada para la selección de los puf
@export var min_area_sprite: Vector2 = Vector2(1, 1) ## Tamaño de área mínima mostrada para la selección de los puf 
@export var increment_decrement_area_sprite: Vector2 = Vector2(increment_decrement_area.x / min_area_selection_size.x, increment_decrement_area.x / min_area_selection_size.x)  ## Incremento en el eje x e y del area de selección de Pufs
@export var shake_duration: float = 1 ## Cantidad de veces que vibra el mouse
@export var shake_intensity: float = 5.0 ## La intensidad de vibración
@export var min_size_sprite_relative_to_camera: float = 1 ## Tamaño mínimo de los sprites en relación al zoom de la cámara
@export var max_size_sprite_relative_to_camera: float = 2 ## Tamaño máximo de los sprites en relación al zoom de la cámara
@export var ratio_camera: float = 0.5 ## El incremento gradual
@export var x_axis_offset: float = 4 ## Desfase en el eje x con respecto al puntero original
@export var y_axis_offset: float = 13 ## Desfase en el eje y con respecto al puntero original
@export var time_tomatic_cleaning: float = 30 ## Tiempo hasta la limpieza automática del cursor

var cursor_map_position_relative_global_tilemap: Vector2i
var cursor_map_position_relative_local_tilemap: Vector2i
var actual_cursor_sprite: String = "default"
var suffix_blood: String = "_blood"
var is_cursor_blood: bool = false
var is_time_to_clean: bool = false
var selected_pufs: Array[Node2D]
var pufs

@onready var area_selection: Area2D = $SelectionArea
@onready var area_selection_shape: CollisionShape2D = $SelectionArea/SelectionAreaShape
@onready var area_selection_sprite: AnimatedSprite2D = $SelectionArea/SelectionAreaSprite
@onready var mouse_sprite: AnimatedSprite2D = $MouseSprite
@onready var grid_sprite: AnimatedSprite2D = $GridSprite
@onready var notice_label: Label = $MouseSprite/NoticeLabel
@onready var camera: Camera2D = get_tree().get_first_node_in_group("camera")
@onready var tilemap: TileMap = get_tree().get_first_node_in_group("tilemap")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	grid_sprite.play("default")
	grid_sprite.visible = true
	mouse_sprite.play(actual_cursor_sprite)
	area_selection_sprite.play("default")

func _process(delta: float) -> void:
	if is_cursor_blood or is_time_to_clean:
		if Input.is_action_just_pressed("clean_blood_mouse"):
			_clean_blood(delta)
			_active_notice_label("")
	
	_connect_to_signals_pufs()
	_update_travel_grid()
	_change_sprite_cursor_according_cell()
	_on_change_zoom(delta)
	_change_visibility_selection_area()

func _physics_process(delta):
	_move_cursor_sprite()
	_move_cursor_grid()
	_move_cursor_selection_area()
	_increment_or_decrement_area()

func _increment_or_decrement_area():
	if Input.is_action_just_pressed("increase_selection_area"):
		area_selection_shape.shape.size += increment_decrement_area
		area_selection_sprite.scale += increment_decrement_area_sprite
	elif Input.is_action_just_pressed("decrease_selection_area"):
		area_selection_shape.shape.size -= increment_decrement_area
		area_selection_sprite.scale -= increment_decrement_area_sprite

func _change_visibility_selection_area():
	if area_selection_shape.shape.size > min_area_selection_size:
		area_selection.visible = true
		grid_sprite.visible = false
		if area_selection_shape.shape.size >= max_area_selection_size: 
			area_selection_shape.shape.size = max_area_selection_size
			area_selection_sprite.scale = max_area_sprite
	elif area_selection_shape.shape.size <= min_area_selection_size:
		area_selection.visible = false
		grid_sprite.visible = true
		if area_selection_shape.shape.size <= min_area_selection_size: 
			area_selection_shape.shape.size = min_area_selection_size
			area_selection_sprite.scale = min_area_sprite

func _connect_to_signals_pufs():
	pufs = get_tree().get_nodes_in_group("pufs")
	for puf in pufs:
		if not puf.is_connected("puf_smashed", Callable(self, "_on_smashed_puf")):
			puf.connect("puf_smashed", Callable(self, "_on_smashed_puf"))

func _change_sprite_cursor_according_cell():
	if tilemap.is_point_death_cells(cursor_map_position_relative_local_tilemap):
		actual_cursor_sprite = "death" if not is_cursor_blood else "death_blood"
		_activate_or_deactivate_grid_sprite(false) 
	elif tilemap.is_point_wall_cells(cursor_map_position_relative_local_tilemap):
		actual_cursor_sprite = "warning" if not is_cursor_blood else "warning_blood"
		_activate_or_deactivate_grid_sprite(false) 
	elif not tilemap.is_point_wall_cells(cursor_map_position_relative_local_tilemap) and not tilemap.is_point_death_cells(cursor_map_position_relative_local_tilemap):
		_activate_or_deactivate_grid_sprite(true) 
		if Input.is_action_just_pressed(InputsHelper.LEFT_CLICK):
			actual_cursor_sprite = "clic" if not is_cursor_blood else "clic_blood"
		elif Input.is_action_pressed(InputsHelper.LEFT_CLICK):
			actual_cursor_sprite = "grab_only" if not is_cursor_blood else "grab_only_blood"
		else: actual_cursor_sprite = "default" if not is_cursor_blood else "default_blood"
	mouse_sprite.play(actual_cursor_sprite)

func _update_travel_grid():
	cursor_map_position_relative_local_tilemap = tilemap.local_to_map(get_local_mouse_position())
	cursor_map_position_relative_global_tilemap = tilemap.map_to_local(cursor_map_position_relative_local_tilemap)

func _move_cursor_grid():
	grid_sprite.global_position = cursor_map_position_relative_global_tilemap

func _move_cursor_sprite():
	mouse_sprite.global_position = Vector2i(get_global_mouse_position().x + x_axis_offset, 
	get_global_mouse_position().y + y_axis_offset)

func _move_cursor_selection_area():
	area_selection.global_position = cursor_map_position_relative_global_tilemap

func _activate_or_deactivate_grid_sprite(activate_or_not: bool):
	if not activate_or_not: grid_sprite.stop() 
	else: grid_sprite.play("default")
	grid_sprite.visible = activate_or_not

func _clean_blood(delta):
	_shake_node(mouse_sprite, delta)
	is_cursor_blood = false

func _active_notice_label(text: String):
	print(text)
	notice_label.visible = true if (text.length() > 0 and not text.is_empty()) else false
	notice_label.text = text

func _shake_node(node: Node2D, delta: float):
	var shake_timer = shake_duration
	while shake_timer > 0:
		var shake_offset: float = randf_range(-shake_intensity, shake_intensity)
		node.position.x += shake_offset
		shake_timer -= delta
		await get_tree().create_timer(delta).timeout
	node.position.x = 0

func _is_time_to_clean():
	await get_tree().create_timer(time_tomatic_cleaning).timeout
	is_time_to_clean = true

func _on_smashed_puf(puf):
	await get_tree().create_timer(2).timeout
	is_cursor_blood = true
	_active_notice_label("[C] to clean cursor")
	await get_tree().create_timer(5).timeout
	_active_notice_label("")

func _on_change_zoom(delta: float):
	var initial_scale: Vector2 = mouse_sprite.scale
	var target_scale: Vector2 = initial_scale
	var _ratio_camera = camera.zoom * ratio_camera
	if Input.is_action_pressed("camera_zoom_in"):
		target_scale /= _ratio_camera
	elif Input.is_action_pressed("camera_zoom_out"):
		target_scale *= _ratio_camera
	target_scale.x = clamp(target_scale.x, min_size_sprite_relative_to_camera, max_size_sprite_relative_to_camera)
	target_scale.y = clamp(target_scale.y, min_size_sprite_relative_to_camera, max_size_sprite_relative_to_camera)

func _on_selection_area_body_entered(body):
	if selected_pufs.is_empty() or not selected_pufs.has(body):
		selected_pufs.append(body)
		emit_signal("change_selected_pufs", selected_pufs)
		if selected_pufs.size() > 2:
			_active_notice_label("[Pufs] " + str(selected_pufs.size()))
		else: _active_notice_label("")
	print_debug("[Pufs] " + str(selected_pufs.size()))

func _on_selection_area_body_exited(body):
	if not selected_pufs.is_empty() and selected_pufs.has(body):
		selected_pufs.erase(body)
		emit_signal("change_selected_pufs", selected_pufs)
		if selected_pufs.size() > 2:
			_active_notice_label("[Pufs] " + str(selected_pufs.size()))
		else: _active_notice_label("")
	print_debug("[Pufs] " + str(selected_pufs.size()))
