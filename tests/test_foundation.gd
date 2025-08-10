extends SceneTree

## Simple foundation test for PlayerComponent and PlayerController
## Tests basic component setup and coordination

func _initialize():
	print("=== FOUNDATION TEST ===")
	print("Testing PlayerComponent and PlayerController foundation...\n")
	
	test_basic_component_creation()
	test_controller_setup()
	test_integration()
	
	print("\n=== FOUNDATION TEST COMPLETE ===")
	quit()

func test_basic_component_creation():
	print("--- Basic Component Creation ---")
	
	var component_script = load("res://components/player_component.gd")
	if component_script:
		var component = component_script.new()
		print("✓ PlayerComponent created successfully")
		
		# Test basic properties
		if not component.is_initialized:
			print("✓ Component starts uninitialized")
		
		if component.get_player_id() == -1:
			print("✓ Component returns -1 for player ID when no controller")
		
		component.free()
	else:
		print("❌ Could not load PlayerComponent script")

func test_controller_setup():
	print("\n--- Controller Setup ---")
	
	var controller_script = load("res://components/player_controller.gd")
	if controller_script:
		var controller = controller_script.new()
		controller.player_id = 1
		print("✓ PlayerController created successfully")
		
		# Test basic properties
		if controller.player_id == 1:
			print("✓ Player ID set correctly")
		
		# Test component registry
		if controller.components.is_empty():
			print("✓ Component registry starts empty")
		
		controller.free()
	else:
		print("❌ Could not load PlayerController script")

func test_integration():
	print("\n--- Basic Integration ---")
	
	var component_script = load("res://components/player_component.gd") 
	var controller_script = load("res://components/player_controller.gd")
	
	if component_script and controller_script:
		var controller = controller_script.new()
		var component = component_script.new()
		
		controller.player_id = 2
		
		# Test initialization
		component.initialize(controller)
		
		if component.is_initialized:
			print("✓ Component initialization successful")
		
		if component.get_player_id() == 2:
			print("✓ Component accesses controller player ID correctly")
		
		# Test cleanup
		component.cleanup()
		
		if not component.is_initialized:
			print("✓ Component cleanup successful")
		
		controller.free()
		component.free()
	else:
		print("❌ Could not load required scripts for integration test")
