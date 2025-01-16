class_name Player
extends CharacterBody2D

@export_group("Movement")
@export var max_speed := 300.0
@export var acceleration := 1800.0
@export var deceleration := 2000.0

@export_group("Stagger & Pushed")
@export var pushed_impact_to_speed_factor := 400.0

@export_group("Dash")
@export var dash_speed := 800.0
@export var dash_for := 0.2
@export var dash_cooldown := 0.5

@export_group("Shooting")
@export var shoot_cooldown := 0.2
@export var shoot_kb := 400.0

@export_group("Melee")
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
var is_dashing := false

# Stagger & push
var pushed_direction := Vector2.ZERO
var pushed_speed := 0.0

var melee_rotation_speed := 0.0

@onready var shoot_axis: Node2D = $ShootAxis
@onready var melee_axis: Node2D = $MeleeAxis
@onready var melee_hit_box: Area2D = $MeleeAxis/HitBoxArea2D
@onready var dash_for_timer: Timer = $Timers/Dash/For
@onready var dash_cooldown_timer: Timer = $Timers/Dash/Cooldown
@onready var shoot_cooldown_timer: Timer = $Timers/Shoot/Cooldown
@onready var melee_cancel_timer: Timer = $Timers/Melee/Cancel
@onready var melee_start_friction_timer: Timer = $Timers/Melee/StartFriction
@onready var stagger_timer: Timer = $Timers/Stagger/Stagger
@onready var stagger_push_timer: Timer = $Timers/Stagger/StaggerPush

@onready var health: Health = $Health

func _ready():
	dash_for_timer.wait_time = dash_for
	dash_cooldown_timer.wait_time = dash_cooldown
	shoot_cooldown_timer.wait_time = shoot_cooldown
	melee_cancel_timer.wait_time = melee_cancel_time
	melee_start_friction_timer.wait_time = melee_start_friction_time

	# Disable hitbox
	melee_hit_box.monitoring = false
	melee_hit_box.area_entered.connect(_on_melee_hit_box_area_entered)

	health.setup()
	health.damage_received.connect(_on_health_damage_received)

func _process(delta):
	get_input()
	shoot_axis.rotation = lerp_angle(shoot_axis.rotation, direction.angle(), 16.0*delta)

func _physics_process(delta):

	#get_input()
	move(delta)
	move_and_slide()

func move(delta):
	if not stagger_push_timer.is_stopped():
		velocity = pushed_speed * pushed_direction
	elif is_dashing:
		velocity = dash_speed * movt_dir
	elif moving:
		velocity.x = move_toward(velocity.x, movt_dir.x*max_speed, acceleration*delta)
		velocity.y = move_toward(velocity.y, movt_dir.y*max_speed, acceleration*delta)
	else:
		# friction
		# also applied at the beginning of phase: stagger but not pushed anymore
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
	else:
		# reset to allow deceleration due to friction when player cannot control move
		# but not dashing (when staggered but not pushed anymore)
		moving = false

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
	return not is_dashing and stagger_timer.is_stopped()

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
	dash_for_timer.start()
	dash_cooldown_timer.start()

func be_hurt_by_projectile(damage: float):
	health.try_receive_damage(roundi(damage))

func stagger(push_direction: Vector2, push_impact: float, stagger_duration: float, stagger_push_duration: float):
	if stagger_duration < stagger_push_duration:
		push_warning("stagger_duration (%f) < stagger_and_pushed_duration (%f), character will be " % [stagger_duration, stagger_push_duration],
			"pushed after being staggered, push will take over")

	# mind push*ed* vs push
	pushed_direction = push_direction
	pushed_speed = push_impact * pushed_impact_to_speed_factor
	stagger_timer.start(stagger_duration)
	stagger_push_timer.start(stagger_push_duration)

func _on_dash_for_timeout():
	is_dashing = false
	if velocity.length_squared() > max_speed**2:
		velocity = velocity.normalized() * max_speed

func _on_melee_hit_box_area_entered(area: Area2D):
	var boss_hurt_box := area as BossHurtBox
	if boss_hurt_box:
		boss_hurt_box.be_hurt_by_melee(melee_attack_damage)
		return

	var projectile_hurt_box := area
	if projectile_hurt_box:
		projectile_hurt_box.get_parent().be_hurt_by_melee(melee_attack_damage)
		return

func _on_health_damage_received(will_die: bool):
	if will_die:
		queue_free()
