class_name BaseProjectile
extends Node

@export var can_be_hit_by_melee_attack: = false
@export var projectile_attack_damage := 1.0

func _ready():
	pass

func be_hurt_by_melee(_damage: float):
	queue_free()

func _on_hit_box_area_2d_area_entered(area: Area2D):
	# We set up collision mask so the only areas hit are player hurt box and player melee hitbox
	# (but currently collision with the latter is verified from player side)
	var player_hurt_box := area as PlayerHurtBox
	if player_hurt_box:
		player_hurt_box.be_hurt_by_projectile(projectile_attack_damage)
		queue_free()

func _on_hit_box_area_2d_body_entered(_body: Node2D):
	# We set up collision mask so the only physics body hit is world,
	# so we know we are hitting a wall
	#TODO add destruction animation
	#print("projectile, hit terrain/world")
	queue_free()
