class_name PlayerInventory
extends "res://components/player_component.gd"

## Player inventory component for managing items with states and tools
## Integrates with existing ResourceManager for basic resources

# Inventory configuration
@export var inventory_size: int = 20
@export var hotbar_size: int = 4

# Inventory storage
var inventory_slots: Array = []  # Array of InventorySlot (dynamic typing)
var selected_hotbar_slot: int = 0

# Component references
var resource_manager  # ResourceManager component
var player_interaction  # PlayerInteraction component

# Signals
signal inventory_changed(slot_index: int)
signal selected_slot_changed(new_slot: int, old_slot: int)
signal item_used(item_definition, quantity: int, player_node: Node3D)  # Updated for farming integration
signal hotbar_slot_selected(slot_index: int)

func _on_initialize():
	"""Initialize the inventory system"""
	# Initialize empty slots
	setup_inventory_slots()
	
	# Get component references
	resource_manager = get_sibling_component("resource_manager")
	player_interaction = get_sibling_component("interaction") 
	
	if not resource_manager:
		emit_error("ResourceManager component not found")
		return
	
	# Note: Starting items are handled by PlayerController.give_starting_items()
	print("PlayerInventory: Inventory system initialized")

func _on_cleanup():
	"""Clean up inventory system"""
	clear_all_slots()

func setup_inventory_slots():
	"""Create and setup all inventory slots"""
	inventory_slots.clear()
	
	for i in range(inventory_size):
		var slot = preload("res://systems/items/inventory_slot.gd").new()
		slot.slot_changed.connect(_on_slot_changed.bind(i))
		slot.item_state_changed.connect(_on_item_state_changed.bind(i))
		inventory_slots.append(slot)

# === SLOT MANAGEMENT ===

func get_slot(index: int):  # -> InventorySlot (dynamic typing)
	"""Get slot by index"""
	if index >= 0 and index < inventory_slots.size():
		return inventory_slots[index]
	return null

func get_selected_slot():  # -> InventorySlot (dynamic typing)
	"""Get currently selected hotbar slot"""
	var slot = get_slot(selected_hotbar_slot)
	if slot and not slot.is_empty():
		print("PlayerInventory: Selected slot ", selected_hotbar_slot, " contains: ", slot.item_definition.display_name)
	else:
		print("PlayerInventory: Selected slot ", selected_hotbar_slot, " is empty")
	return slot

func get_hotbar_slots() -> Array:  # Array[InventorySlot] (dynamic typing)
	"""Get all hotbar slots"""
	var hotbar_slots: Array = []
	for i in range(min(hotbar_size, inventory_slots.size())):
		hotbar_slots.append(inventory_slots[i])
	return hotbar_slots

func clear_slot(index: int) -> bool:
	"""Clear a specific slot"""
	var slot = get_slot(index)
	if slot:
		slot.clear()
		return true
	return false

func clear_all_slots():
	"""Clear all inventory slots"""
	for slot in inventory_slots:
		slot.clear()

# === ITEM ADDITION/REMOVAL ===

func add_item(item_definition, quantity: int = 1, state: String = "") -> int:
	"""Add items to inventory, returns amount actually added"""
	if not item_definition or not item_definition.is_valid():
		return 0
	
	var remaining = quantity
	
	# First try to stack with existing items (if stackable)
	if item_definition.is_stackable:
		remaining = try_stack_with_existing(item_definition, remaining, state)
	
	# Then fill empty slots
	if remaining > 0:
		remaining = fill_empty_slots(item_definition, remaining, state)
	
	var amount_added = quantity - remaining
	if amount_added == 0:
		push_warning("PlayerInventory: Inventory full, couldn't add " + item_definition.display_name)
	
	return amount_added

func try_stack_with_existing(item_definition, quantity: int, state: String) -> int:
	"""Try to stack with existing items, returns remaining quantity"""
	var remaining = quantity
	
	for slot in inventory_slots:
		if remaining <= 0:
			break
		
		if not slot.is_empty() and slot.can_accept_item(item_definition, state):
			var added = slot.add_quantity(remaining)
			remaining -= added
	
	return remaining

