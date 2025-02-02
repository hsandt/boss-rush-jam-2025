extends MarginContainer

@onready var menu_manager = $".."

func _on_back_button_pressed():
	self.hide()
	menu_manager.show_main_menu()
