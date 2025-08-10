# PlayerInteraction handles all object proximity tracking, gathering mechanics, and shelter interactions
extends "res://components/player_component.gd"
class_name PlayerInteraction

# Signals
signal nearby_object_changed(object_type: String, object: Node3D, is_near: bool)
signal gathering_started(object_type: String, object: Node3D)
signal gathering_stopped(object_type: String, object: Node3D)
signal shelter_entered(shelter: Node3D)
signal shelter_exited(shelter: Node3D)
signal interaction_available(interaction_type: String, object: Node3D)

# Nearby object tracking
var nearby_tree: Node3D = null
var nearby_tent: Node3D = null
var nearby_shelter: Node3D = null  # For tent shelter interaction
var nearby_pumpkin: Node3D = null  # For pumpkin gathering

# Internal state
var is_gathering: bool = false
var current_gathering_object: Node3D = null
var gathering_type: String = ""
var interaction_enabled: bool = true  # Control whether interactions are allowed

# Shelter state
var is_in_shelter: bool = false
var current_shelter: Node3D = null

# Tiredness costs for interactions (configurable)
@export var tree_chopping_tiredness_cost: float = 5.0
@export var building_tiredness_cost: float = 3.0
@export var pumpkin_gathering_tiredness_cost: float = 2.0

# Component references
var player_movement # : PlayerMovement (dynamic typing)
var player_survival # : PlayerSurvival (dynamic typing)

func _on_initialize() -> void:
	# Get component references - use lowercase names to match PlayerController
	player_movement = get_sibling_component("movement")
	player_survival = get_sibling_component("survival")
	
	if not player_movement:
		emit_error("PlayerMovement component not found")
		return
	
	if not player_survival:
		emit_error("PlayerSurvival component not found")
		return
	
	# Connect to movement to handle gathering interruption
	if player_movement.has_signal("movement_started"):
		player_movement.movement_started.connect(_on_movement_started)
	
	print("PlayerInteraction initialized for player ", player_controller.player_id)

func _on_cleanup():
	# Stop any ongoing gathering
	if is_gathering:
		stop_gathering()
	
	# Exit shelter if inside one
	if is_in_shelter:
		exit_shelter()
	
	# Clear all nearby objects
	clear_all_nearby_objects()

# Handle interaction input from PlayerController
func handle_interaction_input(action_pressed: bool, action_released: bool):
	# Don't process interactions if disabled (e.g., player is dead)
	if not interaction_enabled:
		return
		
	if action_pressed:
		_handle_interaction_pressed()
	elif action_released:
		_handle_interaction_released()

func _handle_interaction_pressed():
	# Don't process interactions if disabled
	if not interaction_enabled:
		return
		
	# Priority order for interactions:
	# 1. Tree gathering (if not already gathering)
	# 2. Tent building
	# 3. Shelter entry
	# 4. Pumpkin gathering (if not already gathering)
	
	if nearby_tree and not is_gathering:
		start_gathering_tree()
	elif nearby_tent:
		start_building_tent()
	elif nearby_shelter and not is_in_shelter:
		enter_shelter_manually()
	elif nearby_pumpkin and not is_gathering:
		start_gathering_pumpkin()

func _handle_interaction_released():
	# Stop gathering if action key is released (building doesn't need to be stopped)
	if is_gathering:
		stop_gathering()

# Movement integration
func _on_movement_started():
	# If player moves while gathering, stop gathering
	if is_gathering:
		stop_gathering()

# Tree interaction methods
func set_nearby_tree(tree: Node3D):
	# Check if this tree is closer than the current nearby tree
	if nearby_tree == null:
		nearby_tree = tree
		nearby_object_changed.emit("tree", tree, true)
		interaction_available.emit("chop_tree", tree)
		print("Player ", player_controller.player_id, " near tree")
	else:
		# Compare distances to find the closest tree
		var current_distance = player_controller.global_position.distance_to(nearby_tree.global_position)
		var new_distance = player_controller.global_position.distance_to(tree.global_position)
		
		if new_distance < current_distance:
			# Switch to the closer tree
			nearby_tree = tree
			nearby_object_changed.emit("tree", tree, true)
			interaction_available.emit("chop_tree", tree)
			print("Player ", player_controller.player_id, " switched to closer tree")

