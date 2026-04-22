class_name Level
extends Node2D

@export var start_sfx: AudioStream

# currently unused
@onready var projectiles_parent: Node2D = $ProjectilesParent

# currently unused
@onready var aoes_parent: Node2D = $AOEsParent

@onready var fxs_parent: Node2D = $FXsParent

@onready var back_to_menu_timer = $Timers/BackToMenuTimer
@onready var death_screen = $DeathScreenCanvasLayer
@onready var death_screen_canvas_modulate = $DeathScreenCanvasLayer/CanvasModulate
@onready var in_game_manager: InGameManager = get_tree().get_first_node_in_group("in_game_manager")
#@onready var fx_manager: FXManager = get_tree().get_first_node_in_group(&"fx_manager")
@onready var sfx_manager: SFXManager = get_tree().get_first_node_in_group(&"sfx_manager")

func _ready():
	death_screen.hide()
	
	#var tween = create_tween()
	#await tween.tween_interval(0.2).finished
	#if start_sfx:
		#sfx_manager.spawn_sfx(start_sfx)

func clear_all_projectiles():
	NodeUtils.queue_free_children(projectiles_parent)

func clear_all_aoes():
	NodeUtils.queue_free_children(aoes_parent)

func fade_in_death_screen() -> Tween:
	death_screen.show()
	var tween = get_tree().create_tween()
	tween.tween_property(death_screen_canvas_modulate, "color:a", 1.0, 1.0).from(0.0)
	return tween

func _on_back_to_menu_timer_timeout():
	in_game_manager.go_back_to_menu()
