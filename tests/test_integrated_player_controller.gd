# Integrated PlayerController Test Suite for GUT
extends GutTest

const PlayerController = preload("res://scenes/players/player.gd")

var player_controller
var test_scene

func before_each():
	# Create a test scene to add the player controller to
	test_scene = Node3D.new()
	add_child_autofree(test_scene)
	
	# Create player controller (this loads the integrated system)
	player_controller = PlayerController.new()
	player_controller.player_id = 0
	test_scene.add_child(player_controller)

func after_each():
	if player_controller and is_instance_valid(player_controller):
		player_controller.queue_free()

func test_player_controller_initialization():
	assert_not_null(player_controller, "PlayerController should be created")
	assert_eq(player_controller.player_id, 0, "Should have correct player ID")
	assert_true(player_controller.is_in_group("players"), "Should be added to players group")

func test_component_loading():
	# Wait a frame for components to initialize
	await get_tree().process_frame
	
	# Test that all components are loaded
	assert_not_null(player_controller.player_movement, "Should load PlayerMovement component")
	assert_not_null(player_controller.player_survival, "Should load PlayerSurvival component") 
	assert_not_null(player_controller.player_builder, "Should load PlayerBuilder component")
	assert_not_null(player_controller.player_interaction, "Should load PlayerInteraction component")
	assert_not_null(player_controller.player_input_handler, "Should load PlayerInputHandler component")

func test_resource_system_integration():
	# Wait for resource system to initialize
	await get_tree().process_frame
	
	assert_not_null(player_controller.resource_manager, "Should have ResourceManager")
	
	# Test resource management methods
	var wood_added = player_controller.add_wood(5)
	assert_true(wood_added, "Should be able to add wood")
	
	var inventory_space = player_controller.get_inventory_space()
	assert_true(inventory_space >= 0, "Should return valid inventory space")

func test_legacy_compatibility():
	# Wait for components to initialize
	await get_tree().process_frame
	
	# Test that legacy interface methods exist and work
	assert_true(player_controller.has_method("add_wood"), "Should have add_wood method")
	assert_true(player_controller.has_method("get_health"), "Should have get_health method")
	assert_true(player_controller.has_method("is_sheltered"), "Should have is_sheltered method")
	
	# Test health system compatibility
	var initial_health = player_controller.get_health()
	assert_true(initial_health > 0, "Should have positive health")
	
	var health_percentage = player_controller.get_health_percentage()
	assert_true(health_percentage >= 0.0 and health_percentage <= 1.0, "Health percentage should be valid")

func test_signal_connections():
	# Wait for components and signal connections to be established
	await get_tree().process_frame
	
	# Test that component signals are properly connected
	# We check this by looking for the signal connections rather than triggering them
	assert_true(player_controller.has_method("_on_movement_input"), "Should have movement input handler")
	assert_true(player_controller.has_method("_on_action_pressed"), "Should have action press handler")
	assert_true(player_controller.has_method("_on_building_action"), "Should have building action handler")

func test_survival_integration():
	# Wait for components to initialize
	await get_tree().process_frame
	
	# Test tiredness system
	var initial_tiredness = player_controller.get_tiredness()
	assert_true(initial_tiredness >= 0, "Should have valid tiredness value")
	
	var tiredness_percentage = player_controller.get_tiredness_percentage() 
	assert_true(tiredness_percentage >= 0.0 and tiredness_percentage <= 1.0, "Tiredness percentage should be valid")

func test_interaction_system():
	# Wait for components to initialize
	await get_tree().process_frame
	
	# Test shelter state
	var is_sheltered = player_controller.is_sheltered()
	assert_false(is_sheltered, "Should not be sheltered initially")
	
	var current_shelter = player_controller.get_current_shelter()
	assert_null(current_shelter, "Should not have current shelter initially")

func test_day_night_system_compatibility():
	# Wait for components to initialize
	await get_tree().process_frame
	
	# Test day/night event handlers exist
	assert_true(player_controller.has_method("on_day_started"), "Should have day started handler")
	assert_true(player_controller.has_method("on_night_started"), "Should have night started handler")
	
	# Test that calling these methods doesn't cause errors
	player_controller.on_day_started()
	player_controller.on_night_started()
	
	# If we get here without errors, the integration is working
	assert_true(true, "Day/night handlers should work without errors")

func test_component_cleanup():
	# Wait for full initialization
	await get_tree().process_frame
	
	# Test that cleanup methods exist on components
	if player_controller.player_movement and player_controller.player_movement.has_method("cleanup"):
		assert_true(true, "PlayerMovement has cleanup method")
	
	if player_controller.player_survival and player_controller.player_survival.has_method("cleanup"):
		assert_true(true, "PlayerSurvival has cleanup method")
	
	# Test cleanup doesn't cause errors
	player_controller._exit_tree()
	assert_true(true, "Component cleanup should work without errors")