func clear_nearby_tree(tree: Node3D):
	if nearby_tree == tree:
		nearby_tree = null
		nearby_object_changed.emit("tree", tree, false)
		if is_gathering and current_gathering_object == tree:
			stop_gathering()
		print("Player ", player_controller.player_id, " left tree area")
		
		# Check if there are other trees in range to switch to
		_find_alternative_nearby_tree()

func _find_alternative_nearby_tree():
	# This would require the tree system to track which trees the player is in range of
	# For now, we'll rely on the trees calling set_nearby_tree when entered
	pass

func start_gathering_tree():
	if nearby_tree and nearby_tree.has_method("start_gathering"):
		# Always allow chopping regardless of inventory space
		if nearby_tree.start_gathering(player_controller):
			is_gathering = true
			current_gathering_object = nearby_tree
			gathering_type = "tree"
			
			# Play gathering animation via movement component
			if player_movement:
				player_movement.play_animation("gather")
			
			# Apply tiredness cost via survival component
			if player_survival:
				player_survival.lose_tiredness(tree_chopping_tiredness_cost, "chopping tree")
			
			gathering_started.emit("tree", nearby_tree)
			print("Player ", player_controller.player_id, " started chopping tree")
			return true
	return false

# Pumpkin interaction methods
func set_nearby_pumpkin(pumpkin: Node3D):
	if nearby_pumpkin != pumpkin:
		nearby_pumpkin = pumpkin
		nearby_object_changed.emit("pumpkin", pumpkin, true)
		interaction_available.emit("gather_pumpkin", pumpkin)
		print("Player ", player_controller.player_id, " near pumpkin")

func clear_nearby_pumpkin(pumpkin: Node3D):
	if nearby_pumpkin == pumpkin:
		nearby_pumpkin = null
		nearby_object_changed.emit("pumpkin", pumpkin, false)
		if is_gathering and current_gathering_object == pumpkin:
			stop_gathering()
		print("Player ", player_controller.player_id, " left pumpkin area")

func start_gathering_pumpkin():
	if nearby_pumpkin and nearby_pumpkin.has_method("start_gathering"):
		if nearby_pumpkin.start_gathering(player_controller):
			is_gathering = true
			current_gathering_object = nearby_pumpkin
			gathering_type = "pumpkin"
			
			# Play gathering animation via movement component
			if player_movement:
				player_movement.play_animation("gather")
			
			# Apply tiredness cost via survival component
			if player_survival:
				player_survival.lose_tiredness(pumpkin_gathering_tiredness_cost, "gathering pumpkin")
			
			gathering_started.emit("pumpkin", nearby_pumpkin)
			print("Player ", player_controller.player_id, " started gathering pumpkin")

# Generic gathering stop method
func stop_gathering():
	if not is_gathering:
		return
	
	var gathering_object = current_gathering_object
	var gathering_obj_type = gathering_type
	
	# Stop gathering on the object
	if gathering_object and gathering_object.has_method("stop_gathering"):
		gathering_object.stop_gathering()
	
	# Reset state
	is_gathering = false
	current_gathering_object = null
	gathering_type = ""
	
	# Return to idle animation via movement component
	if player_movement:
		player_movement.play_animation("idle")
	
	gathering_stopped.emit(gathering_obj_type, gathering_object)
	print("Player ", player_controller.player_id, " stopped gathering ", gathering_obj_type)

# Tent interaction methods
func set_nearby_tent(tent: Node3D):
	if nearby_tent != tent:
		nearby_tent = tent
		nearby_object_changed.emit("tent", tent, true)
		interaction_available.emit("build_tent", tent)
		print("Player ", player_controller.player_id, " near tent")

