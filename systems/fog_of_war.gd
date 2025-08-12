extends Node3D
class_name FogOfWar

## Fog of War System
## Manages exploration and visibility for survival gameplay

signal area_explored(world_position: Vector2)

# Configuration
@export var grid_size: float = 2.0  # Size of each exploration tile
@export var vision_radius: float = 8.0  # How far players can see
@export var world_bounds: Vector2 = Vector2(150, 150)  # Match ground plane size
@export var fog_intensity: float = 0.8  # How dark unexplored areas are (0-1)
@export var memory_fade: float = 0.5  # How dark previously seen areas are (0-1)
@export var debug_enabled: bool = false  # Enable debug output

# Internal state
var explored_tiles: Dictionary = {}  # Vector2i -> ExplorationState
var currently_visible_tiles: Dictionary = {}  # Vector2i -> bool
var players: Array = []  # Change from Array[Node3D] to Array to avoid type errors
var fog_texture: ImageTexture
var fog_material: ShaderMaterial
var fog_quad: MeshInstance3D

# Grid calculations
var grid_width: int
var grid_height: int
var world_offset: Vector2

enum ExplorationState {
	UNEXPLORED,
	EXPLORED,
	CURRENTLY_VISIBLE
}

func _ready():
	print("[FogOfWar] Initializing fog of war system...")
	setup_grid()
	create_fog_rendering()
	find_players()
	
	# Update fog every frame for smooth player movement
	set_process(true)

func setup_grid():
	"""Calculate grid dimensions and world offset"""
	grid_width = int(ceil(world_bounds.x / grid_size))
	grid_height = int(ceil(world_bounds.y / grid_size))
	world_offset = Vector2(-world_bounds.x/2, -world_bounds.y/2)
	
	print("[FogOfWar] Grid setup: ", grid_width, "x", grid_height, " tiles")
	print("[FogOfWar] World bounds: ", world_bounds, " offset: ", world_offset)

func create_fog_rendering():
	"""Create the visual fog overlay using a ground-projected plane"""
	
	# Create a large plane that covers the ground area
	fog_quad = MeshInstance3D.new()
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = world_bounds
	plane_mesh.subdivide_width = 1
	plane_mesh.subdivide_depth = 1
	fog_quad.mesh = plane_mesh
	
	# Position it slightly above ground to avoid z-fighting, but keep it flat
	fog_quad.position = Vector3(0, 0.05, 0)
	fog_quad.rotation_degrees = Vector3(0, 0, 0)  # Keep it horizontal
	
	# Create fog texture (will be updated each frame)
	var fog_image = Image.create(grid_width, grid_height, false, Image.FORMAT_R8)
	fog_image.fill(Color.WHITE)  # Start with everything fogged
	fog_texture = ImageTexture.create_from_image(fog_image)
	
	# Create shader material for the fog
	create_fog_shader()
	
	add_child(fog_quad)
	print("[FogOfWar] Fog rendering setup complete")

func create_fog_shader():
	"""Create a shader that renders the fog of war effect with correct world mapping"""
	
	fog_material = ShaderMaterial.new()
	
	var shader_code = """
shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never, depth_test_disabled, shadows_disabled, vertex_lighting, ambient_light_disabled;

uniform sampler2D fog_texture : source_color, filter_linear;
uniform float fog_intensity : hint_range(0.0, 1.0) = 0.8;
uniform float memory_fade : hint_range(0.0, 1.0) = 0.5;
uniform vec2 world_bounds;
uniform vec2 world_offset;

varying vec3 world_position;

void vertex() {
	world_position = VERTEX;
}

void fragment() {
	// Convert world position to UV coordinates
	vec2 world_pos_2d = vec2(world_position.x, world_position.z);
	vec2 relative_pos = world_pos_2d - world_offset;
	vec2 fog_uv = relative_pos / world_bounds;
	
	// Flip Y coordinate to match texture orientation
	fog_uv.y = 1.0 - fog_uv.y;
	
	// Sample fog texture with linear filtering for smooth edges
	float fog_value = texture(fog_texture, fog_uv).r;
	
	// Create smooth fog effect based on exploration state
	float alpha = 0.0;
	
	// Smooth transitions between states
	if (fog_value > 0.75) {
		// Unexplored - full fog with smooth transition
		alpha = fog_intensity * smoothstep(0.75, 1.0, fog_value);
	} else if (fog_value > 0.25) {
		// Explored but not currently visible - memory fade with smooth transition
		alpha = memory_fade * smoothstep(0.25, 0.75, fog_value);
	} else {
		// Currently visible - no fog with smooth transition to memory
		alpha = memory_fade * (1.0 - smoothstep(0.0, 0.25, fog_value));
	}
	
	ALBEDO = vec3(0.5, 0.5, 0.5);  // Black fog
	ALPHA = alpha;
}
"""
	
	var shader = Shader.new()
	shader.code = shader_code
	fog_material.shader = shader
	fog_material.set_shader_parameter("fog_texture", fog_texture)
	fog_material.set_shader_parameter("fog_intensity", fog_intensity)
	fog_material.set_shader_parameter("memory_fade", memory_fade)
	fog_material.set_shader_parameter("world_bounds", world_bounds)
	fog_material.set_shader_parameter("world_offset", world_offset)
	
	fog_quad.material_override = fog_material

