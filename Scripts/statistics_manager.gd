class_name StatisticsManager
extends Node2D

@export var total_pufs: int = 0
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


func _ready():
	ui_years_label.text = str(year)
	ui_pollution_label.text = str(pollution)
	ui_poblation_label.text = str(poblation)
	connect("born_puf", Callable(self, "_on_born_puf"))

func _process(delta):
	pass

func _on_born_puf():
	total_pufs+1
