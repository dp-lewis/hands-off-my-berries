extends Node3D

@export var wood_cost: int = 4  # Cost to build the chest
@export var build_time: float = 3.0  # Time to construct
@export var start_built: bool = false  # For testing - start as built chest
@export var storage_capacity: int = 20  # Maximum items that can be stored

var current_builder: Node = null
var build_progress: float = 0.0
var is_being_built: bool = false
var is_built: bool = false

# Storage functionality
var storage_items: Dictionary = {}  # item_type: amount
var nearby_players: Array[Node] = []
var progress_bar: Node3D

@onready var build_area: Area3D
@onready var interaction_area: Area3D
@onready var chest_mesh: Node3D

func _ready():
	# Add to chests group for game manager to find
	add_to_group("chests")
	
	# Find the chest mesh
	chest_mesh = get_child(0)  # The tmpParent from GLB
	
	# Set up areas
	setup_areas()
	
	# Initialize chest state
	if start_built:
		# Start as built chest for testing
		is_built = true
		show_as_built()
		print("Chest started as built (testing mode)")
	else:
		# Start as blueprint (semi-transparent)
		show_as_blueprint()
		print("Chest started as blueprint (needs building)")

func setup_areas():
	# Find existing areas or create them
	var areas = []
	for child in get_children():
		if child is Area3D:
			areas.append(child)
	
	if areas.size() >= 2:
		# Use existing areas - first for building, second for interaction
		build_area = areas[0]
		interaction_area = areas[1]
	elif areas.size() == 1:
		# One area exists, use it for building, create interaction area
		build_area = areas[0]
		create_interaction_area()
	else:
		# No areas exist, create both
		create_build_area()
		create_interaction_area()
	
	# Connect signals
	build_area.body_entered.connect(_on_build_area_entered)
	build_area.body_exited.connect(_on_build_area_exited)
	
	interaction_area.body_entered.connect(_on_interaction_area_entered)
	interaction_area.body_exited.connect(_on_interaction_area_exited)

func create_build_area():
	build_area = Area3D.new()
	build_area.name = "BuildArea"
	add_child(build_area)
	
	var collision_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(3, 2, 3)  # Build interaction area
	collision_shape.shape = box_shape
	build_area.add_child(collision_shape)

func create_interaction_area():
	interaction_area = Area3D.new()
	interaction_area.name = "InteractionArea"
	add_child(interaction_area)
	
	var collision_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(2, 1.5, 2)  # Smaller interaction area
	collision_shape.shape = box_shape
	collision_shape.position = Vector3(0, 0.75, 0)  # Center around chest
	interaction_area.add_child(collision_shape)

func _process(delta):
	if is_being_built:
		# Continue building in background
		build_progress += delta / build_time
		
		# Update progress bar if it exists
		if progress_bar:
			progress_bar.set_progress(build_progress)
		
		# Check if building is complete
		if build_progress >= 1.0:
			complete_building()

# Building System

func show_as_blueprint():
	"""Show chest as semi-transparent blueprint"""
	if chest_mesh:
		make_mesh_transparent(chest_mesh, 0.3)

func show_as_built():
	"""Show chest as fully built and opaque"""
	if chest_mesh:
		make_mesh_opaque(chest_mesh)

func make_mesh_transparent(node: Node, opacity: float):
	"""Make mesh transparent for blueprint state"""
	if node is MeshInstance3D:
		var mesh_instance = node as MeshInstance3D
		var material = StandardMaterial3D.new()
		material.albedo_color = Color(0.8, 0.6, 0.4, opacity)  # Chest brown color
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mesh_instance.material_override = material
	
	for child in node.get_children():
		make_mesh_transparent(child, opacity)

func make_mesh_opaque(node: Node):
	"""Make mesh fully opaque for built state"""
	if node is MeshInstance3D:
		var mesh_instance = node as MeshInstance3D
		mesh_instance.material_override = null  # Use original material
	
	for child in node.get_children():
		make_mesh_opaque(child)

# Building Area Events

func _on_build_area_entered(body: Node3D):
	if body.name.begins_with("Player") and not is_built:
		var player_builder = get_player_builder(body)
		if player_builder:
			print("Player ", get_player_id(body), " entered chest build area")

func _on_build_area_exited(body: Node3D):
	if body.name.begins_with("Player"):
		var player_builder = get_player_builder(body)
		if player_builder:
			print("Player ", get_player_id(body), " left chest build area")

func start_building(builder: Node) -> bool:
	"""Start building the chest"""
	if is_being_built or is_built:
		return false
	
	current_builder = builder
	is_being_built = true
	build_progress = 0.0
	
	# Create progress bar if needed
	create_progress_bar()
	
	print("Chest building started by player ", get_player_id(builder))
	return true

