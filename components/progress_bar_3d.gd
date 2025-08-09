extends Node3D
class_name ProgressBar3D

@export var bar_width: float = 2.0
@export var bar_height: float = 0.2
@export var bar_color: Color = Color.GREEN
@export var background_color: Color = Color.DARK_GRAY
@export var offset_height: float = 2.0  # How high above object to float

var progress: float = 0.0
var background_mesh: MeshInstance3D
var progress_mesh: MeshInstance3D
var target_object: Node3D

func _ready():
	create_progress_bar()

func create_progress_bar():
	# Create background bar
	background_mesh = MeshInstance3D.new()
	var bg_mesh = BoxMesh.new()
	bg_mesh.size = Vector3(bar_width, bar_height, 0.1)
	background_mesh.mesh = bg_mesh
	
	var bg_material = StandardMaterial3D.new()
	bg_material.albedo_color = background_color
	bg_material.unshaded = true
	bg_material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	background_mesh.material_override = bg_material
	
	add_child(background_mesh)
	
	# Create progress bar (starts at 0 width)
	progress_mesh = MeshInstance3D.new()
	var prog_mesh = BoxMesh.new()
	prog_mesh.size = Vector3(0, bar_height, 0.1)
	progress_mesh.mesh = prog_mesh
	
	var prog_material = StandardMaterial3D.new()
	prog_material.albedo_color = bar_color
	prog_material.unshaded = true
	prog_material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	progress_mesh.material_override = prog_material
	
	add_child(progress_mesh)
	
	# Position slightly in front of background
	progress_mesh.position.z = -0.05

func set_progress(value: float):
	progress = clamp(value, 0.0, 1.0)
	update_progress_visual()

func update_progress_visual():
	if progress_mesh and progress_mesh.mesh:
		var mesh = progress_mesh.mesh as BoxMesh
		var new_width = bar_width * progress
		mesh.size = Vector3(new_width, bar_height, 0.1)
		
		# Adjust position so it grows from left to right
		var offset = (bar_width - new_width) * -0.5
		progress_mesh.position.x = offset

func set_target(target: Node3D):
	target_object = target

func _process(_delta):
	# Always face the camera and follow target object
	if target_object:
		global_position = target_object.global_position + Vector3(0, offset_height, 0)
	
	# Make it always face the camera (if there is one)
	var camera = get_viewport().get_camera_3d()
	if camera:
		look_at(camera.global_position, Vector3.UP)

func set_color(color: Color):
	bar_color = color
	if progress_mesh and progress_mesh.material_override:
		progress_mesh.material_override.albedo_color = color

func show_bar():
	visible = true

func hide_bar():
	visible = false
