extends Node

# Integration test for ResourceManager + ResourceConfig
func _ready():
	print("=== ResourceManager + ResourceConfig Integration Test ===")
	
	# Load both components
	var ResourceManagerScript = load("res://components/resource_manager.gd")
	var ResourceConfigScript = load("res://config/resource_config.gd")
	
	var resource_manager = ResourceManagerScript.new()
	var resource_config = ResourceConfigScript.new()
	add_child(resource_manager)
	
	print("\n1. Testing setup with ResourceConfig...")
	# Setup resources using config values
	for resource_type in resource_config.get_active_resource_types():
		var capacity = resource_config.get_max_capacity(resource_type)
		resource_manager.setup_resource_type(resource_type, capacity, 0)
		print("Set up ", resource_type, " with capacity ", capacity)
	print("✓ Setup with ResourceConfig works")
	
	print("\n2. Testing gameplay scenario...")
	# Simulate collecting wood (like chopping trees)
	var wood_collected = 0
	for i in range(3):  # Chop 3 trees, each gives 3 wood
		var added = resource_manager.add_resource("wood", 3)
		wood_collected += added
		print("Chopped tree ", i+1, ", collected ", added, " wood (total: ", wood_collected, ")")
	
	assert(wood_collected == 9, "Should collect 9 wood from 3 trees")
	print("✓ Wood collection simulation works")
	
	print("\n3. Testing building cost check...")
	# Check if we can build a tent (requires 8 wood)
	var current_wood = resource_manager.get_resource_amount("wood")
	var can_build = current_wood >= 8
	print("Current wood: ", current_wood, ", can build tent: ", can_build)
	assert(can_build == true, "Should be able to build tent with 9 wood")
	
	# Build the tent
	var wood_consumed = resource_manager.remove_resource("wood", 8)
	print("Built tent, consumed ", wood_consumed, " wood")
	assert(wood_consumed == 8, "Should consume 8 wood for tent")
	print("✓ Building cost system works")
	
	print("\n4. Testing food system...")
	# Collect food (pumpkins)
	for i in range(3):  # Collect 3 pumpkins, each gives 2 food
		var added = resource_manager.add_resource("food", 2)
		if added < 2:
			print("Food inventory full! Only added ", added, " food")
			break
		print("Collected pumpkin ", i+1, ", added ", added, " food")
	
	var current_food = resource_manager.get_resource_amount("food")
	print("Final food amount: ", current_food)
	assert(current_food == 5, "Should have 5 food (at capacity)")
	print("✓ Food collection system works")
	
	print("\n5. Testing resource debugging...")
	resource_manager.debug_print_resources()
	print("✓ Debug output works")
	
	print("\n=== Integration test passed! ===")
	print("🎉 ResourceManager + ResourceConfig are ready for player integration!")
	
	# Clean exit
	get_tree().quit()
