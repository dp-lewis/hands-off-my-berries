## Mock system for testing player components
## Provides mock objects to enable isolated component testing

class_name MockSystem

## Mock ResourceManager for testing components that need resource access
class MockResourceManager:
	var resources = {"wood": 10, "food": 5}
	signal resource_changed(resource_type: String, old_amount: int, new_amount: int)
	signal resource_full(resource_type: String)
	signal resource_empty(resource_type: String)
	
	func add_resource(type: String, amount: int) -> int:
		var old_amount = resources.get(type, 0)
		resources[type] = old_amount + amount
		resource_changed.emit(type, old_amount, resources[type])
		return amount
	
	func remove_resource(type: String, amount: int) -> int:
		var available = resources.get(type, 0)
		var removed = min(amount, available)
		resources[type] -= removed
		resource_changed.emit(type, resources[type] + removed, resources[type])
		return removed
	
	func get_resource(type: String) -> int:
		return resources.get(type, 0)
	
	func has_resource(type: String, amount: int) -> bool:
		return resources.get(type, 0) >= amount

## Mock Input System for testing input components
class MockInput:
	var action_states = {}
	var analog_inputs = {}
	
	func set_action_state(action: String, pressed: bool):
		action_states[action] = pressed
	
	func set_analog_input(input: String, value: Vector2):
		analog_inputs[input] = value
	
	func is_action_pressed(action: String) -> bool:
		return action_states.get(action, false)
	
	func is_action_just_pressed(action: String) -> bool:
		# Simplified - in real implementation would track frame state
		return action_states.get(action, false)
	
	func get_vector(negative_x: String, positive_x: String, negative_y: String, positive_y: String) -> Vector2:
		var x = 0.0
		var y = 0.0
		
		if action_states.get(negative_x, false):
			x -= 1.0
		if action_states.get(positive_x, false):
			x += 1.0
		if action_states.get(negative_y, false):
			y -= 1.0
		if action_states.get(positive_y, false):
			y += 1.0
		
		return Vector2(x, y)

## Mock AnimationPlayer for testing movement components
class MockAnimationPlayer:
	var current_animation: String = ""
	var animation_playing: bool = false
	
	func play(anim_name: String):
		current_animation = anim_name
		animation_playing = true
	
	func stop():
		animation_playing = false
	
	func is_playing() -> bool:
		return animation_playing

## Mock CharacterBody3D for testing movement
class MockCharacterBody3D:
	var velocity: Vector3 = Vector3.ZERO
	var position: Vector3 = Vector3.ZERO
	var rotation: Vector3 = Vector3.ZERO
	
	func move_and_slide() -> bool:
		position += velocity * (1.0/60.0)  # Assume 60 FPS
		return true

## Mock interaction objects for testing interactor components
class MockTree:
	var position: Vector3 = Vector3.ZERO
	var interaction_type: String = "gathering"
	var wood_yield: int = 5
	
	func get_interaction_type() -> String:
		return interaction_type

class MockTent:
	var position: Vector3 = Vector3.ZERO
	var interaction_type: String = "shelter"
	
	func get_interaction_type() -> String:
		return interaction_type

class MockPumpkin:
	var position: Vector3 = Vector3.ZERO
	var interaction_type: String = "gathering"
	var food_yield: int = 3
	
	func get_interaction_type() -> String:
		return interaction_type

## Mock Scene Tree for testing building components
class MockSceneTree:
	var instantiated_scenes = []
	
	func instantiate_scene(scene_path: String) -> Node3D:
		var node = Node3D.new()
		node.name = scene_path.get_file().get_basename()
		instantiated_scenes.append(node)
		return node
	
	func add_child_to_scene(node: Node3D):
		# Simulate adding to scene
		pass

## Mock collision detection for testing building placement
class MockCollisionDetector:
	var has_collision: bool = false
	var collision_objects = []
	
	func check_collision(position: Vector3, size: Vector3) -> bool:
		return has_collision
	
	func set_collision_at(position: Vector3, has_collision: bool):
		self.has_collision = has_collision
	
	func add_collision_object(obj):
		collision_objects.append(obj)

## Helper function to create a fully mocked player controller for testing
static func create_mock_player_controller(player_id: int = 0):
	var controller_script = load("res://components/player_controller.gd")
	if not controller_script:
		print("Error: Could not load PlayerController script")
		return null
	
	var controller = controller_script.new()
	controller.player_id = player_id
	controller.name = "MockPlayerController"
	
	return controller

## Helper function to create a mock component for testing
static func create_mock_component():
	var component_script = load("res://components/player_component.gd")
	if not component_script:
		print("Error: Could not load PlayerComponent script")
		return null
	
	var component = component_script.new()
	component.name = "MockComponent"
	
	return component
