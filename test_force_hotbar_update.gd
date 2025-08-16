extends Node

## Test to force hotbar UI update and see why items aren't showing

func _ready():
	print("=== FORCE HOTBAR UPDATE TEST ===")
	
	# Wait for initialization
	await get_tree().create_timer(2.0).timeout
	
	# Find player
	var player = get_tree().get_first_node_in_group("players")
	if not player:
		print("❌ No player found")
		return
	
	var inventory = player.get_component("inventory")
	if not inventory:
		print("❌ No inventory found")
		return
	
	print("✅ Found player and inventory")
	
	# Print current inventory
	print("\n📋 Current inventory:")
	inventory.print_inventory()
	
	# Find HotbarUI
	var hotbar_ui = find_hotbar_ui()
	if not hotbar_ui:
		print("❌ No HotbarUI found")
		return
	
	print("✅ Found HotbarUI")
	
	# Force update
	print("\n🔄 Forcing hotbar update...")
	hotbar_ui.update_all_slots()
	
	# Check hotbar UI state
	print("HotbarUI target_inventory:", hotbar_ui.target_inventory)
	print("HotbarUI hotbar_size:", hotbar_ui.hotbar_size)
	print("HotbarUI slots count:", hotbar_ui.hotbar_slots.size())
	
	# Test adding another item to see if update works
	print("\n➕ Adding test item...")
	ItemRegistry.give_item_to_player(player, "berry_seeds", 1)
	
	# Wait and check again
	await get_tree().create_timer(1.0).timeout
	print("\n📋 After adding item:")
	inventory.print_inventory()

func find_hotbar_ui():
	# Search the scene tree for HotbarUI
	return find_node_recursive(get_tree().current_scene, "HotbarUI")

func find_node_recursive(node: Node, class_name: String):
	if node.get_script() and node.get_script().get_global_name() == class_name:
		return node
	
	for child in node.get_children():
		var result = find_node_recursive(child, class_name)
		if result:
			return result
	
	return null
