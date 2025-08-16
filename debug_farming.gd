extends Node

## Debug script for testing the farming system
## Add this as a child node to your main scene to test farming functions

var player_node: Node3D = null

func _ready():
	print("FarmingDebug: Ready to test farming system")
	
	# Find the player node
	call_deferred("find_player")

func find_player():
	"""Find the player node in the scene"""
	var players = get_tree().get_nodes_in_group("players")
	if players.size() > 0:
		player_node = players[0]
		print("FarmingDebug: Found player node: ", player_node.name)
		
		# Test component access
		test_component_access()
	else:
		print("FarmingDebug: No player found in scene")

func test_component_access():
	"""Test that farming component is accessible"""
	if not player_node:
		return
		
	var farming_component = player_node.get_component("farming")
	if farming_component:
		print("FarmingDebug: ✅ Farming component found")
		print("FarmingDebug: Component type: ", farming_component.get_script().get_global_name())
		
		# Test inventory access
		test_inventory_access()
	else:
		print("FarmingDebug: ❌ Farming component not found")

func test_inventory_access():
	"""Test inventory has farming items"""
	var inventory = player_node.get_component("inventory")
	if not inventory:
		print("FarmingDebug: ❌ No inventory component")
		return
	
	print("FarmingDebug: Testing starting items...")
	
	# Check for hoe
	if inventory.has_item("hoe"):
		print("FarmingDebug: ✅ Player has hoe")
	else:
		print("FarmingDebug: ❌ Player missing hoe")
	
	# Check for seeds
	if inventory.has_item("berry_seeds"):
		var seeds_count = inventory.get_item_count("berry_seeds")
		print("FarmingDebug: ✅ Player has ", seeds_count, " berry seeds")
	else:
		print("FarmingDebug: ❌ Player missing berry seeds")
	
	# Check for watering can
	if inventory.has_item("watering_can"):
		print("FarmingDebug: ✅ Player has watering can")
	else:
		print("FarmingDebug: ❌ Player missing watering can")

func _unhandled_input(event):
	"""Handle debug input for testing farming"""
	if not player_node:
		return
		
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F1:
				test_till_soil()
			KEY_F2:
				test_plant_seeds()
			KEY_F3:
				test_water_crops()
			KEY_F4:
				show_farming_stats()

func test_till_soil():
	"""Test soil tilling function"""
	print("FarmingDebug: Testing soil tilling...")
	
	var farming = player_node.get_component("farming")
	if farming:
		farming.attempt_till_soil(null, player_node)
	else:
		print("FarmingDebug: No farming component to test")

func test_plant_seeds():
	"""Test seed planting function"""
	print("FarmingDebug: Testing seed planting...")
	
	var inventory = player_node.get_component("inventory")
	var farming = player_node.get_component("farming")
	
	if inventory and farming:
		var seed_def = ItemRegistry.get_item_definition("berry_seeds")
		if seed_def:
			farming.attempt_plant_seeds(seed_def, 1, player_node)
		else:
			print("FarmingDebug: Could not get berry seeds definition")
	else:
		print("FarmingDebug: Missing components for planting test")

func test_water_crops():
	"""Test crop watering function"""
	print("FarmingDebug: Testing crop watering...")
	
	var farming = player_node.get_component("farming")
	if farming:
		farming.attempt_water_crops(null, player_node)
	else:
		print("FarmingDebug: No farming component to test")

func show_farming_stats():
	"""Show current farming statistics"""
	print("FarmingDebug: Farming Statistics:")
	
	var farming = player_node.get_component("farming")
	if farming:
		var stats = farming.get_farming_stats()
		for key in stats.keys():
			print("  ", key, ": ", stats[key])
	else:
		print("FarmingDebug: No farming component")

func _draw():
	"""Show debug instructions on screen"""
	pass

func _notification(what):
	if what == NOTIFICATION_READY:
		print("FarmingDebug: Farming Debug Controls:")
		print("  F1 - Test Till Soil")
		print("  F2 - Test Plant Seeds") 
		print("  F3 - Test Water Crops")
		print("  F4 - Show Farming Stats")
