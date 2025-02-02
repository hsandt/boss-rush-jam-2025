extends Node

func _process(_delta):

	if OS.has_feature("debug"):
		if Input.is_action_just_pressed(&"exit_game"):
			get_tree().quit()
			return

		if Input.is_action_just_pressed(&"restart_game"):
			get_tree().reload_current_scene()

	if Input.is_action_just_pressed(&"toggle_fullscreen"):
		toggle_fullscreen()


func toggle_fullscreen():
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
