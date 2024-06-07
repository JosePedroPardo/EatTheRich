class_name StatisticsManager
extends CanvasLayer

@export var total_rich_pufs: int = 0
@export var total_poor_pufs: int = 0
@export var total_buildings: int = 0
@export var total_rich_buildings: int = 0
@export var total_poor_buildings: int = 0
@export var year: int = 0
@export var pollution: float = 0

@onready var ui_years_label = get_node(PathsHelper.UI_LABEL_YEAR_RESULT)
@onready var ui_pollution_label = get_node(PathsHelper.UI_LABEL_POLLUTION_RESULT)
@onready var ui_poblation_label = get_node(PathsHelper.UI_LABEL_POBLATION_RESULT)
@onready var total_pufs: Array

@onready var year_sprite: Sprite2D = $SuperiorContainer/YearContainer/Sprite
@onready var year_animation_player: AnimationPlayer = year_sprite.get_child(0)
@onready var poblation_sprite: Sprite2D = $SuperiorContainer/PoblationContainer/Sprite
@onready var poblation_animation_player: AnimationPlayer = poblation_sprite.get_child(0)
@onready var pollution_sprite: Sprite2D = $SuperiorContainer/PollutionContainer/Sprite
@onready var pollution_sprite_player: AnimationPlayer = $SuperiorContainer/PollutionContainer/Sprite/AnimationPlayer

func _ready():
	pass

func _process(delta):
	ui_years_label.text = str(year)
	ui_pollution_label.text = str(pollution) + "%"
	ui_poblation_label.text = str(total_pufs.size())
	_update_poblation()

func _update_poblation():
	var global_puf: int = get_tree().get_nodes_in_group(DefinitionsHelper.GROUP_PUFS).size()
	var animation_to_play: String = ""
	if total_pufs.size() != global_puf:
		if global_puf > total_pufs.size():
			animation_to_play = DefinitionsHelper.ANIMATION_PLUS_UI
		elif global_puf < total_pufs.size():
			animation_to_play = DefinitionsHelper.ANIMATION_MINUM_UI
		total_pufs = get_tree().get_nodes_in_group(DefinitionsHelper.GROUP_PUFS)
		_reproduce_animation(poblation_animation_player, DefinitionsHelper.ANIMATION_PLUS_UI)

func _reproduce_animation(animation_player: AnimationPlayer, animation: String):
	animation_player.queue(animation)

func _on_years_timer_timeout():
	year += 1
	_reproduce_animation(year_animation_player, DefinitionsHelper.ANIMATION_PLUS_UI)
