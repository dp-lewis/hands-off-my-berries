extends Node3D

# Test hotbar navigation with left/right controls
var player_controller
var test_actions = []

func _ready():
	print("=== TESTING HOTBAR NAVIGATION ===")
	
	# Create test player
	var PlayerScript = load("res://scenes/players/player_new.gd")
	player_controller = PlayerScript.new()
	player_controller.player_id = 0
	player_controller.name = "TestPlayer"
	
	# Add required ResourceManager
	var ResourceManagerScript = load("res://components/resource_manager.gd")
	var resource_manager = ResourceManagerScript.new()
	resource_manager.name = "ResourceManager"
	player_controller.add_child(resource_manager)
	
	add_child(player_controller)
	
	# Wait for initialization
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Test navigation
	test_hotbar_navigation()

func test_hotbar_navigation():
	print("\n--- Testing Hotbar Navigation ---")
	
	var inventory = player_controller.player_inventory
	if not inventory:
		print("❌ No inventory found")
		return
	
	print("✅ Inventory found with ", inventory.hotbar_size, " hotbar slots")
	print("Starting slot: ", inventory.selected_hotbar_slot)
	
	# Test right navigation
	print("\n🔄 Testing right navigation...")
	for i in range(2):  # Test with 2 moves instead of 3
		inventory.navigate_hotbar(1)
		print("   After right ", i+1, ": slot ", inventory.selected_hotbar_slot)
	
	# Test left navigation
	print("\n🔄 Testing left navigation...")
	for i in range(2):
		inventory.navigate_hotbar(-1)
		print("   After left ", i+1, ": slot ", inventory.selected_hotbar_slot)
	
	# Test wraparound
	print("\n🔄 Testing wraparound...")
	inventory.select_hotbar_slot(3)  # Go to last slot (now slot 3)
	print("   Set to slot 3, then navigate right...")
	inventory.navigate_hotbar(1)
	print("   After wraparound: slot ", inventory.selected_hotbar_slot, " (should be 0)")
	
	inventory.select_hotbar_slot(0)  # Go to first slot
	print("   Set to slot 0, then navigate left...")
	inventory.navigate_hotbar(-1)
	print("   After wraparound: slot ", inventory.selected_hotbar_slot, " (should be 3)")
	
	print("\n✅ Hotbar navigation test complete!")

func _input(event):
	if event.is_action_pressed("ui_accept"):
		print("\n🔄 Re-running navigation test...")
		test_hotbar_navigation()
	elif event.is_action_pressed("ui_cancel"):
		print("Test complete. Exiting...")
		get_tree().quit()
