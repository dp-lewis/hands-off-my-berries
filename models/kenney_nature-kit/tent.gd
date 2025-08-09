extends Node3D

@export var wood_cost: int = 8  # Cost to build the tent
@export var build_time: float = 5.0  # Time to construct (increased for background building)

var current_builder: Node = null
var build_progress: float = 0.0
var is_being_built: bool = false
var is_built: bool = false

@onready var area_3d: Area3D
@onready var tent_mesh: Node3D

func _ready():
	# Set up the tent as a "blueprint" initially
	setup_area_detection()
	
	# Find the tent mesh to hide it initially
	tent_mesh = get_child(0)  # The tmpParent from GLB
	
	# Start as blueprint (semi-transparent)
	show_as_blueprint()

func setup_area_detection():
	# Create Area3D for interaction if it doesn't exist
	if not has_node("Area3D"):
		area_3d = Area3D.new()
		add_child(area_3d)
		
		var collision_shape = CollisionShape3D.new()
		var box_shape = BoxShape3D.new()
		box_shape.size = Vector3(4, 2, 4)  # Generous interaction area
		collision_shape.shape = box_shape
		area_3d.add_child(collision_shape)
	else:
		area_3d = $Area3D
	
	area_3d.body_entered.connect(_on_player_entered)
	area_3d.body_exited.connect(_on_player_exited)

func _process(delta):
	if is_being_built:
		# Continue building in background
		build_progress += delta / build_time
		
		# Check if building is complete
		if build_progress >= 1.0:
			complete_building()

func show_as_blueprint():
	# Make tent semi-transparent to show it's not built yet
	if tent_mesh:
		make_transparent(tent_mesh, 0.5)
	print("Tent blueprint placed - needs ", wood_cost, " wood to build")

func show_as_built():
	# Make tent fully visible
	if tent_mesh:
		make_transparent(tent_mesh, 1.0)
	print("Tent construction complete!")

func make_transparent(node: Node3D, alpha: float):
	var mesh_instances = find_mesh_instances(node)
	for mesh_instance in mesh_instances:
		var material = StandardMaterial3D.new()
		material.albedo_color = Color(1, 1, 1, alpha)
		if alpha < 1.0:
			material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mesh_instance.material_override = material

func find_mesh_instances(node: Node) -> Array:
	var mesh_instances = []
	if node is MeshInstance3D:
		mesh_instances.append(node)
	
	for child in node.get_children():
		mesh_instances += find_mesh_instances(child)
	
	return mesh_instances

func _on_player_entered(body):
	if body.has_method("start_building_tent") and not is_built and not is_being_built:
		body.set_nearby_tent(self)

func _on_player_exited(body):
	if body.has_method("clear_nearby_tent"):
		body.clear_nearby_tent(self)

func start_building(player: Node) -> bool:
	if is_built:
		print("Tent already built!")
		return false
		
	if is_being_built:
		print("Tent already being built!")
		return false
	
	# Check if player has enough wood
	if player.wood < wood_cost:
		print("Need ", wood_cost, " wood to build tent (have ", player.wood, ")")
		return false
	
	# Deduct wood and start building
	player.wood -= wood_cost
	current_builder = player
	is_being_built = true
	build_progress = 0.0
	
	print("Started building tent... (", build_time, " seconds)")
	print("Player has ", player.wood, " wood remaining")
	return true

func complete_building():
	print("Tent construction complete!")
	
	# Mark as built
	is_built = true
	is_being_built = false
	current_builder = null
	show_as_built()

func get_build_progress() -> float:
	return build_progress

func is_tent_built() -> bool:
	return is_built
