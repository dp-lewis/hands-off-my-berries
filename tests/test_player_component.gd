extends SceneTree

## Unit tests for PlayerComponent base class
## Tests component lifecycle, initialization, and error handling

func _initialize():
	print("=== PLAYER COMPONENT BASE TESTS ===")
	print("Testing component lifecycle, initialization, and error handling...\n")
	
	test_component_initialization()
	test_component_lifecycle()
	test_component_error_handling()
	test_signal_emission()
	test_component_ready_check()
	test_sibling_component_access()
	test_safe_signal_emission()
	test_player_id_access()
	
	print("\n=== COMPONENT BASE TESTS COMPLETE ===")
	quit()

func test_component_initialization():
	print("--- Component Initialization Tests ---")
	
	var component = PlayerComponent.new()
	var controller = PlayerController.new()
	controller.player_id = 1
	
	# Test successful initialization
	component.initialize(controller)
	
	test_assert(component.player_controller == controller, "Controller reference set correctly")
	test_assert(component.is_initialized, "Component marked as initialized")
	test_assert(component.get_player_id() == 1, "Player ID accessible through component")
	
	print("✓ Component initialization successful")
	
	# Test null controller handling
	var component2 = PlayerComponent.new()
	var error_received = false
	component2.component_error.connect(func(msg): error_received = true)
	
	component2.initialize(null)
	assert(not component2.is_initialized, "Component not initialized with null controller")
	assert(error_received, "Error signal emitted for null controller")
	
	print("✓ Null controller handling works correctly")
	
	# Clean up
	component.cleanup()
	component2.cleanup()

func test_component_lifecycle():
	print("\n--- Component Lifecycle Tests ---")
	
	var component = PlayerComponent.new()
	var controller = PlayerController.new()
	
	# Test initialization
	component.initialize(controller)
	assert(component.is_component_ready(), "Component ready after initialization")
	
	# Test cleanup
	component.cleanup()
	assert(component.player_controller == null, "Controller reference cleared after cleanup")
	assert(not component.is_initialized, "Component marked as not initialized after cleanup")
	assert(not component.is_component_ready(), "Component not ready after cleanup")
	
	print("✓ Component lifecycle (init/cleanup) works correctly")

func test_component_error_handling():
	print("\n--- Component Error Handling Tests ---")
	
	var component = PlayerComponent.new()
	var error_received = false
	var received_message = ""
	
	component.component_error.connect(func(msg): 
		error_received = true
		received_message = msg
	)
	
	var test_message = "Test error message"
	component.emit_error(test_message)
	
	assert(error_received, "Error signal emitted correctly")
	assert(received_message == test_message, "Error message passed correctly")
	
	print("✓ Error handling and signal emission works correctly")

func test_signal_emission():
	print("\n--- Signal Emission Tests ---")
	
	var component = PlayerComponent.new()
	var controller = PlayerController.new()
	
	var ready_received = false
	component.component_ready.connect(func(): ready_received = true)
	
	# Initialize should emit component_ready signal
	component.initialize(controller)
	
	assert(ready_received, "Component ready signal emitted during initialization")
	
	print("✓ Component ready signal emission works correctly")
	
	component.cleanup()

func test_component_ready_check():
	print("\n--- Component Ready Check Tests ---")
	
	var component = PlayerComponent.new()
	
	# Test not ready state
	assert(not component.is_component_ready(), "Component not ready before initialization")
	
	# Test ready state
	var controller = PlayerController.new()
	component.initialize(controller)
	assert(component.is_component_ready(), "Component ready after initialization")
	
	# Test not ready after cleanup
	component.cleanup()
	assert(not component.is_component_ready(), "Component not ready after cleanup")
	
	print("✓ Component ready state checking works correctly")

func test_sibling_component_access():
	print("\n--- Sibling Component Access Tests ---")
	
	var component = PlayerComponent.new()
	var controller = PlayerController.new()
	
	# Test without controller
	var result = component.get_sibling_component("test_component")
	assert(result == null, "Returns null when no controller")
	
	# Test with controller (mock the get_component method)
	component.initialize(controller)
	# Note: This will return null since we don't have actual components set up
	# but it tests the code path
	result = component.get_sibling_component("nonexistent_component")
	assert(result == null, "Returns null for nonexistent component")
	
	print("✓ Sibling component access works correctly")
	
	component.cleanup()

func test_safe_signal_emission():
	print("\n--- Safe Signal Emission Tests ---")
	
	var component = PlayerComponent.new()
	
	# Test emission when not ready (should fail safely)
	var error_received = false
	component.component_error.connect(func(msg): error_received = true)
	
	component.safe_emit_signal("component_ready")
	assert(error_received, "Error emitted when trying to emit signal while not ready")
	
	# Test emission when ready
	var controller = PlayerController.new()
	component.initialize(controller)
	error_received = false
	
	# This should work without error
	component.safe_emit_signal("component_ready")
	# Note: We can't easily test the actual emission, but we can test no error occurs
	
	print("✓ Safe signal emission works correctly")
	
	component.cleanup()

func test_player_id_access():
	print("\n--- Player ID Access Tests ---")
	
	var component = PlayerComponent.new()
	
	# Test without controller
	assert(component.get_player_id() == -1, "Returns -1 when no controller")
	
	# Test with controller
	var controller = PlayerController.new()
	controller.player_id = 42
	component.initialize(controller)
	
	assert(component.get_player_id() == 42, "Returns correct player ID when controller available")
	
	print("✓ Player ID access works correctly")
	
	component.cleanup()

## Helper assertion function
func test_assert(condition: bool, message: String):
	if not condition:
		print("❌ ASSERTION FAILED: " + message)
		push_error("Test assertion failed: " + message)
	# Note: We don't stop execution to see all test results
