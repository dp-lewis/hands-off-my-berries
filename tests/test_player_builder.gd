# Player Builder Component Tests
extends Node

func test_assert(condition: bool, message: String):
	if condition:
		print("✓ ", message)
	else:
		print("✗ FAILED: ", message)
		push_error("Test failed: " + message)

func _ready():
	print("=== BUILDER COMPONENT TEST ===")
	
	# Test 1: Basic component creation
	test_builder_component_creation()
	
	# Test 2: Builder initialization
	test_builder_initialization()
	
	# Test 3: Build mode functionality
	test_build_mode_functionality()
	
	# Test 4: Resource checking
	test_resource_checking()
	
	# Test 5: Building types
	test_building_types()
	
	# Test 6: Ghost preview system
	test_ghost_preview_system()
	
	print("=== BUILDER COMPONENT TEST COMPLETE ===")
	get_tree().quit()

func test_builder_component_creation():
	var builder_script = load("res://components/player_builder.gd")
	test_assert(builder_script != null, "PlayerBuilder script loads successfully")
	
	var builder = builder_script.new()
	test_assert(builder != null, "PlayerBuilder instance created")
	test_assert(builder.is_in_build_mode == false, "Default not in build mode")
	test_assert(builder.is_building == false, "Default not building")
	test_assert(builder.current_building_type == "tent", "Default building type is tent")
	test_assert(builder.tent_wood_cost == 8, "Default tent cost is 8 wood")
	test_assert(builder.tent_ghost == null, "No initial ghost")
	
	builder.queue_free()

func test_builder_initialization():
	var builder_script = load("res://components/player_builder.gd")
	var controller_script = load("res://components/player_controller.gd")
	
	var builder = builder_script.new()
	var controller = controller_script.new()
	controller.player_id = 1
	
	# Initialize builder component
	builder.initialize(controller)
	
	test_assert(builder.is_component_ready(), "Builder component initialized successfully")
	test_assert(builder.get_player_id() == 1, "Builder component has correct player ID")
	
	builder.cleanup()
	builder.queue_free()
	controller.queue_free()

func test_build_mode_functionality():
	var builder_script = load("res://components/player_builder.gd")
	var builder = builder_script.new()
	
	# Test initial state
	test_assert(not builder.is_in_building_mode(), "Initially not in build mode")
	
	# Test building type management
	test_assert(builder.get_current_building_type() == "tent", "Default building type is tent")
	
	builder.set_building_type("tent")
	test_assert(builder.get_current_building_type() == "tent", "Building type set correctly")
	
	# Test build mode state (without resources, should fail)
	builder.enter_build_mode()
	test_assert(not builder.is_in_building_mode(), "Build mode fails without resources")
	
	builder.queue_free()

func test_resource_checking():
	var builder_script = load("res://components/player_builder.gd")
	var builder = builder_script.new()
	
	# Test resource affordability (without resource manager)
	test_assert(not builder.can_afford_building("tent"), "Cannot afford tent without resource manager")
	
	# Test building cost retrieval
	var tent_cost = builder.get_building_cost("tent")
	test_assert(tent_cost.has("wood"), "Tent cost includes wood")
	test_assert(tent_cost["wood"] == 8, "Tent costs 8 wood")
	
	var unknown_cost = builder.get_building_cost("unknown")
	test_assert(unknown_cost.is_empty(), "Unknown building has empty cost")
	
	builder.queue_free()

func test_building_types():
	var builder_script = load("res://components/player_builder.gd")
	var builder = builder_script.new()
	
	# Test supported building types
	test_assert(builder.can_afford_building("tent") == false, "Tent type recognized (fails due to no resources)")
	test_assert(builder.can_afford_building("unknown") == false, "Unknown type returns false")
	
	# Test building type changes
	builder.set_building_type("tent")
	test_assert(builder.get_current_building_type() == "tent", "Building type changed to tent")
	
	builder.queue_free()

func test_ghost_preview_system():
	var builder_script = load("res://components/player_builder.gd")
	var builder = builder_script.new()
	
	# Test initial ghost state
	test_assert(builder.tent_ghost == null, "No initial ghost")
	
	# Test ghost opacity and offset settings
	test_assert(builder.ghost_opacity == 0.3, "Default ghost opacity is 30%")
	test_assert(builder.ghost_forward_offset == 2.0, "Default ghost offset is 2 units")
	
	# Test building placement validation
	var can_place = builder.can_place_building_at(Vector3.ZERO, "tent")
	test_assert(not can_place, "Cannot place building without resources")
	
	# Test building operations
	var placed = builder.place_building()
	test_assert(not placed, "Cannot place building when not in build mode")
	
	builder.cancel_building()  # Should not crash when not in build mode
	test_assert(true, "Cancel building works when not in build mode")
	
	builder.queue_free()
