## Spike Trap - damages enemies that walk over it
extends Structure

@export var damage_on_trigger: int = 30
@export var trigger_cooldown: float = 5.0
@export var trigger_radius: float = 16.0

var cooldown_timer: float = 0.0
var is_ready_to_trigger: bool = true

## Cached references
@onready var detection_area: Area2D = $DetectionArea

func _ready() -> void:
	structure_name = "Spike Trap"
	max_health = 50
	costs = {
		Constants.ResourceType.METAL: 8
	}
	can_be_repaired = true

	super._ready()

	# Setup detection area
	if not detection_area:
		detection_area = Area2D.new()
		add_child(detection_area)

		var collision_shape = CollisionShape2D.new()
		var circle_shape = CircleShape2D.new()
		circle_shape.radius = trigger_radius
		collision_shape.shape = circle_shape
		detection_area.add_child(collision_shape)

	detection_area.body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	# Handle cooldown
	if not is_ready_to_trigger:
		cooldown_timer += delta
		if cooldown_timer >= trigger_cooldown:
			is_ready_to_trigger = true
			cooldown_timer = 0.0

			# Visual feedback - trap is ready again
			if sprite:
				sprite.modulate = Color.WHITE

func _on_body_entered(body: Node2D) -> void:
	# Only trigger on enemies
	if not body.is_in_group("enemies"):
		return

	if not is_ready_to_trigger:
		return

	# Trigger trap
	trigger_trap(body)

func trigger_trap(target: Node2D) -> void:
	"""Trigger the trap and damage the target"""
	if target.has_method("take_damage"):
		target.take_damage(damage_on_trigger)
		EventBus.damage_dealt.emit(target, damage_on_trigger)

	# Start cooldown
	is_ready_to_trigger = false
	cooldown_timer = 0.0

	# Visual feedback
	if sprite:
		sprite.modulate = Color(0.5, 0.5, 0.5)  # Darken while on cooldown

		# Trigger animation
		var tween = create_tween()
		tween.tween_property(sprite, "scale", Vector2(1.2, 0.8), 0.1)
		tween.tween_property(sprite, "scale", Vector2.ONE, 0.1)

	print("Trap triggered! Dealt %d damage" % damage_on_trigger)
