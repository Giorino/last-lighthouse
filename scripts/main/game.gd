## Main game scene controller
extends Node2D

## Scene references
const RESOURCE_NODE_SCENE = preload("res://scenes/environment/resource_node.tscn")
const CRAWLER_SCENE = preload("res://scenes/enemies/crawler.tscn")

## Cached references
@onready var day_night_cycle: DayNightCycle = $DayNightCycle
@onready var hud = $HUD
@onready var lighthouse = $Lighthouse
@onready var keeper = $Keeper
@onready var camera = $Camera2D
@onready var navigation_region: NavigationRegion2D = $NavigationRegion2D
@onready var navigation_manager = $NavigationManager
@onready var wave_spawner = $WaveSpawner

func _ready() -> void:
	# Connect to game events
	EventBus.night_started.connect(_on_night_started)
	EventBus.night_ended.connect(_on_night_ended)
	EventBus.game_over.connect(_on_game_over)
	EventBus.all_waves_completed.connect(_on_all_waves_completed)

	# Set up camera to follow keeper
	if camera and keeper:
		camera.set_follow_target(keeper)

	# Initialize navigation system
	if navigation_manager and navigation_region:
		navigation_manager.initialize(navigation_region)

	# Start the game
	GameManager.start_new_game()

	# Spawn initial resource nodes
	spawn_initial_resources()

func _process(_delta: float) -> void:
	# Update HUD with current time and phase
	if day_night_cycle and hud:
		hud.update_time_display(
			day_night_cycle.get_time_remaining(),
			day_night_cycle.get_current_phase()
		)

func spawn_initial_resources() -> void:
	# Spawn some wood nodes around the map
	for i in range(3):
		var resource_node = RESOURCE_NODE_SCENE.instantiate()
		resource_node.global_position = Vector2(
			randf_range(50, 270),
			randf_range(50, 130)
		)
		resource_node.resource_type = Constants.ResourceType.WOOD
		resource_node.amount = 30
		add_child(resource_node)

	# Spawn a metal node
	var metal_node = RESOURCE_NODE_SCENE.instantiate()
	metal_node.global_position = Vector2(randf_range(50, 270), randf_range(50, 130))
	metal_node.resource_type = Constants.ResourceType.METAL
	metal_node.amount = 20
	add_child(metal_node)

func _on_night_started() -> void:
	print("=== NIGHT STARTED ===")
	# Use WaveSpawner to spawn enemies with proper composition
	if wave_spawner:
		wave_spawner.start_night(GameManager.current_night)

func _on_night_ended() -> void:
	# WaveSpawner now handles wave completion
	# This is called when night phase timer ends, but waves may still be active
	print("Night phase ended (timer), waiting for waves to complete...")

func _on_all_waves_completed() -> void:
	# Transition to next day
	if day_night_cycle:
		day_night_cycle.end_night_phase()

func _on_game_over() -> void:
	print("=== GAME OVER ===")
	# Game over screen handles displaying stats and restart logic
	# Don't automatically reload - let the player choose via the game over screen
