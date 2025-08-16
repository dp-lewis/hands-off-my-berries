class_name PlayerFarming
extends PlayerComponent

## PlayerFarming Component - Handles crop planting, soil management, and farming mechanics
## Integrates with PlayerInventory for tool/seed usage and provides sustainable food production

# Farming state
var planted_crops: Array = []  # Array of planted crop instances
var farming_range: float = 2.0  # How close player needs to be to interact with soil

# Soil system
var soil_patches: Dictionary = {}  # Vector3 position -> soil state
var soil_visuals: Dictionary = {}  # Vector3 position -> visual node
var soil_detection_range: float = 3.0

# Farming tools
var current_farming_tool = null

# Signals for component communication
signal crop_planted(position: Vector3, crop_type: String)
signal crop_harvested(position: Vector3, crop_type: String, yield_amount: int)
signal soil_tilled(position: Vector3)
signal farming_action_performed(action_type: String, position: Vector3)

# Soil states
enum SoilState {
	UNTILLED,
	TILLED,
	PLANTED,
	GROWING,
	READY_TO_HARVEST
}

func _on_initialize() -> void:
	"""Component-specific initialization"""
	print("PlayerFarming: Initializing farming component for player ", player_controller.player_id)
	
	# Connect to inventory for tool/seed checking
	if player_controller.has_method("get_component"):
		var inventory = player_controller.get_component("inventory")
		if inventory:
			# Connect to inventory signals for farming actions
			if inventory.has_signal("item_used"):
				inventory.item_used.connect(_on_item_used)
	
	# Set up farming detection area
	setup_farming_detection()

func setup_farming_detection():
	"""Set up area detection for farming interactions"""
	# The farming detection will be handled through existing PlayerInteraction
	# component via ground interaction detection
	pass

func _on_item_used(item_definition, amount: int, player_node: Node3D):
	"""Handle farming tool and seed usage"""
	if not item_definition:
		return
	
	match item_definition.item_id:
		"berry_seeds":
			attempt_plant_seeds(item_definition, amount, player_node)
		"hoe":
			attempt_till_soil(item_definition, player_node)
		"watering_can":
			attempt_water_crops(item_definition, player_node)

func attempt_plant_seeds(seed_definition, _amount: int, player_node: Node3D):
	"""Attempt to plant seeds at player's current location"""
	print("PlayerFarming: Attempting to plant seeds at player position: ", player_node.global_position)
	
	if not can_plant_at_position(player_node.global_position):
		emit_farming_message("Cannot plant here - soil needs to be tilled first!")
		print("PlayerFarming: Planting failed - soil not tilled")
		return false
	
	var plant_position = get_nearest_tilled_position(player_node.global_position)
	if plant_position == Vector3.ZERO:
		emit_farming_message("No tilled soil nearby for planting")
		print("PlayerFarming: No tilled soil found for planting")
		return false
	
	print("PlayerFarming: Found tilled soil for planting at: ", plant_position)
	
	# Plant the seed
	plant_crop_at_position(plant_position, seed_definition)
	emit_farming_message("Planted " + seed_definition.display_name + " successfully!")
	
	# Mark soil as planted
	soil_patches[plant_position] = SoilState.PLANTED
	
	# Update visual indicator for planted soil
	update_soil_visual(plant_position, SoilState.PLANTED)
	
	crop_planted.emit(plant_position, seed_definition.item_id)
	return true

func attempt_till_soil(_tool_definition, player_node: Node3D):
	"""Attempt to till soil with farming tool"""
	print("PlayerFarming: Attempting to till soil at player position: ", player_node.global_position)
	
	var till_position = get_nearest_tillable_position(player_node.global_position)
	if till_position == Vector3.ZERO:
		emit_farming_message("No ground nearby suitable for tilling")
		print("PlayerFarming: No suitable tilling position found")
		return false
	
	print("PlayerFarming: Found suitable tilling position: ", till_position)
	
	# Till the soil
	till_soil_at_position(till_position)
	emit_farming_message("Tilled soil - ready for planting!")
	
	soil_tilled.emit(till_position)
	return true