func update_shader_parameters():
	"""Update shader parameters when exported variables change"""
	if fog_material:
		fog_material.set_shader_parameter("fog_intensity", fog_intensity)
		fog_material.set_shader_parameter("memory_fade", memory_fade)
		fog_material.set_shader_parameter("world_bounds", world_bounds)
		fog_material.set_shader_parameter("world_offset", world_offset)

func find_players():
	"""Find all player nodes in the scene"""
	players.clear()
	var scene_root = get_tree().current_scene
	find_players_recursive(scene_root)
	print("[FogOfWar] Found ", players.size(), " players")

func find_players_recursive(node: Node):
	"""Recursively find player nodes"""
	# Look for CharacterBody3D nodes that are likely players
	if node is CharacterBody3D and node.name.begins_with("Player"):
		players.append(node)
		print("[FogOfWar] Found player: ", node.name, " at ", node.global_position)
		return
	
	# Also check for nodes with player_id method as backup
	if node.has_method("get_player_id"):
		# If it's a component, try to get the parent player node
		var parent = node.get_parent()
		if parent is CharacterBody3D and parent.name.begins_with("Player"):
			# Check if we already added this player
			if parent not in players:
				players.append(parent)
				print("[FogOfWar] Found player via component: ", parent.name, " at ", parent.global_position)
		else:
			print("[FogOfWar] Found player method but no valid player parent: ", node.name, " (", node.get_class(), ")")
	
	for child in node.get_children():
		find_players_recursive(child)

func _process(_delta):
	"""Update fog of war based on player positions"""
	update_player_vision()
	update_fog_texture()
	update_shader_parameters()

func update_player_vision():
	"""Update which tiles are currently visible to players"""
	# Reset current visibility
	currently_visible_tiles.clear()
	
	if debug_enabled:
		print("[FogOfWar] Updating vision for ", players.size(), " players")
	
	# Check vision for each player
	for i in range(players.size()):
		var player = players[i]
		if not is_instance_valid(player):
			if debug_enabled:
				print("[FogOfWar] Player ", i, " is invalid")
			continue
			
		var player_pos = Vector2(player.global_position.x, player.global_position.z)
		var grid_pos = world_to_grid(player_pos)
		if debug_enabled:
			print("[FogOfWar] Player ", i, " at world pos: ", player.global_position, " -> 2D pos: ", player_pos, " -> grid: ", grid_pos)
		reveal_around_position(player_pos)

func reveal_around_position(world_pos: Vector2):
	"""Reveal tiles around a world position using circular vision"""
	var grid_pos = world_to_grid(world_pos)
	var radius_in_tiles = int(ceil(vision_radius / grid_size))
	
	# Check tiles in a square area, but use circular distance for actual revelation
	for x in range(-radius_in_tiles, radius_in_tiles + 1):
		for y in range(-radius_in_tiles, radius_in_tiles + 1):
			var tile_pos = Vector2i(grid_pos.x + x, grid_pos.y + y)
			
			# Check if tile is within bounds
			if tile_pos.x < 0 or tile_pos.x >= grid_width or tile_pos.y < 0 or tile_pos.y >= grid_height:
				continue
			
			# Check if tile is within vision radius using proper circular distance
			var tile_world_pos = grid_to_world(tile_pos)
			var distance = world_pos.distance_to(tile_world_pos)
			
			if distance <= vision_radius:
				# Mark as currently visible
				currently_visible_tiles[tile_pos] = true
				
				# Mark as explored if it wasn't before
				if not explored_tiles.has(tile_pos) or explored_tiles[tile_pos] == ExplorationState.UNEXPLORED:
					explored_tiles[tile_pos] = ExplorationState.EXPLORED
					area_explored.emit(tile_world_pos)

