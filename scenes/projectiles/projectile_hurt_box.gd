class_name ProjectileHurtBox
extends Area2D


@onready var owning_projectile: BaseProjectile = $".."


func be_hurt_by_melee(damage: float):
	owning_projectile.be_hurt_by_melee(damage)
