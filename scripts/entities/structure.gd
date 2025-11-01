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
	current_health = max_health
	add_to_group("structures")

func take_damage(amount: int) -> void:
	current_health -= amount

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

	# Destruction effect
	if sprite:
		var tween = create_tween()
		tween.tween_property(sprite, "modulate:a", 0.0, 0.5)
		await tween.finished

	queue_free()
