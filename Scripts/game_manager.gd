extends Node2D

@export var point_out: Resource = preload(PathsHelper.CURSOR_POINT_OUT)
@export var grab: Resource = preload(PathsHelper.CURSOR_GRAB)
@export var click: Resource = preload(PathsHelper.CURSOR_CLICK)
@export var smash: Resource = preload(PathsHelper.CURSOR_SMASH)
@export var death: Resource = preload(PathsHelper.CURSOR_DEATH)

@onready var grid_sprite: AnimatedSprite2D = $GridSprite
@onready var tilemap: TileMap = $TileMap

func _ready():
	Input.set_custom_mouse_cursor(point_out)
	grid_sprite.play("default")
	grid_sprite.visible = true

func _process(delta: float) -> void:
	grid_sprite.global_position = tilemap.map_to_local(tilemap.local_to_map(get_local_mouse_position())) ## Muestra el grid en la posición del ratón, relativa al tilemap
	
	if Input.is_action_just_pressed(InputsHelper.LEFT_CLICK):
		Input.set_custom_mouse_cursor(grab)
	elif Input.is_action_just_released(InputsHelper.LEFT_CLICK):
		Input.set_custom_mouse_cursor(point_out)
