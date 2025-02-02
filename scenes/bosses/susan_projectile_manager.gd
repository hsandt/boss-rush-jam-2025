extends Node

@export var spawn_delay := 5.0
@export_range(1, 100) var group_count := 3
@export_range(0.0, 10.0) var group_burst_delay := 0.2

@onready var proj_grp_tri_scene001:PackedScene = preload("res://scenes/projectiles/projectile_groups/projectile_group_001.tscn")
@onready var proj_grp_tri_scene002:PackedScene = preload("res://scenes/projectiles/projectile_groups/projectile_group_002.tscn")
@onready var boss_owner:BaseBoss = $".."

var time_value := 0.0

func _physics_process(delta):
	time_value += delta

func _on_proj_delay_001_timeout():

	#TODO temporary pattern for testing groups
	var tween = create_tween()
	var which_proj_group = spawn_projectile_group001 if int(time_value)%2 else spawn_projectile_group002
	for i in range(group_count):
		tween.tween_callback(which_proj_group)
		tween.tween_interval(group_burst_delay)

func spawn_projectile_group001():
	var proj_group = proj_grp_tri_scene001.instantiate() as BaseProjectileGroup
	proj_group.rotation_speed = 4.0
	#var direction = (boss_owner.player.position - boss_owner.position).normalized()
	proj_group.direction = Vector2.RIGHT.rotated(time_value*3.0)
	proj_group.speed = 200.0
	proj_group.expand_speed = proj_group.speed * 0.08
	boss_owner.get_projectile(proj_group)

func spawn_projectile_group002():
	var proj_group = proj_grp_tri_scene002.instantiate() as BaseProjectileGroup
	proj_group.rotation_speed = 1.0
	proj_group.expand_speed = 200.0
	boss_owner.get_projectile(proj_group)
