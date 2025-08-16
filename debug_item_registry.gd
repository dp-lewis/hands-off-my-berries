extends Node

## Quick debug script to test ItemRegistry initialization
## Add this to your scene to debug item definitions

func _ready():
	print("=== ITEM REGISTRY DEBUG ===")
	
	# Initialize ItemRegistry
	var ItemRegistryClass = preload("res://systems/items/item_registry.gd")
	ItemRegistryClass.initialize()
	
	# Test all expected items
	var expected_items = ["bucket", "watering_can", "berry_seeds", "hoe"]
	
	for item_id in expected_items:
		var definition = ItemRegistry.get_item_definition(item_id)
		if definition:
			print("✅ ", item_id, ": ", definition.display_name, " (", definition.item_type, ")")
		else:
			print("❌ ", item_id, ": NOT FOUND")
	
	print("=== END DEBUG ===")
