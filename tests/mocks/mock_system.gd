# Mock System for Player Component Testing
# Provides mock objects for testing components in isolation

extends Node
class_name MockSystem

# Mock ResourceManager for testing
static func create_mock_resource_manager():
	var mock = Node.new()
	mock.set_script(load("res://tests/mocks/mock_resource_manager.gd"))
	return mock

# Mock Input for testing input systems
static func create_mock_input():
	var mock = Node.new()
	mock.set_script(load("res://tests/mocks/mock_input.gd"))
	return mock

# Mock Animation Player for testing animation systems
static func create_mock_animation_player():
	var mock = AnimationPlayer.new()
	mock.name = "AnimationPlayer"
	# Add some basic animation library
	var library = AnimationLibrary.new()
	var walk_anim = Animation.new()
	walk_anim.length = 1.0
	var idle_anim = Animation.new()
	idle_anim.length = 1.0
	library.add_animation("walk", walk_anim)
	library.add_animation("idle", idle_anim)
	mock.add_animation_library("default", library)
	return mock

# Mock CharacterBody3D for testing movement
static func create_mock_character_body():
	var mock = CharacterBody3D.new()
	mock.name = "MockPlayer"
	# Add a mock character model
	var character_model = Node3D.new()
	character_model.name = "character-female-a2"
	mock.add_child(character_model)
	return mock

# Mock UI System for testing UI interactions
static func create_mock_ui():
	var mock = Node.new()
	mock.set_script(load("res://tests/mocks/mock_ui.gd"))
	return mock

# Mock Scene Tree for testing scene operations
static func create_mock_scene_tree():
	var mock = Node.new()
	mock.set_script(load("res://tests/mocks/mock_scene_tree.gd"))
	return mock
