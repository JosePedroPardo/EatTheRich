extends Camera2D

signal area_selected
signal atart_move_selection

@export var SPEED: float = 20.0
@export var ZOOM_SPEED: float = 20.0
@export var ZOOM_MARGIN: float = 0.1
@export var ZOOM_MIN: float = 0.5
@export var ZOOM_MAX: float = 3.0

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

@onready var box: Panel = get_node("../UI/Panel")


func _ready():
	connect("area_selected", Callable(get_parent(), "_on_area_selected"))


func _process(delta):
	zoom_camera(delta)
	move_camera(delta)
	process_select_area()

func zoom_camera(delta: float) -> void:
	zoom.x = lerp(zoom.x, zoom.x * zoom_factor, ZOOM_SPEED * delta)
	zoom.y = lerp(zoom.y, zoom.y * zoom_factor, ZOOM_SPEED * delta)
	
	zoom.x = clamp(zoom.x, ZOOM_MIN, ZOOM_MAX)
	zoom.y = clamp(zoom.y, ZOOM_MIN, ZOOM_MAX)
	if not zooming:
		zoom_factor = 1.0

func move_camera(delta: float) -> void:
	var inputX: int = get_input_x()
	var inputY: int = get_input_y()
	
	position.x = lerp(position.x, position.x + inputX * SPEED * zoom.x, SPEED * delta)
	position.y = lerp(position.y, position.y + inputY * SPEED * zoom.y, SPEED * delta)

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
			emit_signal("area_selected", self)
		else:
			end = start
			is_dragging = false
			draw_area(false)
	

func _input(event: InputEvent) -> void:
	input_for_zoom(event)
	
	if event is InputEventMouse:
		mouse_pos = event.position
		mouse_pos_global = get_global_mouse_position()


func input_for_zoom(event: InputEvent) -> void:
	if abs(zoom_pos.x - get_global_mouse_position().x) > ZOOM_MARGIN:
		zoom_factor = 1.0
	if abs(zoom_pos.y - get_global_mouse_position().y) > ZOOM_MARGIN:
		zoom_factor = 1.0
		
	if event is InputEventMouseButton:
		if event.is_pressed():
			zooming = true
			if event.is_action("camera_zoom_out"):
				zoom_factor -= 0.01 * ZOOM_SPEED
				zoom_pos = get_global_mouse_position()
			if event.is_action("camera_zoom_out"):
				zoom_factor += 0.01 * ZOOM_SPEED
				zoom_pos = get_global_mouse_position()
		else:
			zooming = true


func draw_area(s: bool = true) -> void:
	box.size = Vector2(abs(start_v.x - end_v.x), abs(start_v.y - end_v.y))
	var pos = Vector2()
	pos.x = min(start_v.x, end_v.x)
	pos.y = min(start_v.y, end_v.y)
	box.position = pos
	box.size *= int(s)
