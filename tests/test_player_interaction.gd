extends GutTest

# PlayerInteraction Component Test Suite
# Tests object proximity tracking, gathering mechanics, and shelter interactions

const PlayerInteraction = preload("res://scenes/players/components/player_interaction.gd")
var player_interaction
var mock_player_controller
var mock_movement_component
var mock_survival_component
var mock_tree: Node3D
var mock_tent: Node3D
var mock_shelter: Node3D
var mock_pumpkin: Node3D

func before_each():
	# Create PlayerInteraction component
	player_interaction = PlayerInteraction.new()
	
	# Create mock player controller (CharacterBody3D)
	mock_player_controller = CharacterBody3D.new()
	add_child_autofree(mock_player_controller)
	mock_player_controller.player_id = 1
	
	# Create mock components
	mock_movement_component = Node.new()
	add_child_autofree(mock_movement_component)
	mock_movement_component.set_script(GDScript.new())
	mock_movement_component.get_script().source_code = '''
extends Node
signal movement_started
func play_animation(anim_name: String): pass
'''
	mock_movement_component.get_script().reload()
	
	mock_survival_component = Node.new()
	add_child_autofree(mock_survival_component)
	mock_survival_component.set_script(GDScript.new())
	mock_survival_component.get_script().source_code = '''
extends Node
func lose_tiredness(amount: float, activity: String = ""): pass
'''
	mock_survival_component.get_script().reload()
	
	# Create mock interaction objects
	mock_tree = Node3D.new()
	add_child_autofree(mock_tree)
	mock_tree.set_script(GDScript.new())
	mock_tree.get_script().source_code = '''
extends Node3D
func start_gathering(player): return true
func stop_gathering(): pass
func has_method(method_name: String) -> bool: return method_name in ["start_gathering"]
'''
	mock_tree.get_script().reload()
	
	mock_tent = Node3D.new()
	add_child_autofree(mock_tent)
	mock_tent.set_script(GDScript.new())
	mock_tent.get_script().source_code = '''
extends Node3D
func start_building(player): return true
func has_method(method_name: String) -> bool: return method_name in ["start_building"]
'''
	mock_tent.get_script().reload()
	
	mock_shelter = Node3D.new()
	add_child_autofree(mock_shelter)
	mock_shelter.set_script(GDScript.new())
	mock_shelter.get_script().source_code = '''
extends Node3D
func shelter_player(player): return true
func has_method(method_name: String) -> bool: return method_name in ["shelter_player"]
'''
	mock_shelter.get_script().reload()
	
	mock_pumpkin = Node3D.new()
	add_child_autofree(mock_pumpkin)
	mock_pumpkin.set_script(GDScript.new())
	mock_pumpkin.get_script().source_code = '''
extends Node3D
func start_gathering(player): return true
func stop_gathering(): pass
func has_method(method_name: String) -> bool: return method_name in ["start_gathering"]
'''
	mock_pumpkin.get_script().reload()
	
	# Setup component hierarchy
	add_child_autofree(player_interaction)
	
	# Mock get_sibling_component method
	player_interaction.set_script(player_interaction.get_script().duplicate())
	var original_source = player_interaction.get_script().source_code
	var mock_source = original_source.replace(
		"func get_sibling_component(",
		"func get_sibling_component_original("
	) + '''
func get_sibling_component(component_name: String):
	match component_name:
		"PlayerMovement": return get_node("../MockMovement") if has_node("../MockMovement") else null
		"PlayerSurvival": return get_node("../MockSurvival") if has_node("../MockSurvival") else null
		_: return null
'''
	player_interaction.get_script().source_code = mock_source
	player_interaction.get_script().reload()
	
	# Add mock components to scene for get_sibling_component
	mock_movement_component.name = "MockMovement"
	mock_survival_component.name = "MockSurvival"

func after_each():
	if player_interaction and is_instance_valid(player_interaction):
		player_interaction.cleanup()

func test_component_initialization():
	# Test successful initialization
	player_interaction.initialize(mock_player_controller)
	
	assert_true(player_interaction.is_initialized, "PlayerInteraction should be initialized")
	assert_not_null(player_interaction.player_movement, "Should find PlayerMovement component")
	assert_not_null(player_interaction.player_survival, "Should find PlayerSurvival component")

func test_nearby_tree_tracking():
	player_interaction.initialize(mock_player_controller)
	
	# Test setting nearby tree
	watch_signals(player_interaction)
	player_interaction.set_nearby_tree(mock_tree)
	
	assert_eq(player_interaction.nearby_tree, mock_tree, "Should track nearby tree")
	assert_true(player_interaction.has_nearby_object("tree"), "Should detect nearby tree")
	assert_eq(player_interaction.get_nearby_object("tree"), mock_tree, "Should return nearby tree")
	
	# Verify signals
	assert_signal_emitted(player_interaction, "nearby_object_changed", "Should emit nearby_object_changed signal")
	assert_signal_emitted(player_interaction, "interaction_available", "Should emit interaction_available signal")
	
	# Test clearing nearby tree
	player_interaction.clear_nearby_tree(mock_tree)
	assert_null(player_interaction.nearby_tree, "Should clear nearby tree")
	assert_false(player_interaction.has_nearby_object("tree"), "Should not detect tree after clearing")

