## Central lighthouse - primary objective and defensive mechanic
class_name Lighthouse
extends StaticBody2D

## Lighthouse configuration
@export var max_health: int = 500
@export var beam_fuel_cost: float = 5.0
@export var beam_stun_radius: float = 200.0

## Current state
var current_health: int = max_health
var beam_active: bool = false
var light_rotation: float = 0.0

## Cached references
@onready var light_sprite = $LightBeam
@onready var base_sprite = $BaseSprite

func _ready() -> void:
	# Apply upgrade bonuses
	max_health += GameManager.get_lighthouse_max_hp_bonus()
	current_health = max_health
	add_to_group("lighthouse")

	# Register with GameManager
	GameManager.lighthouse = self

	# Emit initial health
	EventBus.lighthouse_health_changed.emit(current_health, max_health)

func _process(delta: float) -> void:
	# Rotate light beam slowly
	light_rotation += delta * 10.0
	if light_sprite:
		light_sprite.rotation_degrees = light_rotation

	# Handle beam activation (player holds Space)
	if Input.is_action_pressed("lighthouse_beam"):
		activate_beam(delta)
	else:
		deactivate_beam()

func activate_beam(delta: float) -> void:
	# Check if enough fuel
	if ResourceManager.get_resource(Constants.ResourceType.FUEL) <= 0:
		deactivate_beam()
		return

	beam_active = true

	if light_sprite:
		light_sprite.modulate = Color.WHITE
		light_sprite.scale = Vector2(1.5, 1.5)

	# Consume fuel
	ResourceManager.spend_resource(
		Constants.ResourceType.FUEL,
		int(beam_fuel_cost * delta)
	)

	# Stun nearby enemies
	var enemies_in_range = get_enemies_in_radius(beam_stun_radius)
	for enemy in enemies_in_range:
		if enemy.has_method("apply_stun"):
			enemy.apply_stun(delta)

func deactivate_beam() -> void:
	beam_active = false

	if light_sprite:
		light_sprite.modulate = Color(1, 1, 1, 0.5)
		light_sprite.scale = Vector2.ONE

func get_enemies_in_radius(radius: float) -> Array:
	var enemies = []
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(enemy) and global_position.distance_to(enemy.global_position) <= radius:
			enemies.append(enemy)
	return enemies

func take_damage(amount: int) -> void:
	current_health -= amount
	EventBus.lighthouse_health_changed.emit(current_health, max_health)

	# Visual feedback - flash red
	if base_sprite:
		var tween = create_tween()
		tween.tween_property(base_sprite, "modulate", Color.RED, 0.1)
		tween.tween_property(base_sprite, "modulate", Color.WHITE, 0.1)

	print("Lighthouse HP: %d/%d" % [current_health, max_health])

	if current_health <= 0:
		destroy_lighthouse()

func repair(amount: int) -> void:
	current_health = min(current_health + amount, max_health)
	EventBus.lighthouse_health_changed.emit(current_health, max_health)
	print("Lighthouse repaired! HP: %d/%d" % [current_health, max_health])

func destroy_lighthouse() -> void:
	print("Lighthouse destroyed!")
	EventBus.lighthouse_destroyed.emit()

	# Dramatic destruction effect
	if base_sprite:
		var tween = create_tween()
		tween.tween_property(base_sprite, "modulate:a", 0.0, 2.0)
		await tween.finished

	queue_free()