func attempt_water_crops(_tool_definition, player_node: Node3D):
	"""Attempt to water nearby crops"""
	var watered_count = 0
	var player_pos = player_node.global_position
	
	# Find nearby crops to water
	for crop in planted_crops:
		if crop and is_instance_valid(crop):
			var distance = player_pos.distance_to(crop.global_position)
			if distance <= farming_range:
				if crop.has_method("water_crop"):
					crop.water_crop(player_controller)
					watered_count += 1
	
	if watered_count > 0:
		emit_farming_message("Watered " + str(watered_count) + " crops")
		return true
	else:
		emit_farming_message("No crops nearby to water")
		return false

func can_plant_at_position(position: Vector3) -> bool:
	"""Check if position is suitable for planting"""
	# Find the nearest grid position that might be tilled
	var nearest_tilled = get_nearest_tilled_position(position)
	return nearest_tilled != Vector3.ZERO

func get_nearest_tilled_position(player_position: Vector3) -> Vector3:
	"""Find the nearest tilled soil position"""
	var grid_position = Vector3(round(player_position.x), player_position.y, round(player_position.z))
	
	# Check positions in a small radius around player for tilled soil
	for x_offset in range(-2, 3):
		for z_offset in range(-2, 3):
			var check_pos = grid_position + Vector3(x_offset, 0, z_offset)
			var distance = player_position.distance_to(check_pos)
			
			if distance <= farming_range:
				# Check if this position is tilled
				if check_pos in soil_patches and soil_patches[check_pos] == SoilState.TILLED:
					print("PlayerFarming: Found tilled soil at: ", check_pos, " (distance: ", distance, ")")
					return check_pos
	
	print("PlayerFarming: No tilled soil found within range")
	return Vector3.ZERO

func get_nearest_tillable_position(player_position: Vector3) -> Vector3:
	"""Find the nearest position suitable for farming actions"""
	# Round to grid positions for consistent farming locations
	var grid_position = Vector3(round(player_position.x), player_position.y, round(player_position.z))
	
	# Check positions in a small radius around player
	for x_offset in range(-2, 3):
		for z_offset in range(-2, 3):
			var check_pos = grid_position + Vector3(x_offset, 0, z_offset)
			var distance = player_position.distance_to(check_pos)
			
			if distance <= farming_range:
				# This position is suitable
				return check_pos
	
	return Vector3.ZERO

func till_soil_at_position(position: Vector3):
	"""Till soil at the specified position"""
	soil_patches[position] = SoilState.TILLED
	print("PlayerFarming: Tilled soil at ", position)
	
	# Create visual indication of tilled soil
	create_tilled_soil_visual(position)

func create_tilled_soil_visual(position: Vector3):
	"""Create a visual indicator for tilled soil"""
	# Create a visible box mesh for tilled soil
	var tilled_visual = MeshInstance3D.new()
	
	# Create a brown box to represent tilled soil
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(0.9, 0.1, 0.9)  # Wider, more visible
	tilled_visual.mesh = box_mesh
	
	# Create a bright brown material for better visibility
	var material = StandardMaterial3D.new()
	material.flags_unshaded = true
	material.albedo_color = Color(0.8, 0.4, 0.2, 1.0)  # Brighter brown, no transparency
	tilled_visual.material_override = material
	
	# Add to the world first, then set position
	var world = get_tree().current_scene
	if world:
		world.add_child(tilled_visual)
		# Now that it's in the tree, we can set the global position
		tilled_visual.global_position = position + Vector3(0, 0.05, 0)
		soil_visuals[position] = tilled_visual  # Track the visual
		print("PlayerFarming: Created tilled soil visual at ", position)
	else:
		print("PlayerFarming: Could not create tilled soil visual - no scene")

func update_soil_visual(position: Vector3, new_state: SoilState):
	"""Update the visual indicator for soil state changes"""
	# Remove existing visual if it exists
	if position in soil_visuals:
		var old_visual = soil_visuals[position]
		if old_visual and is_instance_valid(old_visual):
			old_visual.queue_free()
		soil_visuals.erase(position)
	
	# Create new visual based on state
	match new_state:
		SoilState.PLANTED:
			create_planted_soil_visual(position)
		# Other states can be added later
		_:
			pass