func clear_nearby_tent(tent: Node3D):
	if nearby_tent == tent:
		nearby_tent = null
		nearby_object_changed.emit("tent", tent, false)
		print("Player ", player_controller.player_id, " left tent area")

func start_building_tent():
	if nearby_tent and nearby_tent.has_method("start_building"):
		if nearby_tent.start_building(player_controller):
			# Apply tiredness cost via survival component
			if player_survival:
				player_survival.lose_tiredness(building_tiredness_cost, "building tent")
			
			print("Player ", player_controller.player_id, " initiated tent construction")
			# Note: Building continues in background, no need to track state

# Shelter interaction methods
func set_nearby_shelter(shelter: Node3D):
	if nearby_shelter != shelter:
		nearby_shelter = shelter
		nearby_object_changed.emit("shelter", shelter, true)
		interaction_available.emit("enter_shelter", shelter)
		print("Player ", player_controller.player_id, " can enter tent shelter")

func clear_nearby_shelter(shelter: Node3D):
	if nearby_shelter == shelter:
		nearby_shelter = null
		nearby_object_changed.emit("shelter", shelter, false)
		print("Player ", player_controller.player_id, " can no longer enter tent shelter")

func enter_shelter_manually():
	if nearby_shelter and nearby_shelter.has_method("shelter_player"):
		if nearby_shelter.shelter_player(player_controller):
			enter_shelter_internal(nearby_shelter)

func enter_tent_shelter(shelter: Node3D):
	# This method is called by the tent for automatic tracking
	enter_shelter_internal(shelter)

func enter_shelter_internal(shelter: Node3D):
	is_in_shelter = true
	current_shelter = shelter
	shelter_entered.emit(shelter)
	print("Player ", player_controller.player_id, " entered tent shelter - safe from night!")

func exit_tent_shelter(shelter: Node3D):
	if current_shelter == shelter:
		exit_shelter()

func exit_shelter():
	if is_in_shelter and current_shelter:
		var shelter = current_shelter
		is_in_shelter = false
		current_shelter = null
		shelter_exited.emit(shelter)
		print("Player ", player_controller.player_id, " left tent shelter")

# Clear all nearby objects (for cleanup)
func clear_all_nearby_objects():
	if nearby_tree:
		clear_nearby_tree(nearby_tree)
	if nearby_tent:
		clear_nearby_tent(nearby_tent)
	if nearby_shelter:
		clear_nearby_shelter(nearby_shelter)
	if nearby_pumpkin:
		clear_nearby_pumpkin(nearby_pumpkin)

# Public getters for external access
func is_gathering_active() -> bool:
	return is_gathering

func get_gathering_type() -> String:
	return gathering_type

func get_gathering_object() -> Node3D:
	return current_gathering_object

func is_sheltered() -> bool:
	return is_in_shelter

func get_current_shelter() -> Node3D:
	return current_shelter

func has_nearby_object(object_type: String) -> bool:
	match object_type:
		"tree":
			return nearby_tree != null
		"tent":
			return nearby_tent != null
		"shelter":
			return nearby_shelter != null
		"pumpkin":
			return nearby_pumpkin != null
		_:
			return false

func get_nearby_object(object_type: String) -> Node3D:
	match object_type:
		"tree":
			return nearby_tree
		"tent":
			return nearby_tent
		"shelter":
			return nearby_shelter
		"pumpkin":
			return nearby_pumpkin
		_:
			return null

# Get available interactions
func get_available_interactions() -> Array[String]:
	var interactions: Array[String] = []
	
	if nearby_tree and not is_gathering:
		interactions.append("chop_tree")
	if nearby_tent:
		interactions.append("build_tent")
	if nearby_shelter and not is_in_shelter:
		interactions.append("enter_shelter")
	if nearby_pumpkin and not is_gathering:
		interactions.append("gather_pumpkin")
	
	return interactions

# Priority interaction (for UI hints)
func get_priority_interaction() -> String:
	var interactions = get_available_interactions()
	if interactions.size() > 0:
		return interactions[0]  # Return highest priority
	return ""
