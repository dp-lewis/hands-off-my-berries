# PlayerBuilder Component
# Handles building mode, ghost previews, and construction mechanics
extends "res://components/player_component.gd"

# Building state
var is_in_build_mode: bool = false
var is_building: bool = false
var current_building_type: String = "tent"

# Available building types (in cycle order)
var available_building_types: Array[String] = ["tent", "chest"]
var current_building_index: int = 0
var cycle_count: int = 0  # Track how many times we've cycled
var max_cycles_before_exit: int = 3  # Exit build mode after cycling through all types once

# Ghost preview system
var tent_ghost: Node3D = null
@export var tent_scene: PackedScene = preload("res://scenes/buildables/tent.tscn")
var chest_ghost: Node3D = null
@export var chest_scene: PackedScene = preload("res://scenes/buildables/chest.tscn")

# Building costs and configuration
@export var tent_wood_cost: int = 8
@export var chest_wood_cost: int = 4
@export var building_tiredness_cost: float = 3.0
@export var ghost_forward_offset: float = 2.0  # Distance in front of player
@export var ghost_opacity: float = 0.3  # Ghost transparency (0.0-1.0)

# Component references
var resource_manager = null
var survival_component = null
var nearby_tent: Node3D = null

func _on_initialize():
	"""Initialize builder component"""
	if not player_controller:
		emit_error("PlayerBuilder: No controller provided")
		return
	
	# Initialize building system
	current_building_type = available_building_types[current_building_index]
	
	# Find resource manager
	find_resource_manager()
	
	# Find survival component
	find_survival_component()
	
	print("PlayerBuilder: Initialized for player ", get_player_id())

func _on_cleanup():
	"""Clean up builder component"""
	# Clean up any active ghost
	destroy_tent_ghost()
	
	resource_manager = null
	survival_component = null
	nearby_tent = null
	is_in_build_mode = false
	is_building = false

func find_resource_manager():
	"""Find the resource manager in the controller"""
	if player_controller:
		resource_manager = player_controller.get_node_or_null("ResourceManager")
		if resource_manager:
			print("PlayerBuilder: Found ResourceManager")
		else:
			print("PlayerBuilder: No ResourceManager found")

func find_survival_component():
	"""Find the survival component for tiredness management"""
	survival_component = get_sibling_component("survival")
	if survival_component:
		print("PlayerBuilder: Connected to survival component")

# Builder Interface Implementation

func toggle_build_mode() -> void:
	"""Cycle through building types or enter/exit build mode"""
	if is_in_build_mode:
		# If already in build mode, cycle to next building type
		cycle_to_next_building()
	else:
		# If not in build mode, enter with current building type
		cycle_count = 0  # Reset cycle count when entering build mode
		enter_build_mode()

func cycle_to_next_building() -> void:
	"""Cycle to the next available building type or exit if we've seen all"""
	# Increment cycle count first
	cycle_count += 1
	
	# Check if we've cycled through all options
	if cycle_count > available_building_types.size():
		# We've cycled through all building types, exit build mode
		cycle_count = 0
		current_building_index = 0  # Reset to first building type for next time
		print("Player ", get_player_id(), " cycled through all building types, exiting build mode")
		exit_build_mode()
		return
	
	# Move to next building type
	current_building_index = (current_building_index + 1) % available_building_types.size()
	var new_building_type = available_building_types[current_building_index]
	
	# Set new building type
	set_building_type(new_building_type)
	
	print("Player ", get_player_id(), " switched to building: ", get_current_building_display_name(), " (", cycle_count, "/", available_building_types.size(), ")")
	
	# Switch ghost without exiting build mode
	switch_ghost_to_building_type(new_building_type)
	
	# Update build mode signal
	build_mode_entered.emit(current_building_type)

func switch_ghost_to_building_type(building_type: String) -> void:
	"""Switch the current ghost to a different building type without exiting build mode"""
	# Destroy current ghost
	destroy_building_ghost()
	
	# Create new ghost for the building type
	create_building_ghost(building_type)

