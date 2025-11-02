## Time Scale Manager - Handles hit pause, slow-mo, and freeze frames
extends Node

## Hit pause settings
@export var hit_pause_enabled: bool = true
@export var light_hit_duration: float = 0.05
@export var medium_hit_duration: float = 0.1
@export var heavy_hit_duration: float = 0.15

## Current time scale state
var is_paused: bool = false
var pause_end_time: float = 0.0  # Use absolute time instead of countdown

func _ready() -> void:
	# Set to always process even when paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	print("TimeScaleManager initialized")

func _process(_delta: float) -> void:
	# Handle hit pause timer using absolute time
	if is_paused:
		var current_time = Time.get_ticks_msec() / 1000.0
		if current_time >= pause_end_time:
			_resume_time()

## Hit pause for light impacts (hits, small damage)
func hit_pause_light() -> void:
	if hit_pause_enabled:
		_apply_hit_pause(light_hit_duration)

## Hit pause for medium impacts (kills, explosions)
func hit_pause_medium() -> void:
	if hit_pause_enabled:
		_apply_hit_pause(medium_hit_duration)

## Hit pause for heavy impacts (boss kills, structure destruction)
func hit_pause_heavy() -> void:
	if hit_pause_enabled:
		_apply_hit_pause(heavy_hit_duration)

## Apply hit pause with custom duration
func hit_pause_custom(duration: float) -> void:
	if hit_pause_enabled:
		_apply_hit_pause(duration)

## Internal hit pause implementation
func _apply_hit_pause(duration: float) -> void:
	var current_time = Time.get_ticks_msec() / 1000.0
	var new_end_time = current_time + duration

	if is_paused:
		# If already paused, extend the duration if needed
		pause_end_time = max(pause_end_time, new_end_time)
	else:
		is_paused = true
		pause_end_time = new_end_time
		Engine.time_scale = 0.0

## Resume normal time
func _resume_time() -> void:
	is_paused = false
	pause_end_time = 0.0
	Engine.time_scale = 1.0

## Slow motion effect
func apply_slow_motion(time_scale: float, duration: float) -> void:
	Engine.time_scale = clamp(time_scale, 0.1, 1.0)

	if duration > 0.0:
		await get_tree().create_timer(duration, true, false, true).timeout
		Engine.time_scale = 1.0

## Enable/disable hit pause
func set_hit_pause_enabled(enabled: bool) -> void:
	hit_pause_enabled = enabled

## Get current time scale
func get_time_scale() -> float:
	return Engine.time_scale

## Force resume (for debugging or special cases)
func force_resume() -> void:
	_resume_time()
