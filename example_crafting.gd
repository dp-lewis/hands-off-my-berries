func craft_bucket(player: Node3D) -> bool:
	"""Craft a bucket using wood resources"""
	var resource_manager = player.get_component("resource_manager")
	var inventory = player.get_component("inventory")
	
	if not resource_manager or not inventory:
		return false
	
	# Check if player has enough wood (e.g., 3 wood for 1 bucket)
	if resource_manager.get_resource_amount("wood") >= 3:
		# Remove wood
		resource_manager.remove_resource("wood", 3)
		
		# Give bucket
		ItemRegistry.give_item_to_player(player, "bucket", 1, "empty")
		
		print("Crafted bucket! Used 3 wood.")
		return true
	else:
		print("Need 3 wood to craft bucket (have: ", resource_manager.get_resource_amount("wood"), ")")
		return false

# Call this when player presses a craft button or interacts with crafting station
# craft_bucket(player)
