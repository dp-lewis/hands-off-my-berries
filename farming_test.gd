# Test Scene for Farming System
extends Node3D

## Simple test scene to validate farming functionality
## Instantiate this in your main game scene to test farming

var player: Node3D
var test_area_created: bool = false

func _ready():
	print("FarmingTest: Setting up farming test scene")
	
	# Find player
	call_deferred("setup_test")

func setup_test():
	"""Set up the farming test environment"""
	var players = get_tree().get_nodes_in_group("players")
	if players.size() > 0:
		player = players[0]
		print("FarmingTest: Found player for testing")
		
		# Verify farming component
		test_farming_component()
		
		# Show instructions
		show_instructions()
	else:
		print("FarmingTest: No player found - cannot test farming")

func test_farming_component():
	"""Test that farming component is working"""
	if not player:
		return
		
	var farming = player.get_component("farming")
	if farming:
		print("FarmingTest: ✅ Farming component is available")
		
		# Test inventory for farming items
		test_farming_inventory()
	else:
		print("FarmingTest: ❌ Farming component not found")

func test_farming_inventory():
	"""Test that player has farming items"""
	var inventory = player.get_component("inventory")
	if not inventory:
		print("FarmingTest: ❌ No inventory component")
		return
	
	print("FarmingTest: Checking farming items...")
	
	# Check starting items
	var items_to_check = ["hoe", "berry_seeds", "watering_can"]
	for item_id in items_to_check:
		if inventory.has_item(item_id):
			var count = inventory.get_item_count(item_id)
			print("FarmingTest: ✅ Has ", count, "x ", item_id)
		else:
			print("FarmingTest: ❌ Missing ", item_id)

func show_instructions():
	"""Display farming test instructions"""
	print("=====================================")
	print("🌱 FARMING SYSTEM TEST INSTRUCTIONS")
	print("=====================================")
	print("1. Use p1_hud_left/p1_hud_right to navigate hotbar")
	print("2. Select HOE and press p1_action to till soil")
	print("3. Select BERRY SEEDS and press p1_action to plant")
	print("4. Select WATERING CAN and press p1_action to water")
	print("5. Watch console for farming messages")
	print("=====================================")
	print("Current hotbar contents:")
	
	var inventory = player.get_component("inventory") if player else null
	if inventory:
		var hotbar_slots = inventory.get_hotbar_slots()
		for i in range(hotbar_slots.size()):
			var slot = hotbar_slots[i]
			if slot and not slot.is_empty():
				print("  Slot ", i, ": ", slot.item_definition.display_name, " x", slot.quantity)
			else:
				print("  Slot ", i, ": [Empty]")

func _unhandled_input(event):
	"""Handle test input"""
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F9:
				show_instructions()
			KEY_F10:
				force_test_all_farming_actions()

func force_test_all_farming_actions():
	"""Force test all farming actions regardless of selection"""
	if not player:
		return
		
	print("FarmingTest: Force testing all farming actions...")
	
	var farming = player.get_component("farming")
	var inventory = player.get_component("inventory")
	
	if not farming or not inventory:
		print("FarmingTest: Missing components for testing")
		return
	
	# Test tilling
	print("FarmingTest: Testing soil tilling...")
	farming.attempt_till_soil(null, player)
	
	# Test planting  
	print("FarmingTest: Testing seed planting...")
	var seed_def = ItemRegistry.get_item_definition("berry_seeds")
	if seed_def:
		farming.attempt_plant_seeds(seed_def, 1, player)
	
	# Test watering
	print("FarmingTest: Testing crop watering...")
	farming.attempt_water_crops(null, player)
	
	# Show stats
	print("FarmingTest: Current farming stats:")
	var stats = farming.get_farming_stats()
	for key in stats.keys():
		print("  ", key, ": ", stats[key])
