extends GdUnitTestSuite

# PlayerInteraction Component Test Suite
# Tests object proximity tracking, gathering mechanics, and shelter interactions

var player_interaction: PlayerInteraction
var mock_player_controller
var mock_movement_component
var mock_survival_component
var mock_tree: Node3D
var mock_tent: Node3D
var mock_shelter: Node3D
var mock_pumpkin: Node3D

func before_test():
	# Create PlayerInteraction component
	player_interaction = PlayerInteraction.new()
	
	# Create mock player controller (CharacterBody3D)
	mock_player_controller = auto_free(CharacterBody3D.new())
	mock_player_controller.player_id = 1
	
	# Create mock components
	mock_movement_component = auto_free(Node.new())
	mock_movement_component.set_script(GDScript.new())
	mock_movement_component.get_script().source_code = '''
extends Node
signal movement_started
func play_animation(anim_name: String): pass
'''
	mock_movement_component.get_script().reload()
	
	mock_survival_component = auto_free(Node.new())
	mock_survival_component.set_script(GDScript.new())
	mock_survival_component.get_script().source_code = '''
extends Node
func lose_tiredness(amount: float, activity: String = ""): pass
'''
	mock_survival_component.get_script().reload()
	
	# Create mock interaction objects
	mock_tree = auto_free(Node3D.new())
	mock_tree.set_script(GDScript.new())
	mock_tree.get_script().source_code = '''
extends Node3D
func start_gathering(player): return true
func stop_gathering(): pass
func has_method(method_name: String) -> bool: return method_name in ["start_gathering"]
'''
	mock_tree.get_script().reload()
	
	mock_tent = auto_free(Node3D.new())
	mock_tent.set_script(GDScript.new())
	mock_tent.get_script().source_code = '''
extends Node3D
func start_building(player): return true
func has_method(method_name: String) -> bool: return method_name in ["start_building"]
'''
	mock_tent.get_script().reload()
	
	mock_shelter = auto_free(Node3D.new())
	mock_shelter.set_script(GDScript.new())
	mock_shelter.get_script().source_code = '''
extends Node3D
func shelter_player(player): return true
func has_method(method_name: String) -> bool: return method_name in ["shelter_player"]
'''
	mock_shelter.get_script().reload()
	
	mock_pumpkin = auto_free(Node3D.new())
	mock_pumpkin.set_script(GDScript.new())
	mock_pumpkin.get_script().source_code = '''
extends Node3D
func start_gathering(player): return true
func stop_gathering(): pass
func has_method(method_name: String) -> bool: return method_name in ["start_gathering"]
'''
	mock_pumpkin.get_script().reload()
	
	# Setup component hierarchy
	add_child(player_interaction)
	add_child(mock_player_controller)
	
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
	add_child(mock_movement_component)
	add_child(mock_survival_component)

func after_test():
	if player_interaction and is_instance_valid(player_interaction):
		player_interaction.cleanup()

func test_component_initialization():
	# Test successful initialization
	player_interaction.initialize(mock_player_controller)
	
	assert_bool(player_interaction.is_initialized).is_true()
	assert_object(player_interaction.player_movement).is_not_null()
	assert_object(player_interaction.player_survival).is_not_null()

func test_nearby_tree_tracking():
	player_interaction.initialize(mock_player_controller)
	
	# Test setting nearby tree
	var signal_spy = monitor_signals(player_interaction)
	player_interaction.set_nearby_tree(mock_tree)
	
	assert_object(player_interaction.nearby_tree).is_equal(mock_tree)
	assert_bool(player_interaction.has_nearby_object("tree")).is_true()
	assert_object(player_interaction.get_nearby_object("tree")).is_equal(mock_tree)
	
	# Verify signals
	assert_signal(signal_spy).is_emitted("nearby_object_changed", ["tree", mock_tree, true])
	assert_signal(signal_spy).is_emitted("interaction_available", ["chop_tree", mock_tree])
	
	# Test clearing nearby tree
	player_interaction.clear_nearby_tree(mock_tree)
	assert_object(player_interaction.nearby_tree).is_null()
	assert_bool(player_interaction.has_nearby_object("tree")).is_false()

func test_tree_gathering():
	player_interaction.initialize(mock_player_controller)
	player_interaction.set_nearby_tree(mock_tree)
	
	var signal_spy = monitor_signals(player_interaction)
	
	# Test starting gathering
	player_interaction.start_gathering_tree()
	
	assert_bool(player_interaction.is_gathering).is_true()
	assert_bool(player_interaction.is_gathering_active()).is_true()
	assert_str(player_interaction.get_gathering_type()).is_equal("tree")
	assert_object(player_interaction.get_gathering_object()).is_equal(mock_tree)
	assert_signal(signal_spy).is_emitted("gathering_started", ["tree", mock_tree])
	
	# Test stopping gathering
	player_interaction.stop_gathering()
	
	assert_bool(player_interaction.is_gathering).is_false()
	assert_bool(player_interaction.is_gathering_active()).is_false()
	assert_str(player_interaction.get_gathering_type()).is_equal("")
	assert_object(player_interaction.get_gathering_object()).is_null()
	assert_signal(signal_spy).is_emitted("gathering_stopped", ["tree", mock_tree])

