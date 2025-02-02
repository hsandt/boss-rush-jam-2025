class_name Level
extends Node2D

# currently unused
@onready var projectiles_parent: Node2D = $ProjectilesParent

# currently unused
@onready var aoes_parent: Node2D = $AOEsParent

@onready var fxs_parent: Node2D = $FXsParent

func clear_all_projectiles():
	NodeUtils.queue_free_children(projectiles_parent)

func clear_all_aoes():
	NodeUtils.queue_free_children(aoes_parent)
