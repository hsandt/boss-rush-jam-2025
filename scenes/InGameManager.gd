class_name InGameManager
extends Node
## In-game manager class
## Provides access to important level objects and debug input
##
## Usage:
## - define input for the following actions:
##     debug_damage_player_character
##     debug_damage_boss


@export var bgm: AudioStream

@onready var player: Player = get_tree().get_first_node_in_group("players")
@onready var bgm_player: AudioStreamPlayer = $AudioStreamPlayer


func _ready():
	if bgm:
		bgm_player.stream = bgm
		bgm_player.play()


func _unhandled_input(event: InputEvent):
	if event.is_action_pressed(&"debug_damage_player_character"):
		player.health.try_receive_damage(1)
	elif event.is_action_pressed(&"debug_damage_boss"):
		var boss: BaseBoss = get_tree().get_first_node_in_group("bosses")
		if boss:
			boss.health.try_receive_damage(1)
