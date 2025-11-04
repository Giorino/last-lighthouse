## Wave Spawner - manages enemy waves with composition logic
extends Node

## Enemy scenes
const CRAWLER_SCENE = preload("res://scenes/enemies/crawler.tscn")
const SPITTER_SCENE = preload("res://scenes/enemies/spitter.tscn")
const BRUTE_SCENE = preload("res://scenes/enemies/brute.tscn")
const SWARM_SCENE = preload("res://scenes/enemies/swarm.tscn")

## Wave state
var current_night: int = 1
var current_wave: int = 0
var total_waves: int = 1
var enemies_remaining: int = 0
var is_spawning: bool = false
var all_waves_complete: bool = false

## Spawn points (edges of map)
var spawn_edges: Array = [
	Vector2(160, 0),      # Top center
	Vector2(320, 90),     # Right center
	Vector2(160, 180),    # Bottom center
	Vector2(0, 90),       # Left center
	Vector2(80, 0),       # Top left
	Vector2(240, 0),      # Top right
	Vector2(320, 45),     # Right top
	Vector2(320, 135)     # Right bottom
]

func start_night(night_number: int) -> void:
	"""Start spawning waves for the given night"""
	current_night = night_number
	current_wave = 0
	all_waves_complete = false
	total_waves = calculate_total_waves(night_number)

	print("=== NIGHT %d STARTED ===" % night_number)
	print("Total waves: %d" % total_waves)

	# Start first wave after a short delay
	await get_tree().create_timer(2.0).timeout
	spawn_next_wave()

func calculate_total_waves(night: int) -> int:
	"""Calculate number of waves based on night number"""
	# 1 wave per 5 nights, minimum 1
	return max(1, ceili(night / 5.0))

func spawn_next_wave() -> void:
	"""Spawn the next wave of enemies"""
	if current_wave >= total_waves:
		print("All waves spawned for night %d" % current_night)
		return

	current_wave += 1
	is_spawning = true

	print("=== WAVE %d/%d ===" % [current_wave, total_waves])
	EventBus.wave_started.emit(current_wave, total_waves)

	# Calculate enemy budget for this wave
	var enemy_budget = calculate_enemy_budget(current_night, current_wave)

	# Generate enemy composition
	var composition = generate_enemy_composition(current_night, enemy_budget)

	# Spawn enemies
	await spawn_enemies(composition)

	is_spawning = false
	print("Wave %d spawning complete. Enemies remaining: %d" % [current_wave, enemies_remaining])

func calculate_enemy_budget(night: int, wave: int) -> int:
	"""Calculate the enemy budget for this wave"""
	# Base budget increases with night number
	var base_budget = night * 10

	# Later waves in the same night have slightly higher budgets
	var wave_multiplier = 1.0 + ((wave - 1) * 0.2)

	return int(base_budget * wave_multiplier)

