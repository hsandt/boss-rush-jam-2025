extends Node

func _process(_delta):

	if Input.is_action_just_pressed(&"exit_game", true):
		get_tree().quit()
		return

	if OS.has_feature("debug") and Input.is_action_just_pressed(&"debug_restart_game", true) or \
			Input.is_action_just_pressed(&"restart_game", true):
		get_tree().reload_current_scene()
		return

	if Input.is_action_just_pressed(&"toggle_fullscreen", true):
		toggle_fullscreen()


func toggle_fullscreen():
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
