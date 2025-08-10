class_name PlayerComponent
extends Node

## Base class for all player components
## Provides common functionality and interface for component coordination

# Reference to the PlayerController that owns this component
var player_controller # : PlayerController (using dynamic typing to avoid circular dependency)
var is_initialized: bool = false

# Common signals for component lifecycle
signal component_ready
signal component_error(message: String)

## Initialize the component with its controller
## This is called by PlayerController when setting up components
func initialize(controller) -> void: # PlayerController type removed to avoid circular dependency
	if not controller:
		emit_error("Cannot initialize component: controller is null")
		return
	
	player_controller = controller
	is_initialized = true
	
	# Call component-specific initialization
	_on_initialize()
	
	# Emit ready signal after initialization
	component_ready.emit()
	
	print("PlayerComponent initialized: ", get_script().resource_path.get_file())

## Override this in derived components for specific initialization
func _on_initialize() -> void:
	# Override in derived classes
	pass

## Clean up the component and release resources
## Called when player is being destroyed or component is being removed
func cleanup() -> void:
	if is_initialized:
		_on_cleanup()
		player_controller = null
		is_initialized = false
		print("PlayerComponent cleaned up: ", get_script().resource_path.get_file())

## Override this in derived components for specific cleanup
func _on_cleanup() -> void:
	# Override in derived classes
	pass

## Emit an error signal with a descriptive message
func emit_error(message: String) -> void:
	print("Component Error [", get_script().resource_path.get_file(), "]: ", message)
	component_error.emit(message)

## Get the player ID from the controller
func get_player_id() -> int:
	if player_controller:
		return player_controller.player_id
	return -1

## Check if the component is properly initialized
func is_component_ready() -> bool:
	return is_initialized and player_controller != null

## Get a reference to another component on the same player
func get_sibling_component(component_type: String): # Returns PlayerComponent but using dynamic typing
	if not player_controller:
		emit_error("Cannot get sibling component: no controller reference")
		return null
	
	return player_controller.get_component(component_type)

## Safe way to emit signals only when component is ready
func safe_emit_signal(signal_name: String, args: Array = []) -> void:
	if not is_component_ready():
		emit_error("Cannot emit signal '" + signal_name + "': component not ready")
		return
	
	# Use call to dynamically emit the signal
	if has_signal(signal_name):
		match args.size():
			0: call("emit_signal", signal_name)
			1: call("emit_signal", signal_name, args[0])
			2: call("emit_signal", signal_name, args[0], args[1])
			3: call("emit_signal", signal_name, args[0], args[1], args[2])
			_: emit_error("Too many signal arguments (max 3)")
	else:
		emit_error("Signal '" + signal_name + "' does not exist")
