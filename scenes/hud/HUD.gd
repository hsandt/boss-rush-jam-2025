class_name HUD
extends CanvasLayer


@export var boss_health_bar: BossHealthBar


func _ready():
	DebugUtils.assert_member_is_set(self, boss_health_bar, "boss_health_bar")

	if not boss_health_bar.boss:
		boss_health_bar.visible = false


func bind_and_show_boss_health_bar(boss: BaseBoss):
	boss_health_bar.bind_to(boss)
	boss_health_bar.visible = true
