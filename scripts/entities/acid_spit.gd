## Acid projectile fired by Spitter enemies
extends Area2D

@export var projectile_speed: float = 200.0
@export var lifetime: float = 3.0

var direction: Vector2 = Vector2.RIGHT
var damage: int = 8
var distance_traveled: float = 0.0
var max_distance: float = 150.0  # Matches spitter attack range

@onready var sprite = $Sprite2D

func _ready() -> void:
	# Set up collision detection
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

	# Auto-destroy after lifetime
	get_tree().create_timer(lifetime).timeout.connect(queue_free)

func initialize(dir: Vector2, dmg: int) -> void:
	"""Initialize projectile with direction and damage"""
	direction = dir.normalized()
	damage = dmg

	# Rotate sprite to face direction
	if sprite:
		rotation = direction.angle()

func _physics_process(delta: float) -> void:
	# Move in direction
	var movement = direction * projectile_speed * delta
	global_position += movement

	# Track distance
	distance_traveled += movement.length()

	# Destroy if traveled max distance
	if distance_traveled >= max_distance:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	"""Handle collision with bodies (structures, lighthouse)"""
	if body.is_in_group("enemies"):
		# Don't hit other enemies
		return

	# Deal damage if target has take_damage method
	if body.has_method("take_damage"):
		body.take_damage(damage)
		EventBus.damage_dealt.emit(body, damage)

	# Destroy projectile
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	"""Handle collision with areas (lighthouse, keeper)"""
	if area.is_in_group("enemies"):
		# Don't hit other enemies
		return

	# Deal damage if target has take_damage method
	if area.has_method("take_damage"):
		area.take_damage(damage)
		EventBus.damage_dealt.emit(area, damage)

	# Destroy projectile
	queue_free()
