## Main HUD displaying game information
extends CanvasLayer

## Resource labels
@onready var wood_label: Label = $MarginContainer/VBoxContainer/TopBar/ResourcePanel/VBoxContainer/WoodLabel
@onready var metal_label: Label = $MarginContainer/VBoxContainer/TopBar/ResourcePanel/VBoxContainer/MetalLabel
@onready var stone_label: Label = $MarginContainer/VBoxContainer/TopBar/ResourcePanel/VBoxContainer/StoneLabel
@onready var fuel_label: Label = $MarginContainer/VBoxContainer/TopBar/ResourcePanel/VBoxContainer/FuelLabel

## Time and phase labels
@onready var time_label: Label = $MarginContainer/VBoxContainer/TopBar/CenterPanel/VBoxContainer/TimeLabel
@onready var phase_label: Label = $MarginContainer/VBoxContainer/TopBar/CenterPanel/VBoxContainer/PhaseLabel

## Lighthouse HP
@onready var lighthouse_hp_label: Label = $MarginContainer/VBoxContainer/TopBar/LighthousePanel/VBoxContainer/HPLabel
@onready var lighthouse_hp_bar: ProgressBar = $MarginContainer/VBoxContainer/TopBar/LighthousePanel/VBoxContainer/HPBar

## PHASE 5: XP and Level display
@onready var level_label: Label = $MarginContainer/VBoxContainer/BottomBar/PlayerPanel/VBoxContainer/LevelLabel
@onready var xp_bar: ProgressBar = $MarginContainer/VBoxContainer/BottomBar/PlayerPanel/VBoxContainer/XPBar
@onready var xp_label: Label = $MarginContainer/VBoxContainer/BottomBar/PlayerPanel/VBoxContainer/XPLabel

## PHASE 5: Weapon slot indicators
@onready var weapon_slots_container: HBoxContainer = $MarginContainer/VBoxContainer/BottomBar/WeaponPanel/HBoxContainer

func _ready() -> void:
	add_to_group("hud")
	# Connect to resource signals
	EventBus.resource_changed.connect(_on_resource_changed)
	EventBus.lighthouse_health_changed.connect(_on_lighthouse_health_changed)

	# PHASE 5: Connect to XP and level signals
	if LevelManager:
		LevelManager.xp_changed.connect(_on_xp_changed)
		LevelManager.level_up.connect(_on_level_up)

	# Initialize displays
	_update_all_resources()
	_update_xp_display()
	_update_weapon_slots()

func _process(_delta: float) -> void:
	# Update time display (will get from DayNightCycle later)
	pass

func _update_all_resources() -> void:
	if wood_label:
		wood_label.text = "Wood: %d" % ResourceManager.get_resource(Constants.ResourceType.WOOD)
	if metal_label:
		metal_label.text = "Metal: %d" % ResourceManager.get_resource(Constants.ResourceType.METAL)
	if stone_label:
		stone_label.text = "Stone: %d" % ResourceManager.get_resource(Constants.ResourceType.STONE)
	if fuel_label:
		fuel_label.text = "Fuel: %d" % ResourceManager.get_resource(Constants.ResourceType.FUEL)

func _on_resource_changed(type: Constants.ResourceType, amount: int) -> void:
	match type:
		Constants.ResourceType.WOOD:
			if wood_label:
				wood_label.text = "Wood: %d" % amount
		Constants.ResourceType.METAL:
			if metal_label:
				metal_label.text = "Metal: %d" % amount
		Constants.ResourceType.STONE:
			if stone_label:
				stone_label.text = "Stone: %d" % amount
		Constants.ResourceType.FUEL:
			if fuel_label:
				fuel_label.text = "Fuel: %d" % amount

func _on_lighthouse_health_changed(current: int, max_health: int) -> void:
	if lighthouse_hp_label:
		lighthouse_hp_label.text = "Lighthouse: %d/%d" % [current, max_health]
	if lighthouse_hp_bar:
		lighthouse_hp_bar.max_value = max_health
		lighthouse_hp_bar.value = current

func update_time_display(time_remaining: float, phase: Constants.Phase) -> void:
	if time_label:
		var minutes = int(time_remaining) / 60
		var seconds = int(time_remaining) % 60
		time_label.text = "%02d:%02d" % [minutes, seconds]

	if phase_label:
		match phase:
			Constants.Phase.DAY:
				phase_label.text = "DAY"
			Constants.Phase.TRANSITION:
				phase_label.text = "TRANSITION"
			Constants.Phase.NIGHT:
				phase_label.text = "NIGHT"

## PHASE 5: Update XP bar and level display
func _update_xp_display() -> void:
	if not LevelManager:
		return

	if level_label:
		level_label.text = "Level %d" % LevelManager.current_level

	if xp_bar:
		xp_bar.max_value = LevelManager.xp_for_next_level
		xp_bar.value = LevelManager.current_xp

	if xp_label:
		xp_label.text = "%d/%d XP" % [LevelManager.current_xp, LevelManager.xp_for_next_level]

func _on_xp_changed(current_xp: int, xp_for_next: int) -> void:
	if xp_bar:
		xp_bar.max_value = xp_for_next
		xp_bar.value = current_xp

	if xp_label:
		xp_label.text = "%d/%d XP" % [current_xp, xp_for_next]

func _on_level_up(new_level: int) -> void:
	if level_label:
		level_label.text = "Level %d" % new_level
	_update_xp_display()

## PHASE 5: Update weapon slot indicators
func _update_weapon_slots() -> void:
	if not weapon_slots_container:
		return

	# Clear existing slots
	for child in weapon_slots_container.get_children():
		child.queue_free()

	# Create 6 weapon slot indicators
	for i in range(6):
		var slot_panel = PanelContainer.new()
		slot_panel.custom_minimum_size = Vector2(24, 24)

		var slot_label = Label.new()
		slot_label.text = "%d" % (i + 1)
		slot_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		slot_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		slot_label.add_theme_font_size_override("font_size", 8)

		slot_panel.add_child(slot_label)
		weapon_slots_container.add_child(slot_panel)

		# TODO: Update slot appearance based on whether weapon is equipped
