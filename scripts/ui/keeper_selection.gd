## Keeper Selection - Choose your keeper before starting a run
extends Control

@onready var back_button = $Header/BackButton
@onready var keepers_container = $CenterContainer/KeepersContainer

## Keeper definitions
var keepers = {
	"engineer": {
		"name": "Engineer",
		"description": "Starter keeper. Balanced stats.\nGood for learning the game.",
		"scene": "res://scenes/characters/keeper_base.tscn",
		"unlocked": true
	},
	"soldier": {
		"name": "Soldier",
		"description": "Combat specialist. +20 HP, 1.5x damage.\nAbility: Rally (boost turret speed)",
		"scene": "res://scenes/characters/keeper_soldier.tscn",
		"unlocked": false
	},
	"scavenger": {
		"name": "Scavenger",
		"description": "Fast gatherer. +30% speed, better resources.\nAbility: Sixth Sense (reveal resources)",
		"scene": "res://scenes/characters/keeper_scavenger.tscn",
		"unlocked": false
	},
	"medic": {
		"name": "Medic",
		"description": "Healer. Passive lighthouse regen.\nAbility: Emergency Heal (50% lighthouse HP)",
		"scene": "res://scenes/characters/keeper_medic.tscn",
		"unlocked": false
	}
}

var selected_keeper: String = "engineer"

func _ready() -> void:
	if back_button:
		back_button.pressed.connect(_on_back_pressed)

	populate_keepers()

func populate_keepers() -> void:
	"""Create keeper selection cards"""
	for keeper_id in keepers.keys():
		var keeper_data = keepers[keeper_id]
		var is_unlocked = SaveManager.is_keeper_unlocked(keeper_id)

		# Create keeper card
		var panel = PanelContainer.new()
		panel.custom_minimum_size = Vector2(120, 150)

		var margin = MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 8)
		margin.add_theme_constant_override("margin_right", 8)
		margin.add_theme_constant_override("margin_top", 8)
		margin.add_theme_constant_override("margin_bottom", 8)
		panel.add_child(margin)

		var vbox = VBoxContainer.new()
		vbox.add_theme_constant_override("separation", 3)
		margin.add_child(vbox)

		# Name
		var name_label = Label.new()
		name_label.text = keeper_data.name
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.add_theme_font_size_override("font_size", 10)
		vbox.add_child(name_label)

		# Icon placeholder
		var icon = ColorRect.new()
		icon.custom_minimum_size = Vector2(60, 60)
		icon.color = Color(0.3, 0.5, 0.7) if is_unlocked else Color(0.2, 0.2, 0.2)
		vbox.add_child(icon)

		# Description
		var desc_label = Label.new()
		desc_label.text = keeper_data.description if is_unlocked else "LOCKED"
		desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
		desc_label.custom_minimum_size = Vector2(104, 0)
		desc_label.add_theme_font_size_override("font_size", 7)
		vbox.add_child(desc_label)

		# Select button
		var select_button = Button.new()
		select_button.add_theme_font_size_override("font_size", 9)
		select_button.custom_minimum_size = Vector2(0, 18)
		if is_unlocked:
			select_button.text = "Select"
			select_button.pressed.connect(_on_keeper_selected.bind(keeper_id))
		else:
			select_button.text = "Locked"
			select_button.disabled = true
		vbox.add_child(select_button)

		keepers_container.add_child(panel)

func _on_keeper_selected(keeper_id: String) -> void:
	"""Start the game with selected keeper"""
	selected_keeper = keeper_id
	GameManager.selected_keeper_id = keeper_id
	print("Selected keeper: %s" % keeper_id)

	# Load game scene
	get_tree().change_scene_to_file("res://scenes/main/game.tscn")

func _on_back_pressed() -> void:
	"""Return to main menu"""
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
