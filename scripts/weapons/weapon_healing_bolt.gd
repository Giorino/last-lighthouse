## Medic's starting weapon - Healing Bolt
## Damages enemies, chance to heal nearby structures
extends Weapon

@export var heal_chance: float = 0.3  # 30% chance to heal
@export var heal_amount: int = 5

func _ready() -> void:
	weapon_name = "Healing Bolt"
	damage = 10
	fire_rate = 1.0  # 1 attack per second
	range = 150.0  # Medium range
	projectile_speed = 300.0
	projectile_count = 1

	# Use turret bullet for now (TODO: Create healing bolt projectile with green color)
	projectile_scene = preload("res://scenes/structures/turret_bullet.tscn")

	super._ready()

## Override fire to add healing mechanic
func fire_at_target(target: Node2D) -> void:
	super.fire_at_target(target)

	# Check for healing trigger
	if randf() < heal_chance:
		heal_nearby_structure()

## Heal nearest damaged structure
func heal_nearby_structure() -> void:
	if not owner_keeper:
		return

	var structures = get_tree().get_nodes_in_group("structures")
	var nearest_structure: Structure = null
	var nearest_distance: float = 150.0  # Heal range

	for structure in structures:
		if not is_instance_valid(structure):
			continue

		# Only heal damaged structures
		if structure.current_health >= structure.max_health:
			continue

		var distance = owner_keeper.global_position.distance_to(structure.global_position)
		if distance <= 150.0 and distance < nearest_distance:
			nearest_structure = structure
			nearest_distance = distance

	if nearest_structure:
		nearest_structure.repair(heal_amount)
		print("Healing Bolt: Healed %s for %d HP" % [nearest_structure.structure_name, heal_amount])

		# Visual feedback
		if VisualEffectsManager:
			VisualEffectsManager.spawn_hit_effect(nearest_structure.global_position)
