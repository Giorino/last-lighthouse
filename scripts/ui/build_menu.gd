## Build menu UI - shows available structures and their costs
extends Control

func _ready() -> void:
	# Initially hidden, BuildSystem will show/hide us
	visible = false
