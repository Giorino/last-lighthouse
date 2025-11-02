## Manages in-game resources (wood, metal, stone, fuel)
extends Node

## Current resource amounts
var resources: Dictionary = {}

## Total resources gathered during this run (for statistics)
var total_resources_gathered: int = 0

func _ready() -> void:
	# Initialize with starting resources
	reset_resources()

## Reset resources to starting amounts
func reset_resources() -> void:
	resources = Constants.STARTING_RESOURCES.duplicate()
	total_resources_gathered = 0
	for type in resources:
		EventBus.resource_changed.emit(type, resources[type])

## Add resources of a given type
func add_resource(type: Constants.ResourceType, amount: int) -> void:
	if amount <= 0:
		return

	resources[type] += amount
	total_resources_gathered += amount
	EventBus.resource_changed.emit(type, resources[type])

## Attempt to spend resources of a given type
## Returns true if successful, false if not enough resources
func spend_resource(type: Constants.ResourceType, amount: int) -> bool:
	if amount <= 0:
		return true

	if resources[type] >= amount:
		resources[type] -= amount
		EventBus.resource_changed.emit(type, resources[type])
		return true

	return false

## Check if the player can afford a given cost dictionary
func can_afford(costs: Dictionary) -> bool:
	for type in costs:
		if resources.get(type, 0) < costs[type]:
			return false
	return true

## Spend multiple resources at once
## Returns true if successful, false if cannot afford
func spend_resources(costs: Dictionary) -> bool:
	if not can_afford(costs):
		return false

	for type in costs:
		spend_resource(type, costs[type])

	return true

## Get current amount of a resource type
func get_resource(type: Constants.ResourceType) -> int:
	return resources.get(type, 0)

## Get total resources gathered during this run
func get_total_resources_gathered() -> int:
	return total_resources_gathered
