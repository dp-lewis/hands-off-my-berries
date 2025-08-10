# Integrated PlayerController
# Replaces the monolithic player.gd with component-based architecture
extends CharacterBody3D

@export var player_id: int = 0
@export var speed: float = 5.0
@export var acceleration: float = 20.0
@export var friction: float = 15.0

# Component references (using dynamic typing to avoid circular dependencies)
var player_movement # : PlayerMovement
var player_survival # : PlayerSurvival
var player_builder # : PlayerBuilder
var player_interaction # : PlayerInteraction
var player_input_handler # : PlayerInputHandler

# Resource Management System (keeping existing integration)
@onready var resource_manager: ResourceManager = $ResourceManager
var resource_config

# UI System (keeping existing integration)
var player_ui: Control = null
@export var player_ui_scene: PackedScene = preload("res://ui/player_ui.tscn")

func _ready():
	# Add player to group for day/night system to find
	add_to_group("players")
	
	# Setup resource management system
	setup_resource_system()
	
	# Create simple UI
	create_player_ui()
	
	# Initialize component architecture
	setup_components()

func setup_components():
	"""Initialize all player components"""
	
	# Create components (load scripts dynamically)
	var PlayerMovement = load("res://components/player_movement.gd")
	var PlayerSurvival = load("res://components/player_survival.gd")
	var PlayerBuilder = load("res://components/player_builder.gd")
	var PlayerInteraction = load("res://scenes/players/components/player_interaction.gd")
	var PlayerInputHandler = load("res://scenes/players/components/player_input_handler.gd")
	
	player_movement = PlayerMovement.new()
	player_survival = PlayerSurvival.new()
	player_builder = PlayerBuilder.new()
	player_interaction = PlayerInteraction.new()
	player_input_handler = PlayerInputHandler.new()
	
	# Add components as children
	add_child(player_movement)
	add_child(player_survival)
	add_child(player_builder)
	add_child(player_interaction)
	add_child(player_input_handler)
	
	# Initialize components with this controller
	player_movement.initialize(self)
	player_survival.initialize(self)
	player_builder.initialize(self)
	player_interaction.initialize(self)
	player_input_handler.initialize(self)
	
	# Setup component communication
	connect_component_signals()
	
	print("PlayerController: All components initialized for player ", player_id)

func connect_component_signals():
	"""Connect signals between components for coordination"""
	
	# Input Handler -> Other Components
	if player_input_handler.has_signal("movement_input"):
		player_input_handler.movement_input.connect(_on_movement_input)
	if player_input_handler.has_signal("action_pressed"):
		player_input_handler.action_pressed.connect(_on_action_pressed)
	if player_input_handler.has_signal("action_released"):
		player_input_handler.action_released.connect(_on_action_released)
	if player_input_handler.has_signal("build_mode_toggled"):
		player_input_handler.build_mode_toggled.connect(_on_build_mode_toggled)
	
	# Movement -> Interaction (movement interrupts gathering)
	if player_movement.has_signal("movement_started"):
		player_movement.movement_started.connect(player_interaction._on_movement_started)
	
	# Interaction -> Movement (for animations)
	if player_interaction.has_signal("gathering_started"):
		player_interaction.gathering_started.connect(_on_gathering_started)
	if player_interaction.has_signal("gathering_stopped"):
		player_interaction.gathering_stopped.connect(_on_gathering_stopped)
	
	# Builder -> Survival (for tiredness costs)
	if player_builder.has_signal("building_action"):
		player_builder.building_action.connect(_on_building_action)
	
	# Component errors
	for component in [player_movement, player_survival, player_builder, player_interaction, player_input_handler]:
		if component.has_signal("component_error"):
			component.component_error.connect(_on_component_error)

func _physics_process(delta):
	"""Main update loop coordinating all components"""
	
	# Update survival systems
	if player_survival:
		player_survival.process_survival(delta)
	
	# Update builder ghost positioning
	if player_builder and player_builder.is_in_build_mode():
		player_builder.update_ghost_position(global_position)
	
	# Move and slide (physics handled by movement component)
	move_and_slide()

# Input event handlers
func _on_movement_input(direction: Vector2):
	"""Handle movement input from input handler"""
	if player_movement:
		player_movement.handle_movement_input(direction, get_physics_process_delta_time())

func _on_action_pressed():
	"""Handle action button press"""
	if player_interaction:
		player_interaction.handle_interaction_input(true, false)

func _on_action_released():
	"""Handle action button release"""
	if player_interaction:
		player_interaction.handle_interaction_input(false, true)

func _on_build_mode_toggled():
	"""Handle build mode toggle"""
	if player_builder:
		player_builder.toggle_build_mode()

# Component coordination handlers
func _on_gathering_started(_object_type: String, _object: Node3D):
	"""Coordinate gathering start across components"""
	if player_movement:
		player_movement.play_animation("gather")

func _on_gathering_stopped(_object_type: String, _object: Node3D):
	"""Coordinate gathering stop across components"""
	if player_movement:
		player_movement.play_animation("idle")

func _on_building_action(action_type: String, cost: float):
	"""Handle building actions that affect survival"""
	if player_survival and action_type == "tiredness_cost":
		player_survival.lose_tiredness(cost, "building")

func _on_component_error(message: String):
	"""Handle component errors"""
	print("PlayerController Error: ", message)

# Legacy compatibility methods (for external game objects)
# These delegate to the appropriate components

# Tree interaction compatibility
func set_nearby_tree(tree: Node3D):
	if player_interaction:
		player_interaction.set_nearby_tree(tree)

func clear_nearby_tree(tree: Node3D):
	if player_interaction:
		player_interaction.clear_nearby_tree(tree)

