class_name ResourceConfig
extends Resource

# Current resource type capacities (matching existing game values)
@export var wood_max_capacity: int = 10
@export var food_max_capacity: int = 5

# Future expansion resource types
@export var stone_max_capacity: int = 8
@export var tools_max_capacity: int = 3

# Get maximum capacity for a specific resource type
func get_max_capacity(resource_type: String) -> int:
	match resource_type:
		"wood":
			return wood_max_capacity
		"food":
			return food_max_capacity
		"stone":
			return stone_max_capacity
		"tools":
			return tools_max_capacity
		_:
			print("ResourceConfig: Warning - unknown resource type '", resource_type, "'")
			return 0

# Get all available resource types
func get_all_resource_types() -> Array[String]:
	return ["wood", "food", "stone", "tools"]

# Get only currently active resource types (wood and food for now)
func get_active_resource_types() -> Array[String]:
	return ["wood", "food"]
