## Camera Controller - Handles smooth following, zoom, and trauma-based screen shake
extends Camera2D
class_name CameraController

## Camera settings
@export var follow_target: Node2D
@export var follow_smoothing: float = 5.0
@export var camera_bounds_enabled: bool = true
@export var bounds_padding: float = 50.0

## Shake settings
@export var shake_decay: float = 2.0  # How fast trauma decays
@export var max_shake_offset: float = 8.0  # Maximum shake offset in pixels
@export var max_shake_rotation: float = 4.0  # Maximum shake rotation in degrees

## Zoom settings
@export var default_zoom: Vector2 = Vector2(1.0, 1.0)
@export var zoom_smoothing: float = 3.0

## Current trauma (0.0 to 1.0)
var trauma: float = 0.0
var trauma_power: float = 2.0  # Exponential trauma effect

## Target zoom
var target_zoom: Vector2 = Vector2(1.0, 1.0)

## Noise for shake randomness
var noise: FastNoiseLite
var noise_y_offset: float = 100.0

func _ready() -> void:
	# Initialize noise for shake effect
	noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.frequency = 4.0

	target_zoom = default_zoom
	zoom = default_zoom

	# Connect to EventBus for global shake events
	EventBus.camera_shake.connect(add_trauma)

	print("CameraController initialized")

func _process(delta: float) -> void:
	# Handle camera follow
	if follow_target and is_instance_valid(follow_target):
		_smooth_follow(delta)

	# Handle zoom interpolation
	zoom = zoom.lerp(target_zoom, zoom_smoothing * delta)

	# Handle screen shake
	if trauma > 0.0:
		_apply_shake(delta)
		trauma = max(trauma - shake_decay * delta, 0.0)
	else:
		# Reset offset and rotation when no trauma
		offset = Vector2.ZERO
		rotation = 0.0

## Smooth camera follow
func _smooth_follow(delta: float) -> void:
	var target_pos = follow_target.global_position
	global_position = global_position.lerp(target_pos, follow_smoothing * delta)

## Apply camera shake based on trauma
func _apply_shake(_delta: float) -> void:
	var shake_amount = pow(trauma, trauma_power)

	# Use noise for smooth random shake
	var time = Time.get_ticks_msec() / 1000.0
	offset.x = max_shake_offset * shake_amount * noise.get_noise_2d(time * 50.0, 0.0)
	offset.y = max_shake_offset * shake_amount * noise.get_noise_2d(0.0, time * 50.0 + noise_y_offset)
	rotation_degrees = max_shake_rotation * shake_amount * noise.get_noise_2d(time * 50.0, noise_y_offset)

## Add trauma to the camera (0.0 to 1.0)
func add_trauma(amount: float) -> void:
	trauma = clamp(trauma + amount, 0.0, 1.0)

## Shake presets for common events
func shake_light() -> void:
	add_trauma(0.2)

func shake_medium() -> void:
	add_trauma(0.5)

func shake_heavy() -> void:
	add_trauma(0.8)

## Set the follow target
func set_follow_target(target: Node2D) -> void:
	follow_target = target

## Zoom functions
func set_zoom_level(new_zoom: Vector2, instant: bool = false) -> void:
	target_zoom = new_zoom
	if instant:
		zoom = new_zoom

func zoom_in(amount: float = 0.1) -> void:
	target_zoom += Vector2(amount, amount)

func zoom_out(amount: float = 0.1) -> void:
	target_zoom -= Vector2(amount, amount)
	target_zoom = target_zoom.clamp(Vector2(0.5, 0.5), Vector2(3.0, 3.0))

func reset_zoom() -> void:
	target_zoom = default_zoom
