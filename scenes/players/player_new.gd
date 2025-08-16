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
var player_inventory # : PlayerInventory

# Resource Management System (keeping existing integration)
@onready var resource_manager: ResourceManager = $ResourceManager
var resource_config

# Legacy property compatibility (for UI system)
var hunger: float:
	get:
		return get_hunger()
var health: float:
	get:
		return get_health()
var tiredness: float:
	get:
		return get_tiredness()
var max_hunger: float:
	get:
		return get_max_hunger()
var max_health: float:
	get:
		return get_max_health()
var max_tiredness: float:
	get:
		return get_max_tiredness()

# UI System (keeping existing integration)
var player_ui: Control = null
@export var player_ui_scene: PackedScene = preload("res://ui/player_ui.tscn")

func _ready():
	# Add player to group for day/night system to find
	add_to_group("players")
	
	# Initialize item system
	setup_item_system()
	
	# Setup resource management system
	setup_resource_system()
	
	# Create simple UI
	create_player_ui()
	
	# Initialize component architecture
	setup_components()

func setup_item_system():
	"""Initialize the item registry and definitions"""
	# Initialize item registry
	var ItemRegistry = preload("res://systems/items/item_registry.gd")
	ItemRegistry.initialize()
	
	print("PlayerController: Item system initialized for player ", player_id)

func setup_components():
	"""Initialize all player components"""
	
	# Create components (load scripts dynamically)
	var PlayerMovement = load("res://components/player_movement.gd")
	var PlayerSurvival = load("res://components/player_survival.gd")
	var PlayerBuilder = load("res://components/player_builder.gd")
	var PlayerInteractionScript = load("res://scenes/players/components/player_interaction.gd")
	var PlayerInputHandlerScript = load("res://scenes/players/components/player_input_handler.gd")
	var PlayerInventory = load("res://components/player_inventory.gd")
	
	print("PlayerController: [SETUP v2] Creating inventory component...")
	player_inventory = PlayerInventory.new()
	print("PlayerController: PlayerInventory created: ", player_inventory)
	
	player_movement = PlayerMovement.new()
	player_survival = PlayerSurvival.new()
	player_builder = PlayerBuilder.new()
	player_interaction = PlayerInteractionScript.new()
	player_input_handler = PlayerInputHandlerScript.new()
	
	# Add components as children
	add_child(player_movement)
	add_child(player_survival)
	add_child(player_builder)
	add_child(player_interaction)
	add_child(player_input_handler)
	print("PlayerController: Adding inventory as child...")
	add_child(player_inventory)
	print("PlayerController: Inventory added, total children: ", get_children().size())
	
	# Initialize components with this controller
	player_movement.initialize(self)
	player_survival.initialize(self)
	player_builder.initialize(self)
	player_interaction.initialize(self)
	player_input_handler.initialize(self)
	print("PlayerController: Initializing inventory component...")
	player_inventory.initialize(self)
	print("PlayerController: Inventory initialized")
	
	# Setup component communication
	connect_component_signals()
	
	# Give starting items to player
	give_starting_items()
	
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
	if player_input_handler.has_signal("hotbar_left_pressed"):
		player_input_handler.hotbar_left_pressed.connect(_on_hotbar_left_pressed)
	if player_input_handler.has_signal("hotbar_right_pressed"):
		player_input_handler.hotbar_right_pressed.connect(_on_hotbar_right_pressed)
	
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
	if player_builder and player_builder.is_in_building_mode():
		player_builder.update_ghost_position()
	
	# Note: Movement physics is handled by PlayerMovement component

# Input event handlers
func _on_movement_input(direction: Vector2):
	"""Handle movement input from input handler"""
	if player_movement:
		player_movement.handle_movement(direction, get_physics_process_delta_time())

func _on_action_pressed():
	"""Handle action button press"""
	# Check if in build mode first
	if player_builder and player_builder.is_in_building_mode():
		# In build mode, action places building
		player_builder.place_building()
	elif player_interaction:
		# Normal mode, handle interactions
		player_interaction.handle_interaction_input(true, false)

func _on_action_released():
	"""Handle action button release"""
	# Only route to interaction if not in build mode
	if not (player_builder and player_builder.is_in_building_mode()) and player_interaction:
		player_interaction.handle_interaction_input(false, true)

func _on_build_mode_toggled():
	"""Handle build mode toggle"""
	if player_builder:
		player_builder.toggle_build_mode()

func _on_hotbar_left_pressed():
	"""Handle hotbar left navigation"""
	if player_inventory:
		player_inventory.navigate_hotbar(-1)  # Move left
		print("Player ", player_id, " navigated hotbar left")

func _on_hotbar_right_pressed():
	"""Handle hotbar right navigation"""
	if player_inventory:
		player_inventory.navigate_hotbar(1)  # Move right
		print("Player ", player_id, " navigated hotbar right")

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

