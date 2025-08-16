class_name BucketItem
extends RefCounted

## Bucket item implementation and behavior
## Demonstrates the inventory system with state management

# Static method to create bucket item definition
static func create_bucket_definition():
	"""Create an ItemDefinition for bucket"""
	var definition = preload("res://systems/items/item_definition.gd").new()
	
	# Basic properties
	definition.item_id = "bucket"
	definition.display_name = "Bucket"
	definition.description = "Used to collect and store water for drinking or watering crops"
	definition.item_type = "tool"
	
	# Stack properties
	definition.max_stack_size = 1
	definition.is_stackable = false
	
	# Tool properties
	definition.is_tool = true
	definition.has_durability = false  # Buckets don't break
	definition.tool_efficiency = 1.0
	var actions: Array[String] = ["water", "collect_water", "drink_water"]
	definition.tool_actions = actions
	
	# State properties
	definition.has_states = true
	var states: Array[String] = ["empty", "full"]
	definition.possible_states = states
	definition.default_state = "empty"
	
	return definition

# Usage methods for bucket
static func use_bucket(bucket_slot, player: Node3D, context: String = "auto") -> bool:
	"""Use bucket based on context or automatic detection"""
	if not bucket_slot or bucket_slot.is_empty():
		print("BucketItem: No bucket to use")
		return false
	
	if bucket_slot.item_definition.item_id != "bucket":
		print("BucketItem: Item is not a bucket")
		return false
	
	# Auto-detect context if not specified
	if context == "auto":
		context = detect_context(player)
	
	match context:
		"collect_water":
			return collect_water(bucket_slot, player)
		"water_crop":
			return water_crop(bucket_slot, player)
		"drink_water":
			return drink_water(bucket_slot, player)
		_:
			print("BucketItem: No valid action for context: ", context)
			return false

static func detect_context(player: Node3D) -> String:
	"""Detect what the player can do with the bucket"""
	var interaction = player.get_component("interaction") if player.has_method("get_component") else null
	
	if not interaction:
		return "drink_water"  # Default fallback
	
	# Check for water source (collect water)
	if interaction.nearby_water:
		return "collect_water"
	
	# Check for crops that need watering
	if interaction.nearby_food:
		var crop = interaction.nearby_food
		if crop.has_method("needs_water") and crop.needs_water():
			return "water_crop"
	
	# Default to drinking water
	return "drink_water"

static func collect_water(bucket_slot, player: Node3D) -> bool:
	"""Collect water into empty bucket"""
	if bucket_slot.get_state() != "empty":
		print("Bucket is already full!")
		return false
	
	var interaction = player.get_component("interaction") if player.has_method("get_component") else null
	if not interaction or not interaction.nearby_water:
		print("No water source nearby")
		return false
	
	# Fill the bucket
	bucket_slot.change_state("full")
	print("Filled bucket with water")
	return true

static func water_crop(bucket_slot, player: Node3D) -> bool:
	"""Use bucket water to water nearby crop"""
	if bucket_slot.get_state() != "full":
		print("Bucket is empty - need to fill it with water first")
		return false
	
	var interaction = player.get_component("interaction") if player.has_method("get_component") else null
	if not interaction or not interaction.nearby_food:
		print("No crop nearby to water")
		return false
	
	var crop = interaction.nearby_food
	if not crop.has_method("water_crop"):
		print("This crop cannot be watered")
		return false
	
	# Try to water the crop
	if crop.water_crop(player):
		bucket_slot.change_state("empty")
		print("Used bucket to water crop - bucket is now empty")
		return true
	else:
		print("Failed to water crop")
		return false

static func drink_water(bucket_slot, player: Node3D) -> bool:
	"""Drink water from bucket"""
	if bucket_slot.get_state() != "full":
		print("Bucket is empty - need to fill it with water first")
		return false
	
	var survival = player.get_component("survival") if player.has_method("get_component") else null
	if not survival:
		print("Player has no survival component")
		return false
	
	# Restore thirst (if thirst system exists)
	if survival.has_method("restore_thirst"):
		survival.restore_thirst(50.0)  # Restore 50 thirst points
		bucket_slot.change_state("empty")
		print("Drank water from bucket - restored thirst")
		return true
	elif survival.has_method("modify_thirst"):
		survival.modify_thirst(-50.0)  # Reduce thirst by 50 (negative = better)
		bucket_slot.change_state("empty")
		print("Drank water from bucket - reduced thirst")
		return true
	else:
		print("Survival component doesn't support thirst restoration")
		return false

# Integration with player interaction system
static func handle_bucket_interaction(player: Node3D) -> bool:
	"""Handle bucket interaction from PlayerInteraction component"""
	var inventory = player.get_component("inventory") if player.has_method("get_component") else null
	if not inventory:
		print("BucketItem: Player has no inventory component")
		return false
	
	var selected_slot = inventory.get_selected_slot()
	if not selected_slot or selected_slot.is_empty():
		print("BucketItem: No item selected")
		return false
	
	if selected_slot.item_definition.item_id != "bucket":
		print("BucketItem: Selected item is not a bucket")
		return false
	
	return use_bucket(selected_slot, player, "auto")

# Helper method for adding bucket to inventory
static func give_bucket_to_player(player: Node3D, state: String = "empty") -> bool:
	"""Give a bucket to player's inventory"""
	var inventory = player.get_component("inventory") if player.has_method("get_component") else null
	if not inventory:
		print("BucketItem: Player has no inventory component")
		return false
	
	var bucket_def = create_bucket_definition()
	var added = inventory.add_item(bucket_def, 1, state)
	
	if added > 0:
		print("Gave ", state, " bucket to player")
		return true
	else:
		print("Could not give bucket - inventory full")
		return false
