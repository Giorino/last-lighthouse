## Save/Load system for persistent data and meta-progression
extends Node

const SAVE_PATH = "user://savegame.save"

## Save data structure
var save_data = {
	"unlocked_keepers": ["engineer"],  # Starts with engineer unlocked
	"meta_currency": 0,
	"total_nights_survived": 0,
	"total_runs": 0,
	"highest_night_reached": 0,
	"total_enemies_killed": 0,
	"total_resources_gathered": 0,
	"unlocks": [],
	"achievements": [],
	"upgrades": {
		# Lighthouse upgrades
		"lighthouse_max_hp": 0,  # +50 HP per level (max 5)
		"lighthouse_beam_damage": 0,  # +5 damage per level (max 5)
		"lighthouse_beam_duration": 0,  # +0.5s stun per level (max 3)
		# Structure upgrades
		"turret_damage": 0,  # +2 damage per level (max 5)
		"turret_fire_rate": 0,  # -10% cooldown per level (max 5)
		"wall_health": 0,  # +20 HP per level (max 5)
		"build_cost_reduction": 0,  # -5% cost per level (max 5)
		# Keeper upgrades
		"starting_wood": 0,  # +10 wood per level (max 5)
		"starting_metal": 0,  # +10 metal per level (max 5)
		"movement_speed": 0,  # +5% speed per level (max 5)
		"ability_cooldown": 0,  # -10% cooldown per level (max 3)
	},
	"settings": {
		"music_volume": 1.0,
		"sfx_volume": 1.0,
		"fullscreen": false
	}
}

func _ready() -> void:
	load_game()

func save_game() -> void:
	"""Save game data to disk"""
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(save_data)
		file.close()
		print("Game saved successfully!")
	else:
		print("ERROR: Failed to save game!")

func load_game() -> void:
	"""Load game data from disk"""
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save file found, using default data")
		return

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var loaded_data = file.get_var()
		file.close()

		# Merge loaded data with default save_data to ensure all keys exist
		# This handles old save files that don't have new features like upgrades
		_merge_save_data(loaded_data)

		print("Game loaded successfully!")
	else:
		print("ERROR: Failed to load game!")

func _merge_save_data(loaded_data: Dictionary) -> void:
	"""Merge loaded data with default save_data structure"""
	for key in loaded_data:
		if key in save_data:
			# If both are dictionaries, merge them recursively
			if typeof(save_data[key]) == TYPE_DICTIONARY and typeof(loaded_data[key]) == TYPE_DICTIONARY:
				for sub_key in loaded_data[key]:
					save_data[key][sub_key] = loaded_data[key][sub_key]
			else:
				# Otherwise just overwrite
				save_data[key] = loaded_data[key]

func update_run_stats(night_reached: int, enemies_killed: int, resources_gathered: int) -> void:
	"""Update stats after a run ends"""
	save_data.total_runs += 1
	save_data.total_nights_survived += night_reached
	save_data.total_enemies_killed += enemies_killed
	save_data.total_resources_gathered += resources_gathered

	if night_reached > save_data.highest_night_reached:
		save_data.highest_night_reached = night_reached

	# Check for unlocks
	check_unlocks()

	# Auto-save
	save_game()

func add_meta_currency(amount: int) -> void:
	"""Add meta-currency (Keeper Tokens)"""
	save_data.meta_currency += amount
	print("Earned %d Keeper Tokens! Total: %d" % [amount, save_data.meta_currency])

func spend_meta_currency(amount: int) -> bool:
	"""Spend meta-currency"""
	if save_data.meta_currency >= amount:
		save_data.meta_currency -= amount
		save_game()
		return true
	return false

func is_keeper_unlocked(keeper_id: String) -> bool:
	"""Check if a keeper is unlocked"""
	return keeper_id in save_data.unlocked_keepers

func unlock_keeper(keeper_id: String) -> void:
	"""Unlock a new keeper"""
	if not is_keeper_unlocked(keeper_id):
		save_data.unlocked_keepers.append(keeper_id)
		EventBus.show_notification.emit("New Keeper Unlocked: %s!" % keeper_id.capitalize())
		save_game()

func check_unlocks() -> void:
	"""Check if player has met unlock conditions"""
	# Soldier: Survive 5 nights
	if save_data.highest_night_reached >= 5:
		unlock_keeper("soldier")

	# Scavenger: Gather 500 total resources
	if save_data.total_resources_gathered >= 500:
		unlock_keeper("scavenger")

	# Medic: Survive 10 nights
	if save_data.highest_night_reached >= 10:
		unlock_keeper("medic")

func get_setting(key: String, default_value = null):
	"""Get a setting value"""
	if save_data.settings.has(key):
		return save_data.settings[key]
	return default_value

func set_setting(key: String, value) -> void:
	"""Set a setting value"""
	save_data.settings[key] = value
	save_game()

## Upgrade System
func get_upgrade_level(upgrade_id: String) -> int:
	"""Get the current level of an upgrade"""
	if not save_data.has("upgrades"):
		return 0
	if save_data.upgrades.has(upgrade_id):
		return save_data.upgrades[upgrade_id]
	return 0

func purchase_upgrade(upgrade_id: String, cost: int, max_level: int) -> bool:
	"""Purchase an upgrade if player can afford it and hasn't maxed it"""
	# Ensure upgrades dictionary exists
	if not save_data.has("upgrades"):
		save_data.upgrades = {}

	var current_level = get_upgrade_level(upgrade_id)

	if current_level >= max_level:
		print("Upgrade %s already at max level!" % upgrade_id)
		return false

	if save_data.meta_currency >= cost:
		save_data.meta_currency -= cost
		save_data.upgrades[upgrade_id] = current_level + 1
		save_game()
		print("Purchased %s (Level %d)" % [upgrade_id, current_level + 1])
		return true
	else:
		print("Not enough Keeper Tokens!")
		return false

func get_meta_currency() -> int:
	"""Get current meta-currency amount"""
	return save_data.meta_currency
