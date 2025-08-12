extends Node3D

@export var wood_cost: int = 4  # Cost to build the chest
@export var build_time: float = 3.0  # Time to construct
@export var start_built: bool = true  # For testing - start as built chest
@export var storage_capacity: int = 20  # Maximum items that can be stored

# Export the node references - assign these in the editor
@export var build_area: Area3D
@export var interaction_area: Area3D
@export var chest_mesh: Node3D
@export var storage_ui_scene: PackedScene  # Assign the ChestStorageUI scene

var current_builder: Node = null
var build_progress: float = 0.0
var is_being_built: bool = false
var is_built: bool = false

# Storage functionality
var storage_items: Dictionary = {}  # item_type: amount
var nearby_players: Array[Node] = []
var progress_bar: Node3D
var storage_ui_instance: Control = null

func _ready():
	# Add to chests group for game manager to find
	add_to_group("chests")
	
	# Set up areas (only if they're assigned in editor)
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
	# Connect signals only if areas are assigned
	if build_area:
		build_area.body_entered.connect(_on_build_area_entered)
		build_area.body_exited.connect(_on_build_area_exited)
	else:
		print("Warning: build_area not assigned in editor")
	
	if interaction_area:
		interaction_area.body_entered.connect(_on_interaction_area_entered)
		interaction_area.body_exited.connect(_on_interaction_area_exited)
	else:
		print("Warning: interaction_area not assigned in editor")

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
		
		# Connect to player's interaction system
		var player_interaction = body.get_component("interaction") if body.has_method("get_component") else null
		if player_interaction and player_interaction.has_method("set_nearby_chest"):
			player_interaction.set_nearby_chest(self)
		
		show_interaction_prompt(body)
		print("Player ", get_player_id(body), " can interact with chest")
	elif body.name.begins_with("Player") and not is_built:
		print("Chest is not built yet - player cannot interact")

func _on_interaction_area_exited(body: Node3D):
	if body.name.begins_with("Player"):
		nearby_players.erase(body)
		
		# Disconnect from player's interaction system
		var player_interaction = body.get_component("interaction") if body.has_method("get_component") else null
		if player_interaction and player_interaction.has_method("clear_nearby_chest"):
			player_interaction.clear_nearby_chest(self)
		
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
	show_storage_options(player)
	return true

func show_storage_options(player: Node):
	"""Show available storage options to player using UI"""
	var player_resource_manager = player.get_node("ResourceManager")
	if not player_resource_manager:
		print("Error: Player has no ResourceManager!")
		return
	
	# Create UI instance if needed
	if not storage_ui_instance and storage_ui_scene:
		storage_ui_instance = storage_ui_scene.instantiate()
		# Add to the scene tree (find the main scene or UI container)
		var main_scene = get_tree().current_scene
		if main_scene:
			main_scene.add_child(storage_ui_instance)
		
		# Connect UI signals
		if storage_ui_instance.has_signal("option_selected"):
			storage_ui_instance.option_selected.connect(_on_ui_option_selected)
		if storage_ui_instance.has_signal("storage_closed"):
			storage_ui_instance.storage_closed.connect(_on_ui_storage_closed)
	
	# Initialize storage menu state
	set_meta("storage_menu_active", true)
	set_meta("storage_menu_option", 0)
	set_meta("storage_current_player", player)
	
	# Show the UI
	if storage_ui_instance:
		storage_ui_instance.show_storage_interface(self, player)
	
	print("Player ", get_player_id(player), " opened chest storage interface")

func _on_ui_option_selected(option_index: int):
	"""Handle option selection from UI"""
	var player = get_meta("storage_current_player", null)
	if not player or not is_instance_valid(player):
		return
	
	# Update the stored option index
	set_meta("storage_menu_option", option_index)
	
	# Execute the option
	_execute_storage_option(player)
	
	# Close menu after execution (except for close option)
	if option_index == 8:  # Close storage option
		_close_storage_menu_ui()
	# Note: UI will update itself when needed, don't force update from here

