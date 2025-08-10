# PlayerMovement Component
# Handles player movement, physics, and basic animation
extends "res://components/player_component.gd"

# Movement properties
@export var speed: float = 5.0
@export var acceleration: float = 20.0
@export var friction: float = 15.0

# Internal state
var movement_enabled: bool = true
var animation_enabled: bool = true
var character_model: Node3D = null
var animation_player: AnimationPlayer = null
var current_velocity: Vector3 = Vector3.ZERO

# Reference to the character body (controller)
var character_body: CharacterBody3D = null

func _on_initialize():
	"""Initialize movement component with controller reference"""
	if not player_controller:
		emit_error("PlayerMovement: No controller provided")
		return
	
	# Get character body reference
	character_body = player_controller as CharacterBody3D
	if not character_body:
		emit_error("PlayerMovement: Controller is not a CharacterBody3D")
		return
	
	# Sync movement properties from controller
	if player_controller.has_method("get") or "speed" in player_controller:
		speed = player_controller.speed
		acceleration = player_controller.acceleration 
		friction = player_controller.friction
	
	# Find character model and animation player
	find_character_model()
	find_animation_player()
	
	print("PlayerMovement: Initialized for player ", get_player_id())

func _on_cleanup():
	"""Clean up movement component"""
	character_model = null
	animation_player = null
	character_body = null
	current_velocity = Vector3.ZERO

func find_character_model():
	"""Find the character model in the controller hierarchy"""
	if character_body:
		character_model = character_body.get_node_or_null("character-female-a2")
		if not character_model:
			# Try alternative character model names
			for child in character_body.get_children():
				if child.name.begins_with("character"):
					character_model = child
					break
	
	if character_model:
		print("PlayerMovement: Found character model: ", character_model.name)
	else:
		print("PlayerMovement: No character model found")

func find_animation_player():
	"""Find the animation player in the character model hierarchy"""
	if character_model:
		animation_player = find_node_by_type(character_model, AnimationPlayer) as AnimationPlayer
		if animation_player:
			print("PlayerMovement: Found AnimationPlayer with animations: ", animation_player.get_animation_list())
		else:
			print("PlayerMovement: No AnimationPlayer found in character model")

func find_node_by_type(node: Node, node_type) -> Node:
	"""Recursively search for a node of specific type"""
	if node is AnimationPlayer:
		return node
	
	for child in node.get_children():
		var result = find_node_by_type(child, node_type)
		if result:
			return result
	
	return null

# Movement Interface Implementation

func handle_movement(input_dir: Vector2, delta: float) -> void:
	"""Handle player movement based on input direction"""
	if not movement_enabled or not character_body:
		return
	
	if input_dir != Vector2.ZERO:
		# Accelerate towards target velocity
		var target_velocity = Vector3(input_dir.x * speed, 0, input_dir.y * speed)
		current_velocity = current_velocity.move_toward(target_velocity, acceleration * delta)
		
		# Rotate character model to face movement direction
		rotate_character_to_direction(input_dir, delta)
		
		# Trigger walking animation
		update_animation(current_velocity)
		
		# Signal movement started (for stopping gathering, etc.)
		if input_dir.length() > 0.1:
			movement_started.emit()
	else:
		# Apply friction when no input
		current_velocity = current_velocity.move_toward(Vector3.ZERO, friction * delta)
		
		# Trigger idle animation when stopped
		if current_velocity.length() < 0.1:
			update_animation(Vector3.ZERO)
			movement_stopped.emit()
	
	# Apply velocity to character body
	character_body.velocity = current_velocity
	character_body.move_and_slide()

func update_animation(velocity: Vector3) -> void:
	"""Update character animation based on velocity"""
	if not animation_player or not animation_enabled:
		return
	
	var new_animation = "idle"
	if velocity.length() > 0.1:
		new_animation = "walk"
		play_animation("walk")
	else:
		play_animation("idle")
	
	# Emit animation change signal
	animation_changed.emit(new_animation)

func play_animation(anim_name: String) -> void:
	"""Play specific animation if available"""
	if not animation_player or not animation_enabled:
		return
	
	# Try common animation names based on the requested type
	var animation_names = []
	match anim_name:
		"walk":
			animation_names = ["walk", "walking", "run", "running", "move", "moving"]
		"idle":
			animation_names = ["idle", "stand", "standing", "rest"]
		"gather":
			animation_names = ["attack_melee_left", "gather", "gathering", "chop", "chopping", "work", "working", "action"]
		"death", "die":
			animation_names = ["death", "die", "dying", "dead", "fall", "collapse"]
	
	# Try to find and play a matching animation
	var available_animations = animation_player.get_animation_list()
	for candidate in animation_names:
		if candidate in available_animations:
			if animation_player.current_animation != candidate:
				animation_player.play(candidate)
			return
	
	# If no specific animation found, log available animations for debugging
	if available_animations.size() > 0:
		print("PlayerMovement: Available animations: ", available_animations)

func play_death_animation() -> void:
	"""Play death animation when player dies"""
	if not animation_player:
		print("PlayerMovement: Cannot play death animation - no AnimationPlayer found")
		return
	
	print("PlayerMovement: Playing death animation for player ", get_player_id())
	
	# Disable automatic animation updates to prevent idle animation from overriding death
	animation_enabled = false
	
	# Force play the death animation (bypass animation_enabled check)
	var death_animation_names = ["death", "die", "dying", "dead", "fall", "collapse"]
	var available_animations = animation_player.get_animation_list()
	
	for candidate in death_animation_names:
		if candidate in available_animations:
			animation_player.play(candidate)
			print("PlayerMovement: Playing death animation: ", candidate)
			break
	
	# Stop movement immediately
	current_velocity = Vector3.ZERO
	if character_body:
		character_body.velocity = Vector3.ZERO

func rotate_character_to_direction(input_dir: Vector2, delta: float) -> void:
	"""Rotate character model to face movement direction"""
	if character_model and input_dir.length() > 0.1:
		var look_direction = Vector3(input_dir.x, 0, input_dir.y).normalized()
		var target_rotation = atan2(look_direction.x, look_direction.z)
		character_model.rotation.y = lerp_angle(character_model.rotation.y, target_rotation, 10.0 * delta)

func get_current_velocity() -> Vector3:
	"""Get the current movement velocity"""
	return current_velocity

func set_movement_enabled(enabled: bool) -> void:
	"""Enable or disable movement processing"""
	movement_enabled = enabled
	if not enabled:
		current_velocity = Vector3.ZERO
		if character_body:
			character_body.velocity = Vector3.ZERO
		# Note: Don't disable animations here - death animation needs to play

func set_animation_enabled(enabled: bool) -> void:
	"""Enable or disable automatic animation updates"""
	animation_enabled = enabled

# Signals for movement events
signal movement_started  # Emitted when player starts moving (for stopping gathering, etc.)
signal movement_stopped  # Emitted when player stops moving

# Animation signals for other components
signal animation_changed(animation_name: String)  # Emitted when animation changes