func test_tree_gathering():
	player_interaction.initialize(mock_player_controller)
	player_interaction.set_nearby_tree(mock_tree)
	
	watch_signals(player_interaction)
	
	# Test starting gathering
	player_interaction.start_gathering_tree()
	
	assert_true(player_interaction.is_gathering, "Should be in gathering state")
	assert_true(player_interaction.is_gathering_active(), "Should be actively gathering")
	assert_eq(player_interaction.get_gathering_type(), "tree", "Should be gathering trees")
	assert_eq(player_interaction.get_gathering_object(), mock_tree, "Should track gathering object")
	assert_signal_emitted(player_interaction, "gathering_started", "Should emit gathering_started signal")
	
	# Test stopping gathering
	player_interaction.stop_gathering()
	
	assert_false(player_interaction.is_gathering, "Should not be gathering")
	assert_false(player_interaction.is_gathering_active(), "Should not be actively gathering")
	assert_eq(player_interaction.get_gathering_type(), "", "Should have no gathering type")
	assert_null(player_interaction.get_gathering_object(), "Should have no gathering object")
	assert_signal_emitted(player_interaction, "gathering_stopped", "Should emit gathering_stopped signal")

func test_pumpkin_gathering():
	player_interaction.initialize(mock_player_controller)
	player_interaction.set_nearby_pumpkin(mock_pumpkin)
	
	watch_signals(player_interaction)
	
	# Test pumpkin gathering
	player_interaction.start_gathering_pumpkin()
	
	assert_true(player_interaction.is_gathering, "Should be gathering pumpkin")
	assert_eq(player_interaction.get_gathering_type(), "pumpkin", "Should be gathering pumpkins")
	assert_signal_emitted(player_interaction, "gathering_started", "Should emit gathering_started signal")

func test_tent_building():
	player_interaction.initialize(mock_player_controller)
	player_interaction.set_nearby_tent(mock_tent)
	
	# Test tent building interaction
	assert_true(player_interaction.has_nearby_object("tent"), "Should detect nearby tent")
	player_interaction.start_building_tent()
	# Building doesn't set gathering state - this is expected

func test_shelter_interactions():
	player_interaction.initialize(mock_player_controller)
	player_interaction.set_nearby_shelter(mock_shelter)
	
	watch_signals(player_interaction)
	
	# Test entering shelter manually
	player_interaction.enter_shelter_manually()
	
	assert_true(player_interaction.is_in_shelter, "Should be in shelter")
	assert_true(player_interaction.is_sheltered(), "Should be sheltered")
	assert_eq(player_interaction.get_current_shelter(), mock_shelter, "Should track current shelter")
	assert_signal_emitted(player_interaction, "shelter_entered", "Should emit shelter_entered signal")
	
	# Test exiting shelter
	player_interaction.exit_shelter()
	
	assert_false(player_interaction.is_in_shelter, "Should not be in shelter")
	assert_false(player_interaction.is_sheltered(), "Should not be sheltered")
	assert_null(player_interaction.get_current_shelter(), "Should have no current shelter")
	assert_signal_emitted(player_interaction, "shelter_exited", "Should emit shelter_exited signal")

func test_interaction_input_handling():
	player_interaction.initialize(mock_player_controller)
	
	# Test with no nearby objects
	player_interaction.handle_interaction_input(true, false)
	assert_false(player_interaction.is_gathering, "Should not be gathering with no objects")
	
	# Test tree interaction priority
	player_interaction.set_nearby_tree(mock_tree)
	player_interaction.set_nearby_tent(mock_tent)
	
	player_interaction.handle_interaction_input(true, false)  # Press
	assert_true(player_interaction.is_gathering, "Should start gathering")
	assert_eq(player_interaction.get_gathering_type(), "tree", "Should prioritize tree gathering")
	
	player_interaction.handle_interaction_input(false, true)  # Release
	assert_false(player_interaction.is_gathering, "Should stop gathering on release")

func test_available_interactions():
	player_interaction.initialize(mock_player_controller)
	
	# Test no interactions
	var interactions = player_interaction.get_available_interactions()
	assert_eq(interactions.size(), 0, "Should have no available interactions")
	assert_eq(player_interaction.get_priority_interaction(), "", "Should have no priority interaction")
	
	# Test multiple interactions
	player_interaction.set_nearby_tree(mock_tree)
	player_interaction.set_nearby_tent(mock_tent)
	player_interaction.set_nearby_shelter(mock_shelter)
	
	interactions = player_interaction.get_available_interactions()
	assert_true(interactions.size() > 0, "Should have available interactions")
	assert_eq(player_interaction.get_priority_interaction(), "chop_tree", "Tree should have highest priority")

func test_gathering_movement_interruption():
	player_interaction.initialize(mock_player_controller)
	player_interaction.set_nearby_tree(mock_tree)
	
	# Start gathering
	player_interaction.start_gathering_tree()
	assert_true(player_interaction.is_gathering, "Should be gathering")
	
	# Simulate movement starting (should stop gathering)
	player_interaction._on_movement_started()
	assert_false(player_interaction.is_gathering, "Movement should stop gathering")

func test_cleanup():
	player_interaction.initialize(mock_player_controller)
	
	# Setup some state
	player_interaction.set_nearby_tree(mock_tree)
	player_interaction.start_gathering_tree()
	player_interaction.set_nearby_shelter(mock_shelter)
	player_interaction.enter_shelter_manually()
	
	# Test cleanup
	player_interaction._on_cleanup()
	
	assert_false(player_interaction.is_gathering, "Should not be gathering after cleanup")
	assert_false(player_interaction.is_in_shelter, "Should not be in shelter after cleanup")
	assert_null(player_interaction.nearby_tree, "Should clear nearby tree")
	assert_null(player_interaction.nearby_shelter, "Should clear nearby shelter")