func generate_enemy_composition(night: int, budget: int) -> Dictionary:
	"""Generate enemy composition based on night number and budget"""
	var composition = {}

	# Enemy costs
	const CRAWLER_COST = 5
	const SPITTER_COST = 8
	const BRUTE_COST = 20
	const SWARM_COST = 2

	# Nights 1-5: Only crawlers
	if night <= 5:
		composition["crawler"] = int(budget / CRAWLER_COST)

	# Nights 6-10: Crawlers + Spitters
	elif night <= 10:
		var spitter_budget = int(budget * 0.3)
		var crawler_budget = budget - spitter_budget

		composition["crawler"] = int(crawler_budget / CRAWLER_COST)
		composition["spitter"] = int(spitter_budget / SPITTER_COST)

	# Nights 11-15: Mixed with Brutes
	elif night <= 15:
		var brute_budget = int(budget * 0.2)
		var spitter_budget = int(budget * 0.3)
		var crawler_budget = budget - brute_budget - spitter_budget

		composition["crawler"] = int(crawler_budget / CRAWLER_COST)
		composition["spitter"] = int(spitter_budget / SPITTER_COST)
		composition["brute"] = int(brute_budget / BRUTE_COST)

	# Nights 16-20: Add swarms
	elif night <= 20:
		var swarm_budget = int(budget * 0.2)
		var brute_budget = int(budget * 0.2)
		var spitter_budget = int(budget * 0.3)
		var crawler_budget = budget - swarm_budget - brute_budget - spitter_budget

		composition["crawler"] = int(crawler_budget / CRAWLER_COST)
		composition["spitter"] = int(spitter_budget / SPITTER_COST)
		composition["brute"] = int(brute_budget / BRUTE_COST)
		composition["swarm"] = int(swarm_budget / SWARM_COST)

	# Nights 21+: All enemy types, heavier focus on dangerous enemies
	else:
		var swarm_budget = int(budget * 0.25)
		var brute_budget = int(budget * 0.25)
		var spitter_budget = int(budget * 0.3)
		var crawler_budget = budget - swarm_budget - brute_budget - spitter_budget

		composition["crawler"] = int(crawler_budget / CRAWLER_COST)
		composition["spitter"] = int(spitter_budget / SPITTER_COST)
		composition["brute"] = int(brute_budget / BRUTE_COST)
		composition["swarm"] = int(swarm_budget / SWARM_COST)

	# Print composition for debugging
	print("Enemy composition (budget %d):" % budget)
	for enemy_type in composition:
		if composition[enemy_type] > 0:
			print("  - %s: %d" % [enemy_type.capitalize(), composition[enemy_type]])

	return composition

func spawn_enemies(composition: Dictionary) -> void:
	"""Spawn enemies based on composition dictionary"""
	var total_enemies = 0

	# Count total enemies
	for enemy_type in composition:
		total_enemies += composition[enemy_type]

	enemies_remaining += total_enemies

	# Spawn each enemy type
	for enemy_type in composition:
		var count = composition[enemy_type]

		for i in range(count):
			# Get enemy scene
			var enemy_scene: PackedScene = null
			match enemy_type:
				"crawler":
					enemy_scene = CRAWLER_SCENE
				"spitter":
					enemy_scene = SPITTER_SCENE
				"brute":
					enemy_scene = BRUTE_SCENE
				"swarm":
					enemy_scene = SWARM_SCENE

			if not enemy_scene:
				print("ERROR: Unknown enemy type: %s" % enemy_type)
				continue

			# Pick random spawn point
			var spawn_pos = spawn_edges.pick_random()

			# Add some randomness to spawn position
			spawn_pos += Vector2(
				randf_range(-20, 20),
				randf_range(-20, 20)
			)

			# Instantiate enemy
			var enemy = enemy_scene.instantiate()
			enemy.global_position = spawn_pos

			# Connect to enemy death
			enemy.tree_exited.connect(_on_enemy_died)

			# Add to scene (parent node)
			get_parent().call_deferred("add_child", enemy)

			# Stagger spawns
			await get_tree().create_timer(0.3).timeout

	print("Spawned %d enemies for wave %d" % [total_enemies, current_wave])

func _on_enemy_died() -> void:
	"""Called when an enemy dies"""
	enemies_remaining = max(0, enemies_remaining - 1)

	print("Enemy died. Remaining: %d" % enemies_remaining)

	# Check if wave is complete
	if enemies_remaining <= 0 and not is_spawning:
		_on_wave_completed()

func _on_wave_completed() -> void:
	"""Called when a wave is completed"""
	print("=== WAVE %d COMPLETED ===" % current_wave)
	EventBus.wave_completed.emit(current_wave)

	# Check if all waves are complete
	if current_wave >= total_waves:
		_on_all_waves_completed()
	else:
		# Spawn next wave after delay
		print("Next wave in 15 seconds...")
		await get_tree().create_timer(15.0).timeout
		spawn_next_wave()

func _on_all_waves_completed() -> void:
	"""Called when all waves for the night are completed"""
	all_waves_complete = true
	print("=== ALL WAVES COMPLETED FOR NIGHT %d ===" % current_night)
	EventBus.all_waves_completed.emit()

func are_all_waves_complete() -> bool:
	"""Check if all waves are complete"""
	return all_waves_complete and enemies_remaining <= 0
