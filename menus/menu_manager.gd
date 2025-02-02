extends Control

@onready var main_menu = $MainMenu
@onready var settings_menu = $SettingsMenu
@onready var pause_menu = $PauseMenu
@onready var cover_art = $Background

func _ready():
	for child in get_children():
		if child.has_method("hide"):
			child.hide()
	cover_art.show()
	main_menu.show()

func _process(_delta):

	# Disabled
	if Input.is_action_just_pressed("pause"):
		if main_menu.hidden and settings_menu.hidden:
			if pause_menu.hidden:
				pause_menu.show()
			else:
				pause_menu.hide()

	if main_menu.hidden and settings_menu.hidden:
		if not cover_art.hidden:
			cover_art.hide()
	elif cover_art.hidden:
		cover_art.show()


func show_main_menu():
	main_menu.show()

func show_settings_menu():
	settings_menu.show()

func show_pause_menu():
	pause_menu.show()
