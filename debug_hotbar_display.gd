extends Node

## Debug script to check hotbar display issues

func _ready():
	print("=== DEBUGGING HOTBAR DISPLAY ===")
	
	# Wait for full initialization
	await get_tree().create_timer(1.0).timeout
	
	# Find player
	var player = get_tree().get_first_node_in_group("players")
	if not player:
		print("❌ No player found")
		return
	
	print("✅ Found player ", player.player_id)
	
	# Check inventory component
	var inventory = player.get_component("inventory")
	if not inventory:
		print("❌ No inventory component")
		return
	
	print("✅ Inventory component found")
	
	# Check inventory contents
	print("\n📋 Inventory contents:")
	inventory.print_inventory()
	
	# Check hotbar specifically
	print("\n🎮 Hotbar slots:")
	for i in range(inventory.hotbar_size):
		var slot = inventory.get_slot(i)
		if slot:
			if slot.is_empty():
				print("  Slot ", i, ": EMPTY")
			else:
				print("  Slot ", i, ": ", slot.get_display_name(), " x", slot.quantity, " state:", slot.get_state())
		else:
			print("  Slot ", i, ": NULL")
	
	# Check UI connection
	print("\n🎨 Checking UI connection...")
	check_hotbar_ui()

func check_hotbar_ui():
	"""Check if HotbarUI is connected and working"""
	# Look for HotbarUI in the scene
	var hotbar_ui = find_hotbar_ui_in_scene()
	if not hotbar_ui:
		print("❌ No HotbarUI found in scene")
		return
	
	print("✅ Found HotbarUI component")
	print("   Target inventory:", hotbar_ui.target_inventory)
	print("   Hotbar slots count:", hotbar_ui.hotbar_slots.size())
	print("   Hotbar size config:", hotbar_ui.hotbar_size)
	
	# Check if UI slots are created
	print("\n🔍 UI slot details:")
	for i in range(hotbar_ui.hotbar_slots.size()):
		var ui_slot = hotbar_ui.hotbar_slots[i]
		if ui_slot:
			print("  UI Slot ", i, ": exists")
		else:
			print("  UI Slot ", i, ": NULL")

func find_hotbar_ui_in_scene() -> Node:
	"""Find HotbarUI node in scene"""
	# Search for HotbarUI by class or name
	var nodes_to_check = get_tree().get_nodes_in_group("ui")
	for node in nodes_to_check:
		if node.get_script() and node.get_script().get_global_name() == "HotbarUI":
			return node
	
	# Fallback: search by name patterns
	var root = get_tree().current_scene
	return find_node_recursive(root, "HotbarUI")

func find_node_recursive(node: Node, target_name: String) -> Node:
	"""Recursively search for node by name"""
	if node.name.contains(target_name) or (node.get_script() and node.get_script().get_global_name() == "HotbarUI"):
		return node
	
	for child in node.get_children():
		var result = find_node_recursive(child, target_name)
		if result:
			return result
	
	return null
