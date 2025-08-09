extends Node

# Simple validation script to test ResourceConfig
func _ready():
	print("=== ResourceConfig Validation Test ===")
	
	# Load the ResourceConfig script and create instance
	var ResourceConfigScript = load("res://config/resource_config.gd")
	var resource_config = ResourceConfigScript.new()
	
	print("\n1. Testing get_max_capacity...")
	var wood_cap = resource_config.get_max_capacity("wood")
	var food_cap = resource_config.get_max_capacity("food")
	var stone_cap = resource_config.get_max_capacity("stone")
	var unknown_cap = resource_config.get_max_capacity("unknown")
	
	print("Wood capacity: ", wood_cap, " (expected: 10)")
	print("Food capacity: ", food_cap, " (expected: 5)")
	print("Stone capacity: ", stone_cap, " (expected: 8)")
	print("Unknown capacity: ", unknown_cap, " (expected: 0)")
	
	assert(wood_cap == 10, "Wood capacity should be 10")
	assert(food_cap == 5, "Food capacity should be 5")
	assert(stone_cap == 8, "Stone capacity should be 8")
	assert(unknown_cap == 0, "Unknown capacity should be 0")
	print("✓ get_max_capacity works")
	
	print("\n2. Testing get_all_resource_types...")
	var all_types = resource_config.get_all_resource_types()
	print("All types: ", all_types)
	assert(all_types.size() == 4, "Should have 4 resource types")
	assert(all_types.has("wood"), "Should include wood")
	assert(all_types.has("food"), "Should include food")
	assert(all_types.has("stone"), "Should include stone")
	assert(all_types.has("tools"), "Should include tools")
	print("✓ get_all_resource_types works")
	
	print("\n3. Testing get_active_resource_types...")
	var active_types = resource_config.get_active_resource_types()
	print("Active types: ", active_types)
	assert(active_types.size() == 2, "Should have 2 active resource types")
	assert(active_types.has("wood"), "Should include wood")
	assert(active_types.has("food"), "Should include food")
	print("✓ get_active_resource_types works")
	
	print("\n=== All ResourceConfig tests passed! ===")
	print("🎉 ResourceConfig is ready for integration!")
	
	# Clean exit
	get_tree().quit()
