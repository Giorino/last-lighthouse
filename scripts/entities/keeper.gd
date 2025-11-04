## Base keeper (player) class with movement and basic combat
class_name Keeper
extends CharacterBody2D

## Keeper configuration
@export var keeper_name: String = "Engineer"
@export var max_health: int = 100
@export var speed: float = 100.0

## Current state
var current_health: int = max_health
var is_dead: bool = false  # Prevent multiple death calls
var is_gathering: bool = false
var is_repairing: bool = false
var repair_target: Structure = null
var repair_progress: float = 0.0
var repair_time: float = 2.0  # Time to complete repair

## Ability system
@export var ability_cooldown: float = 30.0  # 30 second cooldown
var ability_timer: float = 0.0

## Weapon system (Phase 5)
var weapon_manager: WeaponManager = null

## Cached references
@onready var sprite = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	current_health = max_health
	add_to_group("keeper")

	# Apply upgrade bonuses
	speed *= GameManager.get_movement_speed_multiplier()
	ability_cooldown *= GameManager.get_ability_cooldown_multiplier()

	# Create weapon manager
	weapon_manager = WeaponManager.new()
	add_child(weapon_manager)

	# Add starting weapon (override in subclasses)
	add_starting_weapon()

	# Register with GameManager
	GameManager.keeper = self

	# DEBUG: Log initial state
	print("=== KEEPER INITIALIZED: %d/%d HP at position %s ===" % [current_health, max_health, global_position])

func _physics_process(delta: float) -> void:
	# Don't move while gathering or repairing
	if is_gathering or is_repairing:
		velocity = Vector2.ZERO
		_process_repair(delta)
		return

	# Get input direction
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	# Apply movement
	if input_dir != Vector2.ZERO:
		velocity = input_dir.normalized() * speed
	else:
		velocity = Vector2.ZERO

	move_and_slide()

	# Flip sprite based on movement direction (using scale for ColorRect)
	if input_dir.x != 0 and sprite:
		sprite.scale.x = -1 if input_dir.x < 0 else 1

func _process(delta: float) -> void:
	# Update ability cooldown
	if ability_timer < ability_cooldown:
		ability_timer += delta

	# Handle repair input
	if Input.is_action_pressed("repair"):
		if not is_repairing:
			attempt_start_repair()
	elif is_repairing:
		cancel_repair()

func _input(event: InputEvent) -> void:
	# Handle ability input (F key)
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F:
			if ability_timer >= ability_cooldown:
				use_special_ability()
				ability_timer = 0.0
			else:
				var time_left = ability_cooldown - ability_timer
				print("Ability on cooldown: %.1fs remaining" % time_left)

func _unhandled_input(_event: InputEvent) -> void:
	# Shooting will be added later when we have projectiles
	pass

func attempt_start_repair() -> void:
	"""Try to start repairing a nearby damaged structure"""
	# Find damaged structures within range
	var nearby_structures = get_tree().get_nodes_in_group("structures")
	var repair_range = 30.0

	for structure in nearby_structures:
		if not is_instance_valid(structure):
			continue

		# Check if structure is damaged and can be repaired
		if not structure.can_be_repaired:
			continue

		if structure.current_health >= structure.max_health:
			continue

		# Check distance
		var distance = global_position.distance_to(structure.global_position)
		if distance <= repair_range:
			# Check if we can afford repair costs
			var repair_costs = calculate_repair_costs(structure)
			if ResourceManager.can_afford(repair_costs):
				start_repair(structure)
				return
			else:
				print("Not enough resources to repair %s" % structure.structure_name)
				return

	print("No damaged structures nearby to repair")

func calculate_repair_costs(structure: Structure) -> Dictionary:
	"""Calculate repair costs (50% of original cost)"""
	var repair_costs = {}
	for resource_type in structure.costs:
		repair_costs[resource_type] = ceili(structure.costs[resource_type] * 0.5)
	return repair_costs

func start_repair(structure: Structure) -> void:
	"""Start repairing a structure"""
	is_repairing = true
	repair_target = structure
	repair_progress = 0.0

	print("Started repairing %s" % structure.structure_name)

