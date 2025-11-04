## Level Up Screen - Shows upgrade choices when player levels up
class_name LevelUpScreen
extends CanvasLayer

## UI nodes
@onready var panel_container = $PanelContainer
@onready var level_label = $PanelContainer/VBoxContainer/LevelLabel
@onready var choices_container = $PanelContainer/VBoxContainer/ChoicesContainer

## Current upgrade options
var current_options: Array = []

## PHASE 5D: Animation state
var is_animating: bool = false

func _ready() -> void:
	# Hide by default
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS  # Continue processing even when game is paused

	# PHASE 5D: Position off-screen initially for slide-in animation
	if panel_container:
		panel_container.position.y = -300

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
	"""PHASE 5D: Create an animated button for an upgrade choice"""
	var button = Button.new()
	button.custom_minimum_size = Vector2(60, 50)

	# Set button text
	var button_text = "%s\n%s" % [option.name, option.description]
	button.text = button_text

	# Style the button for pixel art
	button.add_theme_font_size_override("font_size", 5)

	# PHASE 5D: Add custom styling
	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = Color(0.15, 0.15, 0.2, 0.9)
	normal_style.border_width_left = 2
	normal_style.border_width_right = 2
	normal_style.border_width_top = 2
	normal_style.border_width_bottom = 2
	normal_style.border_color = Color(0.5, 0.5, 0.6, 1.0)
	button.add_theme_stylebox_override("normal", normal_style)

	var hover_style = StyleBoxFlat.new()
	hover_style.bg_color = Color(0.25, 0.3, 0.4, 1.0)
	hover_style.border_width_left = 2
	hover_style.border_width_right = 2
	hover_style.border_width_top = 2
	hover_style.border_width_bottom = 2
	hover_style.border_color = Color(0.7, 0.8, 1.0, 1.0)
	button.add_theme_stylebox_override("hover", hover_style)

	# PHASE 5D: Connect hover effects
	button.mouse_entered.connect(_on_button_hover.bind(button))
	button.pressed.connect(_on_choice_selected.bind(option, button))

	# Add to container
	choices_container.add_child(button)

	# PHASE 5D: Stagger button animations
	button.modulate.a = 0.0
	button.scale = Vector2(0.8, 0.8)
	var delay = index * 0.1
	await get_tree().create_timer(delay, true, false, true).timeout  # Ignore pause

	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_parallel(true)
	tween.tween_property(button, "modulate:a", 1.0, 0.3)
	tween.tween_property(button, "scale", Vector2.ONE, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

## PHASE 5D: Button hover effect
func _on_button_hover(button: Button) -> void:
	"""Scale up button slightly on hover"""
	if AudioManager:
		AudioManager.play_ui_sound("button_click")

	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(button, "scale", Vector2(1.05, 1.05), 0.1)

func _on_choice_selected(option: Dictionary, button: Button) -> void:
	"""PHASE 5D: Handle upgrade choice selection with feedback"""
	print("Player chose: %s" % option.name)

	# PHASE 5D: Button press animation
	if button:
		var tween = create_tween()
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.tween_property(button, "scale", Vector2(1.15, 1.15), 0.1)
		tween.tween_property(button, "scale", Vector2(0.9, 0.9), 0.1)
		await tween.finished

	# PHASE 5D: Play selection sound
	if AudioManager:
		AudioManager.play_ui_sound("upgrade_selected")

	# Apply the upgrade
	if LevelManager:
		LevelManager.apply_upgrade(option)

	# Hide screen and resume game
	hide_screen()

func show_screen() -> void:
	"""PHASE 5D: Show the level-up screen with slide-in animation"""
	if is_animating:
		return

	is_animating = true
	visible = true

	# Pause the game (or slow it down)
	get_tree().paused = true

	# PHASE 5D: Slide in from top with bounce
	if panel_container:
		panel_container.position.y = -300
		panel_container.modulate.a = 0.0

		var tween = create_tween()
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)  # Work during pause
		tween.set_parallel(true)
		tween.tween_property(panel_container, "position:y", 0, 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		tween.tween_property(panel_container, "modulate:a", 1.0, 0.3)
		await tween.finished

	# PHASE 5D: Play UI sound
	if AudioManager:
		AudioManager.play_sfx("level_up")

	is_animating = false
	print("Level-up screen shown - game paused")

func hide_screen() -> void:
	"""PHASE 5D: Hide the level-up screen with slide-out animation"""
	if is_animating:
		return

	is_animating = true

	# PHASE 5D: Slide out to top with scale
	if panel_container:
		var tween = create_tween()
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)  # Work during pause
		tween.set_parallel(true)
		tween.tween_property(panel_container, "position:y", -300, 0.3).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
		tween.tween_property(panel_container, "modulate:a", 0.0, 0.25)
		tween.tween_property(panel_container, "scale", Vector2(0.9, 0.9), 0.3)
		await tween.finished

		# Reset scale
		panel_container.scale = Vector2.ONE

	visible = false

	# Resume the game
	get_tree().paused = false

	is_animating = false
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
