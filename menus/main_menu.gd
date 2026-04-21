extends Control

@export_range(0.0, 5*360, 0.01, "radians_as_degrees") var menu_intro_start_rotation := deg_to_rad(2.5*360)
@export_range(0.0, 5.0, 0.01, "or_greater") var menu_intro_start_scale := 2.5
@export_range(0.0, 5.0, 0.01, "or_greater") var menu_intro_duration := 1.0
@export_range(0.0, 50.0, 0.01, "or_greater") var menu_intro_shake_amplitude := 50.0
@export_range(0.0, 0.1, 0.01, "or_greater") var menu_intro_shake_period := 0.05
@export_range(0.0, 0.25, 0.01, "or_greater") var menu_intro_shake_duration := 0.25
@onready var menu_manager = $".."
@onready var start_button = $VBoxContainer/StartButton
@onready var settings_button = $VBoxContainer/SettingsButton
@onready var quit_button = $VBoxContainer/QuitButton

func _ready():
	start_button.disabled = true
	settings_button.disabled = true
	quit_button.disabled = true
	
	await play_main_menu_intro()
	
	start_button.disabled = false
	settings_button.disabled = false
	quit_button.disabled = false
	start_button.grab_focus.call_deferred()
	
	
func play_main_menu_intro():
	# Vintage rotating/scaled down newspaper appear effect
	var tween_appear = create_tween()
	tween_appear.parallel().tween_property(self, ^"rotation", 0.0, menu_intro_duration) \
		.from(menu_intro_start_rotation) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween_appear.parallel().tween_property(self, ^"scale", Vector2.ONE, menu_intro_duration) \
		.from(menu_intro_start_scale * Vector2.ONE)

	await tween_appear.finished

	# Shake effect, unsyncing X and Y via randomness

	var tween_shake_x = create_tween()
	tween_shake_x.tween_property(self, ^"position:x", menu_intro_shake_amplitude * randf_range(0.5, 1.0), menu_intro_shake_period * randf_range(0.5, 1.0)) \
		.from_current()
	tween_shake_x.tween_property(self, ^"position:x", -menu_intro_shake_amplitude * randf_range(0.5, 1.0), menu_intro_shake_period * randf_range(0.5, 1.0))
	tween_shake_x.set_loops(0)

	var tween_shake_y = create_tween()
	tween_shake_y.tween_property(self, ^"position:y", menu_intro_shake_amplitude * randf_range(0.5, 1.0), menu_intro_shake_period * randf_range(0.5, 1.0)) \
		.from_current()

	tween_shake_y.tween_property(self, ^"position:y", -menu_intro_shake_amplitude * randf_range(0.5, 1.0), menu_intro_shake_period * randf_range(0.5, 1.0))
	tween_shake_y.set_loops(0)

	# reset to center position
	await get_tree().create_timer(menu_intro_shake_duration).timeout
	tween_shake_x.stop()
	tween_shake_y.stop()
	position = Vector2.ZERO
	
	
func _on_settings_button_pressed():
	self.hide()
	menu_manager.show_settings_menu()

func _on_quit_button_pressed():
	get_tree().quit()
	return

func _on_start_button_pressed():
	self.hide()
	get_tree().change_scene_to_file("res://scenes/worlds/boss_stage1_level_test.tscn")
