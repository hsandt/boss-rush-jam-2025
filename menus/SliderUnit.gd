class_name SliderUnit
extends VBoxContainer

@onready var value_label = $HBoxContainer/ValueLabel

func _ready():
	value_label.text = str($HSlider.value)

func _on_h_slider_value_changed(value):
	value_label.text = str(value)
