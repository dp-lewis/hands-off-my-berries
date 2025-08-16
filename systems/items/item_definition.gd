class_name ItemDefinition
extends Resource

## Defines the properties and behavior of an item type
## Used by the inventory system to create and manage items

# Basic item properties
@export var item_id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var icon_texture: Texture2D
@export var item_type: String = "resource"  # "tool", "consumable", "resource", "misc"

# Stack and quantity properties
@export var max_stack_size: int = 1
@export var is_stackable: bool = false

# Tool-specific properties
@export var is_tool: bool = false
@export var has_durability: bool = false
@export var max_durability: int = 100
@export var tool_efficiency: float = 1.0
@export var tool_actions: Array[String] = []  # ["water", "dig", "chop", "harvest"]

# State management for complex items
@export var has_states: bool = false
@export var possible_states: Array[String] = ["normal"]  # ["empty", "full"] for bucket
@export var default_state: String = "normal"

# Usage properties
@export var is_consumable: bool = false
@export var consume_on_use: bool = false
@export var use_sound: AudioStream
@export var use_animation: String = ""

# Validation method
func is_valid() -> bool:
	"""Check if this item definition is properly configured"""
	if item_id.is_empty():
		print("ItemDefinition: item_id cannot be empty")
		return false
	
	if display_name.is_empty():
		print("ItemDefinition: display_name cannot be empty")
		return false
	
	if max_stack_size < 1:
		print("ItemDefinition: max_stack_size must be at least 1")
		return false
	
	if has_states and possible_states.is_empty():
		print("ItemDefinition: has_states is true but possible_states is empty")
		return false
	
	if has_states and not default_state in possible_states:
		print("ItemDefinition: default_state '", default_state, "' not in possible_states")
		return false
	
	return true

# Get a display name that includes state if applicable
func get_display_name_with_state(current_state: String = "") -> String:
	var name = display_name
	
	if has_states and current_state != "" and current_state != default_state:
		name += " (" + current_state.capitalize() + ")"
	
	return name

# Check if this item can be used as a tool for a specific action
func can_perform_action(action: String) -> bool:
	return is_tool and tool_actions.has(action)

# Get tool efficiency for a specific action
func get_tool_efficiency_for_action(action: String) -> float:
	if can_perform_action(action):
		return tool_efficiency
	return 0.0
