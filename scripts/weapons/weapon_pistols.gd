## Scavenger's starting weapon - Dual Pistols
## Fast fire rate, medium range, aggressive spray
extends Weapon

func _ready() -> void:
	weapon_name = "Dual Pistols"
	damage = 8
	fire_rate = 3.0  # 3 attacks per second (very fast)
	range = 120.0  # Medium range
	projectile_speed = 350.0
	projectile_count = 1

	# Use turret bullet for now (TODO: Create pistol projectile)
	projectile_scene = preload("res://scenes/structures/turret_bullet.tscn")

	super._ready()
