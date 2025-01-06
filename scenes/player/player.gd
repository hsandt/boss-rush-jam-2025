extends CharacterBody2D

@export_group("Movement")
@export var max_speed := 300.0
@export var acceleration := 1800.0
@export var deceleration := 2000.0
#@export_group("Dash")
@export var dash_speed := 800.0 * 60.0
@export var dash_for := 0.2
@export var dash_cooldown := 0.5
#@export_group("Shooting")
@export var shoot_cooldown := 0.2
@export var shoot_kb := 400.0

# look direction
var direction := Vector2.RIGHT
# input direction
var input_dir := Vector2.ZERO
# move direction
var movt_dir := Vector2.RIGHT
var moving := false
var in_control := true
var dashing := false
var can_dash := true
var can_shoot := true

func _ready():
	$Timers/Dash/For.wait_time = dash_for
	$Timers/Dash/Cooldown.wait_time = dash_cooldown
	$Timers/Shoot/Cooldown.wait_time = shoot_cooldown

func _process(delta):
	get_input()
	$axis.rotation = lerp_angle($axis.rotation, direction.angle(), 16.0*delta)

func _physics_process(delta):

	#get_input()
	move(delta)
	move_and_slide()

func move(delta):

	if dashing:
		velocity = dash_speed * movt_dir * delta
	elif moving:
		velocity.x = move_toward(velocity.x, movt_dir.x*max_speed, acceleration*delta)
		velocity.y = move_toward(velocity.y, movt_dir.y*max_speed, acceleration*delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, deceleration*delta)
		velocity.y = move_toward(velocity.y, 0.0, deceleration*delta)

	move_and_slide()

func get_input():

	direction = (get_global_mouse_position() - position).normalized()

	if not in_control:
		return

	input_dir = Vector2.ZERO
	if Input.is_action_pressed("left"):
		input_dir.x -= 1
	if Input.is_action_pressed("right"):
		input_dir.x += 1
	if Input.is_action_pressed("up"):
		input_dir.y -= 1
	if Input.is_action_pressed("down"):
		input_dir.y += 1

	moving = not input_dir.is_zero_approx()
	if moving:
		input_dir = input_dir.normalized()
		movt_dir = input_dir

	if can_dash and Input.is_action_just_pressed("dash"):
		dash()

	if can_shoot and Input.is_action_just_pressed("shoot"):
		shoot()

func shoot():
	print("shot")
	can_shoot = false
	$Timers/Shoot/Cooldown.start()
	velocity -= direction * shoot_kb

func dash():
	dashing = true
	in_control = false
	can_dash = false
	$Timers/Dash/For.start()
	$Timers/Dash/Cooldown.start()

func _on_dash_for_timeout():
	dashing = false
	in_control = true
	if velocity.length_squared() > max_speed**2:
		velocity = velocity.normalized() * max_speed

func _on_dash_cooldown_timeout():
	can_dash = true

func _on_shoot_cooldown_timeout():
	can_shoot = true
