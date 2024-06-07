class_name DefinitionsHelper

''' General Definitions '''
const SCRIPT: String = "script"
const INDEX_NOT_EXIST: int = -1

''' Class Names'''
const CLASS_PUF: String = "PUF"
const CLASS_BUILDING: String = "BUILDING"

''' Script Names'''
const SCRIPT_PUF: String = "Puf"
const SCRIPT_BUILDING: String = "Building"

''' Pufs '''
const RICH_SOCIAL_CLASS: String = "RICH"
const POOR_SOCIAL_CLASS: String = "POOR"
const NAMES: String = "names"
const MEDIOCRES: String = "Mediocres"
const RANDOM_SOCIAL_CLASS: int = -1
const INDEX_RICH_SOCIAL_CLASS: int = 1
const INDEX_POOR_SOCIAL_CLASS: int = 0

''' Texture puf '''
const texture_rich_pufs = [
	PathsHelper.SPRITE_RICH_002, 
]
const texture_poor_pufs = [
	PathsHelper.SPRITE_POOR_001, 
	PathsHelper.SPRITE_POOR_002, 
	PathsHelper.SPRITE_POOR_003, 
]

''' Texture Building '''
const TEXTURE_BUILDING_RICH_001: int = 0
const TEXTURE_BUILDING_RICH_002: int = 1
const TEXTURE_BUILDING_RICH_003: int = 2
const TEXTURE_BUILDING_RICH_004: int = 3
const TEXTURE_BUILDING_RICH_005: int = 4
const TEXTURE_BUILDING_RICH_006: int = 5
const TEXTURE_BUILDING_RICH_007: int = 6
const TEXTURE_BUILDING_RICH_008: int = 7
const TEXTURE_BUILDING_POOR_001: int = 8
const TEXTURE_BUILDING_POOR_002: int = 9

''' Selected methods '''
const METHOD_SELECT: String = "select"
const METHOD_DESELECT: String = "deselect"

''' Animations '''
const ANIMATION_SELECTED_PUF: String = "selected"
const ANIMATION_WALK_PUF: String = "Pufs/walk"
const ANIMATION_RUN_PUF: String = "Pufs/run"
const ANIMATION_RESET_PUF: String = "Pufs/RESET"
const ANIMATION_DIE_PUF: String = "Pufs/die"
const ANIMATION_IDLE_PUF: String = "Pufs/idle"
const ANIMATION_SICK_PUF: String = "Pufs/sick"
const ANIMATION_DRAG_PUF: String = "Pufs/drag"
const ANIMATION_DROP_PUF: String = "Pufs/drop"

''' ALL LAYERS 2D '''
const LAYER_GROUND_2D: int = 0
const LAYER_ENTITIES_2D: int = 1
const LAYER_ITEMS_2D: int = 2
const LAYER_ENVIROMENT_2D: int = 3
const LAYER_GUI_2D: int = 4

''' LAYERS IN TILEMAP '''
const TILEMAP_LAYER_TYPE_WALL = "wall"

''' PATHS OF TILEMAP LAYERS'''
const TM_LAYER_GROUND: int = 0
const TM_LAYER_PATHS: int = 1
