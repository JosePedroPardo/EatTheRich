class_name MouseManager
extends Node2D

var cursor_map_position_relative_global_tilemap: Vector2i
var cursor_map_position_relative_local_tilemap: Vector2i
@export var size_vector_cursor: Vector2 = Vector2(8,8)

@onready var grid_sprite: AnimatedSprite2D = $GridSprite
@onready var tilemap: TileMap = get_tree().get_first_node_in_group("tilemap")
@onready var point_out: Resource = preload(PathsHelper.CURSOR_POINT_OUT)
@onready var grab: Resource = preload(PathsHelper.CURSOR_GRAB)
@onready var click: Resource = preload(PathsHelper.CURSOR_CLICK)
@onready var smash: Resource = preload(PathsHelper.CURSOR_SMASH)
@onready var death: Resource = preload(PathsHelper.CURSOR_DEATH)
@onready var stop: Resource = preload(PathsHelper.CURSOR_STOP)

func _ready():
	Input.set_custom_mouse_cursor(point_out)
	grid_sprite.play("default")
	grid_sprite.visible = true

func _process(delta: float) -> void:
	_update_travel_grid()
	_move_cursor_grid()
	_change_sprite_according_cell()

func _change_sprite_according_cell():
	if tilemap.is_point_death_cells(cursor_map_position_relative_local_tilemap):
		Input.set_custom_mouse_cursor(death,Input.CURSOR_CROSS,)
		_activate_or_deactivate_grid_sprite(false) 
	elif tilemap.is_point_wall_cells(cursor_map_position_relative_local_tilemap):
		Input.set_custom_mouse_cursor(stop, Input.CURSOR_MOVE, size_vector_cursor)
		_activate_or_deactivate_grid_sprite(false) 
	elif not tilemap.is_point_wall_cells(cursor_map_position_relative_local_tilemap) and not tilemap.is_point_death_cells(cursor_map_position_relative_local_tilemap):
		_activate_or_deactivate_grid_sprite(true) 
		if Input.is_action_just_pressed(InputsHelper.LEFT_CLICK):
			Input.set_custom_mouse_cursor(click, Input.CURSOR_IBEAM, size_vector_cursor)
		elif Input.is_action_pressed(InputsHelper.LEFT_CLICK):
			Input.set_custom_mouse_cursor(grab, Input.CURSOR_DRAG, size_vector_cursor)
		else: Input.set_custom_mouse_cursor(point_out,Input.CURSOR_ARROW, size_vector_cursor)
	

func _update_travel_grid():
	cursor_map_position_relative_local_tilemap = tilemap.local_to_map(get_local_mouse_position())
	cursor_map_position_relative_global_tilemap = tilemap.map_to_local(cursor_map_position_relative_local_tilemap)

func _move_cursor_grid():
	grid_sprite.global_position = cursor_map_position_relative_global_tilemap
	
## Muestra el grid en la posición del ratón, relativa al tilemap
func _activate_or_deactivate_grid_sprite(activate_or_not: bool):
	if not activate_or_not: grid_sprite.stop() 
	else: grid_sprite.play("default")
	grid_sprite.visible = activate_or_not
