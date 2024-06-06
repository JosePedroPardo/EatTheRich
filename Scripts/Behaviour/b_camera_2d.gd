extends Camera2D

signal area_selected
signal selected_pufs(selected_pufs_array)

@export var multiplier_speed: float = 4
@export var zoom_speed: float = 10.0
@export var zoom_margin: float = 0.1
@export var zoom_min: float = 1.0
@export var zoom_max: float = 3.0

@export var cood_limit_top: int = 282
@export var cood_limit_bottom: int = 282
@export var cood_limit_left: int = 114
@export var cood_limit_right: int = 425
@export var edge_margin: int = 100  ## Distancia desde los bordes para empezar a mover la cámara

var speed: float = 50.0
var zoom_factor: float = 1.0
var zoom_pos: Vector2 = Vector2()
var zooming: bool = false

var mouse_pos: Vector2 = Vector2()
var mouse_pos_global: Vector2 = Vector2()
var start: Vector2 = Vector2()
var start_v: Vector2 = Vector2()
var end: Vector2 = Vector2()
var end_v: Vector2 = Vector2()
var is_dragging: bool = false
var is_mouse_move: bool = false

@onready var box: Panel = get_node(PathsHelper.UI_PANEL_TO_SELECTED_AREA)
@onready var checkButton: CheckButton = get_node(PathsHelper.UI_TOOGLE_BUTTON_MOUSE_CAMERA)

func _ready():
	checkButton.connect("pressed", Callable(self, "_on_toogle_button_changes_mouse_move"))
	connect("area_selected", Callable(get_parent(), "_on_area_selected"))

func _process(delta):
	zoom_camera(delta)
	move_camera(delta)
	#process_select_area()

func _on_toogle_button_changes_mouse_move():
	is_mouse_move = !is_mouse_move

func _mouse_move(direction: Vector2) -> Vector2:
	if is_mouse_move:
		if mouse_pos.x < edge_margin:
			direction.x = -1
		elif mouse_pos.x > get_viewport_rect().size.x - edge_margin:
			direction.x = 1

		if mouse_pos.y < edge_margin:
			direction.y = -1
		elif mouse_pos.y > get_viewport_rect().size.y - edge_margin:
			direction.y = 1
	
	return direction

func _awsd_move(direction: Vector2) -> Vector2:
	var inputX: int = get_input_x()
	var inputY: int = get_input_y()

	direction.x += inputX
	direction.y += inputY
	
	return direction

func _input(event: InputEvent) -> void:
	input_for_zoom(event)

	if event is InputEventMouse:
		mouse_pos = event.position
		mouse_pos_global = get_global_mouse_position()
		print(mouse_pos)

func _zoom_out():
	zoom_factor -= 0.01 * zoom_speed
	zoom_pos = get_global_mouse_position()

func _zoom_in():
	zoom_factor += 0.01 * zoom_speed
	zoom_pos = get_global_mouse_position()

func get_input_x() -> int:
	return int(Input.is_action_pressed("camera_right")) - int(Input.is_action_pressed("camera_left"))

func get_input_y() -> int:
	return int(Input.is_action_pressed("camera_backward")) - int(Input.is_action_pressed("camera_forward"))

func process_select_area() -> void:
	if Input.is_action_just_pressed("left_click"):
		start = mouse_pos_global
		start_v = mouse_pos
		is_dragging = true
	
	if is_dragging:
		end = mouse_pos_global
		end_v = mouse_pos
		draw_area()
	
	if Input.is_action_just_released("left_click"):
		if start_v.distance_to(mouse_pos) > 20:
			end = mouse_pos_global
			end_v = mouse_pos
			is_dragging = false
			draw_area(false)
			
			var selected_pufs = get_objects_in_area(start, end)
			
			emit_signal("selected_pufs", selected_pufs)
		else:
			end = start
			is_dragging = false
			draw_area(false)

func zoom_camera(delta: float) -> void:
	zoom.x = lerp(zoom.x, zoom.x * zoom_factor, zoom_speed * delta)
	zoom.y = lerp(zoom.y, zoom.y * zoom_factor, zoom_speed * delta)

	zoom.x = clamp(zoom.x, zoom_min, zoom_max)
	zoom.y = clamp(zoom.y, zoom_min, zoom_max)
	if not zooming:
		zoom_factor = 1.0

func move_camera(delta: float) -> void:
	var direction = Vector2()

	# Movimiento por bordes de pantalla
	direction = _mouse_move(direction)
	
	# Movimiento por teclas
	direction = _awsd_move(direction)

	if direction != Vector2():
		position += direction.normalized() * (speed * multiplier_speed) * delta

func input_for_zoom(event: InputEvent) -> void:
	if abs(zoom_pos.x - get_global_mouse_position().x) > zoom_margin:
		zoom_factor = 1.0
	if abs(zoom_pos.y - get_global_mouse_position().y) > zoom_margin:
		zoom_factor = 1.0
	if event.is_pressed():
		zooming = true
		if event.is_action("camera_zoom_out") or event.is_action_pressed("camera_zoom_out"):
			_zoom_out()
		if event.is_action("camera_zoom_in") or event.is_action_pressed("camera_zoom_in"):
			_zoom_in()
	else:
		zooming = true

func draw_area(s: bool = true) -> void:
	box.size = Vector2(abs(start_v.x - end_v.x), abs(start_v.y - end_v.y))
	var pos = Vector2()
	pos.x = min(start_v.x, end_v.x)
	pos.y = min(start_v.y, end_v.y)
	box.position = pos
	box.size *= int(s)

func get_objects_in_area(start: Vector2, end: Vector2) -> Array:
	var area_rect = Rect2(start, end - start)
	var selected_objects = []
	
	for object in get_tree().get_nodes_in_group("selectable"):
		if area_rect.has_point(object.global_position):
			selected_objects.append(object)
	
	return selected_objects
