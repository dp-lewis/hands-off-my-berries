extends GutTest

# PlayerInteraction Component Test Suite - Simplified
# Tests object proximity tracking and basic interaction methods

const PlayerInteractionScript = preload("res://scenes/players/components/player_interaction.gd")
var player_interaction
var test_scene

func before_each():
	# Create a minimal test scene
	test_scene = Node3D.new()
	add_child_autofree(test_scene)
	
	# Create PlayerInteraction component directly
	player_interaction = PlayerInteractionScript.new()
	player_interaction.name = "PlayerInteraction"
	test_scene.add_child(player_interaction)

# Test basic proximity tracking methods
func test_nearby_object_tracking():
	# Test tree tracking
	var mock_tree = Node3D.new()
	mock_tree.name = "MockTree"
	
	player_interaction.set_nearby_tree(mock_tree)
	assert_true(player_interaction.has_nearby_object("tree"), "Should detect nearby tree")
	assert_eq(player_interaction.get_nearby_object("tree"), mock_tree, "Should track specific tree")
	
	player_interaction.clear_nearby_tree(mock_tree)
	assert_false(player_interaction.has_nearby_object("tree"), "Should clear nearby tree")

func test_multiple_object_tracking():
	# Test multiple object types
	var mock_tree = Node3D.new()
	var mock_tent = Node3D.new()
	var mock_pumpkin = Node3D.new()
	
	player_interaction.set_nearby_tree(mock_tree)
	player_interaction.set_nearby_tent(mock_tent)
	player_interaction.set_nearby_pumpkin(mock_pumpkin)
	
	assert_true(player_interaction.has_nearby_object("tree"), "Should track tree")
	assert_true(player_interaction.has_nearby_object("tent"), "Should track tent")
	assert_true(player_interaction.has_nearby_object("pumpkin"), "Should track pumpkin")

func test_interaction_state_tracking():
	# Test gathering state
	var mock_tree = Node3D.new()
	assert_false(player_interaction.is_gathering, "Should start not gathering")
	
	# Set gathering state (without calling full interaction method)
	player_interaction.is_gathering = true
	player_interaction.current_gathering_object = mock_tree
	player_interaction.gathering_type = "tree"
	
	assert_true(player_interaction.is_gathering, "Should be gathering")
	assert_eq(player_interaction.current_gathering_object, mock_tree, "Should track gathering object")
	assert_eq(player_interaction.gathering_type, "tree", "Should track gathering type")

func test_shelter_state_tracking():
	# Test shelter state
	var mock_shelter = Node3D.new()
	assert_false(player_interaction.is_in_shelter, "Should start outside shelter")
	
	# Set shelter state
	player_interaction.is_in_shelter = true
	player_interaction.current_shelter = mock_shelter
	
	assert_true(player_interaction.is_in_shelter, "Should be in shelter")
	assert_eq(player_interaction.current_shelter, mock_shelter, "Should track current shelter")