func _on_ui_storage_closed():
	"""Handle UI storage closed signal"""
	_close_storage_menu_ui()
	
	# Clear any potential input state issues
	#call_deferred("_ensure_input_cleanup")

func _ensure_input_cleanup():
	"""Ensure input is properly cleaned up after UI closes"""
	# Release any potentially stuck input actions
	if Input.is_action_pressed("ui_up"):
		Input.action_release("ui_up")
	if Input.is_action_pressed("ui_down"):
		Input.action_release("ui_down")
	if Input.is_action_pressed("ui_left"):
		Input.action_release("ui_left")
	if Input.is_action_pressed("ui_right"):
		Input.action_release("ui_right")
	
	print("Input cleanup completed")

func _close_storage_menu_ui():
	"""Close the storage menu UI and clean up"""
	set_meta("storage_menu_active", false)
	set_meta("storage_menu_option", 0)
		
	print("Storage menu closed")

func execute_current_storage_option():
	"""Execute the currently selected storage option - called by player interaction"""
	if not get_meta("storage_menu_active", false):
		return false
	
	# If UI is available, use it to execute the current option
	if storage_ui_instance and storage_ui_instance.has_method("execute_current_option"):
		storage_ui_instance.execute_current_option()
		return true
	
	# Fallback to direct execution
	var player = get_meta("storage_current_player", null)
	if not player or not is_instance_valid(player):
		return false
	
	_execute_storage_option(player)
	_close_storage_menu_ui()
	return true

func _execute_storage_option(player: Node):
	"""Execute the currently selected storage option"""
	var option = get_meta("storage_menu_option", 0)
	
	print("\nExecuting option ", option, "...")
	
	match option:
		0:  # Store 5 wood
			transfer_wood_to_chest(player, 5)
		1:  # Store 5 food
			transfer_food_to_chest(player, 5)
		2:  # Take 5 wood
			transfer_wood_from_chest(player, 5)
		3:  # Take 5 food
			transfer_food_from_chest(player, 5)
		4:  # Store ALL wood
			transfer_all_wood_to_chest(player)
		5:  # Store ALL food
			transfer_all_food_to_chest(player)
		6:  # Take ALL wood
			transfer_all_wood_from_chest(player)
		7:  # Take ALL food
			transfer_all_food_from_chest(player)
		8:  # Close storage
			print("Storage closed by player choice")
	
	print("Storage operation complete!")
	
	# Refresh UI to show updated values (only if UI is still active)
	if storage_ui_instance and storage_ui_instance.has_method("refresh_interface"):
		storage_ui_instance.refresh_interface()

# Storage interface management - no longer uses timers

func enable_storage_input(player: Node):
	"""Enable storage interface - now uses player input controls"""
	show_storage_options(player)

# Legacy function - now handled by new player control interface
func _check_storage_input(player: Node, input_timer: Timer):
	"""Legacy input checking - replaced by player control interface"""
	if input_timer and is_instance_valid(input_timer):
		input_timer.queue_free()
	print("Legacy storage input function called - redirecting to new interface")
	show_storage_options(player)

func _close_storage_interface(player: Node, input_timer: Timer, close_timer: Timer):
	"""Close the storage interface"""
	print("Closed storage interface for player ", get_player_id(player))
	
	if input_timer and is_instance_valid(input_timer):
		input_timer.queue_free()
	if close_timer and is_instance_valid(close_timer):
		close_timer.queue_free()

# Storage Transfer Functions

func transfer_wood_to_chest(player: Node, amount: int = 5) -> bool:
	"""Transfer wood from player to chest"""
	var player_resource_manager = player.get_node("ResourceManager")
	if not player_resource_manager:
		return false
	
	var player_wood = player_resource_manager.get_resource_amount("wood")
	var actual_amount = min(amount, player_wood)
	
	if actual_amount <= 0:
		print("Player has no wood to store!")
		return false
	
	if store_item("wood", actual_amount):
		player_resource_manager.remove_resource("wood", actual_amount)
		print("Transferred ", actual_amount, " wood to chest")
		show_storage_status()
		return true
	else:
		print("Chest is full! Cannot store wood.")
		return false

