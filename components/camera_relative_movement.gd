extends Node
class_name CameraRelativeMovement

## Camera-relative movement transformation component
## Transforms 2D input direction based on camera rotation for natural isometric movement

signal movement_requested(world_direction: Vector2)

@export var camera_node_path: NodePath = NodePath("../../Camera3D")  # Default to scene root camera
@export var enable_debug_visualization: bool = true  # Enable debug for testing

var camera: Camera3D
var isometric_transform: Transform3D

func _ready():
	print("[CameraRelativeMovement] Component ready, path: ", get_path())
	print("[CameraRelativeMovement] Configured camera path: ", camera_node_path)
	
	# Find the camera
	if camera_node_path and has_node(camera_node_path):
		camera = get_node(camera_node_path)
		print("[CameraRelativeMovement] Found camera via configured path")
	else:
		print("[CameraRelativeMovement] Camera path not found, searching scene...")
		# Search for camera in scene
		camera = find_camera_in_scene()
	
	if camera:
		# Store the camera's transform for isometric calculations
		isometric_transform = camera.transform
		print("[CameraRelativeMovement] Using camera: ", camera.name)
		print("[CameraRelativeMovement] Camera transform: ", isometric_transform)
		print("[CameraRelativeMovement] Camera path: ", camera.get_path())
	else:
		push_error("[CameraRelativeMovement] No camera found!")

func find_camera_in_scene() -> Camera3D:
	"""Find the first Camera3D in the scene"""
	var scene_root = get_tree().current_scene
	print("[CameraRelativeMovement] Searching for camera from scene root: ", scene_root.name)
	var camera_found = find_node_by_type(scene_root, Camera3D) as Camera3D
	if camera_found:
		print("[CameraRelativeMovement] Found camera: ", camera_found.name, " at path: ", camera_found.get_path())
	else:
		print("[CameraRelativeMovement] No camera found in scene")
	return camera_found

func find_node_by_type(node: Node, node_type) -> Node:
	"""Recursively find the first node of the specified type"""
	if is_instance_of(node, node_type):
		return node
	
	for child in node.get_children():
		var result = find_node_by_type(child, node_type)
		if result:
			return result
	
	return null

func transform_input_to_world(input_dir: Vector2) -> Vector2:
	"""Transform 2D input direction to world direction based on camera rotation"""
	if not camera or input_dir == Vector2.ZERO:
		return input_dir
	
	# For isometric camera, we need to rotate the input direction
	# The camera is rotated, so we need to counter-rotate the input
	
	# Get the camera's forward and right vectors projected onto the ground plane
	var camera_transform = camera.global_transform
	var camera_forward = -camera_transform.basis.z  # Camera looks down -Z
	var camera_right = camera_transform.basis.x
	
	# Project onto the ground plane (Y = 0)
	camera_forward.y = 0
	camera_right.y = 0
	camera_forward = camera_forward.normalized()
	camera_right = camera_right.normalized()
	
	# Create world direction based on camera orientation
	var world_direction = Vector3.ZERO
	world_direction += camera_right * input_dir.x  # Input X -> Camera right
	world_direction += camera_forward * -input_dir.y  # Input Y -> Camera forward (inverted)
	
	# Convert back to 2D for movement system
	var result = Vector2(world_direction.x, world_direction.z)
	
	if enable_debug_visualization:
		print("[CameraRelativeMovement] Input: ", input_dir, " -> World: ", result)
		print("[CameraRelativeMovement] Camera forward: ", camera_forward, " right: ", camera_right)
	
	return result

func handle_input_direction(input_dir: Vector2) -> void:
	"""Process input direction and emit world-relative movement signal"""
	var world_direction = transform_input_to_world(input_dir)
	movement_requested.emit(world_direction)

# Alternative method: Fixed isometric input mapping
func transform_input_isometric_fixed(input_dir: Vector2) -> Vector2:
	"""Transform input using fixed isometric rotation (45 degrees)"""
	if input_dir == Vector2.ZERO:
		return input_dir
	
	# Fixed isometric transformation matrix for 45-degree rotation
	# This creates the classic diamond movement pattern for isometric games
	var cos_45 = cos(PI/4)  # ≈ 0.707
	var sin_45 = sin(PI/4)  # ≈ 0.707
	
	var transformed_x = input_dir.x * cos_45 - input_dir.y * sin_45
	var transformed_y = input_dir.x * sin_45 + input_dir.y * cos_45
	
	return Vector2(transformed_x, transformed_y)

func set_camera_path(path: NodePath) -> void:
	"""Set the camera node path and reinitialize"""
	camera_node_path = path
	if is_inside_tree():
		_ready()
