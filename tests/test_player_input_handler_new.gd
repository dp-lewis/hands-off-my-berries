extends GutTest

# PlayerInputHandler Component Test Suite
# Tests input processing and delegation to other components

const PlayerController = preload("res://scenes/players/player.gd")
var player_controller
var player_input_handler
var test_scene

func before_each():
	# Create a test scene
	test_scene = Node3D.new()
	add_child_autofree(test_scene)
	
	# Create player controller with full component system
	player_controller = PlayerController.new()
	player_controller.player_id = 0
	
	# Create ResourceManager child node (required by PlayerController)
	var ResourceManagerScript = load("res://components/resource_manager.gd")
	var resource_manager = ResourceManagerScript.new()
	resource_manager.name = "ResourceManager"
	player_controller.add_child(resource_manager)
	
	test_scene.add_child(player_controller)
	
	# Wait for components to initialize
	await get_tree().process_frame
	
	# Get the PlayerInputHandler component
	player_input_handler = player_controller.get_component("input")

func test_component_initialization():
	assert_not_null(player_input_handler, "PlayerInputHandler should exist")
	assert_true(player_input_handler.is_initialized, "PlayerInputHandler should be initialized")
	assert_not_null(player_input_handler.player_controller, "Should have player controller reference")
	assert_eq(player_input_handler.player_id, 0, "Should inherit player ID from controller")

func test_input_device_assignment():
	# Test keyboard assignment (player 0)
	assert_eq(player_input_handler.input_device, "keyboard", "Player 0 should default to keyboard")
	
	# Test gamepad assignment (player 1+)
	player_input_handler.player_id = 1
	player_input_handler.determine_input_device()
	assert_eq(player_input_handler.input_device, "gamepad", "Player 1+ should use gamepad")

func test_movement_input_processing():
	# Test movement vector calculation
	var input_vector = player_input_handler.get_movement_input()
	assert_not_null(input_vector, "Should return a movement vector")
	assert_true(input_vector is Vector2, "Movement input should be Vector2")

func test_action_inputs():
	# These tests check that input methods exist and return boolean values
	var interact_input = player_input_handler.is_action_pressed("interact")
	var gather_input = player_input_handler.is_action_pressed("gather")
	var build_input = player_input_handler.is_action_pressed("build")
	var shelter_input = player_input_handler.is_action_pressed("shelter")
	
	assert_true(interact_input is bool, "Interact input should return boolean")
	assert_true(gather_input is bool, "Gather input should return boolean")
	assert_true(build_input is bool, "Build input should return boolean")
	assert_true(shelter_input is bool, "Shelter input should return boolean")

func test_input_mapping_exists():
	# Test that essential input actions are defined
	assert_true(InputMap.has_action("move_up_p0"), "Should have move_up action for player 0")
	assert_true(InputMap.has_action("move_down_p0"), "Should have move_down action for player 0")
	assert_true(InputMap.has_action("move_left_p0"), "Should have move_left action for player 0")
	assert_true(InputMap.has_action("move_right_p0"), "Should have move_right action for player 0")
	assert_true(InputMap.has_action("interact_p0"), "Should have interact action for player 0")
	assert_true(InputMap.has_action("gather_p0"), "Should have gather action for player 0")
	assert_true(InputMap.has_action("build_p0"), "Should have build action for player 0")
	assert_true(InputMap.has_action("shelter_p0"), "Should have shelter action for player 0")

func test_gamepad_input_mapping():
	# Create player with gamepad
	player_controller.player_id = 1
	player_input_handler.player_id = 1
	player_input_handler.determine_input_device()
	
	# Test that gamepad actions exist
	assert_true(InputMap.has_action("move_up_p1"), "Should have move_up action for player 1")
	assert_true(InputMap.has_action("interact_p1"), "Should have interact action for player 1")

func test_input_delegation():
	# Test that input handler can delegate to other components
	var movement_component = player_controller.get_component("movement")
	var interaction_component = player_controller.get_component("interaction")
	var builder_component = player_controller.get_component("builder")
	
	assert_not_null(movement_component, "Should have movement component to delegate to")
	assert_not_null(interaction_component, "Should have interaction component to delegate to")
	assert_not_null(builder_component, "Should have builder component to delegate to")

func test_process_input_method_exists():
	# Test that the main input processing method exists
	assert_true(player_input_handler.has_method("process_input"), "Should have process_input method")
