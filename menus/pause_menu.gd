extends MarginContainer

@onready var in_game_manager: InGameManager = get_tree().get_first_node_in_group("in_game_manager")
@onready var pause_menu_canvas_layer: CanvasLayer = $".."

func _on_resume_button_pressed():
	in_game_manager.resume_game()
	
func _on_quit_button_pressed():
	in_game_manager.go_back_to_menu()
