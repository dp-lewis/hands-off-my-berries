## Builder component interface
## Defines the contract for player building components

class_name BuilderInterface

## Toggle build mode on/off
func toggle_build_mode() -> void:
	pass

## Update ghost preview position and state
func update_ghost_preview() -> void:
	pass

## Attempt to place a building
func place_building() -> bool:
	return false

## Check if player can afford a building type
func can_afford_building(_building_type: String) -> bool:
	return false

## Cancel current building operation
func cancel_building() -> void:
	pass

## Check if player is currently in build mode
func is_in_build_mode() -> bool:
	return false

## Get available building types
func get_available_buildings() -> Array:
	return []

## Set the building type to construct
func set_building_type(_building_type: String) -> void:
	pass
