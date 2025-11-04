## Base class for all weapons - Auto-aim combat system
class_name Weapon
extends Node2D

## Weapon configuration
@export var weapon_name: String = "Weapon"
@export var damage: int = 10
@export var fire_rate: float = 1.0  # attacks per second
@export var range: float = 150.0
@export var projectile_speed: float = 300.0
@export var projectile_count: int = 1  # Can shoot multiple projectiles
@export var projectile_scene: PackedScene

## Internal state
var cooldown_timer: float = 0.0
var owner_keeper: Node2D = null

func _ready() -> void:
	# Weapon is managed by WeaponManager, no need for process here
	set_process(false)

## Called by WeaponManager each frame
func try_fire(delta: float) -> void:
	# Update cooldown
	cooldown_timer -= delta

	if cooldown_timer <= 0:
		var target = find_nearest_enemy()
		if target:
			fire_at_target(target)
			cooldown_timer = 1.0 / fire_rate

## Find nearest enemy within range
func find_nearest_enemy() -> Node2D:
	if not owner_keeper:
		return null

	var enemies = get_tree().get_nodes_in_group("enemies")
	var nearest_enemy: Node2D = null
	var nearest_distance: float = range

	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue

		var distance = owner_keeper.global_position.distance_to(enemy.global_position)
		if distance <= range and distance < nearest_distance:
			nearest_enemy = enemy
			nearest_distance = distance

	return nearest_enemy

## Fire projectile(s) at target
func fire_at_target(target: Node2D) -> void:
	if not projectile_scene or not owner_keeper:
		return

	# Fire multiple projectiles if projectile_count > 1
	for i in projectile_count:
		var projectile = projectile_scene.instantiate()
		projectile.global_position = owner_keeper.global_position

		# Calculate direction to target
		var direction = (target.global_position - owner_keeper.global_position).normalized()

		# Add slight spread for multiple projectiles
		if projectile_count > 1:
			var spread_angle = (i - (projectile_count - 1) / 2.0) * 0.15  # 0.15 radians spread
			direction = direction.rotated(spread_angle)

		# Initialize projectile
		if projectile.has_method("initialize"):
			projectile.initialize(direction, damage, projectile_speed)

		# Add to scene
		get_tree().current_scene.add_child(projectile)

	# Visual/audio feedback
	on_fire()

## Override in subclasses for weapon-specific effects
func on_fire() -> void:
	# Muzzle flash, sound effect, etc.
	if VisualEffectsManager:
		var angle = 0
		if owner_keeper:
			var mouse_pos = get_global_mouse_position()
			var direction = (mouse_pos - owner_keeper.global_position).normalized()
			angle = rad_to_deg(direction.angle())
		VisualEffectsManager.spawn_muzzle_flash(owner_keeper.global_position if owner_keeper else global_position, angle)

## Get weapon stats (for UI display)
func get_stats() -> Dictionary:
	return {
		"name": weapon_name,
		"damage": damage,
		"fire_rate": fire_rate,
		"range": range,
		"projectile_count": projectile_count
	}

## Apply upgrade to weapon
func apply_upgrade(upgrade_type: String, value: float) -> void:
	match upgrade_type:
		"damage":
			damage = int(damage * value)
		"fire_rate":
			fire_rate *= value
		"range":
			range *= value
		"projectile_count":
			projectile_count += int(value)
