## Scavenger Keeper - Fast movement and better resource gathering
extends Keeper

func _ready() -> void:
	keeper_name = "Scavenger"
	max_health = 80  # -20 HP (fragile)
	speed = 130.0  # +30% movement speed

	super._ready()

	print("Scavenger keeper ready - Fast & efficient")

## Scavenger gathers resources faster
func get_gather_speed_multiplier() -> float:
	return 1.5  # 50% faster gathering

## Scavenger gets more resources
func get_resource_multiplier() -> float:
	return 1.3  # 30% more resources

## Scavenger ability: "Sixth Sense" - Reveal all resource nodes
func use_special_ability() -> void:
	print("SCAVENGER ABILITY: Sixth Sense!")

	# In a full implementation, this would highlight resource nodes
	# For now, just print their locations
	var resource_nodes = get_tree().get_nodes_in_group("resource_nodes")

	print("Revealed %d resource nodes!" % resource_nodes.size())

	for node in resource_nodes:
		if is_instance_valid(node):
			print("  - Resource at: %v" % node.global_position)

	# Could add visual indicators here (glowing outlines, minimap pings, etc.)

## Add scavenger's starting weapon - Dual Pistols
func add_starting_weapon() -> void:
	var pistols = preload("res://scripts/weapons/weapon_pistols.gd").new()
	if weapon_manager:
		weapon_manager.add_weapon(pistols)
