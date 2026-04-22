extends MarginContainer

@onready var in_game_manager: InGameManager = get_tree().get_first_node_in_group("in_game_manager")
@onready var pause_menu_canvas_layer: CanvasLayer = $".."
@onready var resume_button: Button = $VBoxContainer/ResumeButton

func _on_resume_button_pressed():
	in_game_manager.resume_game()
	
func _on_quit_button_pressed():
	in_game_manager.go_back_to_menu()


func _on_visibility_changed() -> void:
	if not resume_button:
		# too early, happens when loading scene
		return
		
	if is_visible_in_tree():
		resume_button.grab_focus()
