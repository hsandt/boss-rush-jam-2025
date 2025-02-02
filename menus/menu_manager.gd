extends Control

@onready var main_menu = $MainMenu
@onready var settings_menu = $SettingsMenu
@onready var pause_menu = $PauseMenu

func _ready():
	for child in get_children():
		child.hide()
	main_menu.show()

func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		if main_menu.hidden and settings_menu.hidden:
			if pause_menu.hidden:
				pause_menu.show()
			else:
				pause_menu.hide()

func show_main_menu():
	main_menu.show()

func show_settings_menu():
	settings_menu.show()

func show_pause_menu():
	pause_menu.show()
