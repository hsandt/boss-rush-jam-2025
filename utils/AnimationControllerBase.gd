# From https://github.com/hsandt/hyper-godot-commons/blob/main/visual/AnimationControllerBase.gd
class_name AnimationControllerBase
extends Node
## Abstract base class for an animation controller
## This provides full control over animation for projects where the AnimationTree
## is too loose or cumbersome to use (e.g. complex transitions conditions that are
## hard to write in the condition field)
##
## Currently, for hybrid compatibility, we also support AnimationTree,
## calling AnimationNodeStateMachinePlayback.travel() instead of AnimationPlayer.play().
## This requires all state machine nodes to be named exactly like the Animation they contain
## (which is the default on node creation anyway).
## It still uses the override system to know when to switch back to base animation.
##
## It can play any animation on an AnimationPlayer using a base-override system:
## - Base animation: a continuous animation based
##   on the current state of the animated entity (e.g. Idle, Run, Fall)
##   There are 2 types of base animations:
##     - Main: they are looping and keep playing until _get_base_animation
##       returns a different animation, or there is an override animation
##     - Transition: they are one-time animations and on end,
##       they chain to another base animation based on _on_animation_finished
##       implementation
##   This class is agnostic of entity type and leaves the whole base animation
##   determination to _get_base_animation implementation
## - Override animation: a one-time animation played over the base animation,
##   it takes priority until it ends (e.g. Attack)
##
## Usage:
## - subclass this class with some class MyAnimationController
## - in MyAnimationController, add an exported member representing the model that contains
##   state information used for the animation.
##   For instance, for a character, it could be some MyCharacter class:
##   `@export var character: MyCharacter`
##   and assign it in the inspector
##   You can also check for assignment in initialize:
##   ```
##   func initialize():
##   	super.initialize()
##   	assert(character, "character is not set on %s" % get_path())
##   ```
## - implement _get_base_animation to return the wanted base animation based on
##   owner state, and possibly previous animation
## - implement _on_animation_finished to process animation ends
##   and handle transitions

## Own signal to notify when an animation finished, agnostic of AnimationMixer type
## When using animation tree and traveling through multiple animation nodes,
## this is also emitted when each intermediate animation is finished
## Note: this is emitted before custom processing of animation finished
signal animation_finished(anim_name: StringName)

## Animation player
## When using animation tree:
## - this is still used to verify if animation exists with get_animation(...)
## - if set, we'll use it, but verify that it's the one used by the animation tree
## - if not set, we'll retrieve it from animation tree
@export var animation_player: AnimationPlayer

## Optional animation tree
## If set, we use state machine travel instead of our custom base/override animation system
@export var animation_tree: AnimationTree

## If animation tree is assigned, this is its state machine
var state_machine: AnimationNodeStateMachinePlayback

## If animation tree is assigned, this is the last travel request of the state machine
## (if still traveling, this is the current travel request, else this is the current node,
## which was reached at the end of the last travel, since we only use travel)
## This is a workaround for not being able to access travel request at any time,
## see https://github.com/godotengine/godot-proposals/issues/10445
var state_machine_last_travel_request: StringName

## The name of the current override animation, or &"" is none
var override_animation: StringName


func _ready():
	initialize()
	# Do not call setup, as this script is managed by master script `HeroBase`


func initialize():
	if animation_tree:
		if animation_player:
			assert(animation_player == animation_tree.get_node(animation_tree.anim_player),
				"[AnimationControllerBase] animation_player does not match animation_tree.anim_player node path")
		else:
			animation_player = animation_tree.get_node(animation_tree.anim_player)
	else:
		assert(animation_player, "animation_player is not set on %s" % get_path())
		animation_player.animation_finished.connect(_on_animation_finished)

	if animation_tree:
		# We often deactivate animation tree in the editor to stop previewing
		# (which conflicts with AnimatedSprite2D animation previewing)
		# so manually activate it from code if needed
		animation_tree.active = true

		state_machine = animation_tree["parameters/playback"]
		# When using animation tree, AnimationPlayer.animation_finished signal is not emitted,
		# so we must plug to the equivalent AnimationTree signal instead
		animation_tree.animation_finished.connect(_on_animation_finished)


func setup():
	state_machine_last_travel_request = &""
	clear_any_override_animation()


func _physics_process(_delta: float):
	# If an override animation is active, do not compute the base animation
	# and keep the override animation until it is over
	if override_animation:
		return

	var last_animation = get_current_animation()
	var wanted_base_animation = _get_base_animation(last_animation)

	var last_assigned_animation = get_assigned_animation()

	if wanted_base_animation != last_assigned_animation:
		play_animation(wanted_base_animation)


## Return name of assigned animation
func get_assigned_animation() -> StringName:
	if animation_tree:
		return state_machine_last_travel_request
	else:
		return animation_player.assigned_animation


## Return name of current animation
func get_current_animation() -> StringName:
	if animation_tree:
		return state_machine.get_current_node()
	else:
		# Note that we still return assigned_animation here
		# because current_animation is null at the end of a one-time animation
		return animation_player.assigned_animation


