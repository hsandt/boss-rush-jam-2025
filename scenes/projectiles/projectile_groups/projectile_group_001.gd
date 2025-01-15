extends Node2D
## 3 Projectiles in a triangle formation
## rotate with constant speed
## move in the specified direction with constant speed

var velocity := Vector2.ZERO

var rotation_speed := 2.0
var direction := Vector2(0.707, 0.707)
var speed := 100.0

func setup(rot_speed:float, dir:Vector2, proj_speed:float):
	self.rotation_speed = rot_speed
	self.direction = dir
	self.speed = proj_speed

func _process(_delta):
	if get_child_count() == 0:
		queue_free()

func _physics_process(delta):

	rotate(-rotation_speed * delta)
	velocity += direction * speed * delta

	global_position += velocity * delta
	expand_projectile_pos(delta)

func expand_projectile_pos(delta):
	for proj in get_children():
		var dist = proj.position.length()
		dist += speed * delta * 0.08
		proj.position = proj.position.normalized() * dist
