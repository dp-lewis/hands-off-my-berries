extends Node

## Test to verify players get starting items in their hotbar

func _ready():
	print("=== TESTING STARTING ITEMS ===")
	
	# Wait a bit for player initialization
	await get_tree().create_timer(2.0).timeout
	
	# Find player
	var player = get_tree().get_first_node_in_group("players")
	if not player:
		print("❌ No player found")
		return
	
	print("✅ Found player ", player.player_id)
	
	# Check inventory
	var inventory = player.get_component("inventory")
	if not inventory:
		print("❌ Player has no inventory")
		return
	
	print("✅ Player has inventory component")
	
	# Show inventory contents
	print("\n📋 Player inventory after starting items:")
	inventory.print_inventory()
	
	# Test hotbar navigation
	print("\n🎮 Testing hotbar navigation:")
	print("Current slot:", inventory.selected_hotbar_slot)
	
	# Navigate to show different items
	for i in range(3):
		inventory.navigate_hotbar(1)  # Move right
		await get_tree().create_timer(0.5).timeout
		print("After right navigation:", inventory.selected_hotbar_slot)
		
		var selected_slot = inventory.get_selected_slot()
		if selected_slot and not selected_slot.is_empty():
			print("  Selected item:", selected_slot.get_display_name())
		else:
			print("  Selected slot is empty")
	
	print("\n✅ Starting items test complete!")
