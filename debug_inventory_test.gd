extends Node3D

## Debug script to test inventory and hotbar integration
## This will automatically add items to the player's inventory when the scene starts

func _ready():
	# Wait a moment for everything to initialize
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	
	print("Debug: Starting inventory test...")
	
	# Find the player in the scene
	var player = find_player()
	if not player:
		print("Debug: No player found!")
		return
	
	print("Debug: Found player: ", player.name)
	
	# Get the inventory component
	var inventory = player.get_component("inventory") if player.has_method("get_component") else null
	if not inventory:
		print("Debug: No inventory component found!")
		return
	
	print("Debug: Found inventory component")
	
	# Test adding items
	test_add_items(inventory)

func find_player():
	"""Find a player node in the scene"""
	var players = get_tree().get_nodes_in_group("players")
	if players.size() > 0:
		return players[0]
	
	# Fallback: search for player by name
	return get_tree().get_first_node_in_group("player")

func test_add_items(inventory):
	"""Test adding various food items to inventory"""
	print("Debug: Testing item additions...")
	
	# Test 1: Add berries
	var berries_def = ItemRegistry.get_item_definition("berries")
	if berries_def:
		print("Debug: Adding berries...")
		var added = inventory.add_item(berries_def, 3)
		print("Debug: Added ", added, " berries")
	else:
		print("Debug: No berries definition found!")
	
	# Wait a frame
	await get_tree().process_frame
	
	# Test 2: Add pumpkin
	var pumpkin_def = ItemRegistry.get_item_definition("pumpkin")
	if pumpkin_def:
		print("Debug: Adding pumpkin...")
		var added = inventory.add_item(pumpkin_def, 1)
		print("Debug: Added ", added, " pumpkin")
	else:
		print("Debug: No pumpkin definition found!")
	
	# Wait a frame
	await get_tree().process_frame
	
	# Test 3: Add carrot
	var carrot_def = ItemRegistry.get_item_definition("carrot")
	if carrot_def:
		print("Debug: Adding carrot...")
		var added = inventory.add_item(carrot_def, 2)
		print("Debug: Added ", added, " carrots")
	else:
		print("Debug: No carrot definition found!")
	
	print("Debug: Item addition test complete")