func create_planted_soil_visual(position: Vector3):
	"""Create a visual indicator for planted soil"""
	# Remove any existing tilled visual first
	if position in soil_visuals:
		soil_visuals[position].queue_free()
	
	# Create a visible box mesh for planted soil  
	var planted_visual = MeshInstance3D.new()
	
	# Create a darker brown box to represent planted soil
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(0.9, 0.12, 0.9)  # Slightly taller for planted soil
	planted_visual.mesh = box_mesh
	
	# Create a darker brown material
	var material = StandardMaterial3D.new()
	material.flags_unshaded = true
	material.albedo_color = Color(0.6, 0.3, 0.1, 1.0)  # Darker brown for planted soil
	planted_visual.material_override = material
	
	# Add to the world first, then set position
	var world = get_tree().current_scene
	if world:
		world.add_child(planted_visual)
		# Now that it's in the tree, we can set the global position
		planted_visual.global_position = position + Vector3(0, 0.06, 0)
		soil_visuals[position] = planted_visual  # Update the tracked visual
		print("PlayerFarming: Created planted soil visual at ", position)
	else:
		print("PlayerFarming: Could not create planted soil visual - no scene")

func plant_crop_at_position(position: Vector3, _seed_definition):
	"""Plant a crop at the specified position"""
	print("PlayerFarming: Attempting to create berry crop at position: ", position)
	
	# Create berry crop instance
	var berry_scene = preload("res://scenes/food/berries.tscn")
	if not berry_scene:
		emit_farming_message("Error: Could not load berry crop scene")
		print("PlayerFarming: ERROR - Failed to load berries.tscn")
		return
	
	print("PlayerFarming: Berry scene loaded successfully")
	
	var crop_instance = berry_scene.instantiate()
	if not crop_instance:
		emit_farming_message("Error: Could not instantiate berry crop")
		print("PlayerFarming: ERROR - Failed to instantiate berry crop")
		return
	
	print("PlayerFarming: Berry crop instantiated, preparing to add to scene")
	
	# Add to the world (parent to the scene root or farming area)
	var world = get_tree().current_scene
	if not world:
		emit_farming_message("Error: Could not find scene to add crop to")
		print("PlayerFarming: ERROR - No current scene found")
		return
	
	# Add to scene first, then set position
	world.add_child(crop_instance)
	crop_instance.global_position = position
	print("PlayerFarming: Berry crop added to scene and positioned at: ", position)
	
	# Track the planted crop
	planted_crops.append(crop_instance)
	
	print("PlayerFarming: Planted crop at ", position, " - Total crops: ", planted_crops.size())

func get_soil_state_at_position(position: Vector3) -> SoilState:
	"""Get the soil state at a specific position"""
	var check_position = Vector3(round(position.x), position.y, round(position.z))
	if check_position in soil_patches:
		return soil_patches[check_position]
	return SoilState.UNTILLED

func get_nearby_farmable_areas(player_position: Vector3) -> Array:
	"""Get list of nearby areas that can be farmed"""
	var farmable_areas = []
	
	for x_offset in range(-3, 4):
		for z_offset in range(-3, 4):
			var check_pos = player_position + Vector3(x_offset, 0, z_offset)
			var distance = player_position.distance_to(check_pos)
			
			if distance <= soil_detection_range:
				farmable_areas.append({
					"position": check_pos,
					"soil_state": get_soil_state_at_position(check_pos),
					"distance": distance
				})
	
	return farmable_areas

func emit_farming_message(message: String):
	"""Emit farming-related messages to player"""
	print("PlayerFarming [Player ", player_controller.player_id, "]: ", message)
	# TODO: Connect to UI system for in-game notifications

func get_farming_stats() -> Dictionary:
	"""Get current farming statistics"""
	return {
		"planted_crops": planted_crops.size(),
		"tilled_soil_patches": soil_patches.values().count(SoilState.TILLED),
		"growing_crops": soil_patches.values().count(SoilState.GROWING),
		"ready_crops": soil_patches.values().count(SoilState.READY_TO_HARVEST)
	}

# Utility methods for other components
func has_farming_tool() -> bool:
	"""Check if player has any farming tools"""
	var inventory = player_controller.get_component("inventory")
	if inventory and inventory.has_method("has_item"):
		return inventory.has_item("hoe") or inventory.has_item("watering_can")
	return false

func has_seeds() -> bool:
	"""Check if player has any seeds"""
	var inventory = player_controller.get_component("inventory")
	if inventory and inventory.has_method("has_item"):
		return inventory.has_item("berry_seeds")
	return false

func can_perform_farming_action(action_type: String) -> bool:
	"""Check if player can perform a specific farming action"""
	match action_type:
		"plant":
			return has_seeds()
		"till":
			return has_farming_tool()
		"water":
			return has_farming_tool()
		_:
			return false
