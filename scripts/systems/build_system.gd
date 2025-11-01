## Grid-based building placement system
class_name BuildSystem
extends Node2D

## Available structures
const WALL_SCENE = preload("res://scenes/structures/wall.tscn")

## Build mode state
var build_mode: bool = false
var selected_structure: PackedScene = null
var ghost_instance: Node2D = null

## Grid size
const TILE_SIZE: int = Constants.TILE_SIZE

func _ready() -> void:
	# Listen for build mode input
	pass

func _process(_delta: float) -> void:
	if build_mode and ghost_instance:
		# Snap ghost to grid
		var mouse_pos = get_global_mouse_position()
		var grid_pos = snap_to_grid(mouse_pos)
		ghost_instance.global_position = grid_pos

		# Check if valid placement
		var is_valid = check_placement_valid(grid_pos)
		if ghost_instance.has_node("Sprite2D"):
			var sprite = ghost_instance.get_node("Sprite2D")
			sprite.modulate = Color.GREEN if is_valid else Color.RED

func _input(event: InputEvent) -> void:
	# Toggle build mode with B key
	if event.is_action_pressed("build_mode"):
		if not build_mode:
			enter_build_mode(WALL_SCENE)
		else:
			exit_build_mode()

	# Place structure with left click
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and build_mode:
			place_structure()

	# Cancel with right click
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed and build_mode:
			exit_build_mode()

func enter_build_mode(structure: PackedScene) -> void:
	if not GameManager.enable_building:
		print("Cannot build during night!")
		return

	build_mode = true
	selected_structure = structure

	# Create ghost preview
	ghost_instance = structure.instantiate()

	# Make it semi-transparent
	if ghost_instance.has_node("Sprite2D"):
		var sprite = ghost_instance.get_node("Sprite2D")
		sprite.modulate.a = 0.5

	# Disable collision for ghost
	if ghost_instance.has_node("CollisionShape2D"):
		var collision = ghost_instance.get_node("CollisionShape2D")
		collision.disabled = true

	add_child(ghost_instance)
	print("Entered build mode")

func exit_build_mode() -> void:
	build_mode = false
	selected_structure = null

	if ghost_instance:
		ghost_instance.queue_free()
		ghost_instance = null

	print("Exited build mode")

func snap_to_grid(pos: Vector2) -> Vector2:
	return Vector2(
		floor(pos.x / TILE_SIZE) * TILE_SIZE + TILE_SIZE / 2.0,
		floor(pos.y / TILE_SIZE) * TILE_SIZE + TILE_SIZE / 2.0
	)

func check_placement_valid(pos: Vector2) -> bool:
	# For now, just check if not overlapping with existing structures
	# In a full implementation, you'd check terrain, build radius, etc.

	# Check for overlapping structures
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = pos
	query.collision_mask = 1  # Adjust based on your collision layers

	var result = space_state.intersect_point(query, 10)

	# If we hit any structures, placement is invalid
	for hit in result:
		if hit.collider.is_in_group("structures"):
			return false

	return true

func place_structure() -> void:
	if not ghost_instance:
		return

	var grid_pos = ghost_instance.global_position

	if not check_placement_valid(grid_pos):
		print("Invalid placement!")
		return

	# Get structure data for costs
	var structure = selected_structure.instantiate()
	if not structure.has_method("get"):
		structure.queue_free()
		return

	var costs = structure.costs

	# Check if can afford
	if not ResourceManager.can_afford(costs):
		print("Not enough resources!")
		structure.queue_free()
		return

	# Spend resources
	ResourceManager.spend_resources(costs)

	# Place the structure
	structure.global_position = grid_pos
	get_parent().add_child(structure)

	EventBus.structure_placed.emit(structure)
	print("Structure placed!")

	# Don't exit build mode - allow placing multiple