func enter_build_mode() -> void:
	"""Enter building mode if resources are available"""
	# Check if player has enough resources for the current building type
	if not can_afford_building(current_building_type):
		var cost_info = get_building_cost(current_building_type)
		var current_wood = resource_manager.get_resource_amount("wood") if resource_manager else 0
		var needed_wood = cost_info.get("wood", 0)
		print("Player ", get_player_id(), " needs ", needed_wood, " wood to build ", current_building_type, " (have ", current_wood, ")")
		build_mode_failed.emit("Insufficient resources for " + get_current_building_display_name())
		return
	
	is_in_build_mode = true
	create_building_ghost(current_building_type)
	print("Player ", get_player_id(), " entered build mode - Building: ", get_current_building_display_name())
	build_mode_entered.emit(current_building_type)

func exit_build_mode() -> void:
	"""Exit building mode and clean up ghost"""
	is_in_build_mode = false
	destroy_building_ghost()
	print("Player ", get_player_id(), " exited build mode")
	build_mode_exited.emit()

func update_ghost_preview() -> void:
	"""Update ghost position relative to player"""
	if is_in_build_mode:
		update_ghost_position()

func place_building() -> bool:
	"""Place the current building if in build mode and resources available"""
	if not is_in_build_mode or (not tent_ghost and not chest_ghost):
		return false
	
	if not can_afford_building(current_building_type):
		print("Player ", get_player_id(), " cannot afford building")
		return false
	
	# Deduct resources based on building type
	var wood_cost = 0
	if resource_manager:
		match current_building_type:
			"tent":
				wood_cost = tent_wood_cost
			"chest":
				wood_cost = chest_wood_cost
		resource_manager.remove_resource("wood", wood_cost)
	
	# Create actual building at ghost position
	var new_building = create_actual_building(current_building_type)
	if new_building:
		# Position building at the appropriate ghost location
		if tent_ghost:
			new_building.global_position = tent_ghost.global_position
		elif chest_ghost:
			new_building.global_position = chest_ghost.global_position
		
		var remaining_wood = resource_manager.get_resource_amount("wood") if resource_manager else 0
		print("Player ", get_player_id(), " placed ", current_building_type, " (", remaining_wood, " wood remaining)")
		
		# Apply tiredness cost
		if survival_component and survival_component.has_method("lose_tiredness"):
			survival_component.lose_tiredness(building_tiredness_cost, "building " + current_building_type)
		
		# Exit build mode
		exit_build_mode()
		
		building_placed.emit(new_building, current_building_type)
		return true
	
	return false

func cancel_building() -> void:
	"""Cancel current building operation"""
	if is_in_build_mode:
		exit_build_mode()
		building_cancelled.emit()

func can_afford_building(building_type: String) -> bool:
	"""Check if player can afford the specified building type"""
	match building_type:
		"tent":
			var current_wood = resource_manager.get_resource_amount("wood") if resource_manager else 0
			return current_wood >= tent_wood_cost
		"chest":
			var current_wood = resource_manager.get_resource_amount("wood") if resource_manager else 0
			return current_wood >= chest_wood_cost
		_:
			return false

func get_building_cost(building_type: String) -> Dictionary:
	"""Get the resource cost for a building type"""
	match building_type:
		"tent":
			return {"wood": tent_wood_cost}
		"chest":
			return {"wood": chest_wood_cost}
		_:
			return {}

func set_building_type(building_type: String) -> void:
	"""Set the current building type"""
	current_building_type = building_type
	building_type_changed.emit(building_type)

func get_current_building_type() -> String:
	"""Get the current building type"""
	return current_building_type

func get_current_building_display_name() -> String:
	"""Get a user-friendly name for the current building type"""
	match current_building_type:
		"tent":
			return "Tent (8 wood)"
		"chest":
			return "Chest (4 wood)"
		_:
			return current_building_type.capitalize()

func get_available_building_types() -> Array[String]:
	"""Get list of all available building types"""
	return available_building_types.duplicate()

