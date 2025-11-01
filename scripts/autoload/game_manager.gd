## Core game state and flow control
extends Node

## Current game state
var current_phase: Constants.Phase = Constants.Phase.DAY
var current_night: int = 1
var is_paused: bool = false

## Game flags
var enable_building: bool = true
var enable_scavenging: bool = true

## References to key game objects
var lighthouse: Node2D = null
var keeper: Node2D = null

func _ready() -> void:
	# Connect to key events
	EventBus.lighthouse_destroyed.connect(_on_lighthouse_destroyed)
	EventBus.all_waves_completed.connect(_on_all_waves_completed)

## Initialize a new game
func start_new_game() -> void:
	current_night = 1
	current_phase = Constants.Phase.DAY
	ResourceManager.reset_resources()

	# Start the day phase
	EventBus.day_started.emit()

## Handle lighthouse destruction (game over)
func _on_lighthouse_destroyed() -> void:
	EventBus.game_over.emit()
	print("Game Over - Lighthouse destroyed!")

## Handle completing all waves (win condition for the night)
func _on_all_waves_completed() -> void:
	EventBus.night_ended.emit()
	print("Night %d survived!" % current_night)

## Advance to next night
func advance_to_next_night() -> void:
	current_night += 1
	current_phase = Constants.Phase.DAY
	EventBus.day_started.emit()

## Check if player has won the game (survived target nights)
func check_victory_condition(target_nights: int = 20) -> bool:
	return current_night >= target_nights

## Pause the game
func pause_game() -> void:
	is_paused = true
	get_tree().paused = true

## Resume the game
func resume_game() -> void:
	is_paused = false
	get_tree().paused = false
