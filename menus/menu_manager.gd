extends Control

@onready var main_menu = $MainMenu
@onready var settings_menu = $SettingsMenu
@onready var cover_art = $Background

func _ready():
	cover_art.show()
	main_menu.show()

func show_main_menu():
	main_menu.show()

func show_settings_menu():
	settings_menu.show()
