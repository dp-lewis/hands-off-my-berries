extends CharacterBody3D

@export var speed: float = 5.0
@export var acceleration: float = 20.0
@export var friction: float = 15.0
@export var player_id: int = 0

# Resource and interaction variables
var wood: int = 0
var max_inventory: int = 10  # Maximum items player can carry
var nearby_tree: Node3D = null
var nearby_tent: Node3D = null
var nearby_shelter: Node3D = null  # For tent shelter interaction
var is_gathering: bool = false
var is_building: bool = false

# Shelter variables
var is_in_shelter: bool = false
var current_shelter: Node3D = null

# Building mode variables
var is_in_build_mode: bool = false
var tent_ghost: Node3D = null
@export var tent_scene: PackedScene = preload("res://models/kenney_nature-kit/tent_detailed_closed.tscn")

func _physics_process(delta):
	var input_dir = get_input_direction()
	
	# Handle movement (always works, even while gathering)
	handle_movement(input_dir, delta)
	
	# Handle building mode toggle
	handle_build_mode_input()
	
	# Handle interaction input
	handle_interaction_input()
	
	# Update ghost position if in build mode
	if is_in_build_mode and tent_ghost:
		update_ghost_position()

func handle_movement(input_dir: Vector2, delta: float):
	if input_dir != Vector2.ZERO:
		# Accelerate towards target velocity
		var target_velocity = Vector3(input_dir.x * speed, 0, input_dir.y * speed)
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
		
		# If player moves while gathering, stop gathering (building continues in background)
		if is_gathering and input_dir.length() > 0.1:
			stop_gathering()
	else:
		# Apply friction when no input
		velocity = velocity.move_toward(Vector3.ZERO, friction * delta)
	
	move_and_slide()

func handle_interaction_input():
	var action_key = get_action_key()
	
	if Input.is_action_just_pressed(action_key):  # Changed to just_pressed for single actions
		# Handle different actions based on mode
		if is_in_build_mode:
			# Place tent blueprint
			place_tent_blueprint()
		elif nearby_tree and not is_gathering:
			start_gathering_tree()
		elif nearby_tent:
			start_building_tent()
		elif nearby_shelter and not is_in_shelter:
			enter_shelter_manually()
	elif Input.is_action_just_released(action_key):
		# Stop gathering if action key is released (building doesn't need to be stopped)
		if is_gathering:
			stop_gathering()

func handle_build_mode_input():
	var build_key = get_build_key()
	
	if Input.is_action_just_pressed(build_key):
		toggle_build_mode()

func get_build_key() -> String:
	match player_id:
		0: return "ui_focus_next"  # Tab for keyboard player
		1: return "p2_build"
		2: return "p3_build"
		3: return "p4_build"
	return "ui_select"

func toggle_build_mode():
	if is_in_build_mode:
		exit_build_mode()
	else:
		enter_build_mode()

func enter_build_mode():
	# Check if player has enough wood for tent
	if wood < 8:
		print("Player ", player_id, " needs 8 wood to build tent (have ", wood, ")")
		return
	
	is_in_build_mode = true
	create_tent_ghost()
	print("Player ", player_id, " entered build mode")

func exit_build_mode():
	is_in_build_mode = false
	destroy_tent_ghost()
	print("Player ", player_id, " exited build mode")

func create_tent_ghost():
	if tent_scene and not tent_ghost:
		tent_ghost = tent_scene.instantiate()
		
		# Make it semi-transparent by modifying materials
		make_ghost_transparent()
		
		# Remove any collision or scripts to make it just visual
		remove_ghost_functionality()
		
		# Add to the scene
		get_parent().add_child(tent_ghost)
		update_ghost_position()

func make_ghost_transparent():
	if tent_ghost:
		# Find all MeshInstance3D nodes and make them transparent
		var mesh_instances = find_mesh_instances(tent_ghost)
		for mesh_instance in mesh_instances:
			if mesh_instance.get_surface_override_material_count() == 0:
				# Create a new transparent material
				var material = StandardMaterial3D.new()
				material.albedo_color = Color(1, 1, 1, 0.3)  # 30% opacity
				material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
				mesh_instance.material_override = material
			else:
				# Modify existing material
				var material = mesh_instance.get_surface_override_material(0)
				if material:
					material = material.duplicate()
					material.albedo_color.a = 0.3
					material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
					mesh_instance.set_surface_override_material(0, material)

func find_mesh_instances(node: Node) -> Array:
	var mesh_instances = []
	if node is MeshInstance3D:
		mesh_instances.append(node)
	
	for child in node.get_children():
		mesh_instances += find_mesh_instances(child)
	
	return mesh_instances