# Component access methods
func get_component(component_type: String):
	"""Get a component by type name"""
	print("PlayerController: [UPDATED v2] get_component called with '", component_type, "'")
	print("PlayerController: player_inventory = ", player_inventory)
	
	var lower_type = component_type.to_lower()
	print("PlayerController: Testing against: '", lower_type, "'")
	
	# Use if/else instead of match for debugging
	if lower_type in ["movement", "player_movement", "playermovement"]:
		print("PlayerController: Matched movement")
		return player_movement
	elif lower_type in ["survival", "player_survival", "playersurvival"]:
		print("PlayerController: Matched survival")
		return player_survival
	elif lower_type in ["builder", "player_builder", "playerbuilder"]:
		print("PlayerController: Matched builder")
		return player_builder
	elif lower_type in ["interaction", "player_interaction", "playerinteraction"]:
		print("PlayerController: Matched interaction")
		return player_interaction
	elif lower_type in ["input_handler", "player_input_handler", "playerinputhandler"]:
		print("PlayerController: Matched input_handler")
		return player_input_handler
	elif lower_type in ["inventory", "player_inventory", "playerinventory"]:
		print("PlayerController: MATCHED INVENTORY! Returning: ", player_inventory)
		return player_inventory
	elif lower_type in ["resource_manager", "resourcemanager"]:
		print("PlayerController: Matched resource_manager")
		return resource_manager
	else:
		print("PlayerController: No match found for: '", lower_type, "'")
		print("PlayerController: Unknown component type: ", component_type)
		return null

# Legacy compatibility methods (for external game objects)
# These delegate to the appropriate components

# Tree interaction compatibility
func set_nearby_tree(tree: Node3D):
	if player_interaction:
		player_interaction.set_nearby_tree(tree)

func clear_nearby_tree(tree: Node3D):
	if player_interaction:
		player_interaction.clear_nearby_tree(tree)

func start_gathering_tree():
	if player_interaction:
		return player_interaction.start_gathering_tree()
	return false

func stop_gathering():
	if player_interaction:
		player_interaction.stop_gathering()

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

# Chest interaction compatibility
func set_nearby_chest(chest: Node3D):
	if player_interaction:
		player_interaction.set_nearby_chest(chest)

func clear_nearby_chest(chest: Node3D):
	if player_interaction:
		player_interaction.clear_nearby_chest(chest)

func interact_with_chest():
	if player_interaction:
		return player_interaction.interact_with_chest()
	return false

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

func get_hunger() -> float:
	if player_survival:
		return player_survival.get_hunger()
	return 100.0

func get_hunger_percentage() -> float:
	if player_survival:
		return player_survival.get_hunger_percentage()
	return 1.0

func get_tiredness() -> float:
	if player_survival:
		return player_survival.get_tiredness()
	return 100.0

func get_tiredness_percentage() -> float:
	if player_survival:
		return player_survival.get_tiredness_percentage()
	return 1.0

func get_max_health() -> float:
	if player_survival:
		return player_survival.get_max_health()
	return 100.0

func get_max_hunger() -> float:
	if player_survival:
		return player_survival.get_max_hunger()
	return 100.0

func get_max_tiredness() -> float:
	if player_survival:
		return player_survival.get_max_tiredness()
	return 100.0

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

# === STARTING ITEMS ===

func give_starting_items():
	"""Give player basic starting items when they spawn"""
	# Wait a frame to ensure inventory is fully initialized
	await get_tree().process_frame
	
	if not player_inventory:
		print("PlayerController: Cannot give starting items - no inventory component")
		return
	
	print("PlayerController: Giving starting items to player ", player_id)
	
	# Give basic tools for immediate use
	ItemRegistry.give_item_to_player(self, "bucket", 1, "empty")
	ItemRegistry.give_item_to_player(self, "watering_can", 1)
	
	# Give starting seeds for early game progression
	ItemRegistry.give_item_to_player(self, "berry_seeds", 5)
	
	print("PlayerController: Starting items given - check hotbar with hud_left/hud_right!")

# Debug and Test Methods for Phase 1
func print_inventory():
	"""Print current inventory state for debugging"""
	if player_inventory:
		player_inventory.print_inventory()

# === INVENTORY TEST METHODS (for Phase 1 validation) ===

func test_give_bucket(state: String = "empty"):
	"""Test method: Give player a bucket"""
	var BucketItem = preload("res://systems/items/bucket_item.gd")
	return BucketItem.give_bucket_to_player(self, state)

func test_give_item(item_id: String, quantity: int = 1, state: String = ""):
	"""Test method: Give player any item"""
	var ItemRegistry = preload("res://systems/items/item_registry.gd")
	return ItemRegistry.give_item_to_player(self, item_id, quantity, state)

func test_use_selected_item():
	"""Test method: Try to use currently selected item"""
	if player_inventory:
		return player_inventory.use_selected_item()
	return false

func test_inventory_summary():
	"""Test method: Get inventory summary"""
	if player_inventory:
		var summary = player_inventory.get_inventory_summary()
		print(summary)
		return summary
	return "No inventory component"

# Component cleanup continuation
func _cleanup_components():
	"""Clean up all components"""
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