func fill_empty_slots(item_definition, quantity: int, state: String) -> int:
	"""Fill empty slots with items, returns remaining quantity"""
	var remaining = quantity
	
	for slot in inventory_slots:
		if remaining <= 0:
			break
		
		if slot.is_empty():
			var to_add = min(remaining, item_definition.max_stack_size)
			slot.set_item(item_definition, to_add, state)
			remaining -= to_add
	
	return remaining

func remove_item(item_id: String, quantity: int = 1, state: String = "") -> int:
	"""Remove items from inventory, returns amount actually removed"""
	var remaining = quantity
	
	for slot in inventory_slots:
		if remaining <= 0:
			break
		
		if not slot.is_empty() and slot.item_definition.item_id == item_id:
			# Check state if specified
			if state != "" and slot.get_state() != state:
				continue
			
			var removed = slot.remove_quantity(remaining)
			remaining -= removed
	
	var amount_removed = quantity - remaining
	return amount_removed

func has_item(item_id: String, quantity: int = 1, state: String = "") -> bool:
	"""Check if inventory contains enough of an item"""
	var found = 0
	
	for slot in inventory_slots:
		if not slot.is_empty() and slot.item_definition.item_id == item_id:
			# Check state if specified
			if state != "" and slot.get_state() != state:
				continue
			
			found += slot.quantity
			if found >= quantity:
				return true
	
	return false

func get_item_count(item_id: String, state: String = "") -> int:
	"""Get total count of an item in inventory"""
	var count = 0
	
	for slot in inventory_slots:
		if not slot.is_empty() and slot.item_definition.item_id == item_id:
			# Check state if specified
			if state != "" and slot.get_state() != state:
				continue
			
			count += slot.quantity
	
	return count

# === HOTBAR SELECTION ===

func select_hotbar_slot(slot_index: int) -> bool:
	"""Select a hotbar slot"""
	if slot_index < 0 or slot_index >= hotbar_size:
		print("PlayerInventory: Invalid slot index: ", slot_index)
		return false
	
	var old_slot = selected_hotbar_slot
	selected_hotbar_slot = slot_index
	print("PlayerInventory: Changed selected slot from ", old_slot, " to ", selected_hotbar_slot)
	
	selected_slot_changed.emit(selected_hotbar_slot, old_slot)
	hotbar_slot_selected.emit(selected_hotbar_slot)
	
	return true

func cycle_hotbar_selection(direction: int = 1) -> void:
	"""Cycle through hotbar slots"""
	var new_slot = (selected_hotbar_slot + direction) % hotbar_size
	if new_slot < 0:
		new_slot = hotbar_size - 1
	
	select_hotbar_slot(new_slot)

func navigate_hotbar(direction: int) -> void:
	"""Navigate hotbar left (-1) or right (1)"""
	cycle_hotbar_selection(direction)

# === ITEM USAGE ===

func use_selected_item() -> bool:
	"""Use the currently selected item"""
	var selected_slot = get_selected_slot()
	if not selected_slot or selected_slot.is_empty():
		print("PlayerInventory: No item selected or slot is empty")
		return false
	
	var item_def = selected_slot.item_definition
	print("PlayerInventory: Using item: ", item_def.display_name, " (", item_def.item_id, ")")
	
	# Handle specific item types with custom logic
	var success = false
	match item_def.item_id:
		"berry_seeds":
			print("PlayerInventory: Attempting to plant berry seeds!")
			# The PlayerFarming component will handle the actual planting logic
			success = true
		"hoe":
			print("PlayerInventory: Using hoe to till soil!")
			# The PlayerFarming component will handle the actual tilling logic
			success = true
		"bucket":
			print("PlayerInventory: Using bucket (", selected_slot.current_state, ")")
			# Toggle bucket state
			if selected_slot.current_state == "empty":
				selected_slot.current_state = "full"
			else:
				selected_slot.current_state = "empty"
			success = true
		"watering_can":
			print("PlayerInventory: Using watering can to water crops!")
			# The PlayerFarming component will handle the actual watering logic
			success = true
		_:
			print("PlayerInventory: Generic item usage for ", item_def.item_id)
			success = true
	
	if success:
		# Emit signal with item definition for farming component to handle
		item_used.emit(item_def, selected_slot.quantity, player_controller)
		
		# Handle consumable items
		if item_def.is_consumable and item_def.consume_on_use:
			print("PlayerInventory: Consuming item (before: ", selected_slot.quantity, ")")
			selected_slot.remove_quantity(1)
			print("PlayerInventory: Item consumed (after: ", selected_slot.quantity, ")")
		
		# Handle tool durability
		if item_def.has_durability:
			selected_slot.damage_item(1)  # Basic damage, could be customized
	
	return success

