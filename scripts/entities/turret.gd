## Turret - auto-targeting defensive structure
extends Structure

@export var attack_damage: int = 10
@export var attack_range: float = 150.0
@export var attack_speed: float = 1.0  # attacks per second
@export var projectile_speed: float = 300.0
@export var requires_power: bool = false

var attack_cooldown: float = 1.0
var attack_timer: float = 0.0
var current_target: Node2D = null
var is_powered: bool = true

## Turret projectile scene
var bullet_scene: PackedScene = preload("res://scenes/structures/turret_bullet.tscn")

## Cached references
@onready var barrel = $Barrel  # Visual barrel that rotates

func _ready() -> void:
	structure_name = "Turret"
	max_health = 100
	costs = {
		Constants.ResourceType.WOOD: 10,
		Constants.ResourceType.METAL: 15
	}
	can_be_repaired = true

	super._ready()
	add_to_group("turrets")

	# Calculate cooldown from attack speed
	attack_cooldown = 1.0 / attack_speed

func _process(delta: float) -> void:
	# Check if powered (if power required)
	if requires_power:
		is_powered = check_nearby_generator()

	# Only operate if powered
	if not is_powered:
		return

	# Update attack timer
	attack_timer += delta

	# Find and attack targets
	if not current_target or not is_instance_valid(current_target):
		find_target()
	else:
		# Check if target still in range
		var distance = global_position.distance_to(current_target.global_position)
		if distance > attack_range:
			current_target = null
			find_target()
		else:
			# Rotate barrel toward target
			if barrel:
				var direction = current_target.global_position - global_position
				barrel.rotation = direction.angle()

			# Attack if cooldown ready
			if attack_timer >= attack_cooldown:
				shoot_at_target()
				attack_timer = 0.0

func find_target() -> void:
	"""Find nearest enemy within range"""
	var enemies = get_tree().get_nodes_in_group("enemies")
	var nearest_enemy: Node2D = null
	var nearest_distance: float = attack_range

	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue

		var distance = global_position.distance_to(enemy.global_position)
		if distance <= attack_range and distance < nearest_distance:
			nearest_enemy = enemy
			nearest_distance = distance

	current_target = nearest_enemy

func shoot_at_target() -> void:
	"""Fire projectile at current target"""
	if not current_target or not is_instance_valid(current_target):
		return

	if not bullet_scene:
		# Fallback to instant damage if no bullet scene
		if current_target.has_method("take_damage"):
			current_target.take_damage(attack_damage)
			EventBus.damage_dealt.emit(current_target, attack_damage)
		return

	# Create bullet
	var bullet = bullet_scene.instantiate()
	bullet.global_position = global_position

	# Calculate direction to target
	var direction = (current_target.global_position - global_position).normalized()

	# Initialize bullet
	if bullet.has_method("initialize"):
		bullet.initialize(direction, attack_damage, projectile_speed)

	# Add to scene
	get_parent().add_child(bullet)

	# Visual feedback
	if sprite:
		var tween = create_tween()
		tween.tween_property(sprite, "scale", Vector2(1.1, 1.1), 0.05)
		tween.tween_property(sprite, "scale", Vector2.ONE, 0.05)

func check_nearby_generator() -> bool:
	"""Check if there's a powered generator nearby"""
	var generators = get_tree().get_nodes_in_group("generators")

	for generator in generators:
		if not is_instance_valid(generator):
			continue

		if generator.has_method("is_providing_power"):
			if generator.is_providing_power():
				var distance = global_position.distance_to(generator.global_position)
				if distance <= generator.power_radius:
					return true

	return false