func transfer_food_to_chest(player: Node, amount: int = 5) -> bool:
	"""Transfer food from player to chest"""
	var player_resource_manager = player.get_node("ResourceManager")
	if not player_resource_manager:
		return false
	
	var player_food = player_resource_manager.get_resource_amount("food")
	var actual_amount = min(amount, player_food)
	
	if actual_amount <= 0:
		print("Player has no food to store!")
		return false
	
	if store_item("food", actual_amount):
		player_resource_manager.remove_resource("food", actual_amount)
		print("Transferred ", actual_amount, " food to chest")
		show_storage_status()
		return true
	else:
		print("Chest is full! Cannot store food.")
		return false

func transfer_wood_from_chest(player: Node, amount: int = 5) -> bool:
	"""Transfer wood from chest to player"""
	var player_resource_manager = player.get_node("ResourceManager")
	if not player_resource_manager:
		return false
	
	var chest_wood = get_item_amount("wood")
	var actual_amount = min(amount, chest_wood)
	
	if actual_amount <= 0:
		print("Chest has no wood!")
		return false
	
	# Check if player has space
	var player_space = player_resource_manager.get_available_space("wood")
	actual_amount = min(actual_amount, player_space)
	
	if actual_amount <= 0:
		print("Player inventory is full!")
		return false
	
	var retrieved = retrieve_item("wood", actual_amount)
	if retrieved > 0:
		player_resource_manager.add_resource("wood", retrieved)
		print("Transferred ", retrieved, " wood from chest to player")
		show_storage_status()
		return true
	
	return false

func transfer_food_from_chest(player: Node, amount: int = 5) -> bool:
	"""Transfer food from chest to player"""
	var player_resource_manager = player.get_node("ResourceManager")
	if not player_resource_manager:
		return false
	
	var chest_food = get_item_amount("food")
	var actual_amount = min(amount, chest_food)
	
	if actual_amount <= 0:
		print("Chest has no food!")
		return false
	
	# Check if player has space
	var player_space = player_resource_manager.get_available_space("food")
	actual_amount = min(actual_amount, player_space)
	
	if actual_amount <= 0:
		print("Player food inventory is full!")
		return false
	
	var retrieved = retrieve_item("food", actual_amount)
	if retrieved > 0:
		player_resource_manager.add_resource("food", retrieved)
		print("Transferred ", retrieved, " food from chest to player")
		show_storage_status()
		return true
	
	return false

func transfer_all_wood_to_chest(player: Node) -> bool:
	"""Transfer all wood from player to chest"""
	var player_resource_manager = player.get_node("ResourceManager")
	if not player_resource_manager:
		return false
	
	var player_wood = player_resource_manager.get_resource_amount("wood")
	return transfer_wood_to_chest(player, player_wood)

func transfer_all_food_to_chest(player: Node) -> bool:
	"""Transfer all food from player to chest"""
	var player_resource_manager = player.get_node("ResourceManager")
	if not player_resource_manager:
		return false
	
	var player_food = player_resource_manager.get_resource_amount("food")
	return transfer_food_to_chest(player, player_food)

func transfer_all_wood_from_chest(player: Node) -> bool:
	"""Transfer all wood from chest to player"""
	var chest_wood = get_item_amount("wood")
	return transfer_wood_from_chest(player, chest_wood)

func transfer_all_food_from_chest(player: Node) -> bool:
	"""Transfer all food from chest to player"""
	var chest_food = get_item_amount("food")
	return transfer_food_from_chest(player, chest_food)

func show_storage_status():
	"""Show current storage status"""
	print("Chest status: ", get_total_stored_items(), "/", storage_capacity, " items")
	for item_type in storage_items.keys():
		print("  ", item_type.capitalize(), ": ", storage_items[item_type])

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
