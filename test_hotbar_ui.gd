extends Node3D

# Test script for hotbar UI integration
var player_controller

func _ready():
	print("Testing Hotbar UI Integration...")
	
	# Create a test player with the new player_new.gd
	var PlayerScript = load("res://scenes/players/player_new.gd")
	player_controller = PlayerScript.new()
	player_controller.player_id = 0
	player_controller.name = "TestPlayer"
	
	# Create ResourceManager (required by PlayerController)
	var ResourceManagerScript = load("res://components/resource_manager.gd")
	var resource_manager = ResourceManagerScript.new()
	resource_manager.name = "ResourceManager"
	player_controller.add_child(resource_manager)
	
	add_child(player_controller)
	
	# Wait for components to initialize
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Test hotbar functionality
	test_hotbar_integration()

func test_hotbar_integration():
	print("\n=== TESTING HOTBAR UI INTEGRATION ===")
	
	# Check if player has UI
	if player_controller.player_ui:
		print("✅ Player UI created successfully")
		
		# Check if hotbar UI exists in the player UI
		var hotbar_ui = player_controller.player_ui.hotbar_ui
		if hotbar_ui:
			print("✅ Hotbar UI found in player UI")
			
			# Check if it has slots
			if hotbar_ui.hotbar_slots.size() == 8:
				print("✅ Hotbar has correct number of slots: ", hotbar_ui.hotbar_slots.size())
			else:
				print("❌ Hotbar slot count incorrect: ", hotbar_ui.hotbar_slots.size())
			
			# Check if it's connected to inventory
			if hotbar_ui.target_inventory:
				print("✅ Hotbar connected to player inventory")
				
				# Test giving player a bucket
				test_bucket_in_hotbar()
			else:
				print("❌ Hotbar not connected to inventory")
		else:
			print("❌ Hotbar UI not found in player UI")
	else:
		print("❌ Player UI not created")

func test_bucket_in_hotbar():
	print("\n--- Testing Bucket in Hotbar ---")
	
	# Give player a bucket
	var success = player_controller.test_give_bucket("empty")
	if success:
		print("✅ Bucket given to player successfully")
		
		# Check if hotbar displays the bucket
		await get_tree().process_frame
		
		var hotbar_ui = player_controller.player_ui.hotbar_ui
		if hotbar_ui:
			print("🎯 Hotbar should now show bucket in first slot")
			print("   Selected slot: ", hotbar_ui.selected_slot)
			
			# Test selecting different slots
			for i in range(3):
				player_controller.player_inventory.select_hotbar_slot(i)
				await get_tree().process_frame
				print("   Selected slot ", i, " - hotbar shows: ", hotbar_ui.selected_slot)
		
	else:
		print("❌ Failed to give bucket to player")

func _input(event):
	if event.is_action_pressed("ui_accept"):
		print("\n🔄 Re-running hotbar test...")
		test_hotbar_integration()
	elif event.is_action_pressed("ui_cancel"):
		print("Test complete. Exiting...")
		get_tree().quit()
