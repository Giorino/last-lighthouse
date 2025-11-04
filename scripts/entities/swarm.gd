## Swarm enemy - fast, weak enemy that overwhelms by numbers
extends Enemy

func _ready() -> void:
	enemy_name = "Swarm"
	max_health = 15
	speed = 100.0
	attack_damage = 5
	attack_range = 15.0
	attack_cooldown = 0.8  # Faster attack speed to compensate for low damage
	xp_value = 3  # PHASE 5: Low XP for weak enemy (but spawns in groups)

	super._ready()

func move_toward_target(delta: float) -> void:
	# Swarm enemies are more aggressive and less cautious
	super.move_toward_target(delta)

	# Visual effect - swarm moves erratically
	if sprite and current_state == State.PATHFINDING:
		# Add slight wobble to movement for more chaotic appearance
		sprite.rotation_degrees = sin(Time.get_ticks_msec() * 0.01) * 5.0
