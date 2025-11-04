## Base enemy class with pathfinding and combat
class_name Enemy
extends CharacterBody2D

## Preloaded scenes for drops
const XP_GEM_SCENE = preload("res://scenes/pickups/xp_gem.tscn")

## Enemy configuration
@export var enemy_name: String = "Crawler"
@export var max_health: int = 50
@export var speed: float = 50.0
@export var attack_damage: int = 10
@export var attack_range: float = 20.0
@export var attack_cooldown: float = 1.0
@export var xp_value: int = 5  # XP dropped on death

## Drop chances for resources
@export var wood_drop_chance: float = 0.20  # 20%
@export var metal_drop_chance: float = 0.10  # 10%
@export var stone_drop_chance: float = 0.05  # 5%

## Current state
var current_health: int = max_health
var current_target: Node2D = null
var attack_timer: float = 0.0
var path_recalculate_timer: float = 0.0
var is_stunned: bool = false
var stun_duration: float = 0.0

## State machine
enum State { PATHFINDING, ATTACKING, STUNNED }
var current_state: State = State.PATHFINDING

## Navigation
var navigation_agent: NavigationAgent2D = null
var path_recalculation_cooldown: float = 0.5
var time_since_last_path: float = 0.0

## Cached references
@onready var sprite = $Sprite2D

func _ready() -> void:
	current_health = max_health
	add_to_group("enemies")
	EventBus.enemy_spawned.emit(self)
	
	# Setup navigation agent
	setup_navigation_agent()
	
	# Find the lighthouse
	find_lighthouse_target()

func setup_navigation_agent() -> void:
	"""Create and configure NavigationAgent2D for pathfinding"""
	navigation_agent = NavigationAgent2D.new()
	add_child(navigation_agent)
	
	# Configure navigation agent
	navigation_agent.path_desired_distance = 4.0  # How close to get to waypoints
	navigation_agent.target_desired_distance = attack_range  # How close to get to target
	navigation_agent.avoidance_enabled = true
	navigation_agent.radius = 8.0  # Collision radius for avoidance
	navigation_agent.max_speed = speed
	
	# Wait for navigation to be ready
	await get_tree().physics_frame
	
	print("%s navigation agent ready" % enemy_name)

func _physics_process(delta: float) -> void:
	match current_state:
		State.PATHFINDING:
			move_toward_target(delta)
		State.ATTACKING:
			perform_attack(delta)
		State.STUNNED:
			handle_stun(delta)

func find_lighthouse_target() -> void:
	var lighthouse = get_tree().get_first_node_in_group("lighthouse")
	if lighthouse:
		current_target = lighthouse

func move_toward_target(delta: float) -> void:
	if not current_target or not is_instance_valid(current_target):
		# Target lost, try to find lighthouse again
		find_lighthouse_target()
		return
	
	if not navigation_agent:
		# Fallback to simple pathfinding if navigation agent not ready
		simple_pathfinding()
		return
	
	# Update target position periodically
	time_since_last_path += delta
	if time_since_last_path >= path_recalculation_cooldown:
		navigation_agent.target_position = current_target.global_position
		time_since_last_path = 0.0
	
	# Check if navigation agent has reached target
	if navigation_agent.is_navigation_finished():
		# We've reached the target
		var distance_check = global_position.distance_to(current_target.global_position)
		if distance_check <= attack_range:
			current_state = State.ATTACKING
		return
	
	# Get next position along the path
	var next_path_position = navigation_agent.get_next_path_position()
	var direction = (next_path_position - global_position).normalized()
	
	# Move along the path
	velocity = direction * speed
	move_and_slide()
	
	# Flip sprite based on movement direction
	if sprite and direction.x != 0:
		sprite.scale.x = -1 if direction.x < 0 else 1
	
	# Check if in attack range of target
	var distance_to_target = global_position.distance_to(current_target.global_position)
	if distance_to_target <= attack_range:
		current_state = State.ATTACKING
	
	# Check for obstacles - if we hit a structure or lighthouse, attack it
	if get_slide_collision_count() > 0:
		var collision = get_slide_collision(0)
		var collider = collision.get_collider()

		if collider and (collider.is_in_group("structures") or collider.is_in_group("lighthouse")):
			# Check if this target is within attack range
			var target_distance = global_position.distance_to(collider.global_position)
			if target_distance <= attack_range * 2.0:  # Use 2x range for collision detection
				current_target = collider
				current_state = State.ATTACKING

