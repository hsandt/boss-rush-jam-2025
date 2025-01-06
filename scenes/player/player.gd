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
@export var melee_attack_damage := 1.0
@export var melee_cancel_time := 0.5

# look direction
var direction := Vector2.RIGHT
# input direction
var input_dir := Vector2.ZERO
# move direction
var movt_dir := Vector2.RIGHT
var moving := false
var in_control := true
var is_dashing := false

@onready var dash_for_timer: Timer = $Timers/Dash/For
@onready var dash_cooldown_timer: Timer = $Timers/Dash/Cooldown
@onready var shoot_cooldown_timer: Timer = $Timers/Shoot/Cooldown
@onready var melee_cancel_timer: Timer = $Timers/Melee/Cancel

func _ready():
	dash_for_timer.wait_time = dash_for
	dash_cooldown_timer.wait_time = dash_cooldown
	shoot_cooldown_timer.wait_time = shoot_cooldown
	melee_cancel_timer.wait_time = melee_cancel_time

func _process(delta):
	get_input()
	$axis.rotation = lerp_angle($axis.rotation, direction.angle(), 16.0*delta)

func _physics_process(delta):

	#get_input()
	move(delta)
	move_and_slide()

func move(delta):

	if is_dashing:
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

	if can_control_move():
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

	if can_dash() and Input.is_action_just_pressed("dash"):
		dash()

	if can_shoot() and Input.is_action_just_pressed("shoot"):
		shoot()

	if can_melee_attack() and Input.is_action_just_pressed("melee"):
		melee_attack()

func can_shoot():
	return shoot_cooldown_timer.is_stopped() and not is_dashing

func shoot():
	print("shot")
	shoot_cooldown_timer.start()
	# recoil / knockback
	velocity -= direction * shoot_kb

func can_melee_attack():
	return melee_cancel_timer.is_stopped() and not is_dashing

func melee_attack():
	print("melee_attack")
	melee_cancel_timer.start()

func can_control_move():
	return not is_dashing

func can_dash():
	return dash_cooldown_timer.is_stopped()

func dash():
	# if dash for cooldown < dash for time, player can chain dashes (only in same direction for now)
	# before the last one has even finished (see can_dash)
	# so it's important to stop the dash for timer from previous dash
	# so it can properly restart now
	if not dash_for_timer.is_stopped():
		dash_for_timer.stop()

	is_dashing = true
	in_control = false
	dash_for_timer.start()
	dash_cooldown_timer.start()

func _on_dash_for_timeout():
	is_dashing = false
	in_control = true
	if velocity.length_squared() > max_speed**2:
		velocity = velocity.normalized() * max_speed
