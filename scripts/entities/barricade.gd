## Barricade - cheap, weak defensive wall for quick blocking
extends Structure

func _ready() -> void:
	structure_name = "Barricade"
	max_health = 50
	costs = {
		Constants.ResourceType.WOOD: 3
	}
	can_be_repaired = true

	super._ready()
