# Copied and adapted from previous Godot project by komehara (Godot platformer boss)
extends Control


#@export var health_cell_next_prefab: PackedScene
@export var gauge_fill: TextureProgressBar

@onready var in_game_manager: InGameManager = get_tree().get_first_node_in_group("in_game_manager")
@onready var player := in_game_manager.player


func _ready():
	# Defer setup so Health is ready
	deferred_setup.call_deferred()


func deferred_setup():
	#DebugUtils.assert_member_is_set(self, health_cell_next_prefab, "health_cell_next_prefab")
	DebugUtils.assert_member_is_set(self, gauge_fill, "gauge_fill")

	#for i in player.health.max_health:
		## The first two cells are setup in the scene
		#if i >= 2:
			## Further cells must be created on start, instantiating from prefab variant
			## using Frame Next sprite
			## (do not use Node.duplicate, it would not update references to copied child nodes:
			## https://github.com/godotengine/godot/issues/78060)
			#NodeUtils.instantiate_under(health_cell_next_prefab, self)

	# Initial cell fill
	_refresh_view()

	player.health.value_changed.connect(_on_player_character_health_value_changed)


func _refresh_view():
	var health_ratio := player.health.get_health_ratio()
	gauge_fill.value = health_ratio * 100.0
	#for i in player.health.max_health:
		#var health_cell_node := get_child(i)
		#var health_cell: PlayerCharacterHealthCell = health_cell_node
#
		## Fill cell if enough health
		#health_cell.fill.visible = player.health.current_health > i


func _on_player_character_health_value_changed(_new_value: int):
	_refresh_view()