func test_pumpkin_gathering():
	player_interaction.initialize(mock_player_controller)
	player_interaction.set_nearby_pumpkin(mock_pumpkin)
	
	var signal_spy = monitor_signals(player_interaction)
	
	# Test pumpkin gathering
	player_interaction.start_gathering_pumpkin()
	
	assert_bool(player_interaction.is_gathering).is_true()
	assert_str(player_interaction.get_gathering_type()).is_equal("pumpkin")
	assert_signal(signal_spy).is_emitted("gathering_started", ["pumpkin", mock_pumpkin])

func test_tent_building():
	player_interaction.initialize(mock_player_controller)
	player_interaction.set_nearby_tent(mock_tent)
	
	# Test tent building interaction
	assert_bool(player_interaction.has_nearby_object("tent")).is_true()
	player_interaction.start_building_tent()
	# Building doesn't set gathering state

func test_shelter_interactions():
	player_interaction.initialize(mock_player_controller)
	player_interaction.set_nearby_shelter(mock_shelter)
	
	var signal_spy = monitor_signals(player_interaction)
	
	# Test entering shelter manually
	player_interaction.enter_shelter_manually()
	
	assert_bool(player_interaction.is_in_shelter).is_true()
	assert_bool(player_interaction.is_sheltered()).is_true()
	assert_object(player_interaction.get_current_shelter()).is_equal(mock_shelter)
	assert_signal(signal_spy).is_emitted("shelter_entered", [mock_shelter])
	
	# Test exiting shelter
	player_interaction.exit_shelter()
	
	assert_bool(player_interaction.is_in_shelter).is_false()
	assert_bool(player_interaction.is_sheltered()).is_false()
	assert_object(player_interaction.get_current_shelter()).is_null()
	assert_signal(signal_spy).is_emitted("shelter_exited", [mock_shelter])

func test_interaction_input_handling():
	player_interaction.initialize(mock_player_controller)
	
	# Test with no nearby objects
	player_interaction.handle_interaction_input(true, false)
	assert_bool(player_interaction.is_gathering).is_false()
	
	# Test tree interaction priority
	player_interaction.set_nearby_tree(mock_tree)
	player_interaction.set_nearby_tent(mock_tent)
	
	player_interaction.handle_interaction_input(true, false)  # Press
	assert_bool(player_interaction.is_gathering).is_true()
	assert_str(player_interaction.get_gathering_type()).is_equal("tree")
	
	player_interaction.handle_interaction_input(false, true)  # Release
	assert_bool(player_interaction.is_gathering).is_false()

func test_available_interactions():
	player_interaction.initialize(mock_player_controller)
	
	# Test no interactions
	var interactions = player_interaction.get_available_interactions()
	assert_array(interactions).is_empty()
	assert_str(player_interaction.get_priority_interaction()).is_equal("")
	
	# Test multiple interactions
	player_interaction.set_nearby_tree(mock_tree)
	player_interaction.set_nearby_tent(mock_tent)
	player_interaction.set_nearby_shelter(mock_shelter)
	
	interactions = player_interaction.get_available_interactions()
	assert_array(interactions).contains(["chop_tree", "build_tent", "enter_shelter"])
	assert_str(player_interaction.get_priority_interaction()).is_equal("chop_tree")  # Tree has highest priority

func test_gathering_movement_interruption():
	player_interaction.initialize(mock_player_controller)
	player_interaction.set_nearby_tree(mock_tree)
	
	# Start gathering
	player_interaction.start_gathering_tree()
	assert_bool(player_interaction.is_gathering).is_true()
	
	# Simulate movement starting (should stop gathering)
	player_interaction._on_movement_started()
	assert_bool(player_interaction.is_gathering).is_false()

func test_cleanup():
	player_interaction.initialize(mock_player_controller)
	
	# Setup some state
	player_interaction.set_nearby_tree(mock_tree)
	player_interaction.start_gathering_tree()
	player_interaction.set_nearby_shelter(mock_shelter)
	player_interaction.enter_shelter_manually()
	
	# Test cleanup
	player_interaction._on_cleanup()
	
	assert_bool(player_interaction.is_gathering).is_false()
	assert_bool(player_interaction.is_in_shelter).is_false()
	assert_object(player_interaction.nearby_tree).is_null()
	assert_object(player_interaction.nearby_shelter).is_null()