## Play an animation from start
func play_animation(animation_name: StringName):
	# There is currently no method to check if animation node exists in Animation Tree
	# so check animation on the animation player in all cases instead
	# See https://github.com/godotengine/godot-proposals/issues/6316
	# This works because we follow the convention to name all the animation tree nodes
	# like the animations
	if not animation_player.has_animation(animation_name):
		push_error("[AnimationControllerBase] play_animation: AnimationPlayer on %s has no animation '%s'"
			% [animation_player.get_parent().name, animation_name])
		return

	var last_animation := get_current_animation()

	if animation_tree:
		# We can pass animation_name directly to start/travel because we follow
		# the convention to name all the animation tree nodes like the animations
		if last_animation == animation_name:
			# When already playing the same animation
			# (including when chaining from last frame)
			# we need to force restart (travel would not restart the animation
			# and unlike AnimationPlayer, stop only pauses so travel would
			# not work after stop either)
			state_machine.start(animation_name)
		else:
			state_machine.travel(animation_name)
			state_machine_last_travel_request = animation_name
	else:
		# Workaround for RESET animation values not being used as default properties when missing
		# from new animation
		# See https://github.com/godotengine/godot-proposals/issues/6417
		if animation_player.has_animation(&"RESET"):
			animation_player.play(&"RESET")
			animation_player.advance(0)
		else:
			push_error("[AnimationControllerBase] play_animation: AnimationPlayer on %s has no animation 'RESET'"
				% animation_player.get_parent().name)

		# Note that if you remove the hack above, in order to guarantee playing
		# animation from start when the same animation is already playing,
		# you will need to add `animation_player.stop(true)`
		# instead, with keep_state: true to avoid unnecessary processing since
		# we are going to play another (or the same) animation on top

		animation_player.play(animation_name)

		# extra advance is required when this is called from _on_animation_finished
		# avoid showing default state for 1 frame
		animation_player.advance(0)

	if last_animation != animation_name:
		# Animation changed, call virtual method for custom behavior
		# It has a few advantages compared to using native signals:
		# - no need to handle AnimationMixer signals: animation_started and animation_finished
		#   separately (we cannot use AnimationPlayer.animation_changed which only works
		#   for queued animations, and AnimationPlayer.current_animation_changed doesn't
		#   know the old animation either, so AnimationMixer signals are the best alternative)
		# - it ignores the RESET hack above which would emit animation signals twice
		# - can directly override _on_animation_changed on child class
		# In addition, it has the following difference, which may be an advantage of disadvantage
		# depending on your needs:
		# - if using AnimationTree and the transition to next animation needs to travel through
		#   multiple nodes, this will ignore intermediate nodes (animation_name is just the new
		#   target animation)
		_on_animation_changed(last_animation, animation_name)


## Play an animation as override
## If same animation is already playing and force_restart is true, replay it from start
## Default force_restart is true since most of the time, we want to be able to
## chain override animations (such as a combo melee attack).
## It will keep playing until replaced by another override, or it is over and
## transitions back to the base animation defined by context.
## The override animation is expected to be one-shot, so it can end naturally.
func play_override_animation(animation_name: StringName, force_restart: bool = true):
	# Retrieve Animation resource from the appropriate library and warn if looping
	# Note: animation_player.get_animation works when using animation tree
	var animation_resource := animation_player.get_animation(animation_name)
	if animation_resource and animation_resource.loop_mode != Animation.LOOP_NONE:
		push_error("[AnimationControllerBase] Animation '%s' is expected not to loop, but it does. "
			% animation_name,
			"Animation finished event will not be sent.")

	if override_animation != animation_name or force_restart:
		override_animation = animation_name
		play_animation(override_animation)


## Clear override animation, expecting it to be passed animation
func clear_override_animation(animation: StringName):
	# Note that when not using animation tree, animation_player.assigned_animation == override_animation
	# but when using animation tree, animation_player.assigned_animation is empty, so better check
	# override_animation
	if animation == override_animation:
		clear_any_override_animation()
	else:
		push_error("[AnimationControllerBase] clear_override_animation: expecting passed animation '%s' to be " % animation,
			"the same as override_animation '%s', but it differs. " % override_animation,
			"We won't clear the override animation to be safe.")


## Clear any override animation
func clear_any_override_animation():
	override_animation = &""


# abstract
## Return base animation based on owner state and last animation
func _get_base_animation(_last_animation: StringName) -> StringName:
	push_error("[AnimationControllerBase] _get_base_animation: abstract method requires implementation")
	return &""


## One one-shot animation finished
## Clear override animation if it's the one that finished
## and process animation end
func _on_animation_finished(anim_name: StringName):
	animation_finished.emit(anim_name)

	if override_animation != &"":
		clear_override_animation(anim_name)

	_process_animation_finished(anim_name)


# virtual
## Process one-shot animation end
func _process_animation_finished(_anim_name: StringName):
	pass


# virtual
## Process change of target animation
## - when using AnimationPlayer, this is the assigned animation
## - when using AnimationTree, this is current node animation
func _on_animation_changed(last_animation: StringName, animation_name: StringName):
	pass
