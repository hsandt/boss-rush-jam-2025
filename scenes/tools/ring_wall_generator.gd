@tool
extends Node2D

## StaticBody2D to act as a ring wall segment
@export var wall_segment_scene:PackedScene
@export var wall_radius := 725.0
@export var angle_step := 0.062
## Used as a button to create ring wall
@export var create := false:
	set(value):
		if value:
			delete_segments()
			create_segments()
## Used as a button to delete ring wall
@export var delete := false:
	set(value):
		if value:
			delete_segments()

func _ready():
	if not Engine.is_editor_hint():
		# invoke ring wall creation
		create = true

## delete all children
func delete_segments():
	for wall_axis in get_children():
		wall_axis.queue_free()

## crate ring wall
func create_segments():
	var ia = 0.0
	while ia < TAU:
		var wall_axis = Node2D.new()
		var wall_segment = wall_segment_scene.instantiate()
		wall_segment.position.x = wall_radius
		wall_axis.add_child(wall_segment)
		wall_axis.rotation = ia
		add_child(wall_axis)
		ia += angle_step
