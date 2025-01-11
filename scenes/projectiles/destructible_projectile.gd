class_name DestructibleProjectile
extends BaseProjectile


@export var projectile_attack_damage := 1.0

@onready var projectile_hit_box: Area2D = $HitBoxArea2D


func _ready():
	projectile_hit_box.area_entered.connect(_on_projectile_hit_box_area_entered)

func be_hurt_by_melee(_damage: float):
	queue_free()


func _on_projectile_hit_box_area_entered(area: Area2D):
	var player_hurt_box := area as PlayerHurtBox
	if player_hurt_box:
		player_hurt_box.be_hurt_by_projectile(projectile_attack_damage)
		queue_free()
