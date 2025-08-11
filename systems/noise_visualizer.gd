extends Node3D

# Noise Visualization Helper
# Shows the noise pattern as colored spheres to help tune parameters

@export var visualization_enabled: bool = false
@export var visualization_grid_size: int = 50
@export var visualization_spacing: float = 2.0

@onready var tree_spawner = get_parent().get_node("TreeSpawner")

func _ready():
	if visualization_enabled and tree_spawner:
		call_deferred("create_noise_visualization")

func create_noise_visualization():
	if not tree_spawner or not tree_spawner.noise:
		return
		
	print("Creating noise visualization...")
	
	var half_grid = int(visualization_grid_size / 2)
	for x in range(-half_grid, half_grid):
		for z in range(-half_grid, half_grid):
			var pos = Vector3(x * visualization_spacing, 0.5, z * visualization_spacing)
			var noise_value = tree_spawner.get_noise_at_position(pos)
			
			# Only show points in tree areas (above threshold)
			if noise_value >= tree_spawner.noise_threshold:
				var sphere = create_sphere(pos, noise_value)
				add_child(sphere)

func create_sphere(pos: Vector3, noise_value: float) -> MeshInstance3D:
	var mesh_instance = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 0.2
	sphere_mesh.height = 0.4
	mesh_instance.mesh = sphere_mesh
	
	# Create material based on noise value
	var material = StandardMaterial3D.new()
	var intensity = noise_value
	material.albedo_color = Color(intensity, intensity * 0.5, 0.2, 0.7)
	mesh_instance.material_override = material
	
	mesh_instance.position = pos
	return mesh_instance

func clear_visualization():
	for child in get_children():
		child.queue_free()

func regenerate_visualization():
	clear_visualization()
	await get_tree().process_frame
	create_noise_visualization()

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_V:
			visualization_enabled = !visualization_enabled
			if visualization_enabled:
				create_noise_visualization()
			else:
				clear_visualization()
			print("Noise visualization: ", "ON" if visualization_enabled else "OFF")
