class_name UIButton
extends Button


@onready var sfx_manager: SFXManager = get_tree().get_first_node_in_group(&"sfx_manager")
@onready var click_sfx: AudioStream = preload("res://audio/sfx/UI/UI_menu_navigate.ogg")

func _ready():
	pressed.connect(_button_pressed)

func _button_pressed():
	if click_sfx:
		sfx_manager.spawn_sfx(click_sfx)
