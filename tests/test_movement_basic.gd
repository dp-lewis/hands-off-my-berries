# Simple Movement Component Test
extends Node

func test_assert(condition: bool, message: String):
	if condition:
		print("✓ ", message)
	else:
		print("✗ FAILED: ", message)
		push_error("Test failed: " + message)

func _ready():
	print("=== BASIC MOVEMENT TEST ===")
	
	# Test 1: Component creation
	var movement_script = load("res://components/player_movement.gd")
	test_assert(movement_script != null, "PlayerMovement script loads successfully")
	
	var movement = movement_script.new()
	test_assert(movement != null, "PlayerMovement instance created")
	
	# Test 2: Basic properties
	test_assert(movement.speed > 0, "Movement has default speed")
	test_assert(movement.acceleration > 0, "Movement has default acceleration")
	test_assert(movement.friction > 0, "Movement has default friction")
	test_assert(movement.get_current_velocity() == Vector3.ZERO, "Initial velocity is zero")
	
	# Test 3: Movement enabled/disabled
	movement.set_movement_enabled(false)
	test_assert(movement.movement_enabled == false, "Movement can be disabled")
	test_assert(movement.get_current_velocity() == Vector3.ZERO, "Velocity reset when disabled")
	
	movement.set_movement_enabled(true)
	test_assert(movement.movement_enabled == true, "Movement can be enabled")
	
	# Clean up
	movement.queue_free()
	
	print("=== BASIC MOVEMENT TEST COMPLETE ===")
	get_tree().quit()
