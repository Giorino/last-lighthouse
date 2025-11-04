## Level Manager - Handles in-run XP and leveling system (Phase 5)
extends Node

## Current run stats
var current_level: int = 1
var current_xp: int = 0
var xp_to_next_level: int = 10

## Leveling formula constants
const BASE_XP: int = 10
const XP_EXPONENT: float = 1.5

## Signals
signal xp_gained(amount: int, total: int)
signal leveled_up(new_level: int)
signal level_up_choice_ready(options: Array)

func _ready() -> void:
	print("LevelManager initialized")

## Add XP and check for level up
func add_xp(amount: int) -> void:
	current_xp += amount
	xp_gained.emit(amount, current_xp)

	print("Gained %d XP (Total: %d / %d)" % [amount, current_xp, xp_to_next_level])

	# Check for level up
	while current_xp >= xp_to_next_level:
		level_up()

## Level up the player
func level_up() -> void:
	current_level += 1
	current_xp -= xp_to_next_level
	xp_to_next_level = calculate_xp_for_level(current_level)

	print("=== LEVEL UP! Now level %d ===" % current_level)
	print("Next level requires: %d XP" % xp_to_next_level)

	# Emit level up signal
	leveled_up.emit(current_level)

	# Generate upgrade options
	generate_level_up_choices()

## Calculate XP required for a given level
func calculate_xp_for_level(level: int) -> int:
	# Formula: base_xp * (level ^ 1.5)
	return int(BASE_XP * pow(level, XP_EXPONENT))

## Generate 3 random upgrade choices
func generate_level_up_choices() -> void:
	var available_upgrades = get_available_upgrades()
	var choices: Array = []

	# Pick 3 random upgrades
	for i in range(3):
		if available_upgrades.size() == 0:
			break

		var random_index = randi() % available_upgrades.size()
		choices.append(available_upgrades[random_index])
		available_upgrades.remove_at(random_index)

	# Emit choices for UI to display
	level_up_choice_ready.emit(choices)

	print("Level-up choices generated: %d options" % choices.size())

## Get all available upgrades based on current state
func get_available_upgrades() -> Array:
	var upgrades = []
	var keeper = get_tree().get_first_node_in_group("keeper")

	# Weapon upgrades (60% of pool)
	if keeper and keeper.weapon_manager and not keeper.weapon_manager.is_full():
		upgrades.append({
			"type": "new_weapon",
			"name": "New Weapon",
			"description": "Add a random weapon to your arsenal",
			"icon": "weapon"
		})

	upgrades.append({
		"type": "damage",
		"name": "+20% Damage",
		"description": "All weapons deal 20% more damage",
		"value": 1.2,
		"icon": "damage"
	})

	upgrades.append({
		"type": "fire_rate",
		"name": "+30% Fire Rate",
		"description": "All weapons attack 30% faster",
		"value": 1.3,
		"icon": "speed"
	})

	upgrades.append({
		"type": "projectile_count",
		"name": "+1 Projectile",
		"description": "All weapons shoot one additional projectile",
		"value": 1,
		"icon": "projectile"
	})

	upgrades.append({
		"type": "range",
		"name": "+30% Range",
		"description": "All weapons have 30% longer range",
		"value": 1.3,
		"icon": "range"
	})

	# Stat upgrades (30% of pool)
	upgrades.append({
		"type": "movement_speed",
		"name": "+10% Movement Speed",
		"description": "Move 10% faster",
		"value": 1.1,
		"icon": "speed"
	})

	upgrades.append({
		"type": "max_hp",
		"name": "+20 Max HP",
		"description": "Increase maximum health",
		"value": 20,
		"icon": "health"
	})

	upgrades.append({
		"type": "hp_regen",
		"name": "+5 HP Regen/s",
		"description": "Regenerate 5 HP per second",
		"value": 5,
		"icon": "regen"
	})

	# Economy upgrades (10% of pool)
	upgrades.append({
		"type": "resource_drop_rate",
		"name": "+25% Resource Drops",
		"description": "Enemies drop 25% more resources",
		"value": 1.25,
		"icon": "resource"
	})

	upgrades.append({
		"type": "build_cost",
		"name": "-10% Build Costs",
		"description": "Structures cost 10% less to build",
		"value": 0.9,
		"icon": "build"
	})

	return upgrades

## Apply chosen upgrade
func apply_upgrade(upgrade: Dictionary) -> void:
	var keeper = get_tree().get_first_node_in_group("keeper")
	if not keeper:
		print("ERROR: No keeper found!")
		return

	print("Applying upgrade: %s" % upgrade.name)

	match upgrade.type:
		"new_weapon":
			# TODO: Add random weapon from weapon pool
			print("TODO: Add new weapon")

		"damage", "fire_rate", "range", "projectile_count":
			# Apply to all weapons via WeaponManager
			if keeper.weapon_manager:
				keeper.weapon_manager.apply_upgrade_to_all(upgrade.type, upgrade.value)

		"movement_speed":
			keeper.speed *= upgrade.value
			print("Speed increased to: %.1f" % keeper.speed)

		"max_hp":
			keeper.max_health += int(upgrade.value)
			keeper.current_health += int(upgrade.value)
			print("Max HP increased to: %d" % keeper.max_health)

		"hp_regen":
			# TODO: Implement HP regeneration system
			print("TODO: Implement HP regen")

		"resource_drop_rate":
			# TODO: Store multiplier for resource drops
			print("TODO: Implement resource drop rate")

		"build_cost":
			# TODO: Store multiplier for build costs
			print("TODO: Implement build cost reduction")

## Reset for new run
func reset() -> void:
	current_level = 1
	current_xp = 0
	xp_to_next_level = BASE_XP
	print("LevelManager reset for new run")

## Get current progress (for UI)
func get_progress() -> Dictionary:
	return {
		"level": current_level,
		"current_xp": current_xp,
		"xp_to_next": xp_to_next_level,
		"xp_percent": float(current_xp) / float(xp_to_next_level)
	}
