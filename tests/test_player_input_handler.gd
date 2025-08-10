# PlayerInputHandler Component Test Suite for GUT
extends GutTest

const PlayerInputHandler = preload("res://scenes/players/components/player_input_handler.gd")

var player_input_handler
var mock_player_controller

func before_each():
	# Create basic mock player controller
	mock_player_controller = CharacterBody3D.new()
	add_child_autofree(mock_player_controller)
	mock_player_controller.player_id = 0
	
	# Create and initialize component
	player_input_handler = PlayerInputHandler.new()
	add_child_autofree(player_input_handler)
	player_input_handler.initialize(mock_player_controller)

func test_component_initialization():
	assert_true(player_input_handler.is_initialized, "PlayerInputHandler should be initialized")
	assert_not_null(player_input_handler.player_controller, "Should have player controller reference")
	assert_eq(player_input_handler.player_id, 0, "Should inherit player ID from controller")

func test_input_device_assignment():
	# Test keyboard assignment (player 0)
	assert_eq(player_input_handler.input_device, "keyboard", "Player 0 should default to keyboard")
	
	# Test gamepad assignment (player 1+)
	player_input_handler.player_id = 1
	player_input_handler.setup_input_mappings()
	assert_eq(player_input_handler.input_device, "gamepad_0", "Player 1 should use gamepad_0")

func test_input_direction_processing():
	# Test keyboard input mapping
	player_input_handler.input_device = "keyboard"
	
	# Test the input mapping logic directly
	var expected_suffix = ""
	var actual_suffix = player_input_handler.get_input_suffix()
	assert_eq(actual_suffix, expected_suffix, "Keyboard should have empty suffix")

func test_action_key_mapping():
	# Test action key mapping for different devices
	player_input_handler.input_device = "keyboard"
	var keyboard_action = player_input_handler.get_action_key()
	assert_eq(keyboard_action, "action", "Keyboard should use 'action' key")
	
	player_input_handler.input_device = "gamepad_0"
	var gamepad_action = player_input_handler.get_action_key()
	assert_eq(gamepad_action, "action_p1", "Gamepad 0 should use 'action_p1' key")

func test_build_mode_key_mapping():
	# Test build mode key mapping
	player_input_handler.input_device = "keyboard"
	var keyboard_build = player_input_handler.get_build_mode_key()
	assert_eq(keyboard_build, "build_mode", "Keyboard should use 'build_mode' key")
	
	player_input_handler.input_device = "gamepad_1"
	var gamepad_build = player_input_handler.get_build_mode_key()
	assert_eq(gamepad_build, "build_mode_p2", "Gamepad 1 should use 'build_mode_p2' key")

func test_multi_player_input_isolation():
	# Create multiple input handlers for different players
	var input_handler_p1 = PlayerInputHandler.new()
	add_child_autofree(input_handler_p1)
	
	var mock_controller_p1 = CharacterBody3D.new()
	add_child_autofree(mock_controller_p1)
	mock_controller_p1.player_id = 1
	
	input_handler_p1.initialize(mock_controller_p1)
	
	# Test that different players have different input mappings
	assert_ne(player_input_handler.get_action_key(), input_handler_p1.get_action_key(), 
		"Different players should have different input mappings")

func test_signal_emission():
	# Watch for signals
	watch_signals(player_input_handler)
	
	# Test that component is set up to emit signals
	# (We can't easily simulate actual input events in GUT, so we test signal setup)
	assert_true(player_input_handler.has_signal("movement_input"), "Should have movement_input signal")
	assert_true(player_input_handler.has_signal("action_pressed"), "Should have action_pressed signal")
	assert_true(player_input_handler.has_signal("action_released"), "Should have action_released signal")
	assert_true(player_input_handler.has_signal("build_mode_toggled"), "Should have build_mode_toggled signal")

func test_device_detection():
	# Test gamepad device detection logic
	var device_id = player_input_handler.detect_gamepad_device(1)
	assert_true(device_id >= -1, "Device detection should return valid device ID or -1")
	
	# Test device mapping for different player IDs
	for i in range(4):
		var handler = PlayerInputHandler.new()
		add_child_autofree(handler)
		var controller = CharacterBody3D.new()
		add_child_autofree(controller)
		controller.player_id = i
		handler.initialize(controller)
		
		if i == 0:
			assert_eq(handler.input_device, "keyboard", "Player 0 should use keyboard")
		else:
			assert_true(handler.input_device.begins_with("gamepad_"), "Players 1+ should use gamepad")
