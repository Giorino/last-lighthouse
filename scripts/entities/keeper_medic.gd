## Medic Keeper - Healing specialist with repair bonuses
extends Keeper

var lighthouse_heal_per_second: float = 0.5
var heal_timer: float = 0.0

func _ready() -> void:
	keeper_name = "Medic"
	max_health = 90  # -10 HP
	speed = 95.0  # Slightly slower

	super._ready()

	print("Medic keeper ready - Healing specialist")

func _process(delta: float) -> void:
	super._process(delta)

	# Passive: Slowly heal lighthouse over time
	heal_timer += delta
	if heal_timer >= 1.0:
		heal_lighthouse(lighthouse_heal_per_second)
		heal_timer = 0.0

func heal_lighthouse(amount: float) -> void:
	"""Passively heal the lighthouse"""
	var lighthouse = get_tree().get_first_node_in_group("lighthouse")
	if lighthouse and is_instance_valid(lighthouse):
		if lighthouse.has_method("repair"):
			lighthouse.repair(int(amount))

## Medic repairs cost less
func get_repair_cost_multiplier() -> float:
	return 0.75  # 25% cheaper repairs

## Medic ability: "Emergency Heal" - Restore lighthouse to 50% HP
func use_special_ability() -> void:
	print("MEDIC ABILITY: Emergency Heal!")

	var lighthouse = get_tree().get_first_node_in_group("lighthouse")
	if lighthouse and is_instance_valid(lighthouse):
		var heal_amount = lighthouse.max_health * 0.5
		if lighthouse.has_method("repair"):
			lighthouse.repair(int(heal_amount))	
			print("Healed lighthouse for %d HP!" % heal_amount)
	else:
		print("No lighthouse to heal!")

## Add medic's starting weapon - Healing Bolt
func add_starting_weapon() -> void:
	var healing_bolt = preload("res://scripts/weapons/weapon_healing_bolt.gd").new()
	if weapon_manager:
		weapon_manager.add_weapon(healing_bolt)
