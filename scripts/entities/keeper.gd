## Base keeper (player) class with movement and basic combat
class_name Keeper
extends CharacterBody2D

## Keeper configuration
@export var keeper_name: String = "Engineer"
@export var max_health: int = 100
@export var speed: float = 100.0

## Current state
var current_health: int = max_health
var is_gathering: bool = false

## Cached references
@onready var sprite = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	current_health = max_health
	add_to_group("keeper")

	# Register with GameManager
	GameManager.keeper = self

func _physics_process(_delta: float) -> void:
	# Don't move while gathering
	if is_gathering:
		velocity = Vector2.ZERO
		return

	# Get input direction
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	# Apply movement
	if input_dir != Vector2.ZERO:
		velocity = input_dir.normalized() * speed
	else:
		velocity = Vector2.ZERO

	move_and_slide()

	# Flip sprite based on movement direction (using scale for ColorRect)
	if input_dir.x != 0 and sprite:
		sprite.scale.x = -1 if input_dir.x < 0 else 1

func _unhandled_input(event: InputEvent) -> void:
	# Shooting will be added later when we have projectiles
	pass

func take_damage(amount: int) -> void:
	current_health -= amount

	# Flash red for feedback
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color.RED, 0.1)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)

	if current_health <= 0:
		die()

func die() -> void:
	print("Keeper died!")
	queue_free()

func heal(amount: int) -> void:
	current_health = min(current_health + amount, max_health)