func remove_ghost_functionality():
	if tent_ghost:
		# Remove any Area3D or StaticBody3D to prevent interactions
		for child in tent_ghost.get_children():
			if child is Area3D or child is StaticBody3D:
				child.queue_free()

func destroy_tent_ghost():
	if tent_ghost:
		tent_ghost.queue_free()
		tent_ghost = null

func update_ghost_position():
	if tent_ghost:
		# Position ghost slightly in front of player
		var forward_offset = Vector3(0, 0, -2)  # 2 units in front
		tent_ghost.global_position = global_position + forward_offset

func place_tent_blueprint():
	if tent_ghost and wood >= 8:
		# Deduct wood cost for placing the blueprint
		wood -= 8
		
		# Create actual tent at ghost position
		var new_tent = tent_scene.instantiate()
		get_parent().add_child(new_tent)
		new_tent.global_position = tent_ghost.global_position
		
		print("Player ", player_id, " placed tent blueprint (", wood, " wood remaining)")
		
		# Exit build mode
		exit_build_mode()

func get_input_direction() -> Vector2:
	match player_id:
		0: return Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		1: return Input.get_vector("p2_left", "p2_right", "p2_up", "p2_down")
		2: return Input.get_vector("p3_left", "p3_right", "p3_up", "p3_down")
		3: return Input.get_vector("p4_left", "p4_right", "p4_up", "p4_down")
	return Vector2.ZERO

func get_action_key() -> String:
	match player_id:
		0: return "ui_accept"  # Space/Enter for keyboard player
		1: return "p2_action"
		2: return "p3_action"
		3: return "p4_action"
	return "ui_accept"

# Tree interaction methods
func set_nearby_tree(tree: Node3D):
	nearby_tree = tree
	print("Player ", player_id, " near tree")

func clear_nearby_tree(tree: Node3D):
	if nearby_tree == tree:
		nearby_tree = null
		if is_gathering:
			stop_gathering()
		print("Player ", player_id, " left tree area")

func start_gathering_tree():
	if nearby_tree and nearby_tree.has_method("start_gathering"):
		if nearby_tree.start_gathering(self):
			is_gathering = true
			print("Player ", player_id, " started gathering")

func stop_gathering():
	if is_gathering and nearby_tree:
		nearby_tree.stop_gathering()
		is_gathering = false
		print("Player ", player_id, " stopped gathering")

# Tent interaction methods
func set_nearby_tent(tent: Node3D):
	nearby_tent = tent
	print("Player ", player_id, " near tent")

func clear_nearby_tent(tent: Node3D):
	if nearby_tent == tent:
		nearby_tent = null
		if is_building:
			stop_building()
		print("Player ", player_id, " left tent area")

func start_building_tent():
	if nearby_tent and nearby_tent.has_method("start_building"):
		if nearby_tent.start_building(self):
			print("Player ", player_id, " initiated tent construction")
			# Note: Building continues in background, no need to set is_building flag

func stop_building():
	# This function is no longer needed since building continues in background
	# But kept for compatibility
	pass

# Shelter interaction methods
func set_nearby_shelter(tent: Node3D):
	nearby_shelter = tent
	print("Player ", player_id, " can enter tent shelter")

func clear_nearby_shelter(tent: Node3D):
	if nearby_shelter == tent:
		nearby_shelter = null
		print("Player ", player_id, " can no longer enter tent shelter")

func enter_shelter_manually():
	if nearby_shelter and nearby_shelter.has_method("shelter_player"):
		if nearby_shelter.shelter_player(self):
			is_in_shelter = true
			current_shelter = nearby_shelter
			print("Player ", player_id, " entered tent shelter")

func enter_tent_shelter(tent: Node3D):
	# This method is called by the tent for automatic tracking
	is_in_shelter = true
	current_shelter = tent
	print("Player ", player_id, " is now sheltered in tent")
	# Add shelter benefits here (weather protection, healing, etc.)

func exit_tent_shelter(tent: Node3D):
	if current_shelter == tent:
		is_in_shelter = false
		current_shelter = null
		print("Player ", player_id, " left tent shelter")

func is_sheltered() -> bool:
	return is_in_shelter

func get_current_shelter() -> Node3D:
	return current_shelter

func add_wood(amount: int):
	var space_available = max_inventory - wood
	var amount_to_add = min(amount, space_available)
	
	if amount_to_add > 0:
		wood += amount_to_add
		print("Player ", player_id, " collected ", amount_to_add, " wood (", wood, "/", max_inventory, ")")
		
		# Return true if we could collect all the wood
		return amount_to_add == amount
	else:
		print("Player ", player_id, " inventory full! (", wood, "/", max_inventory, ")")
		return false

func get_inventory_space() -> int:
	return max_inventory - wood

func is_inventory_full() -> bool:
	return wood >= max_inventory
