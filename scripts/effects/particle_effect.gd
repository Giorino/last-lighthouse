## Base class for auto-destroying particle effects
extends GPUParticles2D
class_name ParticleEffect

## Automatically free the effect when particles are done
@export var auto_destroy: bool = true

func _ready() -> void:
	# One-shot by default
	one_shot = true
	emitting = true

	if auto_destroy:
		# Wait for lifetime + a bit of buffer
		await get_tree().create_timer(lifetime + 0.5).timeout
		queue_free()

## Play the effect
func play() -> void:
	restart()
	emitting = true

## Spawn this effect at a position in the scene
static func spawn(effect_scene: PackedScene, spawn_position: Vector2, parent: Node = null) -> ParticleEffect:
	if not effect_scene:
		push_error("ParticleEffect.spawn: effect_scene is null!")
		return null

	var instance = effect_scene.instantiate() as ParticleEffect
	if not instance:
		push_error("ParticleEffect.spawn: Failed to instantiate effect!")
		return null

	# Add to parent or root
	var target_parent = parent if parent else Engine.get_main_loop().current_scene
	target_parent.add_child(instance)

	instance.global_position = spawn_position
	instance.emitting = true

	return instance