# Pumpkin interaction compatibility
func set_nearby_pumpkin(pumpkin: Node3D):
	if player_interaction:
		player_interaction.set_nearby_pumpkin(pumpkin)

func clear_nearby_pumpkin(pumpkin: Node3D):
	if player_interaction:
		player_interaction.clear_nearby_pumpkin(pumpkin)

# Tent interaction compatibility
func set_nearby_tent(tent: Node3D):
	if player_interaction:
		player_interaction.set_nearby_tent(tent)

func clear_nearby_tent(tent: Node3D):
	if player_interaction:
		player_interaction.clear_nearby_tent(tent)

# Shelter interaction compatibility
func set_nearby_shelter(shelter: Node3D):
	if player_interaction:
		player_interaction.set_nearby_shelter(shelter)

func clear_nearby_shelter(shelter: Node3D):
	if player_interaction:
		player_interaction.clear_nearby_shelter(shelter)

func enter_tent_shelter(shelter: Node3D):
	if player_interaction:
		player_interaction.enter_tent_shelter(shelter)

func exit_tent_shelter(shelter: Node3D):
	if player_interaction:
		player_interaction.exit_tent_shelter(shelter)

# Resource inventory compatibility (delegated to ResourceManager)
func add_wood(amount: int) -> bool:
	if not resource_manager:
		print("Warning: ResourceManager not available for Player ", player_id)
		return false
	
	var amount_added = resource_manager.add_resource("wood", amount)
	return amount_added == amount

func get_inventory_space() -> int:
	if not resource_manager:
		return 0
	return resource_manager.get_available_space("wood")

func is_inventory_full() -> bool:
	if not resource_manager:
		return false
	return resource_manager.is_resource_full("wood")

func add_food(amount: int) -> bool:
	if not resource_manager:
		print("Warning: ResourceManager not available for Player ", player_id)
		return false
	
	var amount_added = resource_manager.add_resource("food", amount)
	return amount_added == amount

func get_food_inventory_space() -> int:
	if not resource_manager:
		return 0
	return resource_manager.get_available_space("food")

func is_food_inventory_full() -> bool:
	if not resource_manager:
		return false
	return resource_manager.is_resource_full("food")

# Survival state compatibility
func get_health() -> float:
	if player_survival:
		return player_survival.get_health()
	return 100.0

func get_health_percentage() -> float:
	if player_survival:
		return player_survival.get_health_percentage()
	return 1.0

func get_tiredness() -> float:
	if player_survival:
		return player_survival.get_tiredness()
	return 100.0

func get_tiredness_percentage() -> float:
	if player_survival:
		return player_survival.get_tiredness_percentage()
	return 1.0

func is_sheltered() -> bool:
	if player_interaction:
		return player_interaction.is_sheltered()
	return false

func get_current_shelter() -> Node3D:
	if player_interaction:
		return player_interaction.get_current_shelter()
	return null

# Day/night system compatibility
func on_day_started():
	if player_survival:
		player_survival.on_day_started()

func on_night_started():
	if player_survival:
		player_survival.on_night_started()

# Damage/healing compatibility
func take_damage(amount: float):
	if player_survival:
		player_survival.take_damage(amount)

func heal(amount: float):
	if player_survival:
		player_survival.heal(amount)

func respawn_player():
	if player_survival:
		player_survival.respawn_player()
	global_position = Vector3.ZERO  # Reset to spawn point

# Resource Management System Setup (keeping existing implementation)
func setup_resource_system():
	if not resource_manager:
		print("Warning: ResourceManager not found for Player ", player_id)
		return
	
	# Create resource config dynamically
	var ResourceConfigScript = load("res://config/resource_config.gd")
	resource_config = ResourceConfigScript.new()
	
	# Setup active resource types using config
	for resource_type in resource_config.get_active_resource_types():
		var capacity = resource_config.get_max_capacity(resource_type)
		resource_manager.setup_resource_type(resource_type, capacity, 0)
	
	# Connect signals for UI updates and game events
	resource_manager.resource_changed.connect(_on_resource_changed)
	resource_manager.resource_full.connect(_on_resource_full)
	resource_manager.resource_empty.connect(_on_resource_empty)
	
	print("ResourceManager initialized for Player ", player_id)

# Resource system signal handlers
func _on_resource_changed(_resource_type: String, _old_amount: int, _new_amount: int):
	# This will be used to update UI reactively
	if player_ui and player_ui.has_method("update_stats"):
		player_ui.update_stats()

func _on_resource_full(resource_type: String):
	print("Player ", player_id, " ", resource_type, " inventory is full!")

func _on_resource_empty(resource_type: String):
	print("Player ", player_id, " ", resource_type, " inventory is empty!")

# Player UI Management (keeping existing implementation)
func create_player_ui():
	if player_ui_scene and not player_ui:
		player_ui = player_ui_scene.instantiate()
		# Use call_deferred to avoid "parent node is busy" error
		get_tree().current_scene.add_child.call_deferred(player_ui)
		# Also defer the setup to ensure the UI is added first
		call_deferred("setup_ui_for_player")

func setup_ui_for_player():
	if player_ui and player_ui.has_method("setup_for_player"):
		player_ui.setup_for_player(self)
		print("Created positioned UI for Player ", player_id)

# Component cleanup
func _exit_tree():
	"""Clean up all components when player is destroyed"""
	if player_movement:
		player_movement.cleanup()
	if player_survival:
		player_survival.cleanup()
	if player_builder:
		player_builder.cleanup()
	if player_interaction:
		player_interaction.cleanup()
	if player_input_handler:
		player_input_handler.cleanup()
	
	print("PlayerController: Cleaned up all components for player ", player_id)
