extends MarginContainer

@onready var menu_manager = $".."

func _on_resume_button_pressed():
	self.hide()