func is_in_building_mode() -> bool:
	"""Check if currently in build mode"""
	return is_in_build_mode

# Ghost Preview System

func create_building_ghost(building_type: String) -> void:
	"""Create a ghost preview for the specified building type"""
	match building_type:
		"tent":
			create_tent_ghost()
		"chest":
			create_chest_ghost()
		_:
			print("PlayerBuilder: Unknown building type: ", building_type)

func create_tent_ghost():
	"""Create ghost preview for tent"""
	if tent_scene and not tent_ghost:
		tent_ghost = tent_scene.instantiate()
		
		# Make it semi-transparent
		make_ghost_transparent()
		
		# Remove functionality to make it just visual
		remove_ghost_functionality()
		
		# Add to the scene
		if player_controller and player_controller.get_parent():
			player_controller.get_parent().add_child(tent_ghost)
			update_ghost_position()
			ghost_created.emit(tent_ghost, "tent")

func create_chest_ghost():
	"""Create ghost preview for chest"""
	if chest_scene and not chest_ghost:
		chest_ghost = chest_scene.instantiate()
		
		# Make it semi-transparent using existing system
		make_chest_ghost_transparent()
		
		# Remove functionality to make it just visual
		remove_chest_ghost_functionality()
		
		# Add to the scene
		if player_controller and player_controller.get_parent():
			player_controller.get_parent().add_child(chest_ghost)
			update_ghost_position()
			ghost_created.emit(chest_ghost, "chest")

func make_ghost_transparent():
	"""Make the ghost preview semi-transparent"""
	if tent_ghost:
		# Find all MeshInstance3D nodes and make them transparent
		var mesh_instances = find_mesh_instances(tent_ghost)
		for mesh_instance in mesh_instances:
			create_transparent_material(mesh_instance)

func find_mesh_instances(node: Node) -> Array:
	"""Recursively find all MeshInstance3D nodes"""
	var mesh_instances = []
	if node is MeshInstance3D:
		mesh_instances.append(node)
	
	for child in node.get_children():
		mesh_instances += find_mesh_instances(child)
	
	return mesh_instances

func create_transparent_material(mesh_instance: MeshInstance3D):
	"""Create or modify material to be transparent"""
	if mesh_instance.get_surface_override_material_count() == 0:
		# Create a new transparent material
		var material = StandardMaterial3D.new()
		material.albedo_color = Color(1, 1, 1, ghost_opacity)
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mesh_instance.material_override = material
	else:
		# Modify existing material
		var material = mesh_instance.get_surface_override_material(0)
		if material:
			material = material.duplicate()
			material.albedo_color.a = ghost_opacity
			material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			mesh_instance.set_surface_override_material(0, material)

func remove_ghost_functionality():
	"""Remove collision and interaction from ghost"""
	if tent_ghost:
		# Remove any Area3D or StaticBody3D to prevent interactions
		for child in tent_ghost.get_children():
			if child is Area3D or child is StaticBody3D or child is CharacterBody3D:
				child.queue_free()

func update_ghost_position():
	"""Update ghost position relative to player"""
	if player_controller:
		# Position ghost slightly in front of player
		var forward_offset = Vector3(0, 0, -ghost_forward_offset)
		var new_position = player_controller.global_position + forward_offset
		
		# Update the appropriate ghost based on current building type
		if current_building_type == "tent" and tent_ghost:
			tent_ghost.global_position = new_position
			ghost_position_updated.emit(tent_ghost.global_position)
		elif current_building_type == "chest" and chest_ghost:
			chest_ghost.global_position = new_position
			ghost_position_updated.emit(chest_ghost.global_position)

func make_chest_ghost_transparent():
	"""Make the chest ghost preview semi-transparent"""
	if chest_ghost:
		# Find all MeshInstance3D nodes and make them transparent
		var mesh_instances = find_mesh_instances(chest_ghost)
		for mesh_instance in mesh_instances:
			create_transparent_material(mesh_instance)