func update_fog_texture():
	"""Update the fog texture based on current exploration state with smooth edges"""
	var image = fog_texture.get_image()
	
	# Update texture with smoother interpolation
	for x in range(grid_width):
		for y in range(grid_height):
			var tile_pos = Vector2i(x, y)
			var base_fog_value: float
			
			if currently_visible_tiles.has(tile_pos):
				base_fog_value = 0.0  # Currently visible
			elif explored_tiles.has(tile_pos) and explored_tiles[tile_pos] != ExplorationState.UNEXPLORED:
				base_fog_value = 0.5  # Explored but not visible
			else:
				base_fog_value = 1.0  # Unexplored
			
			# Sample surrounding tiles for smooth transitions
			var fog_value = calculate_smooth_fog_value(tile_pos, base_fog_value)
			
			# Correct Y coordinate mapping (texture Y=0 should be at world -Z)
			var texture_y = y  # No flipping needed - let shader handle coordinate transformation
			image.set_pixel(x, texture_y, Color(fog_value, fog_value, fog_value))
	
	fog_texture.update(image)

func calculate_smooth_fog_value(center_tile: Vector2i, base_value: float) -> float:
	"""Calculate a smooth fog value by sampling neighboring tiles"""
	var total_value = base_value
	var sample_count = 1
	
	# Sample neighboring tiles for smoothing
	var neighbors = [
		Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
		Vector2i(-1,  0),                  Vector2i(1,  0),
		Vector2i(-1,  1), Vector2i(0,  1), Vector2i(1,  1)
	]
	
	for neighbor_offset in neighbors:
		var neighbor_pos = center_tile + neighbor_offset
		
		# Skip if out of bounds
		if neighbor_pos.x < 0 or neighbor_pos.x >= grid_width or neighbor_pos.y < 0 or neighbor_pos.y >= grid_height:
			continue
		
		var neighbor_value: float
		if currently_visible_tiles.has(neighbor_pos):
			neighbor_value = 0.0
		elif explored_tiles.has(neighbor_pos) and explored_tiles[neighbor_pos] != ExplorationState.UNEXPLORED:
			neighbor_value = 0.5
		else:
			neighbor_value = 1.0
		
		# Weight by distance (closer neighbors have more influence)
		var distance = neighbor_offset.length()
		var weight = 1.0 / (1.0 + distance * 0.5)
		total_value += neighbor_value * weight
		sample_count += weight
	
	return total_value / sample_count

func world_to_grid(world_pos: Vector2) -> Vector2i:
	"""Convert world position to grid coordinates"""
	var relative_pos = world_pos - world_offset
	return Vector2i(
		int(relative_pos.x / grid_size),
		int(relative_pos.y / grid_size)
	)

func grid_to_world(grid_pos: Vector2i) -> Vector2:
	"""Convert grid coordinates to world position (center of tile)"""
	return world_offset + Vector2(
		grid_pos.x * grid_size + grid_size * 0.5,
		grid_pos.y * grid_size + grid_size * 0.5
	)

# Public API
func is_position_explored(world_pos: Vector2) -> bool:
	"""Check if a world position has been explored"""
	var grid_pos = world_to_grid(world_pos)
	return explored_tiles.has(grid_pos) and explored_tiles[grid_pos] != ExplorationState.UNEXPLORED

func is_position_visible(world_pos: Vector2) -> bool:
	"""Check if a world position is currently visible"""
	var grid_pos = world_to_grid(world_pos)
	return currently_visible_tiles.has(grid_pos)

func get_exploration_percentage() -> float:
	"""Get the percentage of the world that has been explored"""
	var total_tiles = grid_width * grid_height
	var explored_count = 0
	
	for state in explored_tiles.values():
		if state != ExplorationState.UNEXPLORED:
			explored_count += 1
	
	return float(explored_count) / float(total_tiles) * 100.0

func reveal_area(center: Vector2, radius: float):
	"""Manually reveal an area (useful for starting areas, etc.)"""
	var grid_center = world_to_grid(center)
	var radius_in_tiles = int(ceil(radius / grid_size))
	
	for x in range(-radius_in_tiles, radius_in_tiles + 1):
		for y in range(-radius_in_tiles, radius_in_tiles + 1):
			var tile_pos = Vector2i(grid_center.x + x, grid_center.y + y)
			
			if tile_pos.x < 0 or tile_pos.x >= grid_width or tile_pos.y < 0 or tile_pos.y >= grid_height:
				continue
			
			var tile_world_pos = grid_to_world(tile_pos)
			var distance = center.distance_to(tile_world_pos)
			
			if distance <= radius:
				explored_tiles[tile_pos] = ExplorationState.EXPLORED

# Debug functions
func get_debug_info() -> Dictionary:
	"""Get debug information about the fog of war state"""
	return {
		"grid_size": Vector2i(grid_width, grid_height),
		"explored_tiles": explored_tiles.size(),
		"visible_tiles": currently_visible_tiles.size(),
		"exploration_percentage": get_exploration_percentage(),
		"players_tracked": players.size()
	}
