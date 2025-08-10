extends GdUnitTestSuite

# PlayerInputHandler Component Test Suite
# Tests multi-player input mapping, device-specific controls, and input state management

var input_handler: PlayerInputHandler
var mock_player_controller

func before_test():
	# Create PlayerInputHandler component
	input_handler = PlayerInputHandler.new()
	
	# Create mock player controller (CharacterBody3D)
	mock_player_controller = auto_free(CharacterBody3D.new())
	mock_player_controller.player_id = 1
	
	# Setup component hierarchy
	add_child(input_handler)
	add_child(mock_player_controller)

func after_test():
	if input_handler and is_instance_valid(input_handler):
		input_handler.cleanup()

func test_component_initialization():
	# Test successful initialization
	input_handler.initialize(mock_player_controller)
	
	assert_bool(input_handler.is_initialized).is_true()
	assert_int(input_handler.get_player_id()).is_equal(1)
	assert_bool(input_handler.is_input_available()).is_true()

func test_input_mappings_setup():
	input_handler.initialize(mock_player_controller)
	
	# Test movement mappings
	var mappings = input_handler.get_all_mapped_actions()
	assert_dict(mappings).contains_keys(["movement", "action", "build"])
	
	# Test specific player mappings
	assert_dict(mappings["movement"]).contains_key(1)
	assert_str(mappings["action"][1]).is_equal("p2_action")
	assert_str(mappings["build"][1]).is_equal("p2_build")

func test_player_id_configuration():
	input_handler.initialize(mock_player_controller)
	
	# Test different player IDs
	for player_id in range(4):
		input_handler.set_player_id(player_id)
		assert_int(input_handler.get_player_id()).is_equal(player_id)
		assert_bool(input_handler.is_input_available()).is_true()
		
		# Test action key mapping
		var expected_action = "ui_accept" if player_id == 0 else "p" + str(player_id + 1) + "_action"
		assert_str(input_handler.get_action_key()).is_equal(expected_action)

func test_keyboard_player_mappings():
	input_handler.initialize(mock_player_controller)
	input_handler.set_player_id(0)  # Keyboard player
	
	# Test keyboard-specific mappings
	assert_str(input_handler.get_action_key()).is_equal("ui_accept")
	assert_str(input_handler.get_build_key()).is_equal("ui_focus_next")
	assert_str(input_handler.get_input_device_type()).is_equal("keyboard")

func test_gamepad_player_mappings():
	input_handler.initialize(mock_player_controller)
	input_handler.set_player_id(2)  # Gamepad player
	
	# Test gamepad-specific mappings
	assert_str(input_handler.get_action_key()).is_equal("p3_action")
	assert_str(input_handler.get_build_key()).is_equal("p3_build")
	assert_str(input_handler.get_input_device_type()).is_equal("gamepad")

func test_input_direction_mapping():
	input_handler.initialize(mock_player_controller)
	
	# Test movement mapping for different players
	input_handler.set_player_id(0)
	# Cannot easily test Input.get_vector without actual input, but we can test the mapping exists
	var mappings = input_handler.get_all_mapped_actions()
	var player0_movement = mappings["movement"][0]
	assert_str(player0_movement["left"]).is_equal("ui_left")
	assert_str(player0_movement["right"]).is_equal("ui_right")
	assert_str(player0_movement["up"]).is_equal("ui_up")
	assert_str(player0_movement["down"]).is_equal("ui_down")
	
	input_handler.set_player_id(1)
	var player1_movement = mappings["movement"][1]
	assert_str(player1_movement["left"]).is_equal("p2_left")
	assert_str(player1_movement["right"]).is_equal("p2_right")

func test_custom_mapping_addition():
	input_handler.initialize(mock_player_controller)
	
	# Test adding custom mappings
	input_handler.add_custom_mapping(0, "action", "custom_action")
	input_handler.add_custom_mapping(1, "build", "custom_build")
	
	var mappings = input_handler.get_all_mapped_actions()
	assert_str(mappings["action"][0]).is_equal("custom_action")
	assert_str(mappings["build"][1]).is_equal("custom_build")

