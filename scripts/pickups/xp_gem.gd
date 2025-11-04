## XP Gem - Collectible experience orb dropped by enemies
class_name XPGem
extends Area2D

## Configuration
@export var xp_value: int = 5
@export var magnet_range: float = 40.0  # Auto-collect range
@export var magnet_speed: float = 200.0  # Speed when attracted to player
@export var lifetime: float = 30.0  # Fades after 30 seconds

## State
var is_magnetized: bool = false
var target_player: Node2D = null
var fade_timer: float = 0.0

## Cached references
@onready var sprite = $Sprite2D
@onready var collision_shape = $CollisionShape2D

func _ready() -> void:
	add_to_group("pickups")
	add_to_group("xp_gems")

	# Connect to body entered signal for pickup
	body_entered.connect(_on_body_entered)

	# Start fade timer
	fade_timer = lifetime

func _process(delta: float) -> void:
	# Handle lifetime fade
	fade_timer -= delta
	if fade_timer <= 0:
		fade_out()
		return

	# Visual fade in last 5 seconds
	if fade_timer < 5.0:
		if sprite:
			sprite.modulate.a = fade_timer / 5.0

	# Check for player in magnet range
	if not is_magnetized:
		check_for_player()

	# Move toward player if magnetized
	if is_magnetized and target_player and is_instance_valid(target_player):
		var direction = (target_player.global_position - global_position).normalized()
		global_position += direction * magnet_speed * delta

		# Bobbing effect while moving
		if sprite:
			sprite.position.y = sin(Time.get_ticks_msec() / 100.0) * 2.0

func check_for_player() -> void:
	"""Check if player is in magnet range"""
	var keeper = get_tree().get_first_node_in_group("keeper")
	if keeper and is_instance_valid(keeper):
		var distance = global_position.distance_to(keeper.global_position)
		if distance <= magnet_range:
			is_magnetized = true
			target_player = keeper

func _on_body_entered(body: Node2D) -> void:
	"""Collect XP when player touches gem"""
	if body.is_in_group("keeper"):
		collect(body)

func collect(collector: Node2D) -> void:
	"""Give XP to player and destroy gem"""
	# Add XP to level manager
	if LevelManager:
		LevelManager.add_xp(xp_value)

	# Visual/audio feedback
	if VisualEffectsManager:
		VisualEffectsManager.spawn_hit_effect(global_position)

	# TODO: Add sound effect

	print("Collected %d XP" % xp_value)

	# Destroy gem
	queue_free()

func fade_out() -> void:
	"""Fade out and destroy when lifetime expires"""
	if sprite:
		var tween = create_tween()
		tween.tween_property(sprite, "modulate:a", 0.0, 0.5)
		await tween.finished

	queue_free()

## Initialize gem with specific XP value
func initialize(value: int) -> void:
	xp_value = value

	# Different visual based on XP value (optional)
	if sprite:
		if xp_value >= 50:  # Boss drop
			sprite.modulate = Color(1.0, 0.8, 0.0)  # Gold
			sprite.scale = Vector2(2.0, 2.0)
		elif xp_value >= 15:  # Large enemy
			sprite.modulate = Color(0.8, 0.8, 1.0)  # Blue
			sprite.scale = Vector2(1.5, 1.5)
		else:  # Regular enemy
			sprite.modulate = Color(0.5, 1.0, 0.5)  # Green
			sprite.scale = Vector2(1.0, 1.0)
