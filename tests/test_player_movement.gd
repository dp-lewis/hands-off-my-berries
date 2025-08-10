# Player Movement Component Tests
extends Node

const PlayerMovement = preload("res://components/player_movement.gd")
const PlayerComponent = preload("res://components/player_component.gd")
const PlayerController = preload("res://components/player_controller.gd")
const MockSystem = preload("res://tests/mocks/mock_system.gd")

func test_assert(condition: bool, message: String):
	if condition:
		print("✓ ", message)
	else:
		print("✗ FAILED: ", message)
		push_error("Test failed: " + message)

func _ready():
	print("=== MOVEMENT COMPONENT TEST ===")
	
	# Test 1: Basic component creation
	test_movement_component_creation()
	
	# Test 2: Movement initialization
	test_movement_initialization()
	
	# Test 3: Movement processing
	test_movement_processing()
	
	# Test 4: Animation system
	test_animation_system()
	
	# Test 5: Velocity management
	test_velocity_management()
	
	# Test 6: Integration with controller
	test_controller_integration()
	
	print("=== MOVEMENT COMPONENT TEST COMPLETE ===")
	get_tree().quit()

func test_movement_component_creation():
	var movement = PlayerMovement.new()
	test_assert(movement != null, "PlayerMovement component created successfully")
	test_assert(movement is PlayerComponent, "PlayerMovement extends PlayerComponent")
	test_assert(movement.has_method("handle_movement"), "PlayerMovement has handle_movement method")
	test_assert(movement.has_method("update_animation"), "PlayerMovement has update_animation method")
	test_assert(movement.has_method("get_current_velocity"), "PlayerMovement has get_current_velocity method")
	movement.queue_free()

func test_movement_initialization():
	var movement = PlayerMovement.new()
	var controller = PlayerController.new()
	var mock_body = MockSystem.create_mock_character_body()
	
	# Setup controller with mock
	controller.add_child(mock_body)
	controller.player_id = 1
	
	# Initialize movement component
	movement.initialize(controller)
	
	test_assert(movement.is_component_ready(), "Movement component initialized successfully")
	test_assert(movement.get_player_id() == 1, "Movement component has correct player ID")
	test_assert(movement.speed > 0, "Movement has default speed value")
	test_assert(movement.acceleration > 0, "Movement has default acceleration value")
	test_assert(movement.friction > 0, "Movement has default friction value")
	
	movement.cleanup()
	movement.queue_free()
	controller.queue_free()

func test_movement_processing():
	var movement = PlayerMovement.new()
	var controller = PlayerController.new()
	var mock_body = MockSystem.create_mock_character_body()
	
	# Setup
	controller.add_child(mock_body)
	controller.player_id = 1
	movement.initialize(controller)
	
	# Test movement with input
	var input_dir = Vector2(1.0, 0.0)  # Moving right
	var delta = 0.016  # 60 FPS
	
	movement.handle_movement(input_dir, delta)
	
	var velocity = movement.get_current_velocity()
	test_assert(velocity.length() > 0, "Movement generates velocity with input")
	test_assert(velocity.x > 0, "Movement velocity matches input direction")
	
	# Test stopping
	movement.handle_movement(Vector2.ZERO, delta)
	var stopped_velocity = movement.get_current_velocity()
	test_assert(stopped_velocity.length() < velocity.length(), "Movement velocity decreases without input")
	
	movement.cleanup()
	movement.queue_free()
	controller.queue_free()

func test_animation_system():
	var movement = PlayerMovement.new()
	var controller = PlayerController.new()
	var mock_body = MockSystem.create_mock_character_body()
	var mock_animation = MockSystem.create_mock_animation_player()
	
	# Setup with animation player
	controller.add_child(mock_body)
	mock_body.add_child(mock_animation)
	movement.initialize(controller)
	
	# Test walk animation
	movement.update_animation(Vector3(5.0, 0, 0))  # Moving velocity
	test_assert(mock_animation.current_animation == "walk", "Walk animation triggered for movement")
	
	# Test idle animation  
	movement.update_animation(Vector3.ZERO)  # No velocity
	test_assert(mock_animation.current_animation == "idle", "Idle animation triggered when stopped")
	
	movement.cleanup()
	movement.queue_free()
	controller.queue_free()

func test_velocity_management():
	var movement = PlayerMovement.new()
	var controller = PlayerController.new()
	var mock_body = MockSystem.create_mock_character_body()
	
	# Setup
	controller.add_child(mock_body)
	movement.initialize(controller)
	
	# Test initial velocity
	var initial_velocity = movement.get_current_velocity()
	test_assert(initial_velocity == Vector3.ZERO, "Initial velocity is zero")
	
	# Test setting movement enabled/disabled
	movement.set_movement_enabled(false)
	movement.handle_movement(Vector2(1.0, 0.0), 0.016)
	var disabled_velocity = movement.get_current_velocity()
	test_assert(disabled_velocity == Vector3.ZERO, "Movement disabled prevents velocity changes")
	
	movement.set_movement_enabled(true)
	movement.handle_movement(Vector2(1.0, 0.0), 0.016)
	var enabled_velocity = movement.get_current_velocity()
	test_assert(enabled_velocity.length() > 0, "Movement enabled allows velocity changes")
	
	movement.cleanup()
	movement.queue_free()
	controller.queue_free()

func test_controller_integration():
	var movement = PlayerMovement.new()
	var controller = PlayerController.new()
	var mock_body = MockSystem.create_mock_character_body()
	
	# Setup integration
	controller.add_child(mock_body)
	controller.add_child(movement)
	controller.player_id = 2
	
	# Test component discovery
	controller.setup_components()
	
	test_assert(controller.has_method("get_component"), "Controller has component access method")
	
	var found_movement = controller.get_component("PlayerMovement")
	test_assert(found_movement == movement, "Controller can find movement component")
	test_assert(found_movement.get_player_id() == 2, "Movement component gets player ID from controller")
	
	movement.cleanup()
	controller.queue_free()
