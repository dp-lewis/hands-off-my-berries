# PlayerInteraction Component Test Suite for GUT
extends GutTest

const PlayerInteraction = preload("res://scenes/players/components/player_interaction.gd")

var player_interaction
var mock_player_controller
var mock_tree

func before_each():
	# Create basic mock objects
	mock_player_controller = CharacterBody3D.new()
	add_child_autofree(mock_player_controller)
	
	# Add necessary properties/methods to mock controller
	mock_player_controller.set_script(GDScript.new())
	mock_player_controller.get_script().source_code = """
	var player_movement
	var player_survival
	var resource_manager
	func get_inventory_space(): return 10
	func add_wood(amount): return true
	"""
	mock_player_controller.get_script().reload()
	
	# Create mock tree
	mock_tree = Node3D.new()
	add_child_autofree(mock_tree)
	mock_tree.name = "TreeTest"
	
	# Create and initialize component
	player_interaction = PlayerInteraction.new()
	add_child_autofree(player_interaction)
	player_interaction.initialize(mock_player_controller)

func test_component_initialization():
	assert_true(player_interaction.is_initialized, "PlayerInteraction should be initialized")
	assert_not_null(player_interaction.player_controller, "Should have player controller reference")

func test_tree_proximity_tracking():
	# Test setting nearby tree
	player_interaction.set_nearby_tree(mock_tree)
	assert_eq(player_interaction.nearby_tree, mock_tree, "Should track nearby tree")
	assert_true(player_interaction.has_nearby_object("tree"), "Should detect nearby tree")
	
	# Test clearing nearby tree
	player_interaction.clear_nearby_tree(mock_tree)
	assert_null(player_interaction.nearby_tree, "Should clear nearby tree")
	assert_false(player_interaction.has_nearby_object("tree"), "Should not detect tree after clearing")

func test_gathering_state_management():
	# Setup tree for gathering
	player_interaction.set_nearby_tree(mock_tree)
	
	# Test starting gathering
	player_interaction.handle_interaction_input(true, false)
	assert_true(player_interaction.is_gathering, "Should be in gathering state")
	assert_eq(player_interaction.current_gathering_object, mock_tree, "Should track gathering object")
	
	# Test stopping gathering by movement
	player_interaction._on_movement_started()
	assert_false(player_interaction.is_gathering, "Movement should stop gathering")
	assert_null(player_interaction.current_gathering_object, "Should clear gathering object")

func test_interaction_priority():
	# Create mock objects for priority testing
	var mock_pumpkin = Node3D.new()
	add_child_autofree(mock_pumpkin)
	mock_pumpkin.name = "PumpkinTest"
	
	var mock_tent = Node3D.new()
	add_child_autofree(mock_tent)
	mock_tent.name = "TentTest"
	
	# Set multiple nearby objects
	player_interaction.set_nearby_tree(mock_tree)
	player_interaction.set_nearby_pumpkin(mock_pumpkin)
	player_interaction.set_nearby_tent(mock_tent)
	
	# Test priority (tent should have highest priority)
	var priority_object = player_interaction.get_highest_priority_object()
	assert_eq(priority_object, mock_tent, "Tent should have highest interaction priority")

func test_shelter_functionality():
	var mock_shelter = Node3D.new()
	add_child_autofree(mock_shelter)
	mock_shelter.name = "ShelterTest"
	
	# Test entering shelter
	player_interaction.set_nearby_tent(mock_shelter)
	player_interaction.enter_tent_shelter(mock_shelter)
	assert_true(player_interaction.is_sheltered(), "Should be sheltered")
	assert_eq(player_interaction.get_current_shelter(), mock_shelter, "Should track current shelter")
	
	# Test exiting shelter
	player_interaction.exit_tent_shelter(mock_shelter)
	assert_false(player_interaction.is_sheltered(), "Should not be sheltered after exit")
	assert_null(player_interaction.get_current_shelter(), "Should not have current shelter")

func test_signal_emissions():
	# Watch for signals
	watch_signals(player_interaction)
	
	# Test interaction available signal
	player_interaction.set_nearby_tree(mock_tree)
	assert_signal_emitted(player_interaction, "interaction_available", "Should emit interaction_available signal")
	
	# Test gathering started signal
	player_interaction.handle_interaction_input(true, false)
	assert_signal_emitted(player_interaction, "gathering_started", "Should emit gathering_started signal")
