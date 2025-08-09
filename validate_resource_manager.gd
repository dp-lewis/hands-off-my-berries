extends Node

# Simple validation script to test ResourceManager
func _ready():
	print("=== ResourceManager Validation Test ===")
	
	# Load the ResourceManager script
	var ResourceManagerScript = load("res://components/resource_manager.gd")
	var resource_manager = ResourceManagerScript.new()
	add_child(resource_manager)
	
	# Test basic functionality
	print("\n1. Testing setup_resource_type...")
	resource_manager.setup_resource_type("wood", 10, 5)
	print("✓ Wood setup complete")
	
	print("\n2. Testing get_resource_amount...")
	var wood_amount = resource_manager.get_resource_amount("wood")
	print("Wood amount: ", wood_amount, " (expected: 5)")
	assert(wood_amount == 5, "Wood amount should be 5")
	print("✓ Get resource amount works")
	
	print("\n3. Testing add_resource...")
	var added = resource_manager.add_resource("wood", 3)
	print("Added: ", added, " wood (expected: 3)")
	print("New total: ", resource_manager.get_resource_amount("wood"), " (expected: 8)")
	assert(added == 3, "Should add 3 wood")
	assert(resource_manager.get_resource_amount("wood") == 8, "Total should be 8")
	print("✓ Add resource works")
	
	print("\n4. Testing capacity limits...")
	var overflow_added = resource_manager.add_resource("wood", 5)
	print("Overflow added: ", overflow_added, " wood (expected: 2)")
	print("Final total: ", resource_manager.get_resource_amount("wood"), " (expected: 10)")
	assert(overflow_added == 2, "Should only add 2 wood due to capacity")
	assert(resource_manager.get_resource_amount("wood") == 10, "Should be at capacity")
	print("✓ Capacity limits work")
	
	print("\n5. Testing remove_resource...")
	var removed = resource_manager.remove_resource("wood", 3)
	print("Removed: ", removed, " wood (expected: 3)")
	print("Remaining: ", resource_manager.get_resource_amount("wood"), " (expected: 7)")
	assert(removed == 3, "Should remove 3 wood")
	assert(resource_manager.get_resource_amount("wood") == 7, "Should have 7 remaining")
	print("✓ Remove resource works")
	
	print("\n6. Testing utility functions...")
	var available_space = resource_manager.get_available_space("wood")
	var percentage = resource_manager.get_resource_percentage("wood")
	var is_full = resource_manager.is_resource_full("wood")
	var is_empty = resource_manager.is_resource_empty("wood")
	
	print("Available space: ", available_space, " (expected: 3)")
	print("Percentage: ", percentage, " (expected: 0.7)")
	print("Is full: ", is_full, " (expected: false)")
	print("Is empty: ", is_empty, " (expected: false)")
	
	assert(available_space == 3, "Available space should be 3")
	assert(abs(percentage - 0.7) < 0.01, "Percentage should be 0.7")
	assert(is_full == false, "Should not be full")
	assert(is_empty == false, "Should not be empty")
	print("✓ Utility functions work")
	
	print("\n=== All ResourceManager tests passed! ===")
	print("🎉 ResourceManager is ready for integration!")
	
	# Clean exit
	get_tree().quit()
