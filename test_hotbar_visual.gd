extends Node

## Test script to demonstrate hotbar visual selection feedback

func _ready():
	print("=== TESTING HOTBAR VISUAL SELECTION ===")
	
	# Wait a frame for everything to initialize
	await get_tree().process_frame
	
	# Find the player
	var player = get_node_or_null("Player")
	if not player:
		print("❌ Player not found")
		return
	
	# Get inventory component
	var inventory = player.get_component("inventory")
	if not inventory:
		print("❌ PlayerInventory component not found")
		return
	
	print("✅ Found inventory with", inventory.hotbar_size, "hotbar slots")
	print("📍 Current selected slot:", inventory.selected_hotbar_slot)
	
	# Add some test items for better visual feedback
	add_test_items(inventory)
	
	# Test navigation with visual feedback reporting
	await test_visual_navigation(inventory)
	
	print("✅ Visual hotbar test complete!")

func add_test_items(inventory):
	"""Add some test items to make visual feedback more obvious"""
	print("\n🎒 Adding test items...")
	
	# Try to get some item definitions
	var item_registry = ItemRegistry
	if item_registry and item_registry.has_item("bucket"):
		inventory.add_item(item_registry.get_item_definition("bucket"), 1, "empty")
		print("  Added bucket to inventory")
	
	if item_registry and item_registry.has_item("berry_seeds"):
		inventory.add_item(item_registry.get_item_definition("berry_seeds"), 5)
		print("  Added berry seeds to inventory")

func test_visual_navigation(inventory):
	"""Test navigation with visual feedback reporting"""
	print("\n🎮 Testing visual navigation feedback...")
	print("📍 Starting slot:", inventory.selected_hotbar_slot)
	
	# Navigate right twice
	print("\n🔄 Navigating right...")
	for i in range(2):
		inventory.navigate_hotbar(1)  # Right
		await get_tree().create_timer(0.5).timeout  # Half second delay to see changes
		print("   After right", i+1, ": slot", inventory.selected_hotbar_slot)
	
	# Navigate left once
	print("\n🔄 Navigating left...")
	inventory.navigate_hotbar(-1)  # Left
	await get_tree().create_timer(0.5).timeout
	print("   After left: slot", inventory.selected_hotbar_slot)
	
	# Test wraparound
	print("\n🔄 Testing wraparound...")
	inventory.select_hotbar_slot(3)  # Go to last slot
	await get_tree().create_timer(0.5).timeout
	print("   Set to slot 3")
	
	inventory.navigate_hotbar(1)  # Should wrap to 0
	await get_tree().create_timer(0.5).timeout
	print("   After wraparound right: slot", inventory.selected_hotbar_slot)
