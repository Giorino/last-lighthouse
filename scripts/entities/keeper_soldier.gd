## Soldier Keeper - Combat specialist with weapon bonuses
extends Keeper

func _ready() -> void:
	keeper_name = "Soldier"
	max_health = 120  # +20 HP
	speed = 100.0  # Standard speed

	super._ready()

	print("Soldier keeper ready - Combat specialist")

## Soldier has higher combat effectiveness
func get_damage_multiplier() -> float:
	return 1.5  # 50% more damage

## Soldier ability: "Rally" - Boost all turrets' attack speed temporarily
func use_special_ability() -> void:
	print("SOLDIER ABILITY: Rally!")

	# Get all turrets
	var turrets = get_tree().get_nodes_in_group("turrets")

	if turrets.size() == 0:
		print("No turrets to rally!")
		return

	# Apply 2x attack speed buff for 10 seconds
	for turret in turrets:
		if turret.has_method("apply_buff"):
			turret.apply_buff(2.0, 10.0)

	print("Rallied %d turrets! +100%% attack speed for 10s" % turrets.size())

## Add soldier's starting weapon - Rifle
func add_starting_weapon() -> void:
	var rifle = preload("res://scripts/weapons/weapon_rifle.gd").new()
	if weapon_manager:
		weapon_manager.add_weapon(rifle)
