## Manages dynamic navigation mesh updates for pathfinding
## Updates the navigation mesh when structures are placed or destroyed
class_name NavigationManager
extends Node

## Navigation region reference
var navigation_region: NavigationRegion2D = null

## Game bounds for navigation
var map_width: int = 320
var map_height: int = 180

## Grid size
const TILE_SIZE: int = Constants.TILE_SIZE

func _ready() -> void:
	# Connect to structure events
	EventBus.structure_placed.connect(_on_structure_placed)
	EventBus.structure_destroyed.connect(_on_structure_destroyed)

func initialize(nav_region: NavigationRegion2D) -> void:
	navigation_region = nav_region
	
	# Create initial navigation mesh
	create_base_navigation_mesh()
	
	print("NavigationManager initialized")

func create_base_navigation_mesh() -> void:
	if not navigation_region:
		push_error("NavigationRegion2D not set!")
		return
	
	# Create a NavigationPolygon that covers the entire playable area
	var nav_poly = NavigationPolygon.new()
	
	# Define the outer boundary (entire map)
	var outer_boundary = PackedVector2Array([
		Vector2(0, 0),
		Vector2(map_width, 0),
		Vector2(map_width, map_height),
		Vector2(0, map_height)
	])
	
	nav_poly.add_outline(outer_boundary)
	
	# Use the newer baking method (Godot 4.4+)
	var source_geometry = NavigationMeshSourceGeometryData2D.new()
	NavigationServer2D.parse_source_geometry_data(nav_poly, source_geometry, navigation_region)
	NavigationServer2D.bake_from_source_geometry_data(nav_poly, source_geometry)
	
	navigation_region.navigation_polygon = nav_poly
	
	print("Base navigation mesh created")

func rebuild_navigation_mesh() -> void:
	"""Rebuild the entire navigation mesh based on current structures"""
	if not navigation_region:
		return
	
	var nav_poly = NavigationPolygon.new()
	
	# Clear existing outlines
	nav_poly.clear_outlines()
	
	# Add the outer boundary
	var outer_boundary = PackedVector2Array([
		Vector2(0, 0),
		Vector2(map_width, 0),
		Vector2(map_width, map_height),
		Vector2(0, map_height)
	])
	
	nav_poly.add_outline(outer_boundary)
	
	# Add obstacles for each structure (as holes in the navigation mesh)
	var structures = get_tree().get_nodes_in_group("structures")
	for structure in structures:
		if structure and is_instance_valid(structure):
			add_structure_obstacle(nav_poly, structure)
	
	# Use the newer baking method (Godot 4.4+)
	var source_geometry = NavigationMeshSourceGeometryData2D.new()
	NavigationServer2D.parse_source_geometry_data(nav_poly, source_geometry, navigation_region)
	NavigationServer2D.bake_from_source_geometry_data(nav_poly, source_geometry)
	
	navigation_region.navigation_polygon = nav_poly
	
	print("Navigation mesh rebuilt with %d structures" % structures.size())

func add_structure_obstacle(nav_poly: NavigationPolygon, structure: Node2D) -> void:
	"""Add a structure as an obstacle in the navigation mesh"""
	var pos = structure.global_position
	
	# Create a small obstacle around the structure position
	# Using half tile size for the obstacle
	var half_size = TILE_SIZE / 2.0
	
	var obstacle = PackedVector2Array([
		pos + Vector2(-half_size, -half_size),
		pos + Vector2(half_size, -half_size),
		pos + Vector2(half_size, half_size),
		pos + Vector2(-half_size, half_size)
	])
	
	# Add as an obstacle (hole in the navigation mesh)
	nav_poly.add_outline(obstacle)

func _on_structure_placed(_structure: Node2D) -> void:
	"""Called when a structure is placed"""
	# Rebuild navigation mesh to include the new obstacle
	await get_tree().process_frame  # Wait one frame for structure to be added to scene
	rebuild_navigation_mesh()

func _on_structure_destroyed(_structure: Node2D) -> void:
	"""Called when a structure is destroyed"""
	# Rebuild navigation mesh to remove the obstacle
	await get_tree().process_frame  # Wait one frame for structure to be removed
	rebuild_navigation_mesh()

