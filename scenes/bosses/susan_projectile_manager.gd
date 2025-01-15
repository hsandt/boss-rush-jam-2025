extends Node

@export var spawn_delay := 5.0
@export_range(1, 100) var group_count := 5
@export_range(0.0, 10.0) var group_burst_delay := 0.2

@onready var proj_grp_tri_scene:PackedScene = preload("res://scenes/projectiles/projectile_groups/projectile_group_001.tscn")
@onready var boss_owner:BaseBoss = $".."

var time_value := 0.0

func _physics_process(delta):
	time_value += delta

func _on_proj_delay_001_timeout():
	var tween = create_tween()
	for i in range(group_count):
		tween.tween_callback(spawn_projectile_group)
		tween.tween_interval(group_burst_delay)

func spawn_projectile_group():
	var proj_group = proj_grp_tri_scene.instantiate()
	var rotation_speed = 4.0
	#var direction = (boss_owner.player.position - boss_owner.position).normalized()
	var direction = Vector2.RIGHT.rotated(time_value*3.0)
	var speed = 200.0
	proj_group.setup(rotation_speed, direction, speed)
	boss_owner.get_projectile(proj_group)
