extends CharacterBody3D

@export var speed: float = 5.0
@export var acceleration: float = 20.0
@export var friction: float = 15.0
@export var player_id: int = 0

func _physics_process(delta):
	var input_dir = get_input_direction()
	
	if input_dir != Vector2.ZERO:
		# Accelerate towards target velocity
		var target_velocity = Vector3(input_dir.x * speed, 0, input_dir.y * speed)
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
	else:
		# Apply friction when no input
		velocity = velocity.move_toward(Vector3.ZERO, friction * delta)
	
	move_and_slide()

func get_input_direction() -> Vector2:
	match player_id:
		0: return Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		1: return Input.get_vector("p2_left", "p2_right", "p2_up", "p2_down")
		2: return Input.get_vector("p3_left", "p3_right", "p3_up", "p3_down")
		3: return Input.get_vector("p4_left", "p4_right", "p4_up", "p4_down")
	return Vector2.ZERO
