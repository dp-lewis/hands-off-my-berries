class_name ItemRegistry
extends RefCounted

## Central registry for all item definitions in the game
## Provides access to item definitions and manages item creation

static var _definitions: Dictionary = {}
static var _initialized: bool = false

# Initialize all item definitions
static func initialize():
	"""Initialize the item registry with all available items"""
	if _initialized:
		return
	
	print("ItemRegistry: Initializing item definitions...")
	
	# Register bucket
	var bucket_def = preload("res://systems/items/bucket_item.gd").create_bucket_definition()
	register_item(bucket_def)
	
	# Register berry seeds for future farming expansion
	var berry_seeds_def = create_berry_seeds_definition()
	register_item(berry_seeds_def)
	
	# Register watering can for future tool expansion
	var watering_can_def = create_watering_can_definition()
	register_item(watering_can_def)
	
	# Register hoe for soil preparation
	var hoe_def = create_hoe_definition()
	register_item(hoe_def)
	
	_initialized = true
	print("ItemRegistry: Initialized with ", _definitions.size(), " item definitions")

static func register_item(definition):
	"""Register an item definition"""
	if not definition or not definition.is_valid():
		print("ItemRegistry: Cannot register invalid item definition")
		return false
	
	_definitions[definition.item_id] = definition
	print("ItemRegistry: Registered item '", definition.item_id, "' - ", definition.display_name)
	return true

static func get_item_definition(item_id: String):
	"""Get item definition by ID"""
	if not _initialized:
		initialize()
	
	if item_id in _definitions:
		return _definitions[item_id]
	else:
		print("ItemRegistry: Item definition not found: ", item_id)
		return null

static func get_all_item_ids() -> Array[String]:
	"""Get list of all registered item IDs"""
	if not _initialized:
		initialize()
	
	return _definitions.keys()

static func has_item(item_id: String) -> bool:
	"""Check if item is registered"""
	if not _initialized:
		initialize()
	
	return item_id in _definitions

static func create_item_instance(item_id: String, quantity: int = 1, state: String = ""):
	"""Create an InventorySlot with the specified item"""
	var definition = get_item_definition(item_id)
	if not definition:
		return null
	
	var slot = preload("res://systems/items/inventory_slot.gd").new()
	slot.set_item(definition, quantity, state)
	return slot

# === PREDEFINED ITEM DEFINITIONS ===

static func create_berry_seeds_definition():
	"""Create berry seeds item definition"""
	var definition = preload("res://systems/items/item_definition.gd").new()
	
	definition.item_id = "berry_seeds"
	definition.display_name = "Berry Seeds"
	definition.description = "Plant these to grow berry bushes. Yields food after growth cycle."
	definition.item_type = "consumable"
	
	definition.max_stack_size = 10
	definition.is_stackable = true
	
	definition.is_consumable = true
	definition.consume_on_use = true
	
	return definition

static func create_watering_can_definition():
	"""Create watering can item definition"""
	var definition = preload("res://systems/items/item_definition.gd").new()
	
	definition.item_id = "watering_can"
	definition.display_name = "Watering Can"
	definition.description = "More efficient than a bucket for watering crops. Has limited uses."
	definition.item_type = "tool"
	
	definition.max_stack_size = 1
	definition.is_stackable = false
	
	definition.is_tool = true
	definition.has_durability = true
	definition.max_durability = 50  # 50 uses before breaking
	definition.tool_efficiency = 2.0  # More efficient than bucket
	var watering_actions: Array[String] = ["water"]
	definition.tool_actions = watering_actions
	
	return definition

static func create_hoe_definition():
	"""Create hoe tool item definition"""
	var definition = preload("res://systems/items/item_definition.gd").new()
	
	definition.item_id = "hoe"
	definition.display_name = "Hoe"
	definition.description = "Essential farming tool for tilling soil before planting crops."
	definition.item_type = "tool"
	
	definition.max_stack_size = 1
	definition.is_stackable = false
	
	definition.is_tool = true
	definition.has_durability = true
	definition.max_durability = 100  # 100 uses before breaking
	definition.tool_efficiency = 1.0  # Standard efficiency for tilling
	var tilling_actions: Array[String] = ["till", "prepare_soil"]
	definition.tool_actions = tilling_actions
	
	return definition

# === UTILITY METHODS ===

static func get_items_by_type(item_type: String) -> Array:
	"""Get all items of a specific type"""
	if not _initialized:
		initialize()
	
	var items = []
	for definition in _definitions.values():
		if definition.item_type == item_type:
			items.append(definition)
	
	return items

static func get_tools_with_action(action: String) -> Array:
	"""Get all tools that can perform a specific action"""
	if not _initialized:
		initialize()
	
	var tools = []
	for definition in _definitions.values():
		if definition.is_tool and definition.can_perform_action(action):
			tools.append(definition)
	
	return tools

static func print_registry():
	"""Print all registered items for debugging"""
	if not _initialized:
		initialize()
	
	print("=== ItemRegistry Contents ===")
	for item_id in _definitions.keys():
		var def = _definitions[item_id]
		print("  ", item_id, ": ", def.display_name, " (", def.item_type, ")")
		if def.is_tool:
			print("    Tool actions: ", def.tool_actions)
		if def.has_states:
			print("    States: ", def.possible_states)
	print("==============================")

# Development helper methods
static func give_item_to_player(player: Node3D, item_id: String, quantity: int = 1, state: String = "") -> bool:
	"""Give an item to a player - useful for testing"""
	var inventory = player.get_component("inventory") if player.has_method("get_component") else null
	if not inventory:
		print("ItemRegistry: Player has no inventory component")
		return false
	
	var definition = get_item_definition(item_id)
	if not definition:
		return false
	
	var added = inventory.add_item(definition, quantity, state)
	if added > 0:
		print("ItemRegistry: Gave ", added, "x ", definition.display_name, " to player")
		return true
	else:
		print("ItemRegistry: Could not give item - inventory full")
		return false
