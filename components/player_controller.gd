class_name PlayerController
extends CharacterBody3D

## Main coordinator for all player components
## Replaces the monolithic player.gd script with clean component architecture

@export var player_id: int = 0

# Component references - will be populated automatically in _ready()
var movement # : PlayerComponent (using dynamic typing to avoid circular dependency)
var survival # : PlayerComponent  
var builder # : PlayerComponent
var interactor # : PlayerComponent
var input_handler # : PlayerComponent

# Component registry for dynamic access
var components: Dictionary = {}

# Component lifecycle signals
signal all_components_ready
signal component_failed(component_name: String, error: String)

func _ready():
	print("PlayerController initializing for Player ", player_id)
	
	# Add player to group for game systems to find
	add_to_group("players")
	
	setup_components()

## Find and initialize all player components
func setup_components():
	var component_count = 0
	var ready_count = 0
	
	# Find all PlayerComponent children
	for child in get_children():
		if child.get_script() and child.get_script().get_base_script() and child.get_script().get_base_script().resource_path.ends_with("player_component.gd"):
			component_count += 1
			
			# Register component by type
			var component_type = child.get_script().resource_path.get_file().get_basename()
			components[component_type] = child
			
			# Set up specific component references for easy access
			match component_type:
				"player_movement":
					movement = child
				"player_survival":
					survival = child
				"player_builder":
					builder = child
				"player_interactor":
					interactor = child
				"player_input_handler":
					input_handler = child
			
			# Connect component signals
			child.component_ready.connect(_on_component_ready.bind(child))
			child.component_error.connect(_on_component_error.bind(child))
			
			# Initialize the component
			child.initialize(self)
			ready_count += 1
	
	print("PlayerController: Initialized ", ready_count, "/", component_count, " components")
	
	if ready_count == component_count and component_count > 0:
		all_components_ready.emit()
		print("🎉 All components ready for Player ", player_id)

## Main physics process - coordinates all components
func _physics_process(delta):
	if not are_components_ready():
		return
	
	# Get input from input handler
	var input_dir = Vector2.ZERO
	if input_handler and input_handler.has_method("get_movement_input"):
		input_dir = input_handler.get_movement_input()
	
	# Process movement
	if movement and movement.has_method("handle_movement"):
		movement.handle_movement(input_dir, delta)
	
	# Process survival systems
	if survival and survival.has_method("process_survival"):
		survival.process_survival(delta)
	
	# Update builder ghost preview if in build mode
	if builder and builder.has_method("update_ghost_preview"):
		builder.update_ghost_preview()

## Handle discrete input actions
func _input(event):
	if not are_components_ready():
		return
	
	# Let input handler process the event first
	if input_handler and input_handler.has_method("process_input_event"):
		input_handler.process_input_event(event)
	
	# Handle interaction input
	if input_handler and input_handler.has_method("is_action_just_pressed"):
		if input_handler.is_action_just_pressed("interact"):
			if interactor and interactor.has_method("interact_with_nearest"):
				interactor.interact_with_nearest()
		
		if input_handler.is_action_just_pressed("build"):
			if builder and builder.has_method("toggle_build_mode"):
				builder.toggle_build_mode()

## Get a specific component by type name
func get_component(component_type: String): # Returns PlayerComponent but using dynamic typing
	return components.get(component_type, null)

## Check if all components are ready
func are_components_ready() -> bool:
	for component in components.values():
		if not component.is_component_ready():
			return false
	return not components.is_empty()

## Get the current velocity from movement component
func get_current_velocity() -> Vector3:
	if movement and movement.has_method("get_current_velocity"):
		return movement.get_current_velocity()
	return velocity

## Set movement enabled/disabled (useful for cutscenes, menus, etc.)
func set_movement_enabled(enabled: bool) -> void:
	if movement and movement.has_method("set_movement_enabled"):
		movement.set_movement_enabled(enabled)

## Get current health from survival component
func get_health() -> float:
	if survival and survival.has_method("get_health"):
		return survival.get_health()
	return 0.0

## Get current hunger from survival component  
func get_hunger() -> float:
	if survival and survival.has_method("get_hunger"):
		return survival.get_hunger()
	return 0.0

## Get current tiredness from survival component
func get_tiredness() -> float:
	if survival and survival.has_method("get_tiredness"):
		return survival.get_tiredness()
	return 0.0

## Check if player is in build mode
func is_in_build_mode() -> bool:
	if builder and builder.has_method("is_in_build_mode"):
		return builder.is_in_build_mode()
	return false

## Check if player is currently interacting with something
func is_interacting() -> bool:
	if interactor and interactor.has_method("is_interacting"):
		return interactor.is_interacting()
	return false

## Component event handlers
func _on_component_ready(component): # PlayerComponent type removed for dynamic typing
	print("Component ready: ", component.get_script().resource_path.get_file())
	
	# Check if all components are now ready
	if are_components_ready():
		all_components_ready.emit()

func _on_component_error(component, error_message: String): # PlayerComponent type removed for dynamic typing
	var component_name = component.get_script().resource_path.get_file()
	print("Component error in ", component_name, ": ", error_message)
	component_failed.emit(component_name, error_message)

## Cleanup all components when player is destroyed
func _exit_tree():
	print("PlayerController cleanup for Player ", player_id)
	
	for component in components.values():
		if component and component.has_method("cleanup"):
			component.cleanup()
	
	components.clear()

## Debug function to print component status
func debug_print_components():
	print("=== Player ", player_id, " Components ===")
	for type_name in components:
		var component = components[type_name]
		var status = "READY" if component.is_component_ready() else "NOT READY"
		print("  ", type_name, ": ", status)
	print("=============================")
