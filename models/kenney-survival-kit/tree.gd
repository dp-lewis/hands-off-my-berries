extends Node3D

@export var wood_yield: int = 5
@export var gather_time: float = 2.0
@export var wood_pile_scene: PackedScene = preload("res://models/kenney-survival-kit/resource_wood.tscn")

var players_in_range: Array[Node] = []
var current_gatherer: Node = null
var gather_progress: float = 0.0
var is_being_gathered: bool = false

# Visual state variables
var original_scale: Vector3
var original_rotation: Vector3
var progress_bar: Node3D
@onready var tree_mesh: Node3D

@onready var area_3d: Area3D = $Area3D

func _ready():
	# Store original values for visual effects
	original_scale = scale
	original_rotation = rotation
	tree_mesh = get_child(0)  # Assuming first child is the mesh
	
	# Connect area signals for player detection
	area_3d.body_entered.connect(_on_player_entered)
	area_3d.body_exited.connect(_on_player_exited)

func _process(delta):
	if is_being_gathered and current_gatherer:
		# Update gathering progress
		gather_progress += delta / gather_time
		
		# Update visual state based on progress
		update_chopping_visuals()
		
		# Check if gathering is complete
		if gather_progress >= 1.0:
			complete_gathering()

func _on_player_entered(body):
	if body.has_method("start_gathering_tree"):
		players_in_range.append(body)
		body.set_nearby_tree(self)

func _on_player_exited(body):
	if body in players_in_range:
		players_in_range.erase(body)
		body.clear_nearby_tree(self)
		
		# If this player was gathering, stop the process
		if body == current_gatherer:
			stop_gathering()

func start_gathering(player: Node) -> bool:
	if is_being_gathered:
		return false  # Already being gathered
	
	current_gatherer = player
	is_being_gathered = true
	gather_progress = 0.0
	
	# Create progress bar
	create_progress_bar()
	
	print("Started gathering tree...")
	return true

func stop_gathering():
	if is_being_gathered:
		current_gatherer = null
		is_being_gathered = false
		gather_progress = 0.0
		
		# Reset visual state and remove progress bar
		reset_tree_visuals()
		destroy_progress_bar()
		print("Stopped gathering tree")

func update_chopping_visuals():
	if not tree_mesh:
		return
		
	# Calculate progress-based effects (0.0 to 1.0)
	var progress = gather_progress
	
	# Update progress bar
	if progress_bar:
		progress_bar.set_progress(progress)
	
	# 1. Scale reduction - tree gets smaller as chopped
	var scale_factor = 1.0 - (progress * 0.3)  # Reduce by up to 30%
	scale = original_scale * scale_factor
	
	# 2. Tilt - tree starts leaning as it's chopped more
	var max_tilt = 15.0  # degrees
	var tilt_amount = progress * max_tilt
	rotation.z = original_rotation.z + deg_to_rad(tilt_amount)
	
	# 3. Color change - green to brown as damaged
	var health_color = Color.GREEN.lerp(Color.BROWN, progress)
	update_tree_color(health_color)

func create_progress_bar():
	if not progress_bar:
		# Load the progress bar scene (same as pumpkin)
		var progress_bar_scene = load("res://components/progress_bar_3d.tscn")
		if progress_bar_scene:
			progress_bar = progress_bar_scene.instantiate()
			
			# Position above the tree
			progress_bar.position = Vector3(0, 3.0, 0)  # Higher than pumpkin since trees are taller
			add_child(progress_bar)
			
			progress_bar.set_progress(0.0)
		else:
			print("Warning: Could not load progress bar scene")

func destroy_progress_bar():
	if progress_bar:
		progress_bar.queue_free()
		progress_bar = null

func update_tree_color(color: Color):
	if tree_mesh:
		var mesh_instances = find_mesh_instances(tree_mesh)
		for mesh_instance in mesh_instances:
			var material = StandardMaterial3D.new()
			material.albedo_color = color
			mesh_instance.material_override = material

func reset_tree_visuals():
	if tree_mesh:
		scale = original_scale
		rotation = original_rotation
		
		# Reset to original green color
		update_tree_color(Color.GREEN)

func find_mesh_instances(node: Node) -> Array:
	var mesh_instances = []
	if node is MeshInstance3D:
		mesh_instances.append(node)
	
	for child in node.get_children():
		mesh_instances += find_mesh_instances(child)
	
	return mesh_instances

func complete_gathering():
	if current_gatherer:
		var resource_manager = current_gatherer.get_node("ResourceManager")
		if resource_manager:
			# Try to add wood to gatherer's inventory using ResourceManager
			if resource_manager.add_resource("wood", wood_yield):
				print("Tree chopped! Gave ", wood_yield, " wood")
				
				# Spawn a wood pile at the tree location
				spawn_wood_pile(global_position, get_parent())
				
				# Remove the tree from the scene
				queue_free()
			else:
				print("Gatherer's wood inventory is full!")
				stop_gathering()
		else:
			print("Warning: No ResourceManager found on gatherer!")
			stop_gathering()
	else:
		stop_gathering()

func spawn_wood_pile(spawn_pos: Vector3, parent_node: Node):
	if wood_pile_scene:
		var wood_pile = wood_pile_scene.instantiate()
		
		# Set the wood amount
		wood_pile.wood_amount = wood_yield
		
		# Add to the scene tree first
		parent_node.add_child(wood_pile)
		
		# Then set position (now that it's in the tree)
		wood_pile.global_position = spawn_pos

func get_gather_progress() -> float:
	return gather_progress
