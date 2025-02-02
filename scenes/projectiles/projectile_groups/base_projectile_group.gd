class_name BaseProjectileGroup
extends Node2D

#@export_category("Movement Options")
@export var can_move := false
@export var can_rotate := false
@export var can_expand := false

var velocity := Vector2.ZERO
var rotation_speed := 2.0
var direction := Vector2(0.707, 0.707)
var speed := 100.0
var expand_speed := 8.0

func _process(_delta):
	if get_child_count() == 0:
		queue_free()

func _physics_process(delta):
	if can_move:
		update_velocity(delta)
		move(delta)
	if can_rotate:
		rotate_group(delta)
	if can_expand:
		expand_projectile_pos(delta)

func update_velocity(delta:float):
	velocity += direction * speed * delta

func move(delta:float):
	global_position += velocity * delta

func rotate_group(delta:float):
	rotate(rotation_speed * delta)

func expand_projectile_pos(delta:float):
	for proj in get_children():
		var dist = proj.position.length()
		dist += expand_speed * delta
		proj.position = proj.position.normalized() * dist