func use_item_in_slot(slot_index: int) -> bool:
	"""Use item in a specific slot"""
	var old_selection = selected_hotbar_slot
	if select_hotbar_slot(slot_index):
		var result = use_selected_item()
		select_hotbar_slot(old_selection)  # Restore selection
		return result
	return false

# === UTILITY METHODS ===

func get_empty_slot_count() -> int:
	"""Get number of empty slots"""
	var count = 0
	for slot in inventory_slots:
		if slot.is_empty():
			count += 1
	return count

func is_inventory_full() -> bool:
	"""Check if inventory is completely full"""
	return get_empty_slot_count() == 0

func get_inventory_summary() -> String:
	"""Get a text summary of inventory contents"""
	var summary = "Inventory (" + str(inventory_size - get_empty_slot_count()) + "/" + str(inventory_size) + "):\n"
	
	var item_counts = {}
	for slot in inventory_slots:
		if not slot.is_empty():
			var key = slot.item_definition.item_id + "|" + slot.get_state()
			if key in item_counts:
				item_counts[key] += slot.quantity
			else:
				item_counts[key] = slot.quantity
	
	for key in item_counts.keys():
		var parts = key.split("|")
		var item_id = parts[0]
		var state = parts[1]
		var count = item_counts[key]
		
		summary += "  " + item_id
		if state != "normal" and state != "":
			summary += " (" + state + ")"
		summary += ": " + str(count) + "\n"
	
	return summary

# === INTEGRATION WITH BERRY CROP ===

func can_water_crops() -> bool:
	"""Check if player has tools that can water crops"""
	for slot in inventory_slots:
		if not slot.is_empty() and slot.item_definition.is_tool:
			if slot.item_definition.can_perform_action("water"):
				# For bucket, check if it's full
				if slot.item_definition.item_id == "bucket":
					return slot.get_state() == "full"
				# For watering can, check durability
				elif slot.item_definition.item_id == "watering_can":
					return slot.durability > 0
	return false

func get_watering_tool():  # -> InventorySlot (dynamic typing)
	"""Get the best available watering tool"""
	var best_tool = null
	var best_efficiency = 0.0
	
	for slot in inventory_slots:
		if not slot.is_empty() and slot.item_definition.is_tool:
			if slot.item_definition.can_perform_action("water"):
				var efficiency = slot.item_definition.get_tool_efficiency_for_action("water")
				
				# Check tool availability
				var available = false
				if slot.item_definition.item_id == "bucket" and slot.get_state() == "full":
					available = true
				elif slot.item_definition.item_id == "watering_can" and slot.durability > 0:
					available = true
				
				if available and efficiency > best_efficiency:
					best_tool = slot
					best_efficiency = efficiency
	
	return best_tool

# === SIGNAL HANDLERS ===

func _on_slot_changed(slot_index: int):
	"""Handle slot content changes"""
	inventory_changed.emit(slot_index)

func _on_item_state_changed(_slot_index: int, _old_state: String, _new_state: String):
	"""Handle item state changes"""
	# Item state changed, UI will update automatically via signals

# === RESOURCE INTEGRATION ===

func convert_items_to_resources():
	"""Convert certain items to basic resources (berries → food)"""
	# This can be called when items should be converted to the basic resource system
	# For example, harvested berries could be converted to "food" resource
	pass


