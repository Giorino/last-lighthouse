## Base class for buildable structures
class_name Structure
extends StaticBody2D

## Structure configuration
@export var structure_name: String = "Wall"
@export var max_health: int = 100
@export var costs: Dictionary = {
	Constants.ResourceType.WOOD: 5,
	Constants.ResourceType.STONE: 10
}
@export var can_be_repaired: bool = true

## Current state
var current_health: int = max_health

## Cached references
@onready var sprite = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	# Apply upgrade bonuses for wall-type structures
	if structure_name == "Wall" or structure_name == "Barricade":
		max_health += GameManager.get_wall_health_bonus()

	current_health = max_health
	add_to_group("structures")

func take_damage(amount: int) -> void:
	current_health -= amount

	# PHASE 5D: Enhanced hit feedback - sparks for metal structures
	if VisualEffectsManager:
		VisualEffectsManager.spawn_sparks(global_position)  # Sparks for structure impacts
	if EventBus:
		EventBus.camera_shake.emit(0.1)  # Light shake

	# Visual damage feedback
	if sprite:
		var damage_ratio = float(current_health) / float(max_health)
		sprite.modulate = Color(1, damage_ratio, damage_ratio)

	print("%s HP: %d/%d" % [structure_name, current_health, max_health])

	if current_health <= 0:
		destroy()

func repair(amount: int) -> void:
	if not can_be_repaired:
		return

	current_health = min(current_health + amount, max_health)

	# Update visual
	if sprite:
		var damage_ratio = float(current_health) / float(max_health)
		sprite.modulate = Color(1, damage_ratio, damage_ratio)

	print("%s repaired! HP: %d/%d" % [structure_name, current_health, max_health])

func destroy() -> void:
	print("%s destroyed!" % structure_name)
	EventBus.structure_destroyed.emit(self)

	# PHASE 5D: Enhanced destruction effects - explosion + smoke + sparks
	if VisualEffectsManager:
		VisualEffectsManager.spawn_death_explosion(global_position)
		VisualEffectsManager.spawn_smoke_puff(global_position)
		VisualEffectsManager.spawn_sparks(global_position)
	if EventBus:
		EventBus.camera_shake.emit(0.5)  # Heavy shake for structure destruction
	if TimeScaleManager:
		TimeScaleManager.hit_pause_heavy()

	# Destruction effect
	if sprite:
		var tween = create_tween()
		tween.tween_property(sprite, "modulate:a", 0.0, 0.5)
		await tween.finished

	queue_free()
