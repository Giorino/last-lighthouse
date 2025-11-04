## Camera Controller - Handles smooth following, zoom, and trauma-based screen shake
extends Camera2D
class_name CameraController

## Camera settings
@export var follow_target: Node2D
@export var follow_smoothing: float = 5.0
@export var camera_bounds_enabled: bool = true
@export var bounds_padding: float = 50.0

## PHASE 5D: Enhanced camera features
@export var look_ahead_enabled: bool = true
@export var look_ahead_distance: float = 30.0  # How far ahead to look
@export var look_ahead_smoothing: float = 2.0
@export var deadzone_radius: float = 10.0  # Camera won't move until target leaves this radius

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

## PHASE 5D: Look-ahead state
var target_velocity: Vector2 = Vector2.ZERO
var previous_target_pos: Vector2 = Vector2.ZERO

## PHASE 5D: Camera bounds (set externally or auto-detect from map)
var bounds_rect: Rect2 = Rect2(-10000, -10000, 20000, 20000)  # Default: very large

func _ready() -> void:
	# Initialize noise for shake effect
	noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.frequency = 4.0

	target_zoom = default_zoom
	zoom = default_zoom

	# PHASE 5D: Initialize look-ahead state
	if follow_target and is_instance_valid(follow_target):
		previous_target_pos = follow_target.global_position

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

## PHASE 5D: Enhanced smooth camera follow with look-ahead and deadzone
func _smooth_follow(delta: float) -> void:
	var target_pos = follow_target.global_position

	# Calculate target velocity for look-ahead
	target_velocity = (target_pos - previous_target_pos) / delta if delta > 0 else Vector2.ZERO
	previous_target_pos = target_pos

	# Apply look-ahead: camera moves ahead in movement direction
	var look_ahead_offset = Vector2.ZERO
	if look_ahead_enabled and target_velocity.length() > 10.0:  # Only look ahead if moving
		look_ahead_offset = target_velocity.normalized() * look_ahead_distance
		look_ahead_offset = look_ahead_offset.lerp(Vector2.ZERO, 1.0 / (target_velocity.length() * 0.01))  # Scale with speed

	var desired_pos = target_pos + look_ahead_offset

	# Apply deadzone: only move camera if target is far from camera center
	var distance_from_center = global_position.distance_to(desired_pos)
	if distance_from_center < deadzone_radius:
		return  # Don't move camera, target is within deadzone

	# Smooth interpolation to desired position
	global_position = global_position.lerp(desired_pos, follow_smoothing * delta)

	# PHASE 5D: Enforce camera bounds
	if camera_bounds_enabled:
		global_position.x = clamp(global_position.x, bounds_rect.position.x + bounds_padding,
								  bounds_rect.position.x + bounds_rect.size.x - bounds_padding)
		global_position.y = clamp(global_position.y, bounds_rect.position.y + bounds_padding,
								  bounds_rect.position.y + bounds_rect.size.y - bounds_padding)

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

## PHASE 5D: Set camera bounds
func set_bounds(rect: Rect2) -> void:
	bounds_rect = rect
	print("Camera bounds set: %s" % rect)

## PHASE 5D: Auto-detect bounds from TileMap or world size
func auto_detect_bounds() -> void:
	# Look for TileMap in scene
	var tilemap = get_tree().get_first_node_in_group("tilemap")
	if tilemap and tilemap is TileMap:
		var used_rect = tilemap.get_used_rect()
		var tile_size = tilemap.tile_set.tile_size if tilemap.tile_set else Vector2(16, 16)
		bounds_rect = Rect2(
			used_rect.position * tile_size,
			used_rect.size * tile_size
		)
		print("Auto-detected camera bounds from TileMap: %s" % bounds_rect)
	else:
		print("No TileMap found for auto-detecting bounds")

## PHASE 5D: Zoom effects for special events
func zoom_pulse(amount: float = 0.15, duration: float = 0.3) -> void:
	"""Quick zoom in and out for events like level-up"""
	var original_zoom = target_zoom
	target_zoom = original_zoom - Vector2(amount, amount)
	await get_tree().create_timer(duration).timeout
	target_zoom = original_zoom
