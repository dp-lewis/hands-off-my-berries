extends GutTest

# PlayerInputHandler Component Test Suite
# Tests input processing and delegation to other components

const PlayerControllerScript = preload("res://scenes/players/player.gd")
var player_controller
var player_input_handler
var test_scene

func before_each():
	# Create a test scene
	test_scene = Node3D.new()
	add_child_autofree(test_scene)
	
	# Create player controller with proper script attachment
	player_controller = CharacterBody3D.new()
	player_controller.set_script(PlayerControllerScript)
	
	# Create ResourceManager child node (required by PlayerController)
	var ResourceManagerScript = load("res://components/resource_manager.gd")
	var resource_manager = ResourceManagerScript.new()
	resource_manager.name = "ResourceManager"
	player_controller.add_child(resource_manager)
	
	# Add to scene 
	test_scene.add_child(player_controller)
	
	# Try setting player_id through set() method instead
	player_controller.set("player_id", 0)
	
	# Wait for components to initialize
	await get_tree().process_frame
	
	# Get the PlayerInputHandler component
	player_input_handler = player_controller.get_component("input_handler")

func test_component_initialization():
	assert_not_null(player_input_handler, "PlayerInputHandler should exist")
	assert_true(player_input_handler.is_initialized, "PlayerInputHandler should be initialized")
	assert_not_null(player_input_handler.player_controller, "Should have player controller reference")
	assert_eq(player_input_handler.player_id, 0, "Should inherit player ID from controller")

func test_input_device_assignment():
	# Test that player ID is correctly set
	assert_eq(player_input_handler.get_player_id(), 0, "Player 0 should have correct ID")
	
	# Test changing player ID
	player_input_handler.set_player_id(1)
	assert_eq(player_input_handler.get_player_id(), 1, "Should update player ID")

func test_movement_input_processing():
	# Test movement input direction calculation
	var input_direction = player_input_handler.get_input_direction()
	assert_not_null(input_direction, "Should return a movement direction")
	assert_true(input_direction is Vector2, "Movement input should be Vector2")

func test_action_inputs():
	# These tests check that input methods exist and return boolean values
	var interact_input = player_input_handler.is_action_pressed()
	var build_input = player_input_handler.is_build_mode_just_pressed()
	var just_pressed = player_input_handler.is_action_just_pressed()
	var just_released = player_input_handler.is_action_just_released()
	
	assert_true(interact_input is bool, "Action input should return boolean")
	assert_true(build_input is bool, "Build input should return boolean") 
	assert_true(just_pressed is bool, "Just pressed should return boolean")
	assert_true(just_released is bool, "Just released should return boolean")

func test_input_mapping_exists():
	# Test that essential input actions are defined
	assert_true(InputMap.has_action("ui_left"), "Should have ui_left action")
	assert_true(InputMap.has_action("ui_right"), "Should have ui_right action")
	assert_true(InputMap.has_action("ui_up"), "Should have ui_up action")
	assert_true(InputMap.has_action("ui_down"), "Should have ui_down action")
	assert_true(InputMap.has_action("ui_accept"), "Should have ui_accept action")
	
	# Test input availability
	assert_true(player_input_handler.is_input_available(), "Input should be available for player 0")

func test_gamepad_input_mapping():
	# Test that input mappings exist for multiple players
	var all_mappings = player_input_handler.get_all_mapped_actions()
	assert_true(all_mappings.has("movement"), "Should have movement mappings")
	assert_true(all_mappings.has("action"), "Should have action mappings")
	assert_true(all_mappings.has("build"), "Should have build mappings")
	
	# Test player 1 mappings exist
	assert_true(all_mappings["movement"].has(1), "Should have movement mappings for player 1")
	assert_true(all_mappings["action"].has(1), "Should have action mappings for player 1")

func test_input_delegation():
	# Test that input handler can delegate to other components
	var movement_component = player_controller.get_component("movement")
	var interaction_component = player_controller.get_component("interaction")
	var builder_component = player_controller.get_component("builder")
	
	assert_not_null(movement_component, "Should have movement component to delegate to")
	assert_not_null(interaction_component, "Should have interaction component to delegate to")
	assert_not_null(builder_component, "Should have builder component to delegate to")

func test_process_input_method_exists():
	# Test that key input methods exist
	assert_true(player_input_handler.has_method("get_input_direction"), "Should have get_input_direction method")
	assert_true(player_input_handler.has_method("get_action_key"), "Should have get_action_key method")
	assert_true(player_input_handler.has_method("get_build_key"), "Should have get_build_key method")
	
	# Test key retrieval
	var action_key = player_input_handler.get_action_key()
	var build_key = player_input_handler.get_build_key()
	assert_true(action_key is String, "Action key should be a string")
	assert_true(build_key is String, "Build key should be a string")
