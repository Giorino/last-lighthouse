## Engineer's starting weapon - Wrench Throw
## High damage, melee range, spinning wrench projectile
extends Weapon

func _ready() -> void:
	weapon_name = "Wrench"
	damage = 25
	fire_rate = 0.8  # 0.8 attacks per second (slower)
	range = 80.0  # Melee range
	projectile_speed = 250.0
	projectile_count = 1

	# Use turret bullet for now (TODO: Create wrench projectile)
	projectile_scene = preload("res://scenes/structures/turret_bullet.tscn")

	super._ready()
