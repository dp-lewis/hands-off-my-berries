extends CharacterBody3D

@export var speed: float = 5.0
@export var acceleration: float = 20.0
@export var friction: float = 15.0
@export var player_id: int = 0

# Resource and interaction variables
var wood: int = 0
var food: int = 0  # New food inventory
var max_inventory: int = 10  # Maximum items player can carry
var max_food_inventory: int = 5  # Maximum food items player can carry
var nearby_tree: Node3D = null
var nearby_tent: Node3D = null
var nearby_shelter: Node3D = null  # For tent shelter interaction
var nearby_pumpkin: Node3D = null  # For pumpkin gathering
var is_gathering: bool = false
var is_building: bool = false

# Shelter variables
var is_in_shelter: bool = false
var current_shelter: Node3D = null

# Building mode variables
var is_in_build_mode: bool = false
var tent_ghost: Node3D = null
@export var tent_scene: PackedScene = preload("res://models/kenney_nature-kit/tent_detailed_closed.tscn")

# Character model reference
@onready var character_model: Node3D = $"character-female-a2"
@onready var animation_player: AnimationPlayer

# Simple UI reference
var player_ui: Control = null
@export var simple_ui_scene: PackedScene = preload("res://ui/simple_player_ui.tscn")

# Simple survival variables
var health: float = 100.0
var max_health: float = 100.0
var hunger: float = 100.0  # New hunger system (0-100)
var max_hunger: float = 100.0
var tiredness: float = 100.0  # New tiredness system (0-100)
var max_tiredness: float = 100.0
var is_night_time: bool = false

# Hunger and food system configuration (easy to adjust)
@export var hunger_decrease_rate: float = 0.5  # Hunger lost per minute (casual rate)
@export var health_decrease_rate: float = 5.0  # Health lost per minute when starving
@export var auto_eat_threshold: float = 30.0  # Auto-eat when hunger drops below this
@export var pumpkin_hunger_restore: float = 25.0  # How much hunger pumpkins restore

# Tiredness system configuration (easy to adjust)
@export var base_tiredness_rate: float = 1.0  # Base tiredness lost per minute
@export var walking_tiredness_rate: float = 0.1  # Tiredness lost per second while moving
@export var tree_chopping_tiredness_cost: float = 5.0  # Tiredness lost when chopping a tree
@export var building_tiredness_cost: float = 3.0  # Tiredness lost when building
@export var pumpkin_gathering_tiredness_cost: float = 2.0  # Tiredness lost when gathering pumpkin
@export var tent_recovery_rate: float = 10.0  # Tiredness recovered per minute in tent
@export var tiredness_health_decrease_rate: float = 3.0  # Health lost per minute when exhausted

func _ready():
	# Add player to group for day/night system to find
	add_to_group("players")
	
	# Create simple UI
	create_simple_ui()

func _physics_process(delta):
	var input_dir = get_input_direction()
	
	# Initialize animation player if not done yet
	if not animation_player:
		find_animation_player()
	
	# Handle movement (always works, even while gathering)
	handle_movement(input_dir, delta)
	
	# Handle building mode toggle
	handle_build_mode_input()
	
	# Handle interaction input
	handle_interaction_input()
	
	# Update ghost position if in build mode
	if is_in_build_mode and tent_ghost:
		update_ghost_position()
	
	# Handle hunger and health system
	handle_hunger_system(delta)
	
	# Handle tiredness system
	handle_tiredness_system(delta)
	
	# Simple night survival
	# if is_night_time and not is_in_shelter:
	# 	take_damage(10.0 * delta)  # 10 damage per second at night when exposed
	# elif is_in_shelter:
	# 	heal(5.0 * delta)  # 5 health per second when sheltered

func handle_movement(input_dir: Vector2, delta: float):
	if input_dir != Vector2.ZERO:
		# Accelerate towards target velocity
		var target_velocity = Vector3(input_dir.x * speed, 0, input_dir.y * speed)
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
		
		# Rotate character model to face movement direction
		if character_model and target_velocity.length() > 0.1:
			var look_direction = Vector3(input_dir.x, 0, input_dir.y).normalized()
			var target_rotation = atan2(look_direction.x, look_direction.z)
			character_model.rotation.y = lerp_angle(character_model.rotation.y, target_rotation, 10.0 * delta)
		
		# Play walking animation
		play_animation("walk")
		
		# If player moves while gathering, stop gathering (building continues in background)
		if is_gathering and input_dir.length() > 0.1:
			stop_gathering()
	else:
		# Apply friction when no input
		velocity = velocity.move_toward(Vector3.ZERO, friction * delta)
		
		# Play idle animation when not moving
		if velocity.length() < 0.1:
			play_animation("idle")
	
	move_and_slide()

