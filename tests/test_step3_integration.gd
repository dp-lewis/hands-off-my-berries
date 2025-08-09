extends Node

# Test script to validate Step 3 integration
func _ready():
	print("=== Step 3 Integration Test ===")
	
	# Test 1: Verify ResourceManager can be instantiated
	test_resource_manager_creation()
	
	# Test 2: Test wood resource operations
	test_wood_operations()
	
	# Test 3: Test food resource operations  
	test_food_operations()
	
	print("=== Step 3 Integration Test Complete ===")
	get_tree().quit()

func test_resource_manager_creation():
	print("\n--- Testing ResourceManager Creation ---")
	
	var resource_manager_scene = load("res://components/resource_manager.tscn")
	if resource_manager_scene:
		var resource_manager = resource_manager_scene.instantiate()
		add_child(resource_manager)
		
		if resource_manager.has_method("add_resource"):
			print("✓ ResourceManager instantiated successfully")
			print("✓ ResourceManager has add_resource method")
		else:
			print("✗ ResourceManager missing add_resource method")
		
		resource_manager.queue_free()
	else:
		print("✗ Failed to load ResourceManager scene")

func test_wood_operations():
	print("\n--- Testing Wood Operations ---")
	
	var resource_manager_scene = load("res://components/resource_manager.tscn")
	var resource_manager = resource_manager_scene.instantiate()
	add_child(resource_manager)
	
	# Test adding wood (should work with capacity of 10)
	var result = resource_manager.add_resource("wood", 5)
	if result:
		print("✓ Successfully added 5 wood")
		var amount = resource_manager.get_resource_amount("wood")
		print("✓ Wood amount is now: ", amount)
	else:
		print("✗ Failed to add wood")
	
	# Test adding more wood than capacity
	result = resource_manager.add_resource("wood", 10)  # Should fail, would exceed capacity
	if not result:
		print("✓ Correctly rejected adding wood beyond capacity")
	else:
		print("✗ Incorrectly allowed adding wood beyond capacity")
	
	resource_manager.queue_free()

func test_food_operations():
	print("\n--- Testing Food Operations ---")
	
	var resource_manager_scene = load("res://components/resource_manager.tscn")
	var resource_manager = resource_manager_scene.instantiate()
	add_child(resource_manager)
	
	# Test adding food (should work with capacity of 5)
	var result = resource_manager.add_resource("food", 3)
	if result:
		print("✓ Successfully added 3 food")
		var amount = resource_manager.get_resource_amount("food")
		print("✓ Food amount is now: ", amount)
	else:
		print("✗ Failed to add food")
	
	# Test adding more food than capacity
	result = resource_manager.add_resource("food", 5)  # Should fail, would exceed capacity
	if not result:
		print("✓ Correctly rejected adding food beyond capacity")
	else:
		print("✗ Incorrectly allowed adding food beyond capacity")
	
	resource_manager.queue_free()
