## Main Menu - Entry point for the game
extends Control

@onready var title_label = $CenterContainer/VBoxContainer/TitleLabel
@onready var new_run_button = $CenterContainer/VBoxContainer/ButtonContainer/NewRunButton
@onready var upgrades_button = $CenterContainer/VBoxContainer/ButtonContainer/UpgradesButton
@onready var settings_button = $CenterContainer/VBoxContainer/ButtonContainer/SettingsButton
@onready var quit_button = $CenterContainer/VBoxContainer/ButtonContainer/QuitButton
@onready var stats_label = $StatsContainer/StatsLabel

func _ready() -> void:
	# Connect buttons
	if new_run_button:
		new_run_button.pressed.connect(_on_new_run_pressed)
	if upgrades_button:
		upgrades_button.pressed.connect(_on_upgrades_pressed)
	if settings_button:
		settings_button.pressed.connect(_on_settings_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)

	# Update stats display
	update_stats_display()

func update_stats_display() -> void:
	"""Display player stats and tokens"""
	if not stats_label:
		return

	var tokens = SaveManager.get_meta_currency()
	var highest_night = SaveManager.save_data.highest_night_reached
	var total_runs = SaveManager.save_data.total_runs

	stats_label.text = "Keeper Tokens: %d\nHighest Night: %d\nTotal Runs: %d" % [
		tokens, highest_night, total_runs
	]

func _on_new_run_pressed() -> void:
	print("Starting new run...")
	# Load keeper selection screen
	get_tree().change_scene_to_file("res://scenes/ui/keeper_selection.tscn")

func _on_upgrades_pressed() -> void:
	print("Opening upgrade shop...")
	get_tree().change_scene_to_file("res://scenes/ui/upgrade_shop.tscn")

func _on_settings_pressed() -> void:
	print("Opening settings...")
	# Settings menu already exists, we can navigate to it
	# For now, just toggle the existing settings menu
	var settings_menu = get_node_or_null("../SettingsMenu")
	if settings_menu:
		settings_menu.visible = true

func _on_quit_pressed() -> void:
	print("Quitting game...")
	get_tree().quit()
