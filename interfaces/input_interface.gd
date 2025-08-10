## Input handler component interface
## Defines the contract for player input components

class_name InputInterface

## Get movement input as a Vector2
func get_movement_input() -> Vector2:
	return Vector2.ZERO

## Check if an action was just pressed this frame
func is_action_just_pressed(_action: String) -> bool:
	return false

## Check if an action is currently pressed
func is_action_pressed(_action: String) -> bool:
	return false

## Setup input mapping for a specific device
func setup_input_mapping(_device_id: int) -> bool:
	return false

## Process input events
func process_input_event(_event: InputEvent) -> void:
	pass

## Get the assigned device ID
func get_device_id() -> int:
	return -1

## Check if device is connected and available
func is_device_available() -> bool:
	return false

## Get all available input actions for this player
func get_available_actions() -> Array:
	return []
