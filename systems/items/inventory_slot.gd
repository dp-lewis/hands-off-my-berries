class_name InventorySlot
extends RefCounted

## Represents a single slot in a player's inventory
## Holds an item with quantity, state, and durability information

# Signals
signal slot_changed()
signal item_state_changed(old_state: String, new_state: String)
signal durability_changed(old_durability: int, new_durability: int)

# Core slot data
var item_definition # : ItemDefinition (dynamic typing to avoid circular dependency)
var quantity: int = 0
var current_state: String = ""
var durability: int = 100
var custom_data: Dictionary = {}

# Constructor
func _init(definition = null, qty: int = 0, state: String = ""):
	if definition:
		set_item(definition, qty, state)

# Set item in this slot
func set_item(definition, qty: int = 1, state: String = "") -> void:
	"""Set an item in this slot with optional quantity and state"""
	item_definition = definition
	quantity = max(0, qty)
	
	# Set state
	if definition and definition.has_states:
		current_state = state if state != "" else definition.default_state
	else:
		current_state = definition.default_state if definition else ""
	
	# Set durability
	durability = definition.max_durability if definition and definition.has_durability else 100
	
	slot_changed.emit()

# Clear this slot
func clear() -> void:
	"""Remove all items from this slot"""
	item_definition = null
	quantity = 0
	current_state = ""
	durability = 100
	custom_data.clear()
	slot_changed.emit()

# Query methods
func is_empty() -> bool:
	"""Check if this slot has no items"""
	return item_definition == null or quantity <= 0

func is_full() -> bool:
	"""Check if this slot is at maximum capacity"""
	if is_empty():
		return false
	return quantity >= item_definition.max_stack_size

func get_available_space() -> int:
	"""Get how many more items can fit in this slot"""
	if is_empty():
		return 0
	return item_definition.max_stack_size - quantity

# Stacking methods
func can_stack_with(other_slot: InventorySlot) -> bool:
	"""Check if this slot can stack with another slot"""
	if is_empty() or other_slot.is_empty():
		return false
	
	if not item_definition.is_stackable or not other_slot.item_definition.is_stackable:
		return false
	
	# Must be same item type
	if item_definition.item_id != other_slot.item_definition.item_id:
		return false
	
	# Must be same state (if item has states)
	if item_definition.has_states and current_state != other_slot.current_state:
		return false
	
	# Must have similar durability for tools (within 10%)
	if item_definition.has_durability:
		var durability_diff = abs(durability - other_slot.durability)
		var max_durability = item_definition.max_durability
		if float(durability_diff) / float(max_durability) > 0.1:
			return false
	
	return true

func can_accept_item(definition, state: String = "") -> bool:
	"""Check if this slot can accept a specific item"""
	if is_empty():
		return true
	
	if item_definition.item_id != definition.item_id:
		return false
	
	if not definition.is_stackable:
		return false
	
	if definition.has_states and state != current_state:
		return false
	
	return not is_full()

# Stack operations
func add_quantity(amount: int) -> int:
	"""Add quantity to this slot, returns amount actually added"""
	if is_empty() or not item_definition.is_stackable:
		return 0
	
	var space_available = get_available_space()
	var amount_to_add = min(amount, space_available)
	
	if amount_to_add > 0:
		quantity += amount_to_add
		slot_changed.emit()
	
	return amount_to_add

func remove_quantity(amount: int) -> int:
	"""Remove quantity from this slot, returns amount actually removed"""
	if is_empty():
		return 0
	
	var amount_to_remove = min(amount, quantity)
	quantity -= amount_to_remove
	
	if quantity <= 0:
		clear()
	else:
		slot_changed.emit()
	
	return amount_to_remove

# State management
func change_state(new_state: String) -> bool:
	"""Change the state of the item in this slot"""
	if is_empty() or not item_definition.has_states:
		return false
	
	if not item_definition.possible_states.has(new_state):
		print("InventorySlot: Invalid state '", new_state, "' for item '", item_definition.item_id, "'")
		return false
	
	var old_state = current_state
	current_state = new_state
	
	item_state_changed.emit(old_state, new_state)
	slot_changed.emit()
	return true

func get_state() -> String:
	"""Get the current state of the item"""
	return current_state

# Durability management
func damage_item(damage_amount: int) -> bool:
	"""Damage the item, returns true if item broke"""
	if is_empty() or not item_definition.has_durability:
		return false
	
	var old_durability = durability
	durability = max(0, durability - damage_amount)
	
	durability_changed.emit(old_durability, durability)
	slot_changed.emit()
	
	# Check if item broke
	if durability <= 0:
		print("Item '", get_display_name(), "' broke!")
		clear()
		return true
	
	return false

func repair_item(repair_amount: int) -> void:
	"""Repair the item"""
	if is_empty() or not item_definition.has_durability:
		return
	
	var old_durability = durability
	durability = min(item_definition.max_durability, durability + repair_amount)
	
	if durability != old_durability:
		durability_changed.emit(old_durability, durability)
		slot_changed.emit()

func get_durability_percentage() -> float:
	"""Get durability as percentage (0.0 to 1.0)"""
	if is_empty() or not item_definition.has_durability:
		return 1.0
	
	return float(durability) / float(item_definition.max_durability)

# Display methods
func get_display_name() -> String:
	"""Get display name including state if applicable"""
	if is_empty():
		return ""
	
	return item_definition.get_display_name_with_state(current_state)

func get_tooltip_text() -> String:
	"""Get detailed tooltip text for this item"""
	if is_empty():
		return ""
	
	var tooltip = item_definition.display_name
	
	# Add state info
	if item_definition.has_states and current_state != item_definition.default_state:
		tooltip += " (" + current_state.capitalize() + ")"
	
	# Add quantity info
	if quantity > 1:
		tooltip += " x" + str(quantity)
	
	# Add durability info
	if item_definition.has_durability:
		var durability_percent = int(get_durability_percentage() * 100)
		tooltip += "\nDurability: " + str(durability_percent) + "%"
	
	# Add description
	if not item_definition.description.is_empty():
		tooltip += "\n" + item_definition.description
	
	# Add tool actions
	if item_definition.is_tool and not item_definition.tool_actions.is_empty():
		tooltip += "\nActions: " + ", ".join(item_definition.tool_actions)
	
	return tooltip

# Serialization support for future save/load
func to_dict() -> Dictionary:
	"""Convert slot to dictionary for serialization"""
	var data = {}
	
	if not is_empty():
		data["item_id"] = item_definition.item_id
		data["quantity"] = quantity
		data["state"] = current_state
		data["durability"] = durability
		
		if not custom_data.is_empty():
			data["custom_data"] = custom_data
	
	return data

func from_dict(data: Dictionary, _item_registry) -> bool:
	"""Load slot from dictionary, requires item registry to resolve item_id"""
	if data.is_empty():
		clear()
		return true
	
	var item_id = data.get("item_id", "")
	if item_id.is_empty():
		return false
	
	# This will need ItemRegistry to be implemented
	# var definition = item_registry.get_item_definition(item_id)
	# if not definition:
	#     return false
	
	# For now, just store the data
	custom_data = data.get("custom_data", {})
	return true
