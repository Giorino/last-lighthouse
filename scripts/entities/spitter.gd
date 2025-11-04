## Spitter enemy - ranged attacker that shoots acid projectiles
extends Enemy

## Projectile to spawn
var acid_projectile_scene: PackedScene = preload("res://scenes/enemies/acid_spit.tscn")

func _ready() -> void:
	enemy_name = "Spitter"
	max_health = 30
	speed = 40.0
	attack_damage = 8
	attack_range = 150.0
	attack_cooldown = 1.5  # Slightly slower attack than crawler

	super._ready()

func perform_attack(delta: float) -> void:
	attack_timer += delta

	if attack_timer >= attack_cooldown:
		if current_target and is_instance_valid(current_target):
			# Check if still in range
			var distance = global_position.distance_to(current_target.global_position)

			if distance <= attack_range:
				# Shoot projectile instead of melee attack
				shoot_acid_projectile()
				attack_timer = 0.0

				# Visual attack feedback
				if sprite:
					var original_scale = sprite.scale
					var tween = create_tween()
					tween.tween_property(sprite, "scale", Vector2(1.2, 0.8) * original_scale.x, 0.1)
					tween.tween_property(sprite, "scale", original_scale, 0.1)
			else:
				# Out of range, return to pathfinding
				current_state = State.PATHFINDING
				find_lighthouse_target()
		else:
			# Target destroyed, return to pathfinding
			current_state = State.PATHFINDING
			find_lighthouse_target()

func shoot_acid_projectile() -> void:
	"""Spawn and fire acid projectile toward target"""
	if not acid_projectile_scene:
		print("ERROR: Acid projectile scene not loaded!")
		return

	var projectile = acid_projectile_scene.instantiate()

	# Position projectile at enemy location
	projectile.global_position = global_position

	# Calculate direction to target
	var direction = (current_target.global_position - global_position).normalized()

	# Set projectile properties
	if projectile.has_method("initialize"):
		projectile.initialize(direction, attack_damage)

	# Add to scene
	get_parent().add_child(projectile)