func simple_pathfinding() -> void:
	"""Fallback simple pathfinding when navigation system not ready"""
	var direction = (current_target.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()
	
	if sprite and direction.x != 0:
		sprite.scale.x = -1 if direction.x < 0 else 1

func perform_attack(delta: float) -> void:
	attack_timer += delta

	if attack_timer >= attack_cooldown:
		if current_target and is_instance_valid(current_target):
			# Check if still in range
			var distance = global_position.distance_to(current_target.global_position)

			if distance <= attack_range:
				if current_target.has_method("take_damage"):
					current_target.take_damage(attack_damage)
					EventBus.damage_dealt.emit(current_target, attack_damage)

				attack_timer = 0.0

				# Visual attack feedback
				if sprite:
					var tween = create_tween()
					tween.tween_property(sprite, "scale", Vector2(1.2, 1.2), 0.1)
					tween.tween_property(sprite, "scale", Vector2.ONE, 0.1)
			else:
				# Out of range, return to pathfinding
				current_state = State.PATHFINDING
				find_lighthouse_target()
		else:
			# Target destroyed, return to pathfinding
			current_state = State.PATHFINDING
			find_lighthouse_target()

func handle_stun(delta: float) -> void:
	stun_duration -= delta

	if stun_duration <= 0:
		is_stunned = false
		current_state = State.PATHFINDING

	# Visual stun effect
	if sprite:
		sprite.modulate = Color(0.7, 0.7, 1.0)

func apply_stun(duration: float) -> void:
	if current_state != State.STUNNED:
		stun_duration = duration
		is_stunned = true
		current_state = State.STUNNED
		velocity = Vector2.ZERO

func take_damage(amount: int) -> void:
	current_health -= amount

	# PHASE 5D: Enhanced hit feedback - blood splatter
	if VisualEffectsManager:
		VisualEffectsManager.spawn_blood_splatter(global_position)  # Blood instead of generic hit
	if EventBus:
		EventBus.camera_shake.emit(0.1)  # Light shake
	if TimeScaleManager:
		TimeScaleManager.hit_pause_light()

	# Visual feedback - flash red
	if sprite:
		var tween = create_tween()
		tween.tween_property(sprite, "modulate", Color.RED, 0.1)
		tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)

	if current_health <= 0:
		die()

func die() -> void:
	EventBus.enemy_died.emit(self)
	print("%s died!" % enemy_name)

	# Spawn XP gem (always)
	spawn_xp_gem()

	# Spawn resource drops (chance-based)
	spawn_resource_drops()

	# PHASE 5D: Enhanced death effects - explosion + smoke + blood
	if VisualEffectsManager:
		VisualEffectsManager.spawn_death_explosion(global_position)
		VisualEffectsManager.spawn_smoke_puff(global_position)
		VisualEffectsManager.spawn_blood_splatter(global_position)
	if EventBus:
		EventBus.camera_shake.emit(0.3)  # Medium shake
	if TimeScaleManager:
		TimeScaleManager.hit_pause_medium()

	# Death effect
	if sprite:
		var tween = create_tween()
		tween.tween_property(sprite, "modulate:a", 0.0, 0.3)
		tween.tween_property(sprite, "scale", Vector2(1.5, 1.5), 0.3)
		await tween.finished

	queue_free()

func spawn_xp_gem() -> void:
	"""Spawn an XP gem at the enemy's position"""
	if XP_GEM_SCENE:
		var xp_gem = XP_GEM_SCENE.instantiate() as XPGem
		if xp_gem:
			xp_gem.global_position = global_position
			xp_gem.initialize(xp_value)

			# Add to world (find pickup parent or use root)
			var world = get_tree().get_first_node_in_group("world")
			if world:
				world.add_child(xp_gem)
			else:
				get_parent().add_child(xp_gem)

func spawn_resource_drops() -> void:
	"""Spawn resource drops based on chance"""
	# Wood drops (20% chance, 2-5 quantity)
	if randf() < wood_drop_chance:
		spawn_resource_pickup(Constants.ResourceType.WOOD, randi_range(2, 5))

	# Metal drops (10% chance, 1-3 quantity)
	if randf() < metal_drop_chance:
		spawn_resource_pickup(Constants.ResourceType.METAL, randi_range(1, 3))

	# Stone drops (5% chance, 1-2 quantity)
	if randf() < stone_drop_chance:
		spawn_resource_pickup(Constants.ResourceType.STONE, randi_range(1, 2))

func spawn_resource_pickup(resource_type: Constants.ResourceType, amount: int) -> void:
	"""Spawn a resource pickup on the ground"""
	# TODO: Create resource pickup scene/script
	# For now, just add directly to ResourceManager
	if ResourceManager:
		match resource_type:
			Constants.ResourceType.WOOD:
				ResourceManager.add_resource(resource_type, amount)
				print("Dropped %d wood" % amount)
			Constants.ResourceType.METAL:
				ResourceManager.add_resource(resource_type, amount)
				print("Dropped %d metal" % amount)
			Constants.ResourceType.STONE:
				ResourceManager.add_resource(resource_type, amount)
				print("Dropped %d stone" % amount)

	# TODO: Phase 5C - Create physical resource pickup that player must collect
	# (Similar to XP gems, but for resources)
