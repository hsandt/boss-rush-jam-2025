class_name BossHurtBox
extends Area2D


@export var owning_boss: BaseBoss


func be_hurt_by_melee(damage: float):
	owning_boss.be_hurt_by_melee(damage)

func be_hurt_by_projectile(damage: float):
	owning_boss.be_hurt_by_projectile(damage)
