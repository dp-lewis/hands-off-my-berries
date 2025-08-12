# Enhanced PlayerController with Movement Component Integration
# This is a transitional version that integrates PlayerMovement component
# while maintaining compatibility with existing systems

extends CharacterBody3D

@export var player_id: int = 0

# Original player properties (will be moved to components)
var nearby_tree: Node3D = null
var nearby_tent: Node3D = null
var nearby_shelter: Node3D = null  
var nearby_pumpkin: Node3D = null  
var is_gathering: bool = false
var is_building: bool = false
var is_in_shelter: bool = false
var current_shelter: Node3D = null
var is_in_build_mode: bool = false
var tent_ghost: Node3D = null
@export var tent_scene: PackedScene = preload("res://scenes/buildables/tent.tscn")

# Character model reference
@onready var character_model: Node3D = $"character-female-a2"
@onready var animation_player: AnimationPlayer

# Simple UI reference
var player_ui: Control = null
@export var player_ui_scene: PackedScene = preload("res://ui/player_ui.tscn")

# Resource Management System
@onready var resource_manager: ResourceManager = $ResourceManager
var resource_config: ResourceConfig

# Survival variables (will be moved to PlayerSurvival component)
var health: float = 100.0
var max_health: float = 100.0
var hunger: float = 100.0  
var max_hunger: float = 100.0
var tiredness: float = 100.0  
var max_tiredness: float = 100.0
var is_night_time: bool = false

# Survival configuration
@export var hunger_decrease_rate: float = 2.0  
@export var health_decrease_rate: float = 5.0  
@export var auto_eat_threshold: float = 30.0  
@export var pumpkin_hunger_restore: float = 25.0  

# COMPONENT REFERENCES
@onready var movement_component: Node = null

func _ready():
	print("Enhanced PlayerController starting for player ", player_id)
	
	# Setup components
	setup_components()
	
	# Initialize resource manager
	resource_config = ResourceConfig.new()
	if resource_manager:
		resource_manager.initialize(resource_config)
	
	# Create UI
	create_player_ui()

func setup_components():
	"""Initialize component system"""
	# Find movement component
	movement_component = get_node_or_null("PlayerMovement")
	if movement_component:
		print("Found PlayerMovement component")
		# Initialize the component (will be done by component system later)
		if movement_component.has_method("initialize"):
			movement_component.initialize(self)
			# Connect movement signals
			if movement_component.has_signal("movement_started"):
				movement_component.movement_started.connect(_on_movement_started)
	else:
		print("No PlayerMovement component found - using legacy movement")

func _physics_process(delta):
	var input_dir = get_input_direction()
	
	# Initialize animation player if not done yet
	if not animation_player:
		find_animation_player()
	
	# Handle movement - use component if available, otherwise legacy
	if movement_component and movement_component.has_method("handle_movement"):
		movement_component.handle_movement(input_dir, delta)
	else:
		# Legacy movement handling
		handle_movement_legacy(input_dir, delta)
	
	# Handle building mode toggle
	handle_build_mode_input()
	
	# Handle interaction input
	handle_interaction_input()
	
	# Update ghost position if in build mode
	if is_in_build_mode and tent_ghost:
		update_ghost_position()
	
	# Handle hunger and health system
	handle_hunger_system(delta)
	
	# Handle tiredness system
	handle_tiredness_system(delta)

func _on_movement_started():
	"""Called when movement component detects player started moving"""
	# If player moves while gathering, stop gathering (building continues in background)
	if is_gathering:
		stop_gathering()

# Legacy movement code (kept for fallback)
func handle_movement_legacy(input_dir: Vector2, delta: float):
	if input_dir != Vector2.ZERO:
		# Accelerate towards target velocity
		var speed = 5.0
		var acceleration = 20.0
		var target_velocity = Vector3(input_dir.x * speed, 0, input_dir.y * speed)
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
		
		# Rotate character model to face movement direction
		if character_model and target_velocity.length() > 0.1:
			var look_direction = Vector3(input_dir.x, 0, input_dir.y).normalized()
			var target_rotation = atan2(look_direction.x, look_direction.z)
			character_model.rotation.y = lerp_angle(character_model.rotation.y, target_rotation, 10.0 * delta)
		
		# Play walking animation
		play_animation("walk")
		
		# If player moves while gathering, stop gathering
		if is_gathering and input_dir.length() > 0.1:
			stop_gathering()
	else:
		# Apply friction when no input
		var friction = 15.0
		velocity = velocity.move_toward(Vector3.ZERO, friction * delta)
		
		# Play idle animation when not moving
		if velocity.length() < 0.1:
			play_animation("idle")
	
	move_and_slide()

# Continue with all the original functions... 
# (This is a transitional version - we'll gradually replace more functions with components)

func find_animation_player():
	# Search for AnimationPlayer in the character model hierarchy
	if character_model:
		animation_player = find_node_by_type(character_model, null) as AnimationPlayer
		if animation_player:
			print("Found AnimationPlayer with animations: ", animation_player.get_animation_list())
		else:
			print("No AnimationPlayer found in character model")

func find_node_by_type(node: Node, node_type) -> Node:
	# Check if this node is an AnimationPlayer
	if node is AnimationPlayer:
		return node
	
	# Recursively search children
	for child in node.get_children():
		var result = find_node_by_type(child, node_type)
		if result:
			return result
	
	return null

func play_animation(anim_name: String):
	if not animation_player:
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
	
	# Try to find and play a matching animation
	var available_animations = animation_player.get_animation_list()
	for candidate in animation_names:
		if candidate in available_animations:
			if animation_player.current_animation != candidate:
				animation_player.play(candidate)
			return
	
	# If no specific animation found, try to play anything that might work
	if available_animations.size() > 0:
		print("Available animations: ", available_animations)

func get_input_direction() -> Vector2:
	match player_id:
		0: return Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		1: return Input.get_vector("p2_left", "p2_right", "p2_up", "p2_down")
		2: return Input.get_vector("p3_left", "p3_right", "p3_up", "p3_down")
		3: return Input.get_vector("p4_left", "p4_right", "p4_up", "p4_down")
	return Vector2.ZERO

# All the remaining functions from the original player.gd...
# (For now, we'll keep all the original survival, building, and interaction code)
# This is just a demonstration of how the movement component integration would work

# Placeholder functions (would include all the original functions)
func handle_build_mode_input():
	pass

func handle_interaction_input():
	pass

func update_ghost_position():
	pass

func handle_hunger_system(delta: float):
	pass

func handle_tiredness_system(delta: float):
	pass

func stop_gathering():
	pass

func create_player_ui():
	pass
