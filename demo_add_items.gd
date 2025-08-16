extends Node

## Demo showing how to add items to PlayerInventory

func _ready():
	print("=== HOW TO ADD ITEMS TO INVENTORY ===")
	print()
	
	print("🎯 Your PlayerInventory.add_item() method signature:")
	print("   add_item(item_definition, quantity: int = 1, state: String = '') -> int")
	print()
	
	print("📋 Step-by-step process:")
	print("   1. Get the item definition from ItemRegistry")
	print("   2. Get the player's inventory component") 
	print("   3. Call add_item() with the definition and quantity")
	print("   4. Optionally specify item state")
	print()
	
	print("💡 Example code patterns:")
	print()
	
	print("# Basic addition:")
	print("var seeds = ItemRegistry.get_item_definition('berry_seeds')")
	print("var inventory = player.get_component('inventory')")
	print("var added = inventory.add_item(seeds, 5)")
	print("print('Added:', added, 'seeds')")
	print()
	
	print("# With specific state:")
	print("var bucket = ItemRegistry.get_item_definition('bucket')")
	print("inventory.add_item(bucket, 1, 'empty')  # Empty bucket")
	print("inventory.add_item(bucket, 1, 'full')   # Full bucket")
	print()
	
	print("# Check what was actually added:")
	print("var result = inventory.add_item(item_def, 10)")
	print("if result < 10:")
	print("    print('Only added', result, '- inventory full!')")
	print()
	
	print("🔧 Your add_item() method features:")
	print("   ✅ Auto-stacking for stackable items")
	print("   ✅ Smart empty slot filling")
	print("   ✅ Returns actual amount added")
	print("   ✅ Validates item definitions")
	print("   ✅ Handles item states")
	print("   ✅ Debug output for tracking")
	print()
	
	print("🎮 Available items in your system:")
	demonstrate_available_items()

func demonstrate_available_items():
	"""Show what items are available to add"""
	print()
	print("📦 Items available in ItemRegistry:")
	
	if ItemRegistry:
		var item_ids = ["bucket", "berry_seeds", "watering_can"]
		for item_id in item_ids:
			if ItemRegistry.has_item(item_id):
				var item_def = ItemRegistry.get_item_definition(item_id)
				print("   • ", item_def.display_name, " (", item_id, ")")
				if item_def.has_states:
					print("     States:", item_def.valid_states)
				if item_def.is_stackable:
					print("     Max stack:", item_def.max_stack_size)
			else:
				print("   ⚠️ ", item_id, " not found")
	else:
		print("   ⚠️ ItemRegistry not available")
	
	print()
	print("✅ Use these item IDs with ItemRegistry.get_item_definition()")
	print("✅ Then call inventory.add_item() with the definition!")
