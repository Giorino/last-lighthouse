## Level Up Screen - Shows upgrade choices when player levels up
class_name LevelUpScreen
extends CanvasLayer

## UI nodes
@onready var panel_container = $PanelContainer
@onready var level_label = $PanelContainer/VBoxContainer/LevelLabel
@onready var choices_container = $PanelContainer/VBoxContainer/ChoicesContainer

## Current upgrade options
var current_options: Array = []

func _ready() -> void:
	# Hide by default
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS  # Continue processing even when game is paused

	# Connect to LevelManager signals
	if LevelManager:
		LevelManager.level_up_choice_ready.connect(_on_level_up_choices_ready)

func _on_level_up_choices_ready(options: Array) -> void:
	"""Display level-up choices and pause the game"""
	current_options = options

	# Update level label
	if level_label:
		level_label.text = "LEVEL UP! (Level %d)" % LevelManager.current_level

	# Clear previous choices
	if choices_container:
		for child in choices_container.get_children():
			child.queue_free()

	# Create choice buttons
	for i in range(options.size()):
		var option = options[i]
		create_choice_button(option, i)

	# Show the screen and pause the game
	show_screen()

func create_choice_button(option: Dictionary, index: int) -> void:
	"""Create a button for an upgrade choice"""
	# For now, create simple buttons (will be replaced with fancy buttons later)
	var button = Button.new()
	button.custom_minimum_size = Vector2(90, 60)

	# Set button text
	var button_text = "%s\n%s" % [option.name, option.description]
	button.text = button_text

	# Style the button for pixel art
	button.add_theme_font_size_override("font_size", 8)

	# Connect button press
	button.pressed.connect(_on_choice_selected.bind(option))

	# Add to container
	choices_container.add_child(button)

func _on_choice_selected(option: Dictionary) -> void:
	"""Handle upgrade choice selection"""
	print("Player chose: %s" % option.name)

	# Apply the upgrade
	if LevelManager:
		LevelManager.apply_upgrade(option)

	# Hide screen and resume game
	hide_screen()

func show_screen() -> void:
	"""Show the level-up screen and pause the game"""
	visible = true

	# Pause the game (or slow it down)
	get_tree().paused = true

	print("Level-up screen shown - game paused")

func hide_screen() -> void:
	"""Hide the level-up screen and resume the game"""
	visible = false

	# Resume the game
	get_tree().paused = false

	print("Level-up screen hidden - game resumed")

## Alternative: Use time scale instead of full pause
func show_screen_with_slow_mo() -> void:
	"""Alternative implementation using time scale"""
	visible = true
	if TimeScaleManager:
		TimeScaleManager.set_time_scale(0.1, 999.0)  # Slow to 10% speed

func hide_screen_with_slow_mo() -> void:
	"""Alternative implementation using time scale"""
	visible = false
	if TimeScaleManager:
		TimeScaleManager.set_time_scale(1.0, 0.0)  # Resume normal speed