func complete_building():
	"""Complete chest construction"""
	is_being_built = false
	is_built = true
	build_progress = 1.0
	
	# Remove progress bar
	if progress_bar:
		progress_bar.queue_free()
		progress_bar = null
	
	# Show as fully built
	show_as_built()
	
	print("Chest construction completed!")

func create_progress_bar():
	"""Create a simple progress bar above the chest"""
	# This is a placeholder - you might want to use a proper progress bar scene
	progress_bar = Node3D.new()
	progress_bar.name = "ProgressBar"
	add_child(progress_bar)
	progress_bar.position = Vector3(0, 2, 0)  # Above chest

# Storage System

func _on_interaction_area_entered(body: Node3D):
	if body.name.begins_with("Player") and is_built:
		nearby_players.append(body)
		show_interaction_prompt(body)
		print("Player ", get_player_id(body), " can interact with chest")

func _on_interaction_area_exited(body: Node3D):
	if body.name.begins_with("Player"):
		nearby_players.erase(body)
		hide_interaction_prompt(body)
		print("Player ", get_player_id(body), " left chest interaction area")

func show_interaction_prompt(player: Node):
	"""Show interaction prompt to player"""
	# TODO: Implement UI prompt ("Press E to open chest")
	print("Show interaction prompt for chest to player ", get_player_id(player))

func hide_interaction_prompt(player: Node):
	"""Hide interaction prompt from player"""
	# TODO: Hide UI prompt
	print("Hide interaction prompt for chest from player ", get_player_id(player))

func interact_with_chest(player: Node):
	"""Handle chest interaction (opening/accessing storage)"""
	if not is_built:
		print("Chest is not built yet!")
		return false
	
	print("Player ", get_player_id(player), " opened chest (storage capacity: ", storage_capacity, ")")
	open_storage_interface(player)
	return true

func open_storage_interface(player: Node):
	"""Open the storage interface for the player"""
	# TODO: Implement storage UI
	print("Opening storage interface for player ", get_player_id(player))
	print("Current storage: ", storage_items)
	print("Available capacity: ", get_available_capacity(), "/", storage_capacity)

# Storage Management

func store_item(item_type: String, amount: int) -> bool:
	"""Store items in the chest"""
	var current_total = get_total_stored_items()
	
	if current_total + amount <= storage_capacity:
		if storage_items.has(item_type):
			storage_items[item_type] += amount
		else:
			storage_items[item_type] = amount
		
		print("Stored ", amount, " ", item_type, " in chest")
		return true
	else:
		print("Chest is full! Cannot store ", amount, " ", item_type)
		return false

func retrieve_item(item_type: String, amount: int) -> int:
	"""Retrieve items from the chest, returns actual amount retrieved"""
	if not storage_items.has(item_type):
		return 0
	
	var available = storage_items[item_type]
	var retrieved = min(amount, available)
	
	storage_items[item_type] -= retrieved
	if storage_items[item_type] <= 0:
		storage_items.erase(item_type)
	
	print("Retrieved ", retrieved, " ", item_type, " from chest")
	return retrieved

func get_total_stored_items() -> int:
	"""Get total number of items stored"""
	var total = 0
	for amount in storage_items.values():
		total += amount
	return total

func get_available_capacity() -> int:
	"""Get remaining storage capacity"""
	return storage_capacity - get_total_stored_items()

func has_item(item_type: String) -> bool:
	"""Check if chest contains specific item type"""
	return storage_items.has(item_type) and storage_items[item_type] > 0

func get_item_amount(item_type: String) -> int:
	"""Get amount of specific item type"""
	if storage_items.has(item_type):
		return storage_items[item_type]
	return 0

# Utility Functions

func get_player_builder(player: Node) -> Node:
	"""Get player's builder component"""
	if player.has_method("get_component"):
		return player.get_component("builder")
	return null

func get_player_id(player: Node) -> String:
	"""Get player ID for logging"""
	if player.has_method("get_player_id"):
		return str(player.get_player_id())
	return player.name

# Save/Load Support (for future implementation)

func get_save_data() -> Dictionary:
	"""Get chest data for saving"""
	return {
		"position": global_position,
		"is_built": is_built,
		"storage_items": storage_items,
		"storage_capacity": storage_capacity
	}

func load_save_data(data: Dictionary):
	"""Load chest data from save"""
	if data.has("position"):
		global_position = data["position"]
	if data.has("is_built"):
		is_built = data["is_built"]
		if is_built:
			show_as_built()
		else:
			show_as_blueprint()
	if data.has("storage_items"):
		storage_items = data["storage_items"]
	if data.has("storage_capacity"):
		storage_capacity = data["storage_capacity"]
