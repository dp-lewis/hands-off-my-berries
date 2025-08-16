extends Node

## Test script to demonstrate adding items to inventory

func _ready():
	print("=== TESTING ITEM ADDITION ===")
	
	# Create a test player with inventory
	var test_result = await create_test_environment()
	if not test_result:
		print("❌ Failed to create test environment")
		return
	
	var inventory = test_result
	print("✅ Created test inventory with", inventory.hotbar_size, "hotbar slots")
	
	# Test adding different items
	test_item_addition(inventory)

func create_test_environment():
	"""Create a minimal test environment with inventory"""
	# Load the PlayerInventory script
	var inventory_script = preload("res://components/player_inventory.gd")
	var inventory = inventory_script.new()
	
	# Create a mock player controller
	var mock_controller = Node.new()
	mock_controller.player_id = 0
	add_child(mock_controller)
	
	# Set up the inventory component
	inventory.player_controller = mock_controller
	mock_controller.add_child(inventory)
	
	# Initialize the inventory
	inventory.setup_inventory_slots()
	
	return inventory

func test_item_addition(inventory):
	"""Test adding various items to the inventory"""
	print("\n🧪 Testing item addition...")
	
	# Show initial state
	print("\n📋 Initial inventory state:")
	inventory.print_inventory()
	
	# Test 1: Add berry seeds
	print("\n➕ Adding 3 berry seeds...")
	if ItemRegistry.has_item("berry_seeds"):
		var berry_seeds = ItemRegistry.get_item_definition("berry_seeds")
		var added = inventory.add_item(berry_seeds, 3)
		print("   Actually added:", added, "berry seeds")
	else:
		print("   ⚠️ Berry seeds not found in ItemRegistry")
	
	# Test 2: Add bucket (empty state)
	print("\n➕ Adding empty bucket...")
	if ItemRegistry.has_item("bucket"):
		var bucket = ItemRegistry.get_item_definition("bucket")
		var added = inventory.add_item(bucket, 1, "empty")
		print("   Actually added:", added, "empty bucket")
	else:
		print("   ⚠️ Bucket not found in ItemRegistry")
	
	# Test 3: Add watering can
	print("\n➕ Adding watering can...")
	if ItemRegistry.has_item("watering_can"):
		var watering_can = ItemRegistry.get_item_definition("watering_can")
		var added = inventory.add_item(watering_can, 1)
		print("   Actually added:", added, "watering can")
	else:
		print("   ⚠️ Watering can not found in ItemRegistry")
	
	# Test 4: Try to add more berry seeds (should stack)
	print("\n➕ Adding 2 more berry seeds (should stack)...")
	if ItemRegistry.has_item("berry_seeds"):
		var berry_seeds = ItemRegistry.get_item_definition("berry_seeds")
		var added = inventory.add_item(berry_seeds, 2)
		print("   Actually added:", added, "more berry seeds")
	
	# Show final state
	print("\n📋 Final inventory state:")
	inventory.print_inventory()
	
	# Show hotbar slots specifically
	print("\n🎮 Hotbar slots (first 4):")
	for i in range(inventory.hotbar_size):
		var slot = inventory.get_slot(i)
		if slot and not slot.is_empty():
			var selected_marker = " *" if i == inventory.selected_hotbar_slot else ""
			print("  [", i, "]", selected_marker, " ", slot.get_display_name(), " x", slot.quantity)
		else:
			var selected_marker = " *" if i == inventory.selected_hotbar_slot else ""
			print("  [", i, "]", selected_marker, " (empty)")
	
	print("\n✅ Item addition test complete!")
