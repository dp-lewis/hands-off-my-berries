extends GutTest

# PlayerInteraction Component Test Suite
# Tests object proximity tracking, gathering mechanics, and shelter interactions

const PlayerController = preload("res://scenes/players/player.gd")
var player_controller
var player_interaction
var test_scene
var mock_tree: Node3D
var mock_tent: Node3D
var mock_shelter: Node3D
var mock_pumpkin: Node3D

func before_each():
	# Create a test scene
	test_scene = Node3D.new()
	add_child_autofree(test_scene)
	
	# Create player controller with full component system
	player_controller = PlayerController.new()
	player_controller.player_id = 1
	
	# Create ResourceManager child node (required by PlayerController)
	var ResourceManagerScript = load("res://components/resource_manager.gd")
	var resource_manager = ResourceManagerScript.new()
	resource_manager.name = "ResourceManager"
	player_controller.add_child(resource_manager)
	
	test_scene.add_child(player_controller)
	
	# Wait for components to initialize
	await get_tree().process_frame
	
	# Get the PlayerInteraction component
	player_interaction = player_controller.get_component("interaction")
	
	# Create mock interaction objects
	mock_tree = create_mock_tree()
	mock_tent = create_mock_tent()
	mock_shelter = create_mock_shelter()
	mock_pumpkin = create_mock_pumpkin()
	
	# Add mock objects to scene
	test_scene.add_child(mock_tree)
	test_scene.add_child(mock_tent)
	test_scene.add_child(mock_shelter)
	test_scene.add_child(mock_pumpkin)

func create_mock_tree() -> Node3D:
	var tree = Node3D.new()
	tree.name = "MockTree"
	tree.position = Vector3(5, 0, 0)  # Within interaction range
	tree.set_script(GDScript.new())
	tree.get_script().source_code = '''
extends Node3D
func start_gathering(player): return true
func stop_gathering(): pass
func has_method(method_name: String) -> bool: return method_name in ["start_gathering"]
'''
	tree.get_script().reload()
	return tree

func create_mock_tent() -> Node3D:
	var tent = Node3D.new()
	tent.name = "MockTent"
	tent.position = Vector3(3, 0, 0)  # Within interaction range
	tent.set_script(GDScript.new())
	tent.get_script().source_code = '''
extends Node3D
func start_building(player): return true
func has_method(method_name: String) -> bool: return method_name in ["start_building"]
'''
	tent.get_script().reload()
	return tent

func create_mock_shelter() -> Node3D:
	var shelter = Node3D.new()
	shelter.name = "MockShelter"
	shelter.position = Vector3(2, 0, 0)  # Within interaction range
	shelter.set_script(GDScript.new())
	shelter.get_script().source_code = '''
extends Node3D
func shelter_player(player): return true
func has_method(method_name: String) -> bool: return method_name in ["shelter_player"]
'''
	shelter.get_script().reload()
	return shelter

func create_mock_pumpkin() -> Node3D:
	var pumpkin = Node3D.new()
	pumpkin.name = "MockPumpkin"
	pumpkin.position = Vector3(4, 0, 0)  # Within interaction range
	pumpkin.set_script(GDScript.new())
	pumpkin.get_script().source_code = '''
extends Node3D
func start_gathering(player): return true
func stop_gathering(): pass
func has_method(method_name: String) -> bool: return method_name in ["start_gathering"]
'''
	pumpkin.get_script().reload()
	return pumpkin

# Test object proximity detection
func test_detects_nearby_objects():
	player_controller.position = Vector3.ZERO
	
	# Let proximity detection run
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Check that nearby objects are detected
	var nearby_objects = player_interaction.get_nearby_objects()
	
	assert_true(mock_tree in nearby_objects, "Should detect nearby tree")
	assert_true(mock_tent in nearby_objects, "Should detect nearby tent")
	assert_true(mock_shelter in nearby_objects, "Should detect nearby shelter")
	assert_true(mock_pumpkin in nearby_objects, "Should detect nearby pumpkin")

func test_ignores_distant_objects():
	player_controller.position = Vector3(20, 0, 20)  # Far from all objects
	
	# Let proximity detection run
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Check that distant objects are not detected
	var nearby_objects = player_interaction.get_nearby_objects()
	
	assert_false(mock_tree in nearby_objects, "Should not detect distant tree")
	assert_false(mock_tent in nearby_objects, "Should not detect distant tent")
	assert_false(mock_shelter in nearby_objects, "Should not detect distant shelter")
	assert_false(mock_pumpkin in nearby_objects, "Should not detect distant pumpkin")

func test_gathering_interaction():
	player_controller.position = Vector3.ZERO
	
	# Let proximity detection run
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Start gathering
	var success = player_interaction.start_gathering()
	assert_true(success, "Should start gathering from nearby tree")
	
	# Stop gathering
	player_interaction.stop_gathering()
	# No assertion needed - just checking it doesn't crash

func test_building_interaction():
	player_controller.position = Vector3.ZERO
	
	# Let proximity detection run
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Start building
	var success = player_interaction.start_building()
	assert_true(success, "Should start building with nearby tent")

func test_shelter_interaction():
	player_controller.position = Vector3.ZERO
	
	# Let proximity detection run
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Use shelter
	var success = player_interaction.use_shelter()
	assert_true(success, "Should use nearby shelter")

func test_gathering_fails_when_no_gathering_objects():
	# Move away from gathering objects
	mock_tree.position = Vector3(50, 0, 0)
	mock_pumpkin.position = Vector3(50, 0, 0)
	player_controller.position = Vector3.ZERO
	
	# Let proximity detection run
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Try to start gathering
	var success = player_interaction.start_gathering()
	assert_false(success, "Should not start gathering when no gathering objects nearby")

func test_building_fails_when_no_building_objects():
	# Move away from building objects
	mock_tent.position = Vector3(50, 0, 0)
	player_controller.position = Vector3.ZERO
	
	# Let proximity detection run
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Try to start building
	var success = player_interaction.start_building()
	assert_false(success, "Should not start building when no building objects nearby")

func test_shelter_fails_when_no_shelter():
	# Move away from shelter
	mock_shelter.position = Vector3(50, 0, 0)
	player_controller.position = Vector3.ZERO
	
	# Let proximity detection run
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Try to use shelter
	var success = player_interaction.use_shelter()
	assert_false(success, "Should not use shelter when no shelter nearby")

func test_get_nearby_objects_returns_empty_when_isolated():
	player_controller.position = Vector3(100, 0, 100)  # Very far from everything
	
	# Let proximity detection run
	await get_tree().process_frame
	await get_tree().process_frame
	
	var nearby_objects = player_interaction.get_nearby_objects()
	assert_eq(nearby_objects.size(), 0, "Should return empty array when no objects nearby")

func test_interaction_priority():
	# Position close to multiple objects
	player_controller.position = Vector3.ZERO
	
	# Let proximity detection run
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Test that we can interact with specific types
	var shelter_success = player_interaction.use_shelter()
	var building_success = player_interaction.start_building()
	var gathering_success = player_interaction.start_gathering()
	
	assert_true(shelter_success, "Should be able to use shelter")
	assert_true(building_success, "Should be able to start building")
	assert_true(gathering_success, "Should be able to start gathering")
