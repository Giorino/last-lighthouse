## Base enemy class with pathfinding and combat
class_name Enemy
extends CharacterBody2D

## Enemy configuration
@export var enemy_name: String = "Crawler"
@export var max_health: int = 50
@export var speed: float = 50.0
@export var attack_damage: int = 10
@export var attack_range: float = 20.0
@export var attack_cooldown: float = 1.0

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

## Cached references
@onready var sprite = $Sprite2D

func _ready() -> void:
	current_health = max_health
	add_to_group("enemies")
	EventBus.enemy_spawned.emit(self)

	# Find the lighthouse
	find_lighthouse_target()

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

	# Simple direct pathfinding for Phase 1
	# In Phase 2, we'll implement proper A* pathfinding around obstacles
	var direction = (current_target.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()

	# Flip sprite based on movement direction (using scale for ColorRect)
	if sprite and direction.x != 0:
		sprite.scale.x = -1 if direction.x < 0 else 1

	# Check if in attack range
	var distance_to_target = global_position.distance_to(current_target.global_position)
	if distance_to_target <= attack_range:
		current_state = State.ATTACKING

	# Check for obstacles - if we hit a structure, attack it instead
	if get_slide_collision_count() > 0:
		var collision = get_slide_collision(0)
		var collider = collision.get_collider()

		if collider and collider.is_in_group("structures"):
			current_target = collider
			current_state = State.ATTACKING

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

	# Death effect
	if sprite:
		var tween = create_tween()
		tween.tween_property(sprite, "modulate:a", 0.0, 0.3)
		tween.tween_property(sprite, "scale", Vector2(1.5, 1.5), 0.3)
		await tween.finished

	queue_free()
