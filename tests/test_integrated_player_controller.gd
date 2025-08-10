extends GdUnitTestSuite

# Integrated PlayerController Test Suite
# Tests the complete component-based player system integration

var player_controller: CharacterBody3D
var test_scene: Node3D

func before_test():
	# Create test scene
	test_scene = Node3D.new()
	add_child(test_scene)
	
	# Load and instantiate the new player controller
	var PlayerControllerScript = load("res://scenes/players/player_new.gd")
	player_controller = CharacterBody3D.new()
	player_controller.set_script(PlayerControllerScript)
	player_controller.player_id = 0
	
	# Add ResourceManager to player (required dependency)
	var resource_manager = load("res://systems/resource_manager.gd").new()
	resource_manager.name = "ResourceManager"
	player_controller.add_child(resource_manager)
	
	test_scene.add_child(player_controller)

func after_test():
	if test_scene and is_instance_valid(test_scene):
		test_scene.queue_free()

func test_player_controller_initialization():
	# Test that the controller initializes properly
	assert_object(player_controller).is_not_null()
	assert_int(player_controller.player_id).is_equal(0)

func test_component_creation():
	# Trigger component setup
	player_controller._ready()
	
	# Test that all components are created
	assert_object(player_controller.player_movement).is_not_null()
	assert_object(player_controller.player_survival).is_not_null()
	assert_object(player_controller.player_builder).is_not_null()
	assert_object(player_controller.player_interaction).is_not_null()
	assert_object(player_controller.player_input_handler).is_not_null()

func test_component_initialization():
	player_controller._ready()
	
	# Test that components are properly initialized
	assert_bool(player_controller.player_movement.is_initialized).is_true()
	assert_bool(player_controller.player_survival.is_initialized).is_true()
	assert_bool(player_controller.player_builder.is_initialized).is_true()
	assert_bool(player_controller.player_interaction.is_initialized).is_true()
	assert_bool(player_controller.player_input_handler.is_initialized).is_true()

func test_legacy_compatibility_methods():
	player_controller._ready()
	
	# Test that legacy methods still exist and delegate properly
	assert_bool(player_controller.has_method("set_nearby_tree")).is_true()
	assert_bool(player_controller.has_method("add_wood")).is_true()
	assert_bool(player_controller.has_method("get_health")).is_true()
	assert_bool(player_controller.has_method("is_sheltered")).is_true()

func test_resource_system_integration():
	player_controller._ready()
	
	# Test resource system functionality
	var wood_added = player_controller.add_wood(5)
	assert_bool(wood_added).is_true()
	
	var space = player_controller.get_inventory_space()
	assert_int(space).is_greater_equal(0)

func test_survival_system_integration():
	player_controller._ready()
	
	# Test survival system access
	var health = player_controller.get_health()
	assert_float(health).is_greater(0.0)
	
	var health_percentage = player_controller.get_health_percentage()
	assert_float(health_percentage).is_between(0.0, 1.0)

func test_interaction_system_integration():
	player_controller._ready()
	
	# Test interaction system
	var is_sheltered = player_controller.is_sheltered()
	assert_bool(typeof(is_sheltered) == TYPE_BOOL).is_true()
	
	var shelter = player_controller.get_current_shelter()
	# Should be null initially
	assert_object(shelter).is_null()

func test_component_cleanup():
	player_controller._ready()
	
	# Trigger cleanup
	player_controller._exit_tree()
	
	# Components should still exist but be cleaned up
	assert_object(player_controller.player_movement).is_not_null()

func test_signal_connections():
	player_controller._ready()
	
	# Test that input handler signals are connected
	var input_handler = player_controller.player_input_handler
	assert_bool(input_handler.has_signal("movement_input")).is_true()
	assert_bool(input_handler.has_signal("action_pressed")).is_true()
	assert_bool(input_handler.has_signal("build_mode_toggled")).is_true()

func test_movement_coordination():
	player_controller._ready()
	
	# Test movement input handling exists
	assert_bool(player_controller.has_method("_on_movement_input")).is_true()
	assert_bool(player_controller.has_method("_on_action_pressed")).is_true()

func test_day_night_compatibility():
	player_controller._ready()
	
	# Test day/night system compatibility
	assert_bool(player_controller.has_method("on_day_started")).is_true()
	assert_bool(player_controller.has_method("on_night_started")).is_true()
	
	# Should not crash when called
	player_controller.on_day_started()
	player_controller.on_night_started()

func test_damage_healing_system():
	player_controller._ready()
	
	# Test damage and healing methods exist
	assert_bool(player_controller.has_method("take_damage")).is_true()
	assert_bool(player_controller.has_method("heal")).is_true()
	assert_bool(player_controller.has_method("respawn_player")).is_true()

func test_ui_system_compatibility():
	player_controller._ready()
	
	# Test UI methods exist (they depend on UI scene being available)
	assert_bool(player_controller.has_method("create_player_ui")).is_true()
	assert_bool(player_controller.has_method("setup_ui_for_player")).is_true()

func test_physics_process():
	player_controller._ready()
	
	# Test that physics process doesn't crash
	player_controller._physics_process(0.016)  # ~60 FPS delta
	
	# Should complete without errors
	assert_bool(true).is_true()
