extends Control

@onready var main_menu = $MainMenu
@onready var settings_menu = $SettingsMenu

func _ready():
	for child in get_children():
		child.hide()
	main_menu.show()

func show_main_menu():
	main_menu.show()

func show_settings_menu():
	settings_menu.show()
