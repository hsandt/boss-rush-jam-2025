class_name BaseProjectile
extends Node

@export var is_destructible: = false:
	set(value):
		is_destructible = value
		if hurt_box_area:
			hurt_box_area.set_collision_layer_value(6, value)
@export var projectile_attack_damage := 1.0

#@onready var projectile_hit_box: Area2D = $HitBoxArea2D
@onready var hurt_box_area:Area2D = $HurtBoxArea2D

func _ready():
	hurt_box_area.set_collision_layer_value(6, is_destructible)

func be_hurt_by_melee(_damage: float):
	queue_free()

func _on_hit_box_area_2d_area_entered(area):
	var player_hurt_box := area as PlayerHurtBox
	if player_hurt_box:
		player_hurt_box.be_hurt_by_projectile(projectile_attack_damage)
		queue_free()

func _on_hurt_box_area_2d_body_entered(_body):
	#TODO add destruction animation
	#print("projectile, hit terrain/world")
	queue_free()
