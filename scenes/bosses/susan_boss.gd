extends Node2D

## Arm roattion speed. Use degres in editor
@export var arm_speed := 50.0:
	get:
		return deg_to_rad(arm_speed)
## 1.0: clockwise, -1.0: anticlockwise
@export_range(-1.0, 1.0) var arm_rotation_modifier := 1.0

func _physics_process(delta):

	rotate_arm(delta)

## rotates arm
func rotate_arm(delta):
	$Arm.rotate(arm_speed * arm_rotation_modifier * delta)