func test_input_state_tracking():
	input_handler.initialize(mock_player_controller)
	
	# Test input state structure
	var state = input_handler.get_input_state()
	assert_dict(state).contains_keys(["movement_active", "action_held", "build_mode_active"])
	
	# Initial state should be inactive
	assert_bool(state["movement_active"]).is_false()
	assert_bool(state["action_held"]).is_false()

func test_signal_emission():
	input_handler.initialize(mock_player_controller)
	
	# Test signal connections exist
	assert_bool(input_handler.has_signal("movement_input")).is_true()
	assert_bool(input_handler.has_signal("action_pressed")).is_true()
	assert_bool(input_handler.has_signal("action_released")).is_true()
	assert_bool(input_handler.has_signal("build_mode_toggled")).is_true()

func test_fallback_mappings():
	input_handler.initialize(mock_player_controller)
	
	# Test with invalid player ID
	input_handler.set_player_id(99)
	
	# Should return fallback values
	assert_str(input_handler.get_action_key()).is_equal("ui_accept")
	assert_str(input_handler.get_build_key()).is_equal("ui_select")
	assert_vector2(input_handler.get_input_direction()).is_equal(Vector2.ZERO)

func test_device_type_detection():
	input_handler.initialize(mock_player_controller)
	
	# Test device type detection for each player
	var expected_devices = {
		0: "keyboard",
		1: "gamepad", 
		2: "gamepad",
		3: "gamepad"
	}
	
	for player_id in expected_devices:
		input_handler.set_player_id(player_id)
		assert_str(input_handler.get_input_device_type()).is_equal(expected_devices[player_id])

func test_input_validation():
	input_handler.initialize(mock_player_controller)
	
	# Test input availability check
	assert_bool(input_handler.is_input_available()).is_true()
	
	# Test with valid player configuration
	for player_id in range(4):
		input_handler.set_player_id(player_id)
		assert_bool(input_handler.is_input_available()).is_true()

func test_cleanup():
	input_handler.initialize(mock_player_controller)
	
	# Verify initial state
	assert_bool(input_handler.is_input_available()).is_true()
	var mappings = input_handler.get_all_mapped_actions()
	assert_bool(mappings["movement"].size() > 0).is_true()
	
	# Test cleanup
	input_handler._on_cleanup()
	
	# Verify mappings are cleared
	mappings = input_handler.get_all_mapped_actions()
	assert_bool(mappings["movement"].is_empty()).is_true()
	assert_bool(mappings["action"].is_empty()).is_true()
	assert_bool(mappings["build"].is_empty()).is_true()

func test_multiple_player_isolation():
	# Create multiple input handlers to test isolation
	var handler1 = PlayerInputHandler.new()
	var handler2 = PlayerInputHandler.new()
	var controller1 = auto_free(CharacterBody3D.new())
	var controller2 = auto_free(CharacterBody3D.new())
	controller1.player_id = 0
	controller2.player_id = 2
	
	add_child(handler1)
	add_child(handler2)
	add_child(controller1)
	add_child(controller2)
	
	handler1.initialize(controller1)
	handler2.initialize(controller2)
	
	# Test that each handler has correct player ID
	assert_int(handler1.get_player_id()).is_equal(0)
	assert_int(handler2.get_player_id()).is_equal(2)
	
	# Test that mappings are different
	assert_str(handler1.get_action_key()).is_equal("ui_accept")
	assert_str(handler2.get_action_key()).is_equal("p3_action")
	
	# Cleanup
	handler1.cleanup()
	handler2.cleanup()

func test_movement_detection():
	input_handler.initialize(mock_player_controller)
	
	# Test movement activity detection (indirect test since we can't simulate actual input)
	# We test the logic exists and returns boolean
	var is_moving = input_handler.is_movement_active()
	assert_bool(typeof(is_moving) == TYPE_BOOL).is_true()

func test_input_configuration_completeness():
	input_handler.initialize(mock_player_controller)
	
	# Test that all required player configurations exist
	var mappings = input_handler.get_all_mapped_actions()
	
	# All 4 players should have movement mappings
	for player_id in range(4):
		assert_bool(mappings["movement"].has(player_id)).is_true()
		assert_bool(mappings["action"].has(player_id)).is_true()
		assert_bool(mappings["build"].has(player_id)).is_true()
		
		var movement = mappings["movement"][player_id]
		assert_dict(movement).contains_keys(["left", "right", "up", "down"])
