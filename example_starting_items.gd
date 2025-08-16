func give_starting_items(player: Node3D):
	"""Give players basic starting items"""
	var inventory = player.get_component("inventory")
	if not inventory:
		return
	
	print("Giving starting items to player ", player.player_id)
	
	# Give basic tools
	ItemRegistry.give_item_to_player(player, "bucket", 1, "empty")
	ItemRegistry.give_item_to_player(player, "watering_can", 1)
	
	# Give starting seeds for farming
	ItemRegistry.give_item_to_player(player, "berry_seeds", 5)
	
	print("Starting items given!")

# Call this when player spawns or game starts
# give_starting_items(player)
