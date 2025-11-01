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
@onready var navigation_region: NavigationRegion2D = $NavigationRegion2D
@onready var navigation_manager = $NavigationManager

func _ready() -> void:
	# Connect to game events
	EventBus.night_started.connect(_on_night_started)
	EventBus.night_ended.connect(_on_night_ended)
	EventBus.game_over.connect(_on_game_over)
	EventBus.all_waves_completed.connect(_on_all_waves_completed)

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
	print("=== SPAWNING ENEMIES ===")
	# Simple enemy spawning for Phase 1
	# Spawn 5 crawlers for the first night
	var num_enemies = 5 + (GameManager.current_night * 2)

	for i in range(num_enemies):
		# Spawn at edges
		var spawn_pos = Vector2.ZERO
		var edge = randi() % 4

		match edge:
			0:  # Top
				spawn_pos = Vector2(randf_range(0, 320), 0)
			1:  # Right
				spawn_pos = Vector2(320, randf_range(0, 180))
			2:  # Bottom
				spawn_pos = Vector2(randf_range(0, 320), 180)
			3:  # Left
				spawn_pos = Vector2(0, randf_range(0, 180))

		# Stagger spawns
		await get_tree().create_timer(0.5).timeout

		var crawler = CRAWLER_SCENE.instantiate()
		crawler.global_position = spawn_pos
		add_child(crawler)

func _on_night_ended() -> void:
	# Check if all enemies are dead
	await get_tree().create_timer(1.0).timeout

	var remaining_enemies = get_tree().get_nodes_in_group("enemies")
	if remaining_enemies.size() == 0:
		print("All enemies defeated!")
		EventBus.all_waves_completed.emit()

func _on_all_waves_completed() -> void:
	# Transition to next day
	if day_night_cycle:
		day_night_cycle.end_night_phase()

func _on_game_over() -> void:
	print("=== GAME OVER ===")
	# For Phase 1, just print a message
	# In later phases, show game over screen
	await get_tree().create_timer(2.0).timeout
	get_tree().reload_current_scene()
