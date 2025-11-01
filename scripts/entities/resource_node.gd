## Resource node that can be gathered during day phase
class_name ResourceNode
extends Area2D

## Resource configuration
@export var resource_type: Constants.ResourceType = Constants.ResourceType.WOOD
@export var amount: int = 30
@export var harvest_time: float = 2.0

## Current state
var is_being_harvested: bool = false
var harvest_progress: float = 0.0
var harvester: Node2D = null
var is_depleted: bool = false

## Cached references
@onready var sprite = $Sprite2D
@onready var progress_bar: ProgressBar = $ProgressBar

func _ready() -> void:
	add_to_group("resource_nodes")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	if progress_bar:
		progress_bar.visible = false
		progress_bar.max_value = harvest_time

	# Set sprite color based on resource type
	_update_sprite_color()

func _update_sprite_color() -> void:
	if not sprite:
		return

	match resource_type:
		Constants.ResourceType.WOOD:
			sprite.modulate = Color(0.6, 0.4, 0.2)  # Brown
		Constants.ResourceType.METAL:
			sprite.modulate = Color(0.7, 0.7, 0.8)  # Gray
		Constants.ResourceType.STONE:
			sprite.modulate = Color(0.5, 0.5, 0.5)  # Dark gray
		Constants.ResourceType.FUEL:
			sprite.modulate = Color(0.8, 0.6, 0.2)  # Orange

func _process(delta: float) -> void:
	if is_being_harvested and harvester and is_instance_valid(harvester):
		harvest_progress += delta

		if progress_bar:
			progress_bar.value = harvest_progress

		if harvest_progress >= harvest_time:
			complete_harvest()
	elif is_being_harvested:
		# Harvester is no longer valid, cancel harvest
		cancel_harvest()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("keeper") and not is_depleted:
		# Show prompt - will be handled by UI later
		pass

func _on_body_exited(body: Node2D) -> void:
	if body == harvester:
		cancel_harvest()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and not is_being_harvested and not is_depleted:
		# Check if keeper is nearby
		var keeper = GameManager.keeper
		if keeper and is_instance_valid(keeper):
			if global_position.distance_to(keeper.global_position) < 30.0:
				start_harvest(keeper)

func start_harvest(keeper: Node2D) -> void:
	if not GameManager.enable_scavenging or is_depleted:
		return

	is_being_harvested = true
	harvester = keeper
	harvest_progress = 0.0

	if keeper.has_method("set"):
		keeper.is_gathering = true

	if progress_bar:
		progress_bar.visible = true
		progress_bar.value = 0

	print("Started gathering %s..." % resource_type)

func complete_harvest() -> void:
	if is_depleted:
		return

	ResourceManager.add_resource(resource_type, amount)
	print("Gathered %d %s!" % [amount, resource_type])

	is_depleted = true
	is_being_harvested = false

	if harvester and is_instance_valid(harvester) and harvester.has_method("set"):
		harvester.is_gathering = false

	if progress_bar:
		progress_bar.visible = false

	# Visual feedback - fade out
	if sprite:
		var tween = create_tween()
		tween.tween_property(sprite, "modulate:a", 0.3, 0.5)

func cancel_harvest() -> void:
	is_being_harvested = false
	harvest_progress = 0.0

	if harvester and is_instance_valid(harvester) and harvester.has_method("set"):
		harvester.is_gathering = false

	harvester = null

	if progress_bar:
		progress_bar.visible = false

	print("Gathering cancelled")