func find_animation_player():
	# Search for AnimationPlayer in the character model hierarchy
	if character_model:
		animation_player = find_node_by_type(character_model, null) as AnimationPlayer
		if animation_player:
			print("Found AnimationPlayer with animations: ", animation_player.get_animation_list())
		else:
			print("No AnimationPlayer found in character model")

func find_node_by_type(node: Node, node_type) -> Node:
	# Check if this node is an AnimationPlayer
	if node is AnimationPlayer:
		return node
	
	# Recursively search children
	for child in node.get_children():
		var result = find_node_by_type(child, node_type)
		if result:
			return result
	
	return null

func play_animation(anim_name: String):
	if not animation_player:
		return
	
	# Try common animation names based on the requested type
	var animation_names = []
	match anim_name:
		"walk":
			animation_names = ["walk", "walking", "run", "running", "move", "moving"]
		"idle":
			animation_names = ["idle", "stand", "standing", "rest"]
		"gather":
			animation_names = ["attack_melee_left", "gather", "gathering", "chop", "chopping", "work", "working", "action"]
	
	# Try to find and play a matching animation
	var available_animations = animation_player.get_animation_list()
	for candidate in animation_names:
		if candidate in available_animations:
			if animation_player.current_animation != candidate:
				animation_player.play(candidate)
			return
	
	# If no specific animation found, try to play anything that might work
	if available_animations.size() > 0:
		print("Available animations: ", available_animations)
		# You can manually map animations here once you know their names

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
		elif nearby_pumpkin and not is_gathering:
			start_gathering_pumpkin()
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

# Hunger and Food System
func handle_hunger_system(delta: float):
	# Decrease hunger over time (convert rate from per-minute to per-second)
	hunger -= (hunger_decrease_rate / 10.0) * delta
	hunger = max(hunger, 0.0)
	
	# Log hunger status occasionally (every 5 seconds)
	var time_seconds = int(Time.get_ticks_msec() / 1000.0)
	if time_seconds % 5 == 0 and (Time.get_ticks_msec() % 1000) < 16:
		print("Player ", player_id, " - Hunger: ", int(hunger), "/", int(max_hunger), " Food: ", food)
	
	# Auto-eat if hunger is low and we have food
	if hunger <= auto_eat_threshold and food > 0:
		consume_food()
	
	# If hunger reaches 0, start losing health
	if hunger <= 0.0:
		take_damage((health_decrease_rate / 60.0) * delta)
		if time_seconds % 3 == 0 and (Time.get_ticks_msec() % 1000) < 16:
			print("Player ", player_id, " is starving! Health: ", int(health))

func consume_food():
	if food > 0:
		food -= 1
		hunger = min(hunger + pumpkin_hunger_restore, max_hunger)
		print("Player ", player_id, " auto-ate food! Hunger restored to ", int(hunger), " (", food, " food remaining)")

# Tiredness System
func handle_tiredness_system(delta: float):
	# Base tiredness decrease over time (convert rate from per-minute to per-second)
	tiredness -= (base_tiredness_rate / 60.0) * delta
	
	# Additional tiredness from walking/moving
	var input_dir = get_input_direction()
	if input_dir.length() > 0.1:  # Player is moving
		tiredness -= walking_tiredness_rate * delta
	
	# Recover tiredness if in shelter
	if is_in_shelter:
		tiredness += (tent_recovery_rate / 60.0) * delta
	
	# Clamp tiredness to valid range
	tiredness = clamp(tiredness, 0.0, max_tiredness)
	
	# Log tiredness status occasionally (every 7 seconds to offset from hunger logging)
	var time_seconds = int(Time.get_ticks_msec() / 1000.0)
	if time_seconds % 7 == 0 and (Time.get_ticks_msec() % 1000) < 16:
		var status = " (Resting)" if is_in_shelter else ""
		print("Player ", player_id, " - Tiredness: ", int(tiredness), "/", int(max_tiredness), status)
	
	# If tiredness reaches 0, start losing health
	if tiredness <= 0.0:
		take_damage((tiredness_health_decrease_rate / 60.0) * delta)
		if time_seconds % 4 == 0 and (Time.get_ticks_msec() % 1000) < 16:
			print("Player ", player_id, " is exhausted! Health: ", int(health))

