## Grid-based building placement system
class_name BuildSystem
extends Node2D

## Available structures
const WALL_SCENE = preload("res://scenes/structures/wall.tscn")
const BARRICADE_SCENE = preload("res://scenes/structures/barricade.tscn")
const TURRET_SCENE = preload("res://scenes/structures/turret.tscn")
const TRAP_SCENE = preload("res://scenes/structures/trap.tscn")
const GENERATOR_SCENE = preload("res://scenes/structures/generator.tscn")

## Structure catalog for easy access
var structure_catalog: Dictionary = {
	1: {"name": "Wall", "scene": WALL_SCENE, "description": "Solid defensive wall"},
	2: {"name": "Barricade", "scene": BARRICADE_SCENE, "description": "Cheap, weak barrier"},
	3: {"name": "Turret", "scene": TURRET_SCENE, "description": "Auto-targeting defense"},
	4: {"name": "Trap", "scene": TRAP_SCENE, "description": "Spike trap"},
	5: {"name": "Generator", "scene": GENERATOR_SCENE, "description": "Powers nearby turrets"}
}

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
	# Number keys to select structure (1-5)
	if event is InputEventKey and event.pressed and not event.echo:
		for key in structure_catalog.keys():
			if event.keycode == KEY_0 + key:  # KEY_1, KEY_2, etc.
				var structure_data = structure_catalog[key]
				print("Selected: %s" % structure_data.name)

				if build_mode:
					# Switch structure in build mode
					exit_build_mode()
					enter_build_mode(structure_data.scene)
				else:
					# Enter build mode with selected structure
					enter_build_mode(structure_data.scene)
				return

	# Toggle build mode with B key (default to wall)
	if event.is_action_pressed("build_mode"):
		if not build_mode:
			enter_build_mode(WALL_SCENE)
		else:
			exit_build_mode()

	# Place structure with left click
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and build_mode:
			place_structure()

	# Cancel with right click or ESC
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed and build_mode:
			exit_build_mode()

	if event.is_action_pressed("ui_cancel") and build_mode:
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

	# Show build menu
	show_build_menu()

	print("Entered build mode")

func exit_build_mode() -> void:
	build_mode = false
	selected_structure = null

	if ghost_instance:
		ghost_instance.queue_free()
		ghost_instance = null

	# Hide build menu
	hide_build_menu()

	print("Exited build mode")

func show_build_menu() -> void:
	"""Show the build menu UI"""
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_node("BuildMenu"):
		hud.get_node("BuildMenu").visible = true

func hide_build_menu() -> void:
	"""Hide the build menu UI"""
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_node("BuildMenu"):
		hud.get_node("BuildMenu").visible = false

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

	# Get costs from ghost_instance (already initialized via _ready())
	# The ghost_instance is already in the scene tree, so its _ready() has been called
	var base_costs = ghost_instance.costs

	# Apply cost reduction upgrade
	var cost_multiplier = GameManager.get_build_cost_multiplier()
	var costs = {}
	for resource_type in base_costs:
		costs[resource_type] = ceili(base_costs[resource_type] * cost_multiplier)

	# Check if can afford
	if not ResourceManager.can_afford(costs):
		print("Not enough resources!")
		return

	# Spend resources
	ResourceManager.spend_resources(costs)

	# Create the actual structure for placement
	var structure = selected_structure.instantiate()
	structure.global_position = grid_pos
	get_parent().add_child(structure)

	# Juice: Build particles effect
	if VisualEffectsManager:
		VisualEffectsManager.spawn_build_particles(grid_pos)

	EventBus.structure_placed.emit(structure)
	print("Structure placed!")

	# Don't exit build mode - allow placing multiple
