## Upgrade Shop - Spend Keeper Tokens on permanent upgrades
extends Control

@onready var tokens_label = $Header/TokensLabel
@onready var back_button = $Header/BackButton
@onready var upgrades_container = $ScrollContainer/VBoxContainer

## Upgrade definitions
var upgrades = {
	"lighthouse_max_hp": {
		"name": "Lighthouse Max HP",
		"description": "+50 HP per level",
		"base_cost": 5,
		"max_level": 5,
		"cost_multiplier": 1.5
	},
	"lighthouse_beam_damage": {
		"name": "Beam Damage",
		"description": "+5 damage per level",
		"base_cost": 10,
		"max_level": 5,
		"cost_multiplier": 1.5
	},
	"lighthouse_beam_duration": {
		"name": "Beam Stun Duration",
		"description": "+0.5s stun per level",
		"base_cost": 15,
		"max_level": 3,
		"cost_multiplier": 2.0
	},
	"turret_damage": {
		"name": "Turret Damage",
		"description": "+2 damage per level",
		"base_cost": 8,
		"max_level": 5,
		"cost_multiplier": 1.5
	},
	"turret_fire_rate": {
		"name": "Turret Fire Rate",
		"description": "-10% cooldown per level",
		"base_cost": 10,
		"max_level": 5,
		"cost_multiplier": 1.5
	},
	"wall_health": {
		"name": "Wall Health",
		"description": "+20 HP per level",
		"base_cost": 5,
		"max_level": 5,
		"cost_multiplier": 1.3
	},
	"build_cost_reduction": {
		"name": "Build Cost Reduction",
		"description": "-5% cost per level",
		"base_cost": 12,
		"max_level": 5,
		"cost_multiplier": 1.8
	},
	"starting_wood": {
		"name": "Starting Wood",
		"description": "+10 wood per level",
		"base_cost": 6,
		"max_level": 5,
		"cost_multiplier": 1.4
	},
	"starting_metal": {
		"name": "Starting Metal",
		"description": "+10 metal per level",
		"base_cost": 8,
		"max_level": 5,
		"cost_multiplier": 1.4
	},
	"movement_speed": {
		"name": "Movement Speed",
		"description": "+5% speed per level",
		"base_cost": 7,
		"max_level": 5,
		"cost_multiplier": 1.5
	},
	"ability_cooldown": {
		"name": "Ability Cooldown",
		"description": "-10% cooldown per level",
		"base_cost": 15,
		"max_level": 3,
		"cost_multiplier": 2.0
	}
}

func _ready() -> void:
	if back_button:
		back_button.pressed.connect(_on_back_pressed)

	update_display()
	populate_upgrades()

func update_display() -> void:
	"""Update tokens display"""
	if tokens_label:
		tokens_label.text = "Keeper Tokens: %d" % SaveManager.get_meta_currency()

func populate_upgrades() -> void:
	"""Create upgrade buttons"""
	for upgrade_id in upgrades.keys():
		var upgrade_data = upgrades[upgrade_id]
		var current_level = SaveManager.get_upgrade_level(upgrade_id)
		var cost = calculate_cost(upgrade_data.base_cost, current_level, upgrade_data.cost_multiplier)

		# Create upgrade panel
		var panel = PanelContainer.new()
		panel.custom_minimum_size = Vector2(200, 50)

		var margin = MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 5)
		margin.add_theme_constant_override("margin_right", 5)
		margin.add_theme_constant_override("margin_top", 5)
		margin.add_theme_constant_override("margin_bottom", 5)
		panel.add_child(margin)

		var hbox = HBoxContainer.new()
		margin.add_child(hbox)

		# Info section
		var vbox = VBoxContainer.new()
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(vbox)

		var name_label = Label.new()
		name_label.text = upgrade_data.name
		name_label.add_theme_font_size_override("font_size", 10)
		vbox.add_child(name_label)

		var desc_label = Label.new()
		desc_label.text = upgrade_data.description
		desc_label.add_theme_font_size_override("font_size", 8)
		vbox.add_child(desc_label)

		var level_label = Label.new()
		level_label.text = "Level: %d/%d" % [current_level, upgrade_data.max_level]
		level_label.add_theme_font_size_override("font_size", 8)
		vbox.add_child(level_label)

		# Buy button
		var buy_button = Button.new()
		buy_button.custom_minimum_size = Vector2(50, 40)
		buy_button.add_theme_font_size_override("font_size", 9)

		if current_level >= upgrade_data.max_level:
			buy_button.text = "MAX"
			buy_button.disabled = true
		else:
			buy_button.text = "Buy\n%d" % cost
			buy_button.pressed.connect(_on_upgrade_purchased.bind(upgrade_id, cost, upgrade_data.max_level))

		hbox.add_child(buy_button)

		upgrades_container.add_child(panel)

func calculate_cost(base_cost: int, current_level: int, multiplier: float) -> int:
	"""Calculate upgrade cost based on current level"""
	return int(base_cost * pow(multiplier, current_level))

func _on_upgrade_purchased(upgrade_id: String, cost: int, max_level: int) -> void:
	"""Handle upgrade purchase"""
	if SaveManager.purchase_upgrade(upgrade_id, cost, max_level):
		# Refresh the display
		clear_upgrades()
		update_display()
		populate_upgrades()
		print("Upgrade purchased!")
	else:
		print("Cannot purchase upgrade!")

func clear_upgrades() -> void:
	"""Clear all upgrade panels"""
	for child in upgrades_container.get_children():
		child.queue_free()

func _on_back_pressed() -> void:
	"""Return to main menu"""
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