func lose_tiredness(amount: float, activity: String = ""):
	tiredness = max(tiredness - amount, 0.0)
	if activity != "":
		print("Player ", player_id, " is tired from ", activity, " (Tiredness: ", int(tiredness), ")")

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
			play_animation("gather")
			lose_tiredness(tree_chopping_tiredness_cost, "chopping tree")
			print("Player ", player_id, " started gathering")

func stop_gathering():
	if is_gathering and nearby_tree:
		nearby_tree.stop_gathering()
		is_gathering = false
		play_animation("idle")
		print("Player ", player_id, " stopped gathering")
	elif is_gathering and nearby_pumpkin:
		nearby_pumpkin.stop_gathering()
		is_gathering = false
		play_animation("idle")
		print("Player ", player_id, " stopped gathering pumpkin")

# Pumpkin interaction methods
func set_nearby_pumpkin(pumpkin: Node3D):
	nearby_pumpkin = pumpkin
	print("Player ", player_id, " near pumpkin")

func clear_nearby_pumpkin(pumpkin: Node3D):
	if nearby_pumpkin == pumpkin:
		nearby_pumpkin = null
		if is_gathering:
			stop_gathering()
		print("Player ", player_id, " left pumpkin area")

func start_gathering_pumpkin():
	if nearby_pumpkin and nearby_pumpkin.has_method("start_gathering"):
		if nearby_pumpkin.start_gathering(self):
			is_gathering = true
			play_animation("gather")
			lose_tiredness(pumpkin_gathering_tiredness_cost, "gathering pumpkin")
			print("Player ", player_id, " started gathering pumpkin")

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
			lose_tiredness(building_tiredness_cost, "building tent")
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
			print("Player ", player_id, " entered tent shelter - safe from night!")

func enter_tent_shelter(tent: Node3D):
	# This method is called by the tent for automatic tracking
	is_in_shelter = true
	current_shelter = tent
	print("Player ", player_id, " is now sheltered in tent - resting and recovering!")
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

func add_food(amount: int) -> bool:
	var space_available = max_food_inventory - food
	var amount_to_add = min(amount, space_available)
	
	if amount_to_add > 0:
		food += amount_to_add
		print("Player ", player_id, " collected ", amount_to_add, " food (", food, "/", max_food_inventory, ")")
		
		# Return true if we could collect all the food
		return amount_to_add == amount
	else:
		print("Player ", player_id, " food inventory full! (", food, "/", max_food_inventory, ")")
		return false

func get_food_inventory_space() -> int:
	return max_food_inventory - food

func is_food_inventory_full() -> bool:
	return food >= max_food_inventory

# Simple day/night survival methods
func on_day_started():
	is_night_time = false
	print("Player ", player_id, " feels safer in daylight")

func on_night_started():
	is_night_time = true
	print("Player ", player_id, " feels the danger of night")
	if not is_in_shelter:
		print("Player ", player_id, " is exposed to night dangers!")

func take_damage(amount: float):
	health = max(health - amount, 0.0)
	
	if health <= 0.0:
		print("Player ", player_id, " has died from night exposure!")
		respawn_player()
	elif health < 25.0:
		print("Player ", player_id, " is in critical condition! (", int(health), "/", int(max_health), " health)")

func heal(amount: float):
	health = min(health + amount, max_health)

func respawn_player():
	health = max_health
	global_position = Vector3.ZERO  # Reset to spawn point
	print("Player ", player_id, " has respawned")

func get_health() -> float:
	return health

func get_health_percentage() -> float:
	return health / max_health

func get_tiredness() -> float:
	return tiredness

func get_tiredness_percentage() -> float:
	return tiredness / max_tiredness

# Simple UI Management
func create_simple_ui():
	if simple_ui_scene and not player_ui:
		player_ui = simple_ui_scene.instantiate()
		# Use call_deferred to avoid "parent node is busy" error
		get_tree().current_scene.add_child.call_deferred(player_ui)
		# Also defer the setup to ensure the UI is added first
		call_deferred("setup_ui_for_player")

func setup_ui_for_player():
	if player_ui and player_ui.has_method("setup_for_player"):
		player_ui.setup_for_player(self)
		print("Created simple UI for Player ", player_id)
