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
const INDEX_RANDOM_SOCIAL_CLASS: int = -1
const INDEX_RICH_SOCIAL_CLASS: int = 1
const INDEX_POOR_SOCIAL_CLASS: int = 0

'''  Type of celebration puf'''
const TYPE_CELEBRATION_SMASH_PUF: String = "smash"

''' Ways of dying of the Pufs'''
const WAY_DYING_SMASH: String = "smash"
const WAY_DYING_BY_FALL_PUF: String = "by_fall"
const WAY_DYING_NEEDS: String = "needs"

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
const ANIMATION_TERROR_PUF: String = "Pufs/terror"
const ANIMATION_CELEBRATION_PUF: String = "Pufs/celebration"
const ANIMATION_PICK_ME: String = "Pufs/pick_me"
const ANIMATION_JUMP_PUF: String = "Pufs/jump"
const ANIMATION_DEATH_BY_FALL_PUF: String = "Pufs/DBFall"
const ANIMATION_TO_DIE_PUF: String = "Pufs/ToDie"
const ANIMATION_DEATH_BY_SMASH_PUF: String = "Pufs/DBSmash"

const ANIMATION_DEATH_BY_SMASH_CURSOR: String = "Cursor/DBSmash"

const ANIMATION_PLUS_UI: String = "MinumPlus/plus"
const ANIMATION_MINUM_UI: String = "MinumPlus/minum"
const ANIMATION_UP_UI: String = "Pollution/up"
const ANIMATION_DOWN_UI: String = "Pollution/down"

''' All layers 2D '''
const LAYER_GROUND_2D: int = 0
const LAYER_ENTITIES_2D: int = 1
const LAYER_ITEMS_2D: int = 2
const LAYER_ENVIROMENT_2D: int = 3
const LAYER_GUI_2D: int = 4

''' Layers in tilemap '''
const TILEMAP_LAYER_TYPE_WALL = "wall"
const TILEMAP_LAYER_TYPE_SPAWN = "spawn"
const TILEMAP_LAYER_TYPE_OUTLINE = "outline"
const TILEMAP_LAYER_TYPE_DEATH = "death"

''' Paths fo tilemap layers '''
const TM_LAYER_GROUND: int = 0
const TM_LAYER_PATHS: int = 1

''' Names of groups'''
const GROUP_PUFS: String = "pufs"
const GROUP_MANAGER_PUFS: String = "manager_pufs"
const GROUP_UI_LABELS_RESULT: String = "ui_labels_result"
const GROUP_UI_STATISTICS_ANIMATIONS: String = "ui_statistics_animations"
const GROUP_UI_DEBUG: String = "debug"
const GROUP_TILEMAP: String = "tilemap"
const GROUP_CAMERA: String = "camera"

''' Definition statistics '''
const UI_LABEL_STATISTICS_TIME_TO_RICH: String = "next rich in..."
const UI_LABEL_STATISTICS_INITIAL_TIME: String = "next Puf in..."
