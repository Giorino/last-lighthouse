## Global event bus for decoupled communication between systems
extends Node

# Day/Night cycle signals
signal day_started
signal night_approaching(seconds_left: int)
signal transition_started
signal night_started
signal night_ended

# Resource signals
signal resource_changed(type: Constants.ResourceType, amount: int)

# Combat signals
signal enemy_spawned(enemy: Node2D)
signal enemy_died(enemy: Node2D)
signal damage_dealt(target: Node2D, amount: int)

# Building signals
signal structure_placed(structure: Node2D)
signal structure_destroyed(structure: Node2D)

# Lighthouse signals
signal lighthouse_health_changed(current: int, max_health: int)
signal lighthouse_destroyed

# Wave signals
signal wave_started(wave_number: int, total_waves: int)
signal wave_completed(wave_number: int)
signal all_waves_completed

# Game state signals
signal game_over
signal game_won

# UI signals
signal show_notification(message: String)

# Camera signals
signal camera_shake(trauma: float)
