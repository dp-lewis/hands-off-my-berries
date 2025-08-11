# PlayerInputHandler Component
# Handles multi-player input mapping and device-specific controls
extends "res://components/player_component.gd"
class_name PlayerInputHandler

# Signals for input events
signal movement_input(direction: Vector2)
signal action_pressed
signal action_released
signal build_mode_toggled

# Input configuration for different player IDs
var player_id: int = 0

# Input action mappings for each player
var movement_actions: Dictionary = {}
var action_keys: Dictionary = {}
var build_keys: Dictionary = {}

func _on_initialize() -> void:
	# Get player ID from controller
	if player_controller and player_controller.has_method("get") and "player_id" in player_controller:
		player_id = player_controller.player_id
	else:
		emit_error("PlayerInputHandler: Could not get player_id from controller")
		return
	
	# Initialize input mappings
	setup_input_mappings()
	
	print("PlayerInputHandler initialized for player ", player_id)

func _on_cleanup() -> void:
	# Clear input mappings
	movement_actions.clear()
	action_keys.clear()
	build_keys.clear()

func setup_input_mappings():
	"""Setup input action mappings for all players"""
	
	# Movement mappings
	movement_actions = {
		0: {
			"left": "p1_left",
			"right": "p1_right", 
			"up": "p1_up",
			"down": "p1_down"
		},
		1: {
			"left": "p2_left",
			"right": "p2_right",
			"up": "p2_up", 
			"down": "p2_down"
		},
		2: {
			"left": "p3_left",
			"right": "p3_right",
			"up": "p3_up",
			"down": "p3_down"
		},
		3: {
			"left": "p4_left",
			"right": "p4_right", 
			"up": "p4_up",
			"down": "p4_down"
		}
	}
	
	# Action key mappings
	action_keys = {
		0: "p1_action",  # Space/Enter for keyboard player
		1: "p2_action",
		2: "p3_action", 
		3: "p4_action"
	}
	
	# Build key mappings
	build_keys = {
		0: "p1_build",  # Tab for keyboard player
		1: "p2_build",
		2: "p3_build",
		3: "p4_build"
	}

func _process(_delta: float) -> void:
	if not is_initialized:
		return
	
	# Handle movement input
	var movement_dir = get_input_direction()
	if movement_dir != Vector2.ZERO:
		movement_input.emit(movement_dir)
	
	# Handle action input
	var action_key = get_action_key()
	if Input.is_action_just_pressed(action_key):
		action_pressed.emit()
	elif Input.is_action_just_released(action_key):
		action_released.emit()
	
	# Handle build mode input
	var build_key = get_build_key()
	if Input.is_action_just_pressed(build_key):
		build_mode_toggled.emit()

func get_input_direction() -> Vector2:
	"""Get movement input direction for this player"""
	if player_id not in movement_actions:
		return Vector2.ZERO
	
	var actions = movement_actions[player_id]
	return Input.get_vector(
		actions["left"],
		actions["right"], 
		actions["up"],
		actions["down"]
	)

func get_action_key() -> String:
	"""Get action key for this player"""
	if player_id in action_keys:
		return action_keys[player_id]
	return "ui_accept"  # Fallback

func get_build_key() -> String:
	"""Get build mode key for this player"""
	if player_id in build_keys:
		return build_keys[player_id]
	return "ui_select"  # Fallback

# Manual input checking methods (for external polling)
func is_action_pressed() -> bool:
	"""Check if action key is currently pressed"""
	return Input.is_action_pressed(get_action_key())

func is_action_just_pressed() -> bool:
	"""Check if action key was just pressed this frame"""
	return Input.is_action_just_pressed(get_action_key())

func is_action_just_released() -> bool:
	"""Check if action key was just released this frame"""
	return Input.is_action_just_released(get_action_key())

func is_build_mode_just_pressed() -> bool:
	"""Check if build mode key was just pressed this frame"""
	return Input.is_action_just_pressed(get_build_key())

# Input mapping configuration methods
func set_player_id(new_player_id: int) -> void:
	"""Change the player ID and update input mappings"""
	player_id = new_player_id
	setup_input_mappings()
	print("PlayerInputHandler: Updated to player ", player_id)

func get_player_id() -> int:
	"""Get the current player ID"""
	return player_id

func add_custom_mapping(player_id_target: int, input_type: String, action_name: String) -> void:
	"""Add custom input mapping for specific player"""
	match input_type:
		"action":
			action_keys[player_id_target] = action_name
		"build":
			build_keys[player_id_target] = action_name
		_:
			emit_error("Unknown input type: " + input_type)

func get_all_mapped_actions() -> Dictionary:
	"""Get all input mappings for debugging/configuration"""
	return {
		"movement": movement_actions,
		"action": action_keys,
		"build": build_keys
	}

func is_input_available() -> bool:
	"""Check if input system is properly configured"""
	return player_id in movement_actions and player_id in action_keys and player_id in build_keys

# Device detection and management
func get_input_device_type() -> String:
	"""Detect the type of input device being used"""
	match player_id:
		0:
			return "keyboard"  # Player 0 typically uses keyboard
		1, 2, 3:
			return "gamepad"   # Players 1-3 use gamepads
		_:
			return "unknown"

func validate_input_configuration() -> bool:
	"""Validate that all required input actions exist in the input map"""
	var required_actions = []
	
	# Add movement actions for this player
	if player_id in movement_actions:
		var actions = movement_actions[player_id]
		required_actions.append_array([actions["left"], actions["right"], actions["up"], actions["down"]])
	
	# Add action and build keys
	required_actions.append(get_action_key())
	required_actions.append(get_build_key())
	
	# Check if all actions exist in InputMap
	for action in required_actions:
		if not InputMap.has_action(action):
			emit_error("Missing input action: " + action)
			return false
	
	return true

# Input state tracking for complex interactions
var input_state: Dictionary = {
	"movement_active": false,
	"action_held": false,
	"build_mode_active": false
}

func update_input_state() -> void:
	"""Update internal input state tracking"""
	var movement_dir = get_input_direction()
	input_state["movement_active"] = movement_dir.length() > 0.1
	input_state["action_held"] = is_action_pressed()
	# Note: build_mode_active is managed by the builder component

func get_input_state() -> Dictionary:
	"""Get current input state for external components"""
	update_input_state()
	return input_state.duplicate()

func is_movement_active() -> bool:
	"""Check if player is currently providing movement input"""
	return get_input_direction().length() > 0.1
