## Manages the day/night cycle and phase transitions
class_name DayNightCycle
extends Node

## Current phase and timing
var current_phase: Constants.Phase = Constants.Phase.NIGHT
var time_remaining: float = 0.0
var current_night: int = 1

## Warning flags
var warned_30_seconds: bool = false

func _ready() -> void:
	# PHASE 5: Start with first night (not day)
	start_night_phase()

func _process(delta: float) -> void:
	if GameManager.is_paused:
		return

	# PHASE 5: Removed transition phase, direct Day/Night switching
	match current_phase:
		Constants.Phase.DAY:
			_process_day_phase(delta)
		Constants.Phase.NIGHT:
			_process_night_phase(delta)

func _process_day_phase(delta: float) -> void:
	time_remaining -= delta

	# PHASE 5: Day is only 30s, warn at 10s
	if time_remaining <= 10.0 and not warned_30_seconds:
		warned_30_seconds = true
		EventBus.night_approaching.emit(10)
		EventBus.show_notification.emit("Night approaches in 10 seconds!")

	if time_remaining <= 0:
		# PHASE 5: Go directly to night (no transition)
		start_night_phase()

func _process_night_phase(delta: float) -> void:
	# PHASE 5: Timer counts down during night
	time_remaining -= delta

	# Night can end in two ways:
	# 1. Timer reaches 0
	# 2. All waves completed (handled by wave spawner)
	if time_remaining <= 0:
		end_night_phase()

func start_day_phase() -> void:
	current_phase = Constants.Phase.DAY
	time_remaining = Constants.DAY_DURATION  # 30 seconds
	warned_30_seconds = false

	# PHASE 5: Enable building during day
	GameManager.enable_building = true
	GameManager.enable_scavenging = false  # No scavenging in Phase 5

	EventBus.day_started.emit()
	print("=== DAY %d STARTED (30s build phase) ===" % current_night)

func start_night_phase() -> void:
	current_phase = Constants.Phase.NIGHT

	# Disable building during night
	GameManager.enable_building = false
	GameManager.enable_scavenging = false

	# PHASE 5: Progressive night duration
	# Night 1: 60s, Night 2: 90s, Night 3: 120s, Night 4: 150s, Night 5+: 180s
	var night_duration: float
	match current_night:
		1:
			night_duration = 60.0
		2:
			night_duration = 90.0
		3:
			night_duration = 120.0
		4:
			night_duration = 150.0
		_:
			night_duration = 180.0  # Capped at 3 minutes

	time_remaining = night_duration

	EventBus.night_started.emit()
	print("=== NIGHT %d STARTED (%ds duration) ===" % [current_night, int(night_duration)])

func end_night_phase() -> void:
	print("=== NIGHT %d SURVIVED ===" % current_night)
	EventBus.night_ended.emit()

	# PHASE 5: No win condition, endless survival
	# Advance to next night
	current_night += 1
	GameManager.current_night = current_night

	# Start next day (30s build phase)
	start_day_phase()

## Get remaining time in current phase
func get_time_remaining() -> float:
	return time_remaining

## Get current phase
func get_current_phase() -> Constants.Phase:
	return current_phase
