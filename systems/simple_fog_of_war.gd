extends Control
class_name SimpleFogOfWar

## Simple 2D Fog of War Overlay
## A black screen overlay that reveals areas as players explore

# Configuration
@export var reveal_radius: float = 80.0  # Radius in screen pixels to reveal around player
@export var map_size: Vector2 = Vector2(512, 512)  # Internal fog map resolution

# Internal state
var fog_texture: ImageTexture
var fog_image: Image
var players: Array = []
var camera: Camera3D
var color_rect: ColorRect  # Make this accessible for debugging

func _ready():
	print("[SimpleFogOfWar] Initializing simple fog of war...")
	call_deferred("setup_fog_system")

func setup_fog_system():
	print("[SimpleFogOfWar] Setting up fog system...")
	
	# Set up as fullscreen overlay
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE  # Don't block input
	
	# Create fog texture - start completely black (opaque)
	fog_image = Image.create(int(map_size.x), int(map_size.y), false, Image.FORMAT_RGBA8)
	fog_image.fill(Color.BLACK)  # Start with everything fogged
	fog_texture = ImageTexture.create_from_image(fog_image)
	
	# Create ColorRect with shader for the fog effect
	create_fog_overlay()
	
	# Find camera and players
	call_deferred("find_camera_and_players")
	
	# Update every frame
	set_process(true)
	
	print("[SimpleFogOfWar] Fog system setup complete. Overlay should be visible!")
	
	# Initial debug info
	var viewport_size = get_viewport().get_visible_rect().size
	print("[SimpleFogOfWar] Viewport size: ", viewport_size)
	print("[SimpleFogOfWar] Overlay size: ", size)

func create_fog_overlay():
	"""Create a ColorRect with a shader for the fog effect"""
	color_rect = ColorRect.new()
	color_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	color_rect.color = Color.BLACK  # Start with black overlay
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Create shader material for fog with texture-based revelation
	var shader_material = ShaderMaterial.new()
	var shader = Shader.new()
	
	shader.code = """
shader_type canvas_item;

uniform sampler2D fog_map;

void fragment() {
	vec2 fog_uv = SCREEN_UV;
	float fog_alpha = texture(fog_map, fog_uv).a;
	COLOR = vec4(0.0, 0.0, 0.0, fog_alpha);
}
"""
	
	shader_material.shader = shader
	shader_material.set_shader_parameter("fog_map", fog_texture)
	color_rect.material = shader_material
	
	add_child(color_rect)
	
	print("[SimpleFogOfWar] Created fog overlay with shader")

func find_camera_and_players():
	"""Find the camera and player nodes"""
	var scene_root = get_tree().current_scene
	
	# Find camera
	camera = scene_root.find_child("Camera3D", true, false)
	if camera:
		print("[SimpleFogOfWar] Found camera: ", camera.name)
	else:
		print("[SimpleFogOfWar] Warning: No camera found!")
	
	# Find players
	players.clear()
	find_players_recursive(scene_root)
	print("[SimpleFogOfWar] Found ", players.size(), " players")

func find_players_recursive(node: Node):
	"""Recursively find player nodes"""
	if node is CharacterBody3D and node.name.begins_with("Player"):
		players.append(node)
		print("[SimpleFogOfWar] Found player: ", node.name)
		return
	
	for child in node.get_children():
		find_players_recursive(child)

func _process(_delta):
	"""Update fog of war each frame"""
	if not camera or players.is_empty():
		return
	
	# Update fog for each player
	var fog_updated = false
	for player in players:
		if is_instance_valid(player):
			var screen_pos = world_to_screen(player.global_position)
			if screen_pos != Vector2(-1, -1):  # Valid screen position
				reveal_at_screen_position(screen_pos)
				fog_updated = true
	
	# Update texture if we revealed anything
	if fog_updated:
		fog_texture.update(fog_image)

func world_to_screen(world_pos: Vector3) -> Vector2:
	"""Convert 3D world position to screen coordinates"""
	if not camera:
		return Vector2(-1, -1)
	
	# Project world position to screen
	var screen_position = camera.unproject_position(world_pos)
	
	# Check if position is visible (in front of camera)
	var cam_transform = camera.global_transform
	var to_point = world_pos - cam_transform.origin
	if cam_transform.basis.z.dot(to_point) > 0:  # Behind camera
		return Vector2(-1, -1)
	
	return screen_position

func reveal_at_screen_position(screen_pos: Vector2):
	"""Reveal fog around a screen position"""
	# Convert screen position to fog texture coordinates
	var viewport_size = get_viewport().get_visible_rect().size
	var fog_pos = Vector2(
		(screen_pos.x / viewport_size.x) * map_size.x,
		(screen_pos.y / viewport_size.y) * map_size.y
	)
	
	# Reveal in a circle around the position
	var radius_in_texture = (reveal_radius / viewport_size.x) * map_size.x
	
	var min_x = max(0, int(fog_pos.x - radius_in_texture))
	var max_x = min(int(map_size.x), int(fog_pos.x + radius_in_texture))
	var min_y = max(0, int(fog_pos.y - radius_in_texture))
	var max_y = min(int(map_size.y), int(fog_pos.y + radius_in_texture))
	
	for x in range(min_x, max_x):
		for y in range(min_y, max_y):
			var distance = Vector2(x - fog_pos.x, y - fog_pos.y).length()
			if distance <= radius_in_texture:
				# Create smooth falloff at edges
				var alpha = 1.0 - (distance / radius_in_texture)
				alpha = smoothstep(0.0, 1.0, alpha)
				
				# Get current pixel value and make it more transparent
				var current_color = fog_image.get_pixel(x, y)
				var new_alpha = current_color.a * (1.0 - alpha * 0.15)  # Gradually reveal
				new_alpha = max(0.0, new_alpha)  # Don't go below 0
				fog_image.set_pixel(x, y, Color(0, 0, 0, new_alpha))

# Public API
func reveal_area(world_pos: Vector3, radius: float):
	"""Manually reveal an area around a world position"""
	var screen_pos = world_to_screen(world_pos)
	if screen_pos != Vector2(-1, -1):
		var old_radius = reveal_radius
		reveal_radius = radius
		reveal_at_screen_position(screen_pos)
		reveal_radius = old_radius
		fog_texture.update(fog_image)

func clear_fog():
	"""Clear all fog (reveal everything)"""
	fog_image.fill(Color.TRANSPARENT)
	fog_texture.update(fog_image)

func reset_fog():
	"""Reset to completely fogged"""
	fog_image.fill(Color.BLACK)
	fog_texture.update(fog_image)
