## Turret bullet projectile
extends Area2D

@export var default_speed: float = 300.0
@export var lifetime: float = 2.0

var direction: Vector2 = Vector2.RIGHT
var damage: int = 10
var speed: float = 300.0

@onready var sprite = $Sprite2D

func _ready() -> void:
	# Set up collision detection
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

	# Auto-destroy after lifetime
	get_tree().create_timer(lifetime).timeout.connect(queue_free)

func initialize(dir: Vector2, dmg: int, spd: float = 300.0) -> void:
	"""Initialize projectile with direction, damage, and speed"""
	direction = dir.normalized()
	damage = dmg
	speed = spd

	# Rotate sprite to face direction
	if sprite:
		rotation = direction.angle()

func _physics_process(delta: float) -> void:
	# Move in direction
	global_position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	"""Handle collision with bodies (enemies)"""
	if body.is_in_group("structures") or body.is_in_group("lighthouse"):
		# Don't hit friendly structures
		return

	# Deal damage if target has take_damage method
	if body.has_method("take_damage"):
		body.take_damage(damage)
		EventBus.damage_dealt.emit(body, damage)

	# Destroy projectile
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	"""Handle collision with areas"""
	if area.is_in_group("structures") or area.is_in_group("lighthouse"):
		# Don't hit friendly structures
		return

	# Deal damage if target has take_damage method
	if area.has_method("take_damage"):
		area.take_damage(damage)
		EventBus.damage_dealt.emit(area, damage)

	# Destroy projectile
	queue_free()