func _process_repair(delta: float) -> void:
	"""Process repair progress"""
	if not is_repairing or not repair_target:
		return

	# Check if target is still valid
	if not is_instance_valid(repair_target):
		cancel_repair()
		return

	# Check if structure is already at full health
	if repair_target.current_health >= repair_target.max_health:
		complete_repair()
		return

	# Check if still in range
	var distance = global_position.distance_to(repair_target.global_position)
	if distance > 30.0:
		cancel_repair()
		print("Moved too far from repair target")
		return

	# Update progress
	repair_progress += delta

	# Visual feedback (pulse sprite)
	if sprite:
		var pulse = 0.8 + (sin(repair_progress * 10) * 0.2)
		sprite.modulate = Color(pulse, 1.0, pulse)

	# Check if repair is complete
	if repair_progress >= repair_time:
		complete_repair()

func complete_repair() -> void:
	"""Complete the repair and spend resources"""
	if not repair_target or not is_instance_valid(repair_target):
		cancel_repair()
		return

	# Calculate and spend repair costs
	var repair_costs = calculate_repair_costs(repair_target)

	# Double-check we can afford it
	if not ResourceManager.can_afford(repair_costs):
		print("Cannot afford repair (resources changed)")
		cancel_repair()
		return

	# Spend resources
	for resource_type in repair_costs:
		ResourceManager.spend_resources({resource_type: repair_costs[resource_type]})

	# Repair structure to full health
	var heal_amount = repair_target.max_health - repair_target.current_health
	repair_target.repair(heal_amount)

	print("Repaired %s to full health!" % repair_target.structure_name)

	# Reset repair state
	is_repairing = false
	repair_target = null
	repair_progress = 0.0

	# Reset sprite modulation
	if sprite:
		sprite.modulate = Color.WHITE

func cancel_repair() -> void:
	"""Cancel ongoing repair"""
	is_repairing = false
	repair_target = null
	repair_progress = 0.0

	# Reset sprite modulation
	if sprite:
		sprite.modulate = Color.WHITE

func take_damage(amount: int) -> void:
	if is_dead:
		return  # Already dead, ignore further damage

	current_health -= amount
	print("[%d ms] Keeper took %d damage! HP: %d/%d" % [
		Time.get_ticks_msec(),
		amount,
		current_health,
		max_health
	])

	# Flash red for feedback
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color.RED, 0.1)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)

	if current_health <= 0:
		die()

func die() -> void:
	if is_dead:
		return  # Already dead, prevent multiple calls

	is_dead = true
	print("Keeper died!")

	# Disable collision immediately to prevent further damage
	if collision_shape:
		collision_shape.set_deferred("disabled", true)

	# Trigger game over
	EventBus.game_over.emit()

	# Visual death effect
	if sprite:
		var tween = create_tween()
		tween.tween_property(sprite, "modulate:a", 0.0, 0.5)
		tween.tween_property(sprite, "scale", Vector2(1.5, 1.5), 0.5)
		await tween.finished

	queue_free()

func heal(amount: int) -> void:
	current_health = min(current_health + amount, max_health)

## Special ability (override in subclasses)
func use_special_ability() -> void:
	print("%s special ability activated! (Base keeper has no special ability)" % keeper_name)
	# Base implementation does nothing - subclasses override this
	# Soldier: Rally (boost turrets)
	# Scavenger: Sixth Sense (reveal resources)
	# Medic: Emergency Heal (restore lighthouse HP)

## Multiplier methods (for keeper bonuses)
func get_damage_multiplier() -> float:
	return 1.0

func get_gather_speed_multiplier() -> float:
	return 1.0

func get_resource_multiplier() -> float:
	return 1.0

func get_repair_cost_multiplier() -> float:
	return 1.0

## Add starting weapon (override in subclasses)
func add_starting_weapon() -> void:
	# Engineer (base keeper) gets wrench
	if keeper_name == "Engineer":
		var wrench = preload("res://scripts/weapons/weapon_wrench.gd").new()
		if weapon_manager:
			weapon_manager.add_weapon(wrench)
