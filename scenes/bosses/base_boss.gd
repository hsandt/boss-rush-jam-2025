class_name BaseBoss
extends Node2D


## Signal sent when boss is despawned (typically after gameplay death)
signal despawn


@export_group("Components")

@export var health: Health

@onready var hud: HUD = get_tree().get_first_node_in_group("hud")
@onready var player: Player = get_tree().get_first_node_in_group("players")


func _ready():
	initialize()
	setup()

func initialize():
	DebugUtils.assert_member_is_set(self, health, "health")

	health.damage_received.connect(_on_damage_received)

func setup():
	health.setup()
	hud.bind_and_show_boss_health_bar(self)


func be_hurt_by_melee(damage: float):
	print("player hit boss's body")
	health.try_receive_damage(roundi(damage))
	#TODO player hit with minor stagger
	#TODO slight kb away from the boss and arm

func be_hurt_by_projectile(damage: float):
	health.be_hurt_by_projectile(roundi(damage))

func _on_damage_received(will_die: bool):
	if will_die:
		print("Boss is dead!")
		play_boss_death_animation()
	else:
		print("Boss received damage!")

func get_projectile(projectile):
	$Projectiles.add_child(projectile)

# virtual
func play_boss_death_animation():
	push_error("[BaseBoss] play_boss_death_animation: not implemented")
