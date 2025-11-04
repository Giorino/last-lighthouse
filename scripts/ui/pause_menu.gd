## Pause menu - ESC to pause/resume
extends CanvasLayer

@onready var control = $Control
@onready var resume_button = $Control/Panel/VBoxContainer/ResumeButton
@onready var settings_button = $Control/Panel/VBoxContainer/SettingsButton
@onready var quit_button = $Control/Panel/VBoxContainer/QuitButton

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS  # Process even when paused

	# Connect buttons
	if resume_button:
		resume_button.pressed.connect(_on_resume_pressed)
	if settings_button:
		settings_button.pressed.connect(_on_settings_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()

func toggle_pause() -> void:
	if get_tree().paused:
		resume_game()
	else:
		pause_game()

func pause_game() -> void:
	get_tree().paused = true
	visible = true
	print("Game paused")

func resume_game() -> void:
	get_tree().paused = false
	visible = false
	print("Game resumed")

func _on_resume_pressed() -> void:
	resume_game()

func _on_settings_pressed() -> void:
	# Hide pause menu, show settings
	control.visible = false
	var settings = get_node_or_null("../SettingsMenu")
	if settings:
		settings.show_settings()

func _on_quit_pressed() -> void:
	print("Quitting to main menu...")
	resume_game()  # Unpause first
	# TODO: Load main menu scene when it exists
	get_tree().quit()
