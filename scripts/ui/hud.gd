## Main HUD displaying game information
extends CanvasLayer

## Resource labels
@onready var wood_label: Label = $MarginContainer/HBoxContainer/ResourcePanel/VBoxContainer/WoodLabel
@onready var metal_label: Label = $MarginContainer/HBoxContainer/ResourcePanel/VBoxContainer/MetalLabel
@onready var stone_label: Label = $MarginContainer/HBoxContainer/ResourcePanel/VBoxContainer/StoneLabel
@onready var fuel_label: Label = $MarginContainer/HBoxContainer/ResourcePanel/VBoxContainer/FuelLabel

## Time and phase labels
@onready var time_label: Label = $MarginContainer/HBoxContainer/CenterPanel/VBoxContainer/TimeLabel
@onready var phase_label: Label = $MarginContainer/HBoxContainer/CenterPanel/VBoxContainer/PhaseLabel

## Lighthouse HP
@onready var lighthouse_hp_label: Label = $MarginContainer/HBoxContainer/LighthousePanel/VBoxContainer/HPLabel
@onready var lighthouse_hp_bar: ProgressBar = $MarginContainer/HBoxContainer/LighthousePanel/VBoxContainer/HPBar

func _ready() -> void:
	add_to_group("hud")
	# Connect to resource signals
	EventBus.resource_changed.connect(_on_resource_changed)
	EventBus.lighthouse_health_changed.connect(_on_lighthouse_health_changed)

	# Initialize displays
	_update_all_resources()

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
