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

## Selected keeper for the run
var selected_keeper_id: String = "engineer"

func _ready() -> void:
	# Connect to key events
	EventBus.lighthouse_destroyed.connect(_on_lighthouse_destroyed)
	EventBus.all_waves_completed.connect(_on_all_waves_completed)

## Initialize a new game
func start_new_game() -> void:
	current_night = 1
	current_phase = Constants.Phase.DAY

	# Apply upgrade bonuses to starting resources
	apply_starting_resource_upgrades()

	# Start the day phase
	EventBus.day_started.emit()

## Apply upgrade bonuses to starting resources
func apply_starting_resource_upgrades() -> void:
	var wood_bonus = SaveManager.get_upgrade_level("starting_wood") * 10
	var metal_bonus = SaveManager.get_upgrade_level("starting_metal") * 10

	# Reset to default + bonuses
	ResourceManager.resources[Constants.ResourceType.WOOD] = 50 + wood_bonus
	ResourceManager.resources[Constants.ResourceType.METAL] = 10 + metal_bonus
	ResourceManager.resources[Constants.ResourceType.STONE] = 0
	ResourceManager.resources[Constants.ResourceType.FUEL] = 10

	print("Starting resources applied: Wood +%d, Metal +%d" % [wood_bonus, metal_bonus])

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

## Get upgrade multiplier/bonus values for gameplay
func get_lighthouse_max_hp_bonus() -> int:
	return SaveManager.get_upgrade_level("lighthouse_max_hp") * 50

func get_turret_damage_bonus() -> int:
	return SaveManager.get_upgrade_level("turret_damage") * 2

func get_turret_fire_rate_multiplier() -> float:
	# Each level reduces cooldown by 10%
	var level = SaveManager.get_upgrade_level("turret_fire_rate")
	return 1.0 - (level * 0.1)

func get_wall_health_bonus() -> int:
	return SaveManager.get_upgrade_level("wall_health") * 20

func get_build_cost_multiplier() -> float:
	# Each level reduces cost by 5%
	var level = SaveManager.get_upgrade_level("build_cost_reduction")
	return 1.0 - (level * 0.05)

func get_movement_speed_multiplier() -> float:
	# Each level increases speed by 5%
	var level = SaveManager.get_upgrade_level("movement_speed")
	return 1.0 + (level * 0.05)

func get_ability_cooldown_multiplier() -> float:
	# Each level reduces cooldown by 10%
	var level = SaveManager.get_upgrade_level("ability_cooldown")
	return 1.0 - (level * 0.1)
