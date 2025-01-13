extends BaseBoss

## Arm roation speed
@export_range(0, 360, 0.1, "radians_as_degrees") var arm_speed_phase1 := deg_to_rad(50.0)
## 1.0: clockwise, -1.0: anticlockwise
@export_range(-1.0, 1.0) var arm_rotation_modifier := 1.0
@export_group("Arm own stagger")
@export var arm_stagger_time := 1.0
@export var enable_arm_shake_on_hit := true
@export var arm_shake_offset := 1.0
@export var arm_shake_freq := 10.0
@export var force_stop_arm := false
@export_group("Arm effect on player")
@export var arm_hit_damage: float = 1.0
@export var arm_stagger_player_duration: float = 1.0
@export var arm_push_impact: float = 1.0
@export_group("Spin")
@export var max_spin := 3.0*TAU

## Current phase (0 before start, phase 1 is 1)
var current_phase: int = 0
## Current spin speed (absolute, use arm_rotation_modifier to change rotation sense)
var current_spin_speed: float = 0.0
var spin_progress := 0.0
var is_processing_player_arm_collision: bool = false

@onready var arm_stagger_timer:Timer = $Timers/Arm/Stagger
@onready var arm: Node2D = $Arm
@onready var arm_animation_player: AnimationPlayer = $Arm/AnimationPlayer
@onready var boss_spin_progress = $BossSpinProgress

func initialize():
	super.initialize()

	arm_stagger_timer.wait_time = arm_stagger_time

func setup():
	super.setup()
	enter_phase(1)

func _process(_delta):
	update_boss_spin_ui()

func update_boss_spin_ui():
	boss_spin_progress.material.set_shader_parameter("progress", spin_progress/max_spin)

func _physics_process(delta):
	if not is_arm_staggered():
		rotate_arm(delta)

func enter_phase(new_phase: int):
	current_phase = new_phase

	if new_phase == 1:
		current_spin_speed = arm_speed_phase1

## rotates arm
func rotate_arm(delta):
	var angle = current_spin_speed * arm_rotation_modifier * delta
	spin_progress += angle
	arm.rotate(angle)

func shake_arm():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	for i in range(arm_shake_freq):
		var angle_offset = randf_range(-1.0, 1.0) * 0.016 * arm_shake_offset
		tween.tween_property(arm, "rotation", arm.rotation+angle_offset, arm_stagger_time / arm_shake_freq)

func provoke_arm_rotation_direction_reversal():
	#TODO check when player dashes through the arm
	#reverse direction
	arm_rotation_modifier *= -1
	arm_animation_player.play("reverse_direction")

func is_arm_staggered():
	return not arm_stagger_timer.is_stopped() or force_stop_arm

func set_arm_modifier(value:float):
	arm_rotation_modifier = sigmoid(arm_rotation_modifier) * value

func reset_arm_modifier():
	arm_rotation_modifier = sigmoid(arm_rotation_modifier)

func _on_player_hurt_arm_area_body_entered(body: Node2D):
	# Ignore collisions if not trying to move yourself
	if current_spin_speed == 0.0 or arm_rotation_modifier == 0.0:
		return

	# safeguard to avoid processing collision multiple times until
	# arm is properly going in the other direction
	var player := body as Player
	if player:
		if not is_processing_player_arm_collision:
			# Check arm rotation sense vs player relative position
			var arm_direction := Vector2.RIGHT.rotated(arm.rotation)
			var to_player := player.position - position
			var sign_angle_toward_player := signf(arm_direction.angle_to(to_player))
			var sign_rotation := signf(arm_rotation_modifier)

			if sign_angle_toward_player == sign_rotation:
				# Moving art toward the player character, so collision is valid
				is_processing_player_arm_collision = true

				# make the player take damage, knockback & stagger
				player.health.try_receive_damage(roundi(arm_hit_damage))
				var push_direction := arm_direction.rotated(sign_angle_toward_player * PI / 2)
				player.stagger(push_direction, arm_push_impact, arm_stagger_player_duration)

				# TODO: screen shake

				arm_stagger_timer.start()
				if enable_arm_shake_on_hit:
					shake_arm()
				arm_animation_player.play("RESET")

				await arm_stagger_timer.timeout
				provoke_arm_rotation_direction_reversal()
				is_processing_player_arm_collision = false

## sigmoid math function
func sigmoid(value:float) -> float:
	if value > 0.0:
		return 1.0
	elif value < 0.0:
		return -1.0
	else:
		return 0.0
