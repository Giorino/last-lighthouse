## Game Over Screen - Shows run stats and allows retry
extends CanvasLayer

@onready var control = $Control
@onready var title_label = $Control/Panel/VBoxContainer/Title
@onready var night_label = $Control/Panel/VBoxContainer/Stats/NightLabel
@onready var enemies_label = $Control/Panel/VBoxContainer/Stats/EnemiesLabel
@onready var resources_label = $Control/Panel/VBoxContainer/Stats/ResourcesLabel
@onready var tokens_label = $Control/Panel/VBoxContainer/Stats/TokensLabel
@onready var retry_button = $Control/Panel/VBoxContainer/Buttons/RetryButton
@onready var quit_button = $Control/Panel/VBoxContainer/Buttons/QuitButton

var night_reached: int = 0
var enemies_killed: int = 0
var resources_gathered: int = 0
var tokens_earned: int = 0

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS  # Process even when paused

	# Connect to game over signal
	EventBus.game_over.connect(_on_game_over)
	EventBus.enemy_died.connect(_on_enemy_died)

	# Connect buttons
	if retry_button:
		retry_button.pressed.connect(_on_retry_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)

func _on_game_over() -> void:
	"""Called when the game ends"""
	var stats = {
		"night": GameManager.current_night,
		"enemies_killed": enemies_killed,
		"resources_gathered": 0  # Not tracked for now
	}
	show_game_over(stats)

func _on_enemy_died(_enemy: Node2D) -> void:
	"""Track enemy kills"""
	enemies_killed += 1

func show_game_over(stats: Dictionary) -> void:
	"""Display the game over screen with run stats"""
	night_reached = stats.get("night", 0)
	enemies_killed = stats.get("enemies_killed", 0)
	resources_gathered = stats.get("resources_gathered", 0)

	# Calculate tokens earned (1 per night + 1 per 10 enemies)
	tokens_earned = night_reached + int(enemies_killed / 10)

	# Update labels
	if night_label:
		night_label.text = "Night Reached: %d" % night_reached
	if enemies_label:
		enemies_label.text = "Enemies Killed: %d" % enemies_killed
	if resources_label:
		resources_label.text = "Resources Gathered: %d" % resources_gathered
	if tokens_label:
		tokens_label.text = "Keeper Tokens: +%d" % tokens_earned

	# Update SaveManager
	if SaveManager:
		SaveManager.update_run_stats(night_reached, enemies_killed, resources_gathered)
		SaveManager.add_meta_currency(tokens_earned)

	# Show screen and pause game
	visible = true
	get_tree().paused = true

	print("=== GAME OVER ===")
	print("Night: %d | Enemies: %d | Resources: %d | Tokens: +%d" % [
		night_reached, enemies_killed, resources_gathered, tokens_earned
	])

func _on_retry_pressed() -> void:
	print("Retrying...")
	# Unpause before reloading
	get_tree().paused = false
	# Reload the game scene
	get_tree().reload_current_scene()

func _on_quit_pressed() -> void:
	print("Quitting to main menu...")
	# TODO: Load main menu when it exists
	get_tree().quit()
