## Generator - provides power to nearby turrets
extends Structure

@export var power_radius: float = 100.0
@export var generates_power: bool = true

func _ready() -> void:
	structure_name = "Generator"
	max_health = 75
	costs = {
		Constants.ResourceType.METAL: 20,
		Constants.ResourceType.FUEL: 10
	}
	can_be_repaired = true

	super._ready()
	add_to_group("generators")

func is_providing_power() -> bool:
	"""Check if generator is operational"""
	return current_health > 0 and generates_power

func get_powered_turrets() -> Array:
	"""Get all turrets within power radius"""
	var powered_turrets = []
	var all_turrets = get_tree().get_nodes_in_group("turrets")

	for turret in all_turrets:
		if global_position.distance_to(turret.global_position) <= power_radius:
			powered_turrets.append(turret)

	return powered_turrets
