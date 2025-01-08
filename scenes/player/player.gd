class_name Player
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
@export var melee_cancel_time := 0.1
@export var melee_start_friction_time := 0.1
@export_range(0, 360, 0.001, "radians_as_degrees") var melee_friction_deceleration := deg_to_rad(6*360)
@export_range(0, 360, 0.001, "radians_as_degrees") var melee_attack_initial_rotation_speed := deg_to_rad(2.5*360)

# look direction
var direction := Vector2.RIGHT
# input direction
var input_dir := Vector2.ZERO
# move direction
var movt_dir := Vector2.RIGHT
var moving := false
var in_control := true
var is_dashing := false

var melee_rotation_speed := 0.0

@onready var shoot_axis: Node2D = $ShootAxis
@onready var melee_axis: Node2D = $MeleeAxis
@onready var melee_hit_box: Area2D = $MeleeAxis/HitBoxArea2D
@onready var dash_for_timer: Timer = $Timers/Dash/For
@onready var dash_cooldown_timer: Timer = $Timers/Dash/Cooldown
@onready var shoot_cooldown_timer: Timer = $Timers/Shoot/Cooldown
@onready var melee_cancel_timer: Timer = $Timers/Melee/Cancel
@onready var melee_start_friction_timer: Timer = $Timers/Melee/StartFriction

@onready var health: Health = $Health

func _ready():
	dash_for_timer.wait_time = dash_for
	dash_cooldown_timer.wait_time = dash_cooldown
	shoot_cooldown_timer.wait_time = shoot_cooldown
	melee_cancel_timer.wait_time = melee_cancel_time
	melee_start_friction_timer.wait_time = melee_start_friction_time

	melee_hit_box.monitoring = false
	melee_hit_box.area_entered.connect(_on_melee_hit_box_area_entered)

	health.setup()

func _process(delta):
	get_input()
	shoot_axis.rotation = lerp_angle(shoot_axis.rotation, direction.angle(), 16.0*delta)

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

	update_melee_rotation(delta)

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
	# Enable hitbox during move
	melee_hit_box.monitoring = true

	# Default to CW attack
	# Do not add, directly set to speed to support cancel chain without reaching crazy speeds
	melee_rotation_speed = melee_attack_initial_rotation_speed

	# in case of cancel chain, stop timer for proper restart
	if not melee_start_friction_timer.is_stopped():
		melee_start_friction_timer.stop()

	melee_start_friction_timer.start()
	melee_cancel_timer.start()

func update_melee_rotation(delta: float):
	if melee_rotation_speed != 0.0 and melee_start_friction_timer.is_stopped():
		# apply friction
		melee_rotation_speed = move_toward(melee_rotation_speed, 0.0, melee_friction_deceleration * delta)
		if melee_rotation_speed == 0.0:
			# End of rotation, disable melee hitbox
			melee_hit_box.monitoring = false

	melee_axis.rotation += melee_rotation_speed * delta

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

func _on_melee_hit_box_area_entered(area: Area2D):
	var projectile := area as ProjectileHurtBox
	if projectile:
		projectile.be_hurt_by_melee(melee_attack_damage)
