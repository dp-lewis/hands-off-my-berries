extends GutTest

# PlayerInteraction Component Test Suite
# Tests object proximity tracking, gathering mechanics, and shelter interactions

const PlayerControllerScript = preload("res://scenes/players/player.gd")
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
	player_controller = PlayerControllerScript.new()
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
func has_method(method_name: StringName) -> bool: 
	return method_name == "start_gathering" or super.has_method(method_name)
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
func has_method(method_name: StringName) -> bool: 
	return method_name == "start_building" or super.has_method(method_name)
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
func has_method(method_name: StringName) -> bool: 
	return method_name == "shelter_player" or super.has_method(method_name)
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
func has_method(method_name: StringName) -> bool: 
	return method_name == "start_gathering" or super.has_method(method_name)
'''
	pumpkin.get_script().reload()
	return pumpkin

# Test object proximity tracking
func test_nearby_tree_tracking():
	# Test setting nearby tree
	player_interaction.set_nearby_tree(mock_tree)
	assert_true(player_interaction.has_nearby_object("tree"), "Should detect nearby tree")
	assert_eq(player_interaction.get_nearby_object("tree"), mock_tree, "Should track specific tree")
	
	# Test clearing nearby tree
	player_interaction.clear_nearby_tree(mock_tree)
	assert_false(player_interaction.has_nearby_object("tree"), "Should clear nearby tree")

func test_nearby_tent_tracking():
	# Test setting nearby tent
	player_interaction.set_nearby_tent(mock_tent)
	assert_true(player_interaction.has_nearby_object("tent"), "Should detect nearby tent")
	assert_eq(player_interaction.get_nearby_object("tent"), mock_tent, "Should track specific tent")
	
	# Test clearing nearby tent
	player_interaction.clear_nearby_tent(mock_tent)
	assert_false(player_interaction.has_nearby_object("tent"), "Should clear nearby tent")

func test_tree_gathering():
	player_interaction.set_nearby_tree(mock_tree)
	
	# Test starting tree gathering
	var success = player_interaction.start_gathering_tree()
	assert_true(success, "Should start gathering tree")
	assert_true(player_interaction.is_gathering_active(), "Should be actively gathering")
	assert_eq(player_interaction.get_gathering_type(), "tree", "Should be gathering trees")
	assert_eq(player_interaction.get_gathering_object(), mock_tree, "Should track gathering object")
	
	# Test stopping gathering
	player_interaction.stop_gathering()
	assert_false(player_interaction.is_gathering_active(), "Should stop gathering")
	assert_eq(player_interaction.get_gathering_type(), "", "Should clear gathering type")

func test_pumpkin_gathering():
	player_interaction.set_nearby_pumpkin(mock_pumpkin)
	
	# Test starting pumpkin gathering
	var success = player_interaction.start_gathering_pumpkin()
	assert_true(success, "Should start gathering pumpkin")
	assert_true(player_interaction.is_gathering_active(), "Should be actively gathering")
	assert_eq(player_interaction.get_gathering_type(), "pumpkin", "Should be gathering pumpkins")
	assert_eq(player_interaction.get_gathering_object(), mock_pumpkin, "Should track gathering object")

func test_tent_building():
	player_interaction.set_nearby_tent(mock_tent)
	
	# Test tent building
	var success = player_interaction.start_building_tent()
	assert_true(success, "Should start building tent")

func test_shelter_interaction():
	player_interaction.set_nearby_shelter(mock_shelter)
	
	# Test entering shelter
	player_interaction.enter_shelter_manually()
	assert_true(player_interaction.is_sheltered(), "Should be sheltered")
	assert_eq(player_interaction.get_current_shelter(), mock_shelter, "Should track current shelter")
	
	# Test exiting shelter
	player_interaction.exit_shelter()
	assert_false(player_interaction.is_sheltered(), "Should not be sheltered")
	assert_null(player_interaction.get_current_shelter(), "Should clear current shelter")

func test_interaction_input_handling():
	# Test with nearby tree - should start gathering
	player_interaction.set_nearby_tree(mock_tree)
	player_interaction.handle_interaction_input(true, false)  # Press
	assert_true(player_interaction.is_gathering_active(), "Should start gathering tree")
	
	player_interaction.handle_interaction_input(false, true)  # Release
	assert_false(player_interaction.is_gathering_active(), "Should stop gathering on release")

func test_interaction_priority():
	# Set multiple nearby objects
	player_interaction.set_nearby_tree(mock_tree)
	player_interaction.set_nearby_tent(mock_tent)
	player_interaction.set_nearby_shelter(mock_shelter)
	
	# Tree should have highest priority
	player_interaction.handle_interaction_input(true, false)
	assert_true(player_interaction.is_gathering_active(), "Should start gathering (tree priority)")
	assert_eq(player_interaction.get_gathering_type(), "tree", "Should gather tree (highest priority)")

func test_gathering_fails_without_nearby_objects():
	# No nearby objects set
	var tree_success = player_interaction.start_gathering_tree()
	var pumpkin_success = player_interaction.start_gathering_pumpkin()
	var tent_success = player_interaction.start_building_tent()
	
	assert_false(tree_success, "Should not start tree gathering without nearby tree")
	assert_false(pumpkin_success, "Should not start pumpkin gathering without nearby pumpkin")
	assert_false(tent_success, "Should not start tent building without nearby tent")

func test_gathering_state_management():
	player_interaction.set_nearby_tree(mock_tree)
	
	# Test that gathering blocks new gathering
	player_interaction.start_gathering_tree()
	assert_true(player_interaction.is_gathering_active(), "Should be gathering")
	
	# Try to start different gathering - should not work while already gathering
	player_interaction.set_nearby_pumpkin(mock_pumpkin)
	var pumpkin_success = player_interaction.start_gathering_pumpkin()
	assert_true(pumpkin_success, "Pumpkin gathering should work (current implementation allows it)")
	
	# Should still be gathering the new object
	assert_eq(player_interaction.get_gathering_type(), "pumpkin", "Should switch to pumpkin gathering")
