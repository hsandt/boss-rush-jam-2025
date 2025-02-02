# Copied and adapted from two previous boss projects by komehara
class_name BossHealthBar
extends Control


@export var gauge_fill: TextureProgressBar


## Bound boss
var boss: BaseBoss


func _ready():
	DebugUtils.assert_member_is_set(self, gauge_fill, "gauge_fill")


func bind_to(p_boss: BaseBoss):
	boss = p_boss

	# Initial cell fill
	_refresh_view()

	boss.health.value_changed.connect(_on_boss_health_value_changed)
	boss.despawn.connect(_on_boss_despawn)


func unbind():
	boss.health.value_changed.disconnect(_on_boss_health_value_changed)
	boss.despawn.disconnect(_on_boss_despawn)
	boss = null


func _refresh_view():
	# TextureRect has a limitation where it refuses a size.x = 0 and will clamp
	# to size.x = 1 with an offset of -0.5 when the anchor_right reaches anchor_left's value
	# This would cause the gauge fill to slightly pop off the frame on the left
	# To avoid this, when health reaches 0, hide the gauge fill completely
	var health_ratio := boss.health.get_health_ratio()
	if health_ratio > 0:
		gauge_fill.visible = true
		gauge_fill.value = health_ratio * 100.0
	else:
		gauge_fill.visible = false


func _on_boss_health_value_changed(_new_value: int):
	_refresh_view()


func _on_boss_despawn():
	unbind()
