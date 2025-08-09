extends CharacterBody3D

@export var speed: float = 5.0
@export var acceleration: float = 20.0
@export var friction: float = 15.0
@export var player_id: int = 0

# Resource and interaction variables
var wood: int = 0
var nearby_tree: Node3D = null
var is_gathering: bool = false

func _physics_process(delta):
	var input_dir = get_input_direction()
	
	# Handle movement (always works, even while gathering)
	handle_movement(input_dir, delta)
	
	# Handle interaction input
	handle_interaction_input()

func handle_movement(input_dir: Vector2, delta: float):
	if input_dir != Vector2.ZERO:
		# Accelerate towards target velocity
		var target_velocity = Vector3(input_dir.x * speed, 0, input_dir.y * speed)
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
		
		# If player moves while gathering, stop gathering
		if is_gathering and input_dir.length() > 0.1:
			stop_gathering()
	else:
		# Apply friction when no input
		velocity = velocity.move_toward(Vector3.ZERO, friction * delta)
	
	move_and_slide()

func handle_interaction_input():
	var action_key = get_action_key()
	
	if Input.is_action_pressed(action_key):
		# Try to start or continue gathering
		if nearby_tree and not is_gathering:
			start_gathering_tree()
	else:
		# Stop gathering if action key is released
		if is_gathering:
			stop_gathering()

func get_input_direction() -> Vector2:
	match player_id:
		0: return Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		1: return Input.get_vector("p2_left", "p2_right", "p2_up", "p2_down")
		2: return Input.get_vector("p3_left", "p3_right", "p3_up", "p3_down")
		3: return Input.get_vector("p4_left", "p4_right", "p4_up", "p4_down")
	return Vector2.ZERO

func get_action_key() -> String:
	match player_id:
		0: return "ui_accept"  # Space/Enter for keyboard player
		1: return "p2_action"
		2: return "p3_action"
		3: return "p4_action"
	return "ui_accept"

# Tree interaction methods
func set_nearby_tree(tree: Node3D):
	nearby_tree = tree
	print("Player ", player_id, " near tree")

func clear_nearby_tree(tree: Node3D):
	if nearby_tree == tree:
		nearby_tree = null
		if is_gathering:
			stop_gathering()
		print("Player ", player_id, " left tree area")

func start_gathering_tree():
	if nearby_tree and nearby_tree.has_method("start_gathering"):
		if nearby_tree.start_gathering(self):
			is_gathering = true
			print("Player ", player_id, " started gathering")

func stop_gathering():
	if is_gathering and nearby_tree:
		nearby_tree.stop_gathering()
		is_gathering = false
		print("Player ", player_id, " stopped gathering")

func add_wood(amount: int):
	wood += amount
	print("Player ", player_id, " now has ", wood, " wood")
