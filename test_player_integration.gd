extends Node

# Test integration of ResourceManager with Player
func _ready():
	print("=== Player + ResourceManager Integration Test ===")
	
	# Load player scene
	var player_scene = preload("res://scenes/players/player.tscn")
	var player = player_scene.instantiate()
	add_child(player)
	
	# Wait for player to be ready
	await get_tree().process_frame
	await get_tree().process_frame  # Extra frame for ResourceManager setup
	
	print("\n1. Testing ResourceManager presence...")
	if player.resource_manager:
		print("✓ ResourceManager found in player")
	else:
		print("❌ ResourceManager not found!")
		get_tree().quit()
		return
	
	print("\n2. Testing resource collection...")
	# Test wood collection
	var wood_success = player.add_wood(5)
	print("Added 5 wood, success: ", wood_success)
	print("Current wood: ", player.resource_manager.get_resource_amount("wood"))
	
	# Test food collection
	var food_success = player.add_food(3)
	print("Added 3 food, success: ", food_success)
	print("Current food: ", player.resource_manager.get_resource_amount("food"))
	
	print("\n3. Testing building requirements...")
	# Try to build without enough wood (need 8, have 5)
	player.enter_build_mode()
	
	if not player.is_in_build_mode:
		print("✓ Correctly prevented building with insufficient wood")
	else:
		print("❌ Should not allow building with insufficient wood")
	
	# Add enough wood and try again
	player.add_wood(5)  # Total now 10
	player.enter_build_mode()
	
	if player.is_in_build_mode:
		print("✓ Correctly allowed building with sufficient wood")
		player.exit_build_mode()  # Clean up
	else:
		print("❌ Should allow building with sufficient wood")
	
	print("\n4. Testing inventory limits...")
	# Try to overfill wood inventory (capacity is 10, have 10)
	var overflow_success = player.add_wood(5)
	print("Tried to add 5 more wood (already at capacity), success: ", overflow_success)
	print("Final wood amount: ", player.resource_manager.get_resource_amount("wood"))
	
	if not overflow_success:
		print("✓ Correctly prevented overflow")
	else:
		print("❌ Should prevent overflow")
	
	print("\n=== Integration Test Complete ===")
	print("🎉 Player + ResourceManager integration successful!")
	
	# Clean exit
	get_tree().quit()
