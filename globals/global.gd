extends Node

func _process(_delta):

	if Input.is_action_just_pressed(&"exit_game"):
		get_tree().quit()
		return

	if Input.is_action_just_pressed(&"toggle_fullscreen"):
		toggle_fullscreen()

	if Input.is_action_just_pressed(&"restart_game"):
		get_tree().reload_current_scene()


func toggle_fullscreen():
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
