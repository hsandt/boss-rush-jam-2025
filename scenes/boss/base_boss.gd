class_name BaseBoss
extends Node2D


## Signal sent when boss is despawned (typically after gameplay death)
signal despawn



@export_group("Components")

@export var health: Health


func _ready():
	initialize()
	setup()

func initialize():
	DebugUtils.assert_member_is_set(self, health, "health")

	health.damage_received.connect(_on_damage_received)

func setup():
	health.setup()

func _on_damage_received(will_die: bool):
	if will_die:
		print("Boss is dead!")
	else:
		print("Boss received damage!")
