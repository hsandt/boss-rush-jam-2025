class_name FXManager
extends Node


@onready var level: Level = get_tree().get_first_node_in_group(&"level")
@onready var sfx_manager: FXManager = get_tree().get_first_node_in_group(&"sfx_manager")


## Spawn one-shot FX
func spawn_fx(fx_prefab: PackedScene, spawn_position: Vector2, flip_x: bool = false,
		spawn_angle: float = 0.0, sfx: AudioStream = null) -> OneShotFX:
	var fx: OneShotFX = NodeUtils.instantiate_under_at(fx_prefab, level.fxs_parent, spawn_position)

	if flip_x:
		fx.scale.x *= -1

	# Note: rotation complementarity based on flip must done by caller
	fx.rotation = spawn_angle

	if sfx != null:
		sfx_manager.spawn_sfx(sfx)
	return fx
