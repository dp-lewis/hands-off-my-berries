## Interactor component interface
## Defines the contract for player interaction components

class_name InteractorInterface

## Add a nearby object for potential interaction
func add_nearby_object(_obj: Node3D, _interaction_type: String) -> void:
	pass

## Remove a nearby object from interaction range
func remove_nearby_object(_obj: Node3D, _interaction_type: String) -> void:
	pass

## Interact with the nearest object of a given type
func interact_with_nearest(_interaction_type: String = "") -> void:
	pass

## Start gathering from a target object
func start_gathering(_target: Node3D) -> void:
	pass

## Enter a shelter
func enter_shelter(_shelter: Node3D) -> void:
	pass

## Exit current shelter
func exit_shelter() -> void:
	pass

## Check if player is currently interacting with something
func is_interacting() -> bool:
	return false

## Get the current interaction target
func get_current_interaction() -> Node3D:
	return null

## Get all nearby objects of a specific type
func get_nearby_objects(_interaction_type: String) -> Array:
	return []
