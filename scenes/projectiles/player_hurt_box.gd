class_name PlayerHurtBox
extends Area2D


@onready var owning_player: Player = $".."


func be_hurt_by_projectile(damage: float):
	owning_player.be_hurt_by_projectile(damage)
