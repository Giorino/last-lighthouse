## Manages the day/night cycle and phase transitions
class_name DayNightCycle
extends Node

## Current phase and timing
var current_phase: Constants.Phase = Constants.Phase.DAY
var time_remaining: float = 0.0
var current_night: int = 1

## Warning flags
var warned_30_seconds: bool = false

func _ready() -> void:
	# Start the first day
	start_day_phase()

func _process(delta: float) -> void:
	if GameManager.is_paused:
		return

	match current_phase:
		Constants.Phase.DAY:
			_process_day_phase(delta)
		Constants.Phase.TRANSITION:
			_process_transition_phase(delta)
		Constants.Phase.NIGHT:
			_process_night_phase(delta)

func _process_day_phase(delta: float) -> void:
	time_remaining -= delta

	# Warning at 30 seconds
	if time_remaining <= 30.0 and not warned_30_seconds:
		warned_30_seconds = true
		EventBus.night_approaching.emit(30)
		EventBus.show_notification.emit("Night approaches in 30 seconds!")

	# Warning at 10 seconds
	if time_remaining <= 10.0 and time_remaining > 9.0:
		EventBus.night_approaching.emit(10)
		EventBus.show_notification.emit("Night approaches in 10 seconds!")

	if time_remaining <= 0:
		start_transition()

func _process_transition_phase(delta: float) -> void:
	time_remaining -= delta

	if time_remaining <= 0:
		start_night_phase()

func _process_night_phase(_delta: float) -> void:
	# Night ends when all waves are completed
	# This is handled by the wave spawner emitting all_waves_completed
	pass

func start_day_phase() -> void:
	current_phase = Constants.Phase.DAY
	time_remaining = Constants.DAY_DURATION
	warned_30_seconds = false

	# Enable day mechanics
	GameManager.enable_building = true
	GameManager.enable_scavenging = true

	EventBus.day_started.emit()
	print("=== DAY %d STARTED ===" % current_night)

func start_transition() -> void:
	current_phase = Constants.Phase.TRANSITION
	time_remaining = Constants.TRANSITION_DURATION

	# Disable day mechanics
	GameManager.enable_building = false
	GameManager.enable_scavenging = false

	EventBus.transition_started.emit()
	print("=== TRANSITION PHASE ===")

func start_night_phase() -> void:
	current_phase = Constants.Phase.NIGHT

	# Disable day mechanics (should already be disabled)
	GameManager.enable_building = false
	GameManager.enable_scavenging = false

	EventBus.night_started.emit()
	print("=== NIGHT %d STARTED ===" % current_night)

func end_night_phase() -> void:
	print("=== NIGHT %d SURVIVED ===" % current_night)
	EventBus.night_ended.emit()

	# Check victory condition
	if GameManager.check_victory_condition(20):
		EventBus.game_won.emit()
		print("=== GAME WON! ===")
		return

	# Advance to next night
	current_night += 1
	GameManager.current_night = current_night

	# Start next day
	start_day_phase()

## Get remaining time in current phase
func get_time_remaining() -> float:
	return time_remaining

## Get current phase
func get_current_phase() -> Constants.Phase:
	return current_phase
