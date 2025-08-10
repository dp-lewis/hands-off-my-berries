## Movement component interface
## Defines the contract for player movement components

class_name MovementInterface

## Handle movement input and physics
func handle_movement(input_dir: Vector2, delta: float) -> void:
	pass

## Update character animation based on movement
func update_animation(velocity: Vector3) -> void:
	pass

## Get the current velocity vector
func get_current_velocity() -> Vector3:
	return Vector3.ZERO

## Enable or disable movement (useful for cutscenes, menus)
func set_movement_enabled(enabled: bool) -> void:
	pass

## Update character rotation to face movement direction
func update_character_rotation(movement_direction: Vector3) -> void:
	pass

## Set movement speed modifier (for effects like buffs/debuffs)
func set_speed_modifier(modifier: float) -> void:
	pass
