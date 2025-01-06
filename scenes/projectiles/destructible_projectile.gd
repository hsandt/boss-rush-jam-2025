class_name DestructibleProjectile
extends BaseProjectile

func be_hurt_by_melee(_damage: float):
	queue_free()