func remove_chest_ghost_functionality():
	"""Remove collision and interaction from chest ghost"""
	if chest_ghost:
		# Remove any Area3D or StaticBody3D to prevent interactions
		for child in chest_ghost.get_children():
			if child is Area3D or child is StaticBody3D or child is CharacterBody3D:
				child.queue_free()

func destroy_building_ghost():
	"""Destroy the current building ghost"""
	destroy_tent_ghost()
	destroy_chest_ghost()

func destroy_tent_ghost():
	"""Destroy tent ghost preview"""
	if tent_ghost:
		tent_ghost.queue_free()
		tent_ghost = null
		ghost_destroyed.emit()

func destroy_chest_ghost():
	"""Destroy chest ghost preview"""
	if chest_ghost:
		chest_ghost.queue_free()
		chest_ghost = null
		ghost_destroyed.emit()

# Building Creation System

func create_actual_building(building_type: String) -> Node3D:
	"""Create the actual building (not ghost)"""
	match building_type:
		"tent":
			return create_actual_tent()
		"chest":
			return create_actual_chest()
		_:
			print("PlayerBuilder: Cannot create unknown building type: ", building_type)
			return null

func create_actual_tent() -> Node3D:
	"""Create an actual tent building"""
	if tent_scene:
		var new_tent = tent_scene.instantiate()
		if player_controller and player_controller.get_parent():
			player_controller.get_parent().add_child(new_tent)
		return new_tent
	return null

func create_actual_chest() -> Node3D:
	"""Create an actual chest building"""
	if chest_scene:
		var new_chest = chest_scene.instantiate()
		if player_controller and player_controller.get_parent():
			player_controller.get_parent().add_child(new_chest)
		return new_chest
	return null

# Interaction with nearby buildings

func set_nearby_tent(tent: Node3D):
	"""Set nearby tent for building interactions"""
	nearby_tent = tent
	print("Player ", get_player_id(), " near tent")
	nearby_building_detected.emit(tent, "tent")

func clear_nearby_tent(tent: Node3D):
	"""Clear nearby tent reference"""
	if nearby_tent == tent:
		nearby_tent = null
		if is_building:
			stop_building()
		print("Player ", get_player_id(), " left tent area")
		nearby_building_lost.emit(tent, "tent")

func start_building_tent():
	"""Start building/upgrading nearby tent"""
	if nearby_tent and nearby_tent.has_method("start_building"):
		if nearby_tent.start_building(player_controller):
			# Apply tiredness cost through survival component
			if survival_component and survival_component.has_method("lose_tiredness"):
				survival_component.lose_tiredness(building_tiredness_cost, "building tent")
			print("Player ", get_player_id(), " initiated tent construction")
			building_started.emit(nearby_tent, "tent")
			return true
	return false

func stop_building():
	"""Stop current building operation"""
	# Building continues in background, so this is mainly for cleanup
	is_building = false
	building_stopped.emit()

# Building state queries

func get_nearby_buildings() -> Array:
	"""Get list of nearby buildings"""
	var buildings = []
	if nearby_tent:
		buildings.append(nearby_tent)
	return buildings

func can_place_building_at(_position: Vector3, building_type: String) -> bool:
	"""Check if a building can be placed at the specified position"""
	# Basic validation - could be expanded with collision checking
	if not can_afford_building(building_type):
		return false
	
	# Add more validation logic here (terrain, other buildings, etc.)
	# TODO: Use _position for collision/terrain checking
	return true

# Signals for building system events
signal build_mode_entered(building_type: String)
signal build_mode_exited
signal build_mode_failed(reason: String)
signal building_type_changed(new_type: String)

signal ghost_created(ghost: Node3D, building_type: String)
signal ghost_destroyed
signal ghost_position_updated(position: Vector3)

signal building_placed(building: Node3D, building_type: String)
signal building_started(building: Node3D, building_type: String)
signal building_stopped
signal building_cancelled

signal nearby_building_detected(building: Node3D, building_type: String)
signal nearby_building_lost(building: Node3D, building_type: String)
