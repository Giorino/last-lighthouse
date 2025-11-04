## Brute enemy - heavy tank with high HP and damage
extends Enemy

## Brute-specific properties
@export var structure_damage_multiplier: float = 1.5  # Deals extra damage to structures

func _ready() -> void:
	enemy_name = "Brute"
	max_health = 200
	speed = 30.0
	attack_damage = 25
	attack_range = 25.0
	attack_cooldown = 1.5  # Slower attack, but hits harder

	super._ready()

func perform_attack(delta: float) -> void:
	attack_timer += delta

	if attack_timer >= attack_cooldown:
		if current_target and is_instance_valid(current_target):
			# Check if still in range
			var distance = global_position.distance_to(current_target.global_position)

			if distance <= attack_range:
				if current_target.has_method("take_damage"):
					# Calculate damage (bonus against structures)
					var final_damage = attack_damage
					if current_target.is_in_group("structures"):
						final_damage = int(attack_damage * structure_damage_multiplier)

					current_target.take_damage(final_damage)
					EventBus.damage_dealt.emit(current_target, final_damage)

				attack_timer = 0.0

				# Heavy attack visual feedback
				if sprite:
					var tween = create_tween()
					tween.tween_property(sprite, "scale", Vector2(1.3, 0.9), 0.15)
					tween.tween_property(sprite, "scale", Vector2.ONE, 0.15)
			else:
				# Out of range, return to pathfinding
				current_state = State.PATHFINDING
				find_lighthouse_target()
		else:
			# Target destroyed, return to pathfinding
			current_state = State.PATHFINDING
			find_lighthouse_target()
