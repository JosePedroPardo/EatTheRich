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
const RICH: String = "RICH"
const POOR: String = "POOR"
const NAMES: String = "names"
const MEDIOCRES: String = "Mediocres"
const RANDOM_SOCIAL_CLASS: int = -1
const RICH_SOCIAL_CLASS: int = 1
const POOR_SOCIAL_CLASS: int = 0

''' Texture puf '''
const texture_rich_pufs = [
	PathsHelper.SPRITE_RICH_002, 
]
const texture_poor_pufs = [
	PathsHelper.SPRITE_POOR_001, 
	PathsHelper.SPRITE_POOR_002, 
	PathsHelper.SPRITE_POOR_003, 
]

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
