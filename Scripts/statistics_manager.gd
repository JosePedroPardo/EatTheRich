class_name StatisticsManager
extends CanvasLayer

@export var wait_year: float = 30 ## La duración de un año
@export var max_pollution: float = 100

var total_rich_pufs: int = 0
var total_poor_pufs: int = 0
var total_buildings: int = 0
var total_rich_buildings: int = 0
var total_poor_buildings: int = 0
var year: int = 0
var total_pollution: float = 0
var rich_pollution: float = 0.67 ## Cantidad de pollution generada por año por un rico
var poor_pollution: float = 0.33 ## Cantidad de pollution generada por año por un rico
var building_rich_pollution: float = rich_pollution * 3
var building_poor_pollution: float = poor_pollution * 3

@onready var labels = get_tree().get_nodes_in_group(DefinitionsHelper.GROUP_UI_LABELS_RESULT)
@onready var ui_years_label = PathsHelper.get_node_by_name(labels, "YResult")
@onready var ui_pollution_label =  PathsHelper.get_node_by_name(labels, "PResult")
@onready var ui_poblation_label =  PathsHelper.get_node_by_name(labels, "PoResult")
@onready var total_pufs: Array

@onready var year_sprite: Sprite2D = $SuperiorContainer/YearContainer/Sprite
@onready var pollution_sprite: Sprite2D = $SuperiorContainer/PollutionContainer/Sprite
@onready var poblation_sprite: Sprite2D = $SuperiorContainer/PoblationContainer/Sprite
@onready var year_animation_player: AnimationPlayer = year_sprite.get_child(0)
@onready var poblation_animation_player: AnimationPlayer = poblation_sprite.get_child(0)
@onready var pollution_sprite_player: AnimationPlayer = $SuperiorContainer/PollutionContainer/Sprite/AnimationPlayer
@onready var year_timer: Timer = $YearsTimer

func _ready():
	year_timer.wait_time = wait_year
	year_timer.start()

func _process(delta):
	ui_years_label.text = str(year)
	ui_pollution_label.text = str(total_pollution)
	ui_poblation_label.text = str(total_pufs.size())
	_update_poblation()
	_calculate_total_pollution()

func _update_poblation():
	var global_puf: int = get_tree().get_nodes_in_group(DefinitionsHelper.GROUP_PUFS).size()
	var animation_to_play: String = ""
	if total_pufs.size() != global_puf:
		if global_puf > total_pufs.size():
			animation_to_play = DefinitionsHelper.ANIMATION_PLUS_UI
		elif global_puf < total_pufs.size():
			animation_to_play = DefinitionsHelper.ANIMATION_MINUM_UI
		total_pufs = get_tree().get_nodes_in_group(DefinitionsHelper.GROUP_PUFS)
		_reproduce_animation(poblation_sprite, poblation_animation_player, DefinitionsHelper.ANIMATION_PLUS_UI)

func _reproduce_animation(animation_sprite: Sprite2D, animation_player: AnimationPlayer, animation: String):
	animation_sprite.visible = true
	if animation_player.is_playing():
		animation_player.queue(animation)
	elif animation_player.get_queue().is_empty(): 
		animation_player.play(animation)

func _calculate_total_pollution(): 
	var global_pollution: float = ((total_rich_pufs + total_rich_buildings) * rich_pollution) + ((total_poor_pufs + total_poor_buildings) * poor_pollution)
	if global_pollution == 0:
		pollution_sprite.visible = false
		pollution_sprite_player.stop()
		return
	else: pollution_sprite.visible = true
	
	if global_pollution != total_pollution:
		if global_pollution > total_pollution:
			pollution_sprite_player.play(DefinitionsHelper.ANIMATION_UP_UI)
		elif global_pollution < total_pollution:
			pollution_sprite_player.play(DefinitionsHelper.ANIMATION_DOWN_UI)
	
	total_pollution = global_pollution

func _on_years_timer_timeout():
	year += 1
	_reproduce_animation(year_sprite, year_animation_player, DefinitionsHelper.ANIMATION_PLUS_UI)

func _on_manager_pufs_born_a_rich():
	total_rich_pufs += 1

func _on_manager_pufs_born_a_poor():
	total_poor_pufs += 1

