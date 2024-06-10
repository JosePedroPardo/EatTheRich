class_name StatisticsManager
extends Node

@export var wait_year: float = 60 ## La duración de un año
@export var max_pollution: float = 100
@export var slow_increment: float = wait_year / 100
@export var debug_invert_pollution: bool = false

var total_rich_pufs: int = 0
var total_poor_pufs: int = 0
var total_buildings: int = 0
var total_rich_buildings: int = 0
var total_poor_buildings: int = 0
var year: int = 0:
	get:
		return year
var previous_pollution: float = 0
var actual_pollution: float = 0
var target_pollution: float = 0
var pollution_change_rate: float = 0.1 ## Tasa de cambio por frame
var rich_pollution: float = 0.067 ## Cantidad de pollution generada por año por un rico
var poor_pollution: float = 0.033 ## Cantidad de pollution generada por año por un rico
var building_rich_pollution: float = rich_pollution * 0.3
var building_poor_pollution: float = poor_pollution * 0.3

@onready var ui_labels = get_tree().get_nodes_in_group(DefinitionsHelper.GROUP_UI_LABELS_RESULT)
@onready var ui_years_label = PathsHelper.get_node_by_name(ui_labels, "YResult")
@onready var ui_pollution_label =  PathsHelper.get_node_by_name(ui_labels, "PResult")
@onready var ui_poblation_label =  PathsHelper.get_node_by_name(ui_labels, "PoResult")
@onready var total_pufs: Array

@onready var ui_sprites = get_tree().get_nodes_in_group(DefinitionsHelper.GROUP_UI_STATISTICS_ANIMATIONS)
@onready var year_sprite: Sprite2D = PathsHelper.get_node_by_name(ui_sprites, "YearSprite")
@onready var pollution_sprite: Sprite2D = PathsHelper.get_node_by_name(ui_sprites, "PollutionSprite")
@onready var poblation_sprite: Sprite2D = PathsHelper.get_node_by_name(ui_sprites, "PoblationSprite")
@onready var year_animation_player: AnimationPlayer = year_sprite.get_child(0)
@onready var poblation_animation_player: AnimationPlayer = poblation_sprite.get_child(0)
@onready var pollution_sprite_player: AnimationPlayer =pollution_sprite.get_child(0)
@onready var year_timer: Timer = $YearsTimer

func _ready():
	year_timer.wait_time = wait_year
	year_timer.start()

func _process(delta):
	ui_pollution_label.text = String.num(actual_pollution, 2)
	_update_poblation()
	_update_pollution(delta)

func _update_poblation():
	var global_puf: int = get_tree().get_nodes_in_group(DefinitionsHelper.GROUP_PUFS).size()
	var animation_to_play: String = ""
	if total_pufs.size() != global_puf:
		if global_puf > total_pufs.size():
			animation_to_play = DefinitionsHelper.ANIMATION_PLUS_UI
		elif global_puf < total_pufs.size():
			animation_to_play = DefinitionsHelper.ANIMATION_MINUM_UI
		total_pufs = get_tree().get_nodes_in_group(DefinitionsHelper.GROUP_PUFS)
		ui_poblation_label.text = str(total_pufs.size())
		_reproduce_animation(poblation_sprite, poblation_animation_player,animation_to_play, true)

func _change_visibility_sprite(sprite: Sprite2D, visibility: bool):
	sprite.visible = visibility

func _update_pollution(delta): 
	var slow_delta: float = delta * slow_increment
	var visibility: bool = false
	var animation_to_play: String = ""
	previous_pollution = actual_pollution
	if actual_pollution < target_pollution:
		actual_pollution += pollution_change_rate * slow_delta
		if actual_pollution > target_pollution:
			actual_pollution = target_pollution
	elif actual_pollution > target_pollution:
		actual_pollution -= pollution_change_rate * slow_delta
		if actual_pollution < target_pollution:
			actual_pollution = target_pollution
	if actual_pollution != 0:
		_change_visibility_sprite(pollution_sprite, true)
	else:
		_change_visibility_sprite(pollution_sprite, false)

func _calculate_total_pollution() -> float:
	if debug_invert_pollution: 
		return -1 * ((total_rich_pufs + total_rich_buildings) * rich_pollution) + ((total_poor_pufs + total_poor_buildings) * poor_pollution)
	return ((total_rich_pufs + total_rich_buildings) * rich_pollution) + ((total_poor_pufs + total_poor_buildings) * poor_pollution)

func _update_animations_to_pollution(animation_to_play: String):
	pollution_sprite_player.stop()
	pollution_sprite_player.play(animation_to_play)

func _reproduce_animation(animation_sprite: Sprite2D, animation_player: AnimationPlayer, animation: String, cut_animation: bool):
	_change_visibility_sprite(animation_sprite, true)
	if cut_animation:
		animation_player.stop()
		animation_player.play(animation)
		return
	if animation_player.is_playing():
		animation_player.queue(animation)
	elif animation_player.get_queue().is_empty(): 
		animation_player.play(animation)

func _shake_label(label: Label, intensity: float, duration: float, frequency: float):
	var original_position = label.position
	var elapsed_time = 0
	while elapsed_time < duration:
		await get_tree().create_timer(frequency).timeout
		label.position = original_position + Vector2(
			randf_range(-intensity, intensity),
			0  # Solo movimiento horizontal
		)
		elapsed_time += frequency
	label.position = original_position

func _on_manager_pufs_born_a_rich():
	total_rich_pufs += 1

func _on_manager_pufs_born_a_poor():
	total_poor_pufs += 1

func _on_years_timer_timeout():
	year += 1
	ui_years_label.text = str(year)
	target_pollution += _calculate_total_pollution()
	_reproduce_animation(year_sprite, year_animation_player, DefinitionsHelper.ANIMATION_PLUS_UI, false)
	var animation_to_play = DefinitionsHelper.ANIMATION_DOWN_UI if actual_pollution > target_pollution else DefinitionsHelper.ANIMATION_UP_UI
	_update_animations_to_pollution(animation_to_play)
