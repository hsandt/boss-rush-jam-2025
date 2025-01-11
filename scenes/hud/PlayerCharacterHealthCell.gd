# Copied from previous Godot project by komehara (Godot platformer boss)
class_name PlayerCharacterHealthCell
extends Control


@export var bg_fill: TextureRect
@export var fill: TextureRect
@export var frame: TextureRect


func _ready():
	DebugUtils.assert_member_is_set(self, bg_fill, "bg_fill")
	DebugUtils.assert_member_is_set(self, fill, "fill")
	DebugUtils.assert_member_is_set(self, frame, "frame")
