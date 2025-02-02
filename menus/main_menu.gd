extends MarginContainer

@onready var menu_manager = $".."

func _on_settings_button_pressed():
	self.hide()
	menu_manager.show_settings_menu()

func _on_quit_button_pressed():
	get_tree().quit()
	return

func _on_start_button_pressed():
	self.hide()
	get_tree().change_scene_to_file("res://scenes/worlds/boss_stage1_level_test.tscn")
