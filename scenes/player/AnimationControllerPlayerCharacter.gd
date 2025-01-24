class_name AnimationControllerPlayerCharacter
extends AnimationControllerBase
## Animation controller for Player Character


## Player character owner
@export var player: Player


# override
func initialize():
	super.initialize()

	DebugUtils.assert_member_is_set(self, player, "player")


# implement
## Return base animation based on owner state and last animation
func _get_base_animation(last_animation: StringName) -> StringName:
	var new_animation: String
	var should_not_loop: bool = false

	if player.is_dashing:
		new_animation = &"Dash"
		should_not_loop = true
	else:
		if player.is_jumping:
			new_animation = &"Jump"
		else:
			if player.moving:
				new_animation = &"Run"
			else:
				new_animation = &"Idle"

	if OS.has_feature("debug"):
		if should_not_loop:
			# Retrieve Animation resource from the appropriate library and warn if not looping
			var animation_resource := animation_player.get_animation(new_animation)
			if animation_resource and animation_resource.loop_mode != Animation.LOOP_NONE:
				push_warning("[CharacterAnim] Animation '%s' is expected not to loop, but it does"
					% new_animation)

	return new_animation


# override
## Process animation end
func _process_animation_finished(anim_name: StringName):
	if anim_name == &"Hurt":
		# Hurt animation finished, update health flag
		player.health.is_hurting = false
