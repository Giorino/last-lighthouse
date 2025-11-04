## Manages weapons for a keeper - Auto-fires all equipped weapons
class_name WeaponManager
extends Node

## Configuration
const MAX_WEAPON_SLOTS: int = 6

## Weapon slots
var weapon_slots: Array[Weapon] = []
var owner_keeper: Node2D = null

## Stats multipliers (from upgrades)
var damage_multiplier: float = 1.0
var fire_rate_multiplier: float = 1.0
var range_multiplier: float = 1.0

func _ready() -> void:
	# Initialize empty slots
	weapon_slots.resize(MAX_WEAPON_SLOTS)

	# Get owner keeper
	if get_parent() is Keeper:
		owner_keeper = get_parent()

func _process(delta: float) -> void:
	# Auto-fire all equipped weapons
	for weapon in weapon_slots:
		if weapon:
			weapon.try_fire(delta)

## Add weapon to first empty slot
func add_weapon(weapon: Weapon) -> bool:
	# Find first empty slot
	for i in range(MAX_WEAPON_SLOTS):
		if weapon_slots[i] == null:
			weapon_slots[i] = weapon
			weapon.owner_keeper = owner_keeper
			add_child(weapon)

			# Apply current multipliers to new weapon
			apply_multipliers_to_weapon(weapon)

			print("Added weapon: %s to slot %d" % [weapon.weapon_name, i])
			return true

	print("No empty weapon slots available!")
	return false

## Remove weapon from slot
func remove_weapon(slot_index: int) -> void:
	if slot_index < 0 or slot_index >= MAX_WEAPON_SLOTS:
		return

	if weapon_slots[slot_index]:
		var weapon = weapon_slots[slot_index]
		weapon.queue_free()
		weapon_slots[slot_index] = null
		print("Removed weapon from slot %d" % slot_index)

## Get weapon at slot
func get_weapon(slot_index: int) -> Weapon:
	if slot_index < 0 or slot_index >= MAX_WEAPON_SLOTS:
		return null
	return weapon_slots[slot_index]

## Get number of equipped weapons
func get_weapon_count() -> int:
	var count = 0
	for weapon in weapon_slots:
		if weapon:
			count += 1
	return count

## Check if slots are full
func is_full() -> bool:
	return get_weapon_count() >= MAX_WEAPON_SLOTS

## Apply upgrade to all weapons
func apply_upgrade_to_all(upgrade_type: String, value: float) -> void:
	match upgrade_type:
		"damage":
			damage_multiplier *= value
		"fire_rate":
			fire_rate_multiplier *= value
		"range":
			range_multiplier *= value
		"projectile_count":
			# Add projectile to all weapons
			for weapon in weapon_slots:
				if weapon:
					weapon.projectile_count += int(value)

	# Apply to all current weapons
	for weapon in weapon_slots:
		if weapon:
			apply_multipliers_to_weapon(weapon)

	print("Applied upgrade: %s x%.2f to all weapons" % [upgrade_type, value])

## Apply current multipliers to a weapon
func apply_multipliers_to_weapon(weapon: Weapon) -> void:
	# Store base values if not already stored
	if not weapon.has_meta("base_damage"):
		weapon.set_meta("base_damage", weapon.damage)
	if not weapon.has_meta("base_fire_rate"):
		weapon.set_meta("base_fire_rate", weapon.fire_rate)
	if not weapon.has_meta("base_range"):
		weapon.set_meta("base_range", weapon.range)

	# Apply multipliers
	weapon.damage = int(weapon.get_meta("base_damage") * damage_multiplier)
	weapon.fire_rate = weapon.get_meta("base_fire_rate") * fire_rate_multiplier
	weapon.range = weapon.get_meta("base_range") * range_multiplier

## Get all weapon stats (for UI)
func get_all_weapon_stats() -> Array:
	var stats = []
	for weapon in weapon_slots:
		if weapon:
			stats.append(weapon.get_stats())
		else:
			stats.append(null)
	return stats
