class_name ResourceManager
extends Node

# Resource storage
var resources: Dictionary = {}
var max_capacities: Dictionary = {}

# Signals for reactive programming
signal resource_changed(resource_type: String, old_amount: int, new_amount: int)
signal resource_full(resource_type: String)
signal resource_empty(resource_type: String)

# Setup a new resource type with initial capacity and amount
func setup_resource_type(type: String, max_capacity: int, initial_amount: int = 0):
	max_capacities[type] = max_capacity
	resources[type] = clamp(initial_amount, 0, max_capacity)
	print("ResourceManager: Set up resource type '", type, "' with capacity ", max_capacity, " and initial amount ", resources[type])

# Add resources, returns the amount actually added
func add_resource(type: String, amount: int) -> int:
	if not resources.has(type):
		print("ResourceManager: Warning - trying to add unknown resource type '", type, "'")
		return 0
	
	var old_amount = resources[type]
	var max_capacity = max_capacities[type]
	var available_space = max_capacity - old_amount
	var amount_to_add = min(amount, available_space)
	
	resources[type] += amount_to_add
	
	# Emit signals
	if amount_to_add > 0:
		resource_changed.emit(type, old_amount, resources[type])
		print("ResourceManager: Added ", amount_to_add, " ", type, " (", resources[type], "/", max_capacity, ")")
	
	if resources[type] >= max_capacity:
		resource_full.emit(type)
	
	return amount_to_add

# Remove resources, returns the amount actually removed
func remove_resource(type: String, amount: int) -> int:
	if not resources.has(type):
		print("ResourceManager: Warning - trying to remove unknown resource type '", type, "'")
		return 0
	
	var old_amount = resources[type]
	var amount_to_remove = min(amount, old_amount)
	
	resources[type] -= amount_to_remove
	
	# Emit signals
	if amount_to_remove > 0:
		resource_changed.emit(type, old_amount, resources[type])
		print("ResourceManager: Removed ", amount_to_remove, " ", type, " (", resources[type], "/", max_capacities[type], ")")
	
	if resources[type] <= 0:
		resource_empty.emit(type)
	
	return amount_to_remove

# Get current amount of a resource
func get_resource_amount(type: String) -> int:
	if not resources.has(type):
		return 0
	return resources[type]

# Get available space for a resource
func get_available_space(type: String) -> int:
	if not resources.has(type):
		return 0
	return max_capacities[type] - resources[type]

# Check if a resource is at maximum capacity
func is_resource_full(type: String) -> bool:
	if not resources.has(type):
		return false
	return resources[type] >= max_capacities[type]

# Check if a resource is empty
func is_resource_empty(type: String) -> bool:
	if not resources.has(type):
		return true
	return resources[type] <= 0

# Get resource as percentage of capacity (0.0 to 1.0)
func get_resource_percentage(type: String) -> float:
	if not resources.has(type) or max_capacities[type] <= 0:
		return 0.0
	return float(resources[type]) / float(max_capacities[type])

# Get all resource types
func get_all_resource_types() -> Array[String]:
	var types: Array[String] = []
	for type in resources.keys():
		types.append(type)
	return types

# Debug method to print all resources
func debug_print_resources():
	print("ResourceManager - Current Resources:")
	for type in resources.keys():
		print("  ", type, ": ", resources[type], "/", max_capacities[type], " (", int(get_resource_percentage(type) * 100), "%)")
