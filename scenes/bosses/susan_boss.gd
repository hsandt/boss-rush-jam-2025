extends Node2D

## Arm roation speed
@export_range(0, 360, 0.1, "radians_as_degrees") var arm_speed := deg_to_rad(50.0)
## 1.0: clockwise, -1.0: anticlockwise
@export_range(-1.0, 1.0) var arm_rotation_modifier := 1.0
@export_group("ArmStagger")
@export var arm_stagger_time := 1.0
@export var enable_arm_shake_on_hit := true
@export var arm_shake_offset := 1.0
@export var arm_shake_freq := 10.0
@export var force_stop_arm := false
@export_group("Spin")
@export var max_spin := 3.0*TAU
var spin_progress := 0.0

@onready var arm_stagger_timer:Timer = $Timers/Arm/Stagger
@onready var boss_spin_progress = $BossSpinProgress

func _ready():
	arm_stagger_timer.wait_time = arm_stagger_time

func _process(_delta):

	update_boss_spin_ui()

	# TODO placeholder for testing:
	# to be removed later
	if Input.is_action_just_pressed("shoot"):
		provoke_arm_rotation_direction_reversal()

func update_boss_spin_ui():
	boss_spin_progress.material.set_shader_parameter("progress", spin_progress/max_spin)

func _physics_process(delta):

	if not is_arm_staggered():
		rotate_arm(delta)

## rotates arm
func rotate_arm(delta):
	var angle = arm_speed * arm_rotation_modifier * delta
	spin_progress += angle
	$Arm.rotate(angle)

func shake_arm():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	for i in range(arm_shake_freq):
		var angle_offset = randf_range(-1.0, 1.0) * 0.016 * arm_shake_offset
		tween.tween_property($Arm, "rotation", $Arm.rotation+angle_offset, arm_stagger_time / arm_shake_freq)

func provoke_arm_rotation_direction_reversal():
	#TODO check when player dashes through the arm
	#reverse direction
	arm_rotation_modifier *= -1
	$Arm/AnimationPlayer.play("reverse_direction")

func is_arm_staggered():
	return not arm_stagger_timer.is_stopped() or force_stop_arm

func set_arm_modifier(value:float):
	arm_rotation_modifier = sigmoid(arm_rotation_modifier) * value

func reset_arm_modifier():
	arm_rotation_modifier = sigmoid(arm_rotation_modifier)

func _on_player_hurt_arm_area_body_entered(_body):
	print("player hit arm")
	# TODO make the player take damage, knockback & stagger
	#body.stagger()
	#screen shake
	arm_stagger_timer.start()
	if enable_arm_shake_on_hit:
		shake_arm()
	$Arm/AnimationPlayer.play("RESET")

func _on_player_hurt_body_area_body_entered(_body):
	print("player hit boss's body")
	#TODO player hit with minor stagger
	#TODO slight kb away from the boss and arm

## sigmoid math function
func sigmoid(value:float) -> float:
	if value > 0.0:
		return 1.0
	elif value < 0.0:
		return -1.0
	else:
		return 0.0
