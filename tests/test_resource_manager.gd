extends GutTest

var resource_manager: ResourceManager

func before_each():
	resource_manager = ResourceManager.new()
	add_child(resource_manager)

func after_each():
	resource_manager.queue_free()

func test_setup_resource_type():
	# Test basic resource type setup
	resource_manager.setup_resource_type("wood", 10, 5)
	
	assert_eq(resource_manager.get_resource_amount("wood"), 5, "Initial amount should be set")
	assert_eq(resource_manager.get_available_space("wood"), 5, "Available space should be calculated correctly")
	assert_false(resource_manager.is_resource_full("wood"), "Should not be full initially")
	assert_false(resource_manager.is_resource_empty("wood"), "Should not be empty with initial amount")

func test_setup_resource_type_exceeding_capacity():
	# Test setup with initial amount exceeding capacity (should be clamped)
	resource_manager.setup_resource_type("wood", 10, 15)
	
	assert_eq(resource_manager.get_resource_amount("wood"), 10, "Should clamp initial amount to capacity")
	assert_true(resource_manager.is_resource_full("wood"), "Should be full when clamped to capacity")

func test_add_resource_within_capacity():
	# Test adding resources within capacity limits
	resource_manager.setup_resource_type("wood", 10, 0)
	
	var amount_added = resource_manager.add_resource("wood", 5)
	
	assert_eq(amount_added, 5, "Should add full amount when space available")
	assert_eq(resource_manager.get_resource_amount("wood"), 5, "Resource amount should increase")

func test_add_resource_exceeding_capacity():
	# Test adding more resources than capacity allows
	resource_manager.setup_resource_type("wood", 10, 8)
	
	var amount_added = resource_manager.add_resource("wood", 5)
	
	assert_eq(amount_added, 2, "Should only add what fits")
	assert_eq(resource_manager.get_resource_amount("wood"), 10, "Should be at max capacity")
	assert_true(resource_manager.is_resource_full("wood"), "Should be full")

func test_add_resource_unknown_type():
	# Test adding to unknown resource type
	var amount_added = resource_manager.add_resource("unknown", 5)
	
	assert_eq(amount_added, 0, "Should not add unknown resource type")

func test_remove_resource_sufficient_amount():
	# Test removing resources when sufficient amount available
	resource_manager.setup_resource_type("food", 5, 3)
	
	var amount_removed = resource_manager.remove_resource("food", 2)
	
	assert_eq(amount_removed, 2, "Should remove requested amount")
	assert_eq(resource_manager.get_resource_amount("food"), 1, "Resource amount should decrease")

func test_remove_resource_insufficient_amount():
	# Test removing more resources than available
	resource_manager.setup_resource_type("food", 5, 2)
	
	var amount_removed = resource_manager.remove_resource("food", 5)
	
	assert_eq(amount_removed, 2, "Should only remove what's available")
	assert_eq(resource_manager.get_resource_amount("food"), 0, "Should be empty")
	assert_true(resource_manager.is_resource_empty("food"), "Should be empty")

func test_remove_resource_unknown_type():
	# Test removing from unknown resource type
	var amount_removed = resource_manager.remove_resource("unknown", 5)
	
	assert_eq(amount_removed, 0, "Should not remove from unknown resource type")

func test_resource_percentage_calculation():
	# Test percentage calculations
	resource_manager.setup_resource_type("wood", 10, 7)
	
	assert_eq(resource_manager.get_resource_percentage("wood"), 0.7, "Should calculate correct percentage")
	
	# Test empty resource
	resource_manager.setup_resource_type("food", 5, 0)
	assert_eq(resource_manager.get_resource_percentage("food"), 0.0, "Empty resource should be 0%")
	
	# Test full resource
	resource_manager.setup_resource_type("stone", 8, 8)
	assert_eq(resource_manager.get_resource_percentage("stone"), 1.0, "Full resource should be 100%")

func test_unknown_resource_type_queries():
	# Test handling of unknown resource types
	var amount = resource_manager.get_resource_amount("unknown")
	assert_eq(amount, 0, "Unknown resource should return 0")
	
	var space = resource_manager.get_available_space("unknown")
	assert_eq(space, 0, "Unknown resource should have 0 space")
	
	assert_false(resource_manager.is_resource_full("unknown"), "Unknown resource should not be full")
	assert_true(resource_manager.is_resource_empty("unknown"), "Unknown resource should be empty")
	
	var percentage = resource_manager.get_resource_percentage("unknown")
	assert_eq(percentage, 0.0, "Unknown resource should have 0% percentage")

func test_resource_signals():
	# Test that signals are emitted correctly
	resource_manager.setup_resource_type("wood", 10, 3)
	
	# Watch for signals
	watch_signals(resource_manager)
	
	# Add resources and check signal
	resource_manager.add_resource("wood", 2)
	assert_signal_emitted(resource_manager, "resource_changed", "Should emit resource_changed when adding")
	
	# Fill to capacity and check full signal
	resource_manager.add_resource("wood", 5)
	assert_signal_emitted(resource_manager, "resource_full", "Should emit resource_full when at capacity")
	
	# Remove all resources and check empty signal
	resource_manager.remove_resource("wood", 10)
	assert_signal_emitted(resource_manager, "resource_empty", "Should emit resource_empty when depleted")

func test_get_all_resource_types():
	# Test getting all resource types
	resource_manager.setup_resource_type("wood", 10)
	resource_manager.setup_resource_type("food", 5)
	resource_manager.setup_resource_type("stone", 8)
	
	var types = resource_manager.get_all_resource_types()
	
	assert_eq(types.size(), 3, "Should return correct number of resource types")
	assert_true(types.has("wood"), "Should include wood")
	assert_true(types.has("food"), "Should include food")
	assert_true(types.has("stone"), "Should include stone")

func test_resource_manager_complex_scenario():
	# Test a complex scenario similar to actual gameplay
	resource_manager.setup_resource_type("wood", 10, 0)
	resource_manager.setup_resource_type("food", 5, 0)
	
	# Collect some wood
	var wood_added = resource_manager.add_resource("wood", 6)
	assert_eq(wood_added, 6, "Should collect 6 wood")
	
	# Try to build (requires 8 wood, but only have 6)
	var can_build = resource_manager.get_resource_amount("wood") >= 8
	assert_false(can_build, "Should not be able to build with insufficient wood")
	
	# Collect more wood
	resource_manager.add_resource("wood", 4)  # Total now 10
	can_build = resource_manager.get_resource_amount("wood") >= 8
	assert_true(can_build, "Should be able to build with sufficient wood")
	
	# Build tent (consume 8 wood)
	var wood_consumed = resource_manager.remove_resource("wood", 8)
	assert_eq(wood_consumed, 8, "Should consume 8 wood for building")
	assert_eq(resource_manager.get_resource_amount("wood"), 2, "Should have 2 wood remaining")
	
	# Try to overfill food inventory
	var food_added = resource_manager.add_resource("food", 10)
	assert_eq(food_added, 5, "Should only add up to capacity")
	assert_true(resource_manager.is_resource_full("food"), "Food should be full")
	
	# Try to add more food (should add 0)
	var extra_food = resource_manager.add_resource("food", 1)
	assert_eq(extra_food, 0, "Should not add when full")
