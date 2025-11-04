## Visual Effects Manager - Centralized particle and visual effect spawning
extends Node

## Preloaded particle effects
var hit_effect: PackedScene
var death_explosion: PackedScene
var muzzle_flash: PackedScene
var build_particles: PackedScene
var level_up_particles: PackedScene  # PHASE 5

func _ready() -> void:
	# Load all effect scenes
	hit_effect = load("res://scenes/effects/hit_effect.tscn")
	death_explosion = load("res://scenes/effects/death_explosion.tscn")
	muzzle_flash = load("res://scenes/effects/muzzle_flash.tscn")
	build_particles = load("res://scenes/effects/build_particles.tscn")
	level_up_particles = load("res://scenes/effects/level_up_particles.tscn")  # PHASE 5

	print("VisualEffectsManager initialized")

## Spawn a hit effect at a position
func spawn_hit_effect(position: Vector2, parent: Node = null) -> void:
	_spawn_effect(hit_effect, position, parent)

## Spawn a death explosion at a position
func spawn_death_explosion(position: Vector2, parent: Node = null) -> void:
	_spawn_effect(death_explosion, position, parent)

## Spawn a muzzle flash at a position with optional rotation
func spawn_muzzle_flash(position: Vector2, rotation_degrees: float = 0.0, parent: Node = null) -> void:
	var effect = _spawn_effect(muzzle_flash, position, parent)
	if effect:
		effect.rotation_degrees = rotation_degrees

## Spawn build/placement particles at a position
func spawn_build_particles(position: Vector2, parent: Node = null) -> void:
	_spawn_effect(build_particles, position, parent)

## PHASE 5: Spawn level-up celebration particles at a position
func spawn_level_up_particles(position: Vector2, parent: Node = null) -> void:
	_spawn_effect(level_up_particles, position, parent)

## Generic effect spawner
func _spawn_effect(effect_scene: PackedScene, position: Vector2, parent: Node = null) -> Node2D:
	if not effect_scene:
		push_error("Effect scene is null!")
		return null

	var instance = effect_scene.instantiate()
	if not instance:
		push_error("Failed to instantiate effect!")
		return null

	# Determine parent node
	var target_parent = parent
	if not target_parent:
		# Use the current scene's root
		target_parent = get_tree().current_scene

	target_parent.add_child(instance)
	instance.global_position = position

	# Start emission if it's a particle system
	# Note: ParticleEffect script handles auto-cleanup, so we don't need to schedule it here
	if instance is GPUParticles2D or instance is CPUParticles2D:
		instance.emitting = true

	return instance
