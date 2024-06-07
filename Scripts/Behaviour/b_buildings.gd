class_name BehaviourBuildings
extends StaticBody2D

var owners_puf: Array[BehaviourPuf]:
	get: 
		return owners_puf
	set(_owners_puf):
		owners_puf = _owners_puf
var is_rich_building: bool:
	get:
		return is_rich_building
	set(_is_rich_building):
		is_rich_building = _is_rich_building
var myself: Building: 
	get: return myself
	set(_myself):
		myself = _myself

@onready var sprite_building: Sprite2D = $SpriteBuilding

func _init(_owners_puf: Array[BehaviourPuf]):
	owners_puf = _owners_puf

func _ready():
	#myself = Building.new()
	_change_sprite_according_group(owners_puf.size())

func _change_sprite_according_group(count_group: int):
	var texture_frame: int
	match(count_group):
		3: texture_frame = DefinitionsHelper.TEXTURE_BUILDING_POOR_002 if is_rich_building == true else DefinitionsHelper.TEXTURE_BUILDING_RICH_002
		6: texture_frame = DefinitionsHelper.TEXTURE_BUILDING_POOR_001 if is_rich_building == true else DefinitionsHelper.TEXTURE_BUILDING_RICH_002
		9: texture_frame = DefinitionsHelper.TEXTURE_BUILDING_POOR_002 if is_rich_building == true else DefinitionsHelper.TEXTURE_BUILDING_RICH_003
		12: texture_frame = DefinitionsHelper.TEXTURE_BUILDING_POOR_002 if is_rich_building == true else DefinitionsHelper.TEXTURE_BUILDING_RICH_004
		15: texture_frame = DefinitionsHelper.TEXTURE_BUILDING_POOR_002 if is_rich_building == true else DefinitionsHelper.TEXTURE_BUILDING_RICH_005
	sprite_building.frame = texture_frame
