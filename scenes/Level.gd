class_name Level
extends Node2D

# currently unused
@onready var projectiles_parent: Node2D = $ProjectilesParent

# currently unused
@onready var aoes_parent: Node2D = $AOEsParent

@onready var fxs_parent: Node2D = $FXsParent

@onready var back_to_menu_timer = $Timers/BackToMenuTimer
@onready var death_screen = $DeathScreen

func clear_all_projectiles():
	NodeUtils.queue_free_children(projectiles_parent)

func clear_all_aoes():
	NodeUtils.queue_free_children(aoes_parent)

func _on_back_to_menu_timer_timeout():
	get_tree().change_scene_to_file("res://menus/menus.tscn")
