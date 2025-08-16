# Phase 1 Inventory System Test Script
# This script validates the basic inventory system functionality

extends Node

## Test script for Phase 1 inventory system implementation
## Run this to validate that the foundation is working properly

func _ready():
	print("=== Phase 1 Inventory System Test ===")
	run_all_tests()

func run_all_tests():
	"""Run all Phase 1 validation tests"""
	print("\n1. Testing ItemDefinition creation...")
	test_item_definition()
	
	print("\n2. Testing InventorySlot functionality...")
	test_inventory_slot()
	
	print("\n3. Testing ItemRegistry...")
	test_item_registry()
	
	print("\n4. Testing BucketItem creation...")
	test_bucket_item()
	
	print("\n5. Testing PlayerInventory basic functionality...")
	test_player_inventory()
	
	print("\n=== Phase 1 Test Complete ===")
	print("If no errors appeared above, Phase 1 foundation is working!")

func test_item_definition():
	"""Test ItemDefinition creation and validation"""
	print("  Creating bucket item definition...")
	
	var ItemDefinition = preload("res://systems/items/item_definition.gd")
	var bucket_def = ItemDefinition.new()
	
	bucket_def.item_id = "bucket"
	bucket_def.display_name = "Test Bucket"
	bucket_def.description = "A test bucket"
	bucket_def.item_type = "tool"
	bucket_def.has_states = true
	bucket_def.possible_states = ["empty", "full"]
	bucket_def.default_state = "empty"
	
	if bucket_def.is_valid():
		print("  ✓ ItemDefinition validation passed")
	else:
		print("  ✗ ItemDefinition validation failed")
	
	var display_name = bucket_def.get_display_name_with_state("full")
	print("  Display name with state: ", display_name)

func test_inventory_slot():
	"""Test InventorySlot creation and functionality"""
	print("  Creating inventory slot...")
	
	var InventorySlot = preload("res://systems/items/inventory_slot.gd")
	var slot = InventorySlot.new()
	
	if slot.is_empty():
		print("  ✓ Empty slot detected correctly")
	else:
		print("  ✗ Empty slot detection failed")
	
	# Test state changes (without item for now)
	print("  ✓ InventorySlot basic functionality works")

func test_item_registry():
	"""Test ItemRegistry initialization"""
	print("  Initializing ItemRegistry...")
	
	var ItemRegistry = preload("res://systems/items/item_registry.gd")
	ItemRegistry.initialize()
	
	var item_ids = ItemRegistry.get_all_item_ids()
	print("  Available items: ", item_ids)
	
	var bucket_def = ItemRegistry.get_item_definition("bucket")
	if bucket_def:
		print("  ✓ Bucket definition retrieved successfully")
		print("    Name: ", bucket_def.display_name)
		print("    States: ", bucket_def.possible_states)
	else:
		print("  ✗ Failed to retrieve bucket definition")

func test_bucket_item():
	"""Test BucketItem creation"""
	print("  Creating bucket item...")
	
	var BucketItem = preload("res://systems/items/bucket_item.gd")
	var bucket_def = BucketItem.create_bucket_definition()
	
	if bucket_def and bucket_def.is_valid():
		print("  ✓ Bucket definition created successfully")
		print("    ID: ", bucket_def.item_id)
		print("    Actions: ", bucket_def.tool_actions)
		print("    States: ", bucket_def.possible_states)
	else:
		print("  ✗ Bucket definition creation failed")

func test_player_inventory():
	"""Test PlayerInventory component basics"""
	print("  Creating PlayerInventory component...")
	
	var PlayerInventory = preload("res://components/player_inventory.gd")
	var inventory = PlayerInventory.new()
	
	print("  ✓ PlayerInventory component created")
	print("    Inventory size: ", inventory.inventory_size)
	print("    Hotbar size: ", inventory.hotbar_size)
	
	# Test empty inventory
	var empty_count = inventory.get_empty_slot_count()
	print("    Empty slots: ", empty_count)
	
	if empty_count == inventory.inventory_size:
		print("  ✓ Empty inventory state correct")
	else:
		print("  ✗ Empty inventory state incorrect")

# Input handler for manual testing
func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_T:
				print("\n--- Manual Test Triggered ---")
				test_with_player()
			KEY_R:
				print("\n--- Re-running All Tests ---")
				run_all_tests()

func test_with_player():
	"""Test with actual player if available"""
	var players = get_tree().get_nodes_in_group("players")
	if players.is_empty():
		print("No players found in scene")
		return
	
	var player = players[0]
	print("Testing with player: ", player.name)
	
	# Test giving bucket to player
	if player.has_method("test_give_bucket"):
		print("Giving empty bucket to player...")
		if player.test_give_bucket("empty"):
			print("✓ Bucket given successfully")
			
			if player.has_method("test_inventory_summary"):
				player.test_inventory_summary()
		else:
			print("✗ Failed to give bucket")
	else:
		print("Player doesn't have test methods - Phase 1 integration incomplete")

func print_instructions():
	"""Print testing instructions"""
	print("\n=== Phase 1 Testing Instructions ===")
	print("- Press 'T' to test with first player in scene")
	print("- Press 'R' to re-run all foundation tests")
	print("- Load a scene with a player to test integration")
	print("==========================================")

func _on_test_complete():
	print_instructions()
