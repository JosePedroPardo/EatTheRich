extends CanvasLayer

@onready var debug_fps_label: Label = $PanelContainer/DebugContainer/FPSContainer/F_result
@onready var debug_resolution_label: Label = $PanelContainer/DebugContainer/ResolutionContainer/R_result
var window_size = DisplayServer.window_get_size()
var screen_size = DisplayServer.screen_get_size()

func _process(delta):
	debug_fps_label.text = str(Engine.get_frames_per_second())
	debug_resolution_label.text = str(screen_size)
