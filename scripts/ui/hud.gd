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
		LevelManager.xp_gained.connect(_on_xp_gained)
		LevelManager.leveled_up.connect(_on_leveled_up)

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
		xp_bar.max_value = LevelManager.xp_to_next_level
		xp_bar.value = LevelManager.current_xp

	if xp_label:
		xp_label.text = "%d/%d XP" % [LevelManager.current_xp, LevelManager.xp_to_next_level]

func _on_xp_gained(amount: int, total: int) -> void:
	# Update XP bar when XP is gained
	if xp_bar:
		xp_bar.max_value = LevelManager.xp_to_next_level
		xp_bar.value = LevelManager.current_xp

	if xp_label:
		xp_label.text = "%d/%d XP" % [LevelManager.current_xp, LevelManager.xp_to_next_level]

func _on_leveled_up(new_level: int) -> void:
	if level_label:
		level_label.text = "Level %d" % new_level
	_update_xp_display()

## PHASE 5D: Enhanced weapon slot indicators with visual feedback
func _update_weapon_slots() -> void:
	if not weapon_slots_container:
		return

	# Clear existing slots
	for child in weapon_slots_container.get_children():
		child.queue_free()

	# Get keeper's weapon manager
	var keeper = GameManager.keeper
	var weapon_manager = null
	if keeper and keeper.has_node("WeaponManager"):
		weapon_manager = keeper.get_node("WeaponManager")
	elif keeper and "weapon_manager" in keeper:
		weapon_manager = keeper.weapon_manager

	# Create 6 weapon slot indicators
	for i in range(6):
		var slot_panel = PanelContainer.new()
		slot_panel.custom_minimum_size = Vector2(20, 20)
		slot_panel.name = "WeaponSlot%d" % i

		# Check if slot is filled
		var is_filled = false
		var weapon_name = ""
		if weapon_manager and weapon_manager.weapon_slots.size() > i:
			var weapon = weapon_manager.weapon_slots[i]
			if weapon != null:
				is_filled = true
				weapon_name = weapon.weapon_name if "weapon_name" in weapon else "?"

		# Style based on filled/empty
		var bg_color = Color(0.2, 0.5, 0.2, 0.8) if is_filled else Color(0.2, 0.2, 0.2, 0.5)
		var panel_style = StyleBoxFlat.new()
		panel_style.bg_color = bg_color
		panel_style.border_width_left = 1
		panel_style.border_width_right = 1
		panel_style.border_width_top = 1
		panel_style.border_width_bottom = 1
		panel_style.border_color = Color(0.5, 0.5, 0.5, 1.0) if is_filled else Color(0.3, 0.3, 0.3, 0.5)
		slot_panel.add_theme_stylebox_override("panel", panel_style)

		var slot_label = Label.new()
		if is_filled and weapon_name:
			# Show first letter of weapon name
			slot_label.text = weapon_name.substr(0, 1).to_upper()
		else:
			# Show slot number
			slot_label.text = "%d" % (i + 1)
		slot_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		slot_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		slot_label.add_theme_font_size_override("font_size", 6)
		slot_label.add_theme_color_override("font_color", Color.WHITE if is_filled else Color(0.5, 0.5, 0.5))

		slot_panel.add_child(slot_label)
		weapon_slots_container.add_child(slot_panel)

## PHASE 5D: Call this when weapons change
func refresh_weapon_slots() -> void:
	_update_weapon_slots()
