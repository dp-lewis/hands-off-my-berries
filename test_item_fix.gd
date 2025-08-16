extends Node

# Quick test for bucket item definition fix
func _ready():
	print("Testing bucket item definition fix...")
	
	# Test bucket creation
	var bucket_def = BucketItem.create_bucket_definition()
	
	if bucket_def:
		print("✅ Bucket definition created successfully")
		print("   Tool actions: ", bucket_def.tool_actions)
		print("   Has states: ", bucket_def.has_states)
		print("   Possible states: ", bucket_def.possible_states)
	else:
		print("❌ Bucket definition failed")
	
	# Test watering can
	var watering_def = ItemRegistry.create_watering_can_definition()
	
	if watering_def:
		print("✅ Watering can definition created successfully")
		print("   Tool actions: ", watering_def.tool_actions)
	else:
		print("❌ Watering can definition failed")
	
	get_tree().quit()
