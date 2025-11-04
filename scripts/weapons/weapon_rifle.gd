## Soldier's starting weapon - Rifle
## Balanced damage, long range, military precision
extends Weapon

func _ready() -> void:
	weapon_name = "Rifle"
	damage = 15
	fire_rate = 1.5  # 1.5 attacks per second
	range = 200.0  # Long range
	projectile_speed = 400.0
	projectile_count = 1

	# Use turret bullet for now (TODO: Create rifle projectile)
	projectile_scene = preload("res://scenes/structures/turret_bullet.tscn")

	super._ready()
