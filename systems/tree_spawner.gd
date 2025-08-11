extends Node3D

@export var tree_scene: PackedScene  # Legacy single tree (still supported)
@export var area_size: Vector2 = Vector2(150, 150)
@export var tree_count: int = 50
@export var min_distance: float = 3.0
@export var player_clearing_radius: float = 10.0
@export var additional_clearings: Array[Vector3] = []
@export var clearing_radius: float = 8.0

# Tree variety system
@export_group("Tree Variety")
@export var tree_scenes: Array[PackedScene] = []  # Multiple tree types
@export var tree_weights: Array[float] = []  # Probability weights for each tree type
@export var use_tree_variety: bool = false  # Enable multiple tree types

# Noise-based clustering parameters
@export_group("Noise Clustering")
@export var use_noise_clustering: bool = true
@export var noise_scale: float = 0.05  # Lower = bigger clusters
@export var noise_threshold: float = 0.3  # Higher = fewer trees (0.0 to 1.0)
@export var cluster_density: float = 0.7  # Chance to place tree in valid noise area
@export var noise_seed: int = 12345

var player_spawn_points: Array[Vector3] = []
var noise: FastNoiseLite
var cumulative_weights: Array[float] = []  # For weighted random selection

func _ready():
	# Initialize noise
	setup_noise()
	
	# Setup tree variety system
	setup_tree_weights()
	
	# Wait a frame for the scene to be fully loaded
	await get_tree().process_frame
	find_player_spawn_points()
	spawn_trees()

func setup_noise():
	noise = FastNoiseLite.new()
	noise.seed = noise_seed
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = noise_scale

func setup_tree_weights():
	if not use_tree_variety or tree_scenes.is_empty():
		return
	
	# If no weights specified, use equal weights
	if tree_weights.is_empty():
		tree_weights.resize(tree_scenes.size())
		tree_weights.fill(1.0)
	
	# Ensure weights array matches scenes array size
	while tree_weights.size() < tree_scenes.size():
		tree_weights.append(1.0)
	
	# Calculate cumulative weights for efficient random selection
	cumulative_weights.clear()
	var total = 0.0
	for weight in tree_weights:
		total += weight
		cumulative_weights.append(total)
	
	print("Tree variety setup: ", tree_scenes.size(), " tree types with weights: ", tree_weights)

func find_player_spawn_points():
	# Find all player nodes in the scene
	var players = get_tree().get_nodes_in_group("players")
	if players.is_empty():
		# Fallback: search for player nodes by name pattern
		var scene_root = get_tree().current_scene
		for child in scene_root.get_children():
			if child.name.begins_with("Player"):
				players.append(child)
	
	for player in players:
		player_spawn_points.append(player.global_position)
		print("Found player spawn at: ", player.global_position)

func spawn_trees():
	var positions = []
	var tries = 0
	var max_tries = tree_count * 30  # More tries needed for noise filtering
	
	while positions.size() < tree_count and tries < max_tries:
		var x = randf_range(-area_size.x/2, area_size.x/2)
		var z = randf_range(-area_size.y/2, area_size.y/2)
		var pos = Vector3(x, 0, z)
		
		if is_valid_tree_position(pos, positions):
			positions.append(pos)
		tries += 1
	
	print("Spawned ", positions.size(), " trees out of ", tree_count, " requested (", tries, " tries)")
	
	for pos in positions:
		var tree_scene_to_use = get_random_tree_scene()
		if tree_scene_to_use:
			var tree = tree_scene_to_use.instantiate()
			tree.position = pos
			# Add some random rotation for variety
			tree.rotation_degrees.y = randf() * 360.0
			add_child(tree)
		else:
			print("Warning: No tree scene available for spawning at ", pos)

func is_valid_tree_position(pos: Vector3, existing_positions: Array) -> bool:
	# First check noise clustering if enabled
	if use_noise_clustering:
		var noise_value = noise.get_noise_2d(pos.x, pos.z)
		# Convert from [-1,1] to [0,1] range
		var normalized_noise = (noise_value + 1.0) / 2.0
		
		# Check if position is in a "forest" area (above threshold)
		if normalized_noise < noise_threshold:
			return false
		
		# Even in valid noise areas, use cluster density for variation
		if randf() > cluster_density:
			return false
	
	# Check distance from player spawn points
	for spawn_point in player_spawn_points:
		if pos.distance_to(spawn_point) < player_clearing_radius:
			return false
	
	# Check distance from additional clearings
	for clearing in additional_clearings:
		if pos.distance_to(clearing) < clearing_radius:
			return false
	
	# Check distance from other trees
	for existing_pos in existing_positions:
		if pos.distance_to(existing_pos) < min_distance:
			return false
	
	return true

# Get a random tree scene based on weights
func get_random_tree_scene() -> PackedScene:
	# If tree variety is disabled or no scenes, fall back to single tree_scene
	if not use_tree_variety or tree_scenes.is_empty():
		return tree_scene
	
	# If only one scene in array, return it
	if tree_scenes.size() == 1:
		return tree_scenes[0]
	
	# Weighted random selection
	var random_value = randf() * cumulative_weights[-1]  # Last element is total weight
	
	for i in range(cumulative_weights.size()):
		if random_value <= cumulative_weights[i]:
			return tree_scenes[i]
	
	# Fallback (shouldn't happen)
	return tree_scenes[0]

# Method to add clearings at runtime if needed
func add_clearing(clearing_position: Vector3, radius: float = 8.0):
	additional_clearings.append(clearing_position)
	clearing_radius = radius
	
# Method to regenerate trees (useful for testing)
func regenerate_trees():
	# Remove existing trees
	for child in get_children():
		child.queue_free()
	await get_tree().process_frame
	spawn_trees()

# Method to regenerate with new noise seed
func regenerate_with_new_seed():
	noise_seed = randi()
	setup_noise()
	regenerate_trees()

# Method to get noise value at position (for debugging/visualization)
func get_noise_at_position(pos: Vector3) -> float:
	if noise:
		var noise_value = noise.get_noise_2d(pos.x, pos.z)
		return (noise_value + 1.0) / 2.0  # Convert to 0-1 range
	return 0.0

# Helper methods for tree variety management
func add_tree_type(scene: PackedScene, weight: float = 1.0):
	"""Add a new tree type with specified weight"""
	tree_scenes.append(scene)
	tree_weights.append(weight)
	setup_tree_weights()

func remove_tree_type(index: int):
	"""Remove a tree type by index"""
	if index >= 0 and index < tree_scenes.size():
		tree_scenes.remove_at(index)
		if index < tree_weights.size():
			tree_weights.remove_at(index)
		setup_tree_weights()

func set_tree_weight(index: int, weight: float):
	"""Set the weight for a specific tree type"""
	if index >= 0 and index < tree_weights.size():
		tree_weights[index] = weight
		setup_tree_weights()

func get_tree_type_stats() -> Dictionary:
	"""Get statistics about tree type distribution"""
	var stats = {}
	if use_tree_variety and not tree_scenes.is_empty():
		var total_weight = cumulative_weights[-1] if not cumulative_weights.is_empty() else 0.0
		for i in range(tree_scenes.size()):
			var scene_name = tree_scenes[i].resource_path.get_file().get_basename()
			var percentage = (tree_weights[i] / total_weight * 100.0) if total_weight > 0 else 0.0
			stats[scene_name] = {
				"weight": tree_weights[i],
				"percentage": percentage
			}
	return stats
