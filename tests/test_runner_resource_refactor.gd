extends Control

var gut: Gut

func _ready():
	# Create and configure GUT
	gut = Gut.new()
	add_child(gut)
	
	print("Starting Resource Manager Refactoring Tests...")
	
	# Add our test script
	gut.add_script("res://tests/test_resource_manager.gd")
	
	# Configure GUT settings
	gut.log_level = 1  # Show more details
	gut.yield_between_tests = true
	
	# Run the tests
	gut.test_scripts()
	
	# Connect to finished signal to show results
	gut.tests_finished.connect(_on_tests_finished)

func _on_tests_finished():
	print("\n=== Test Results ===")
	print("Tests run: ", gut.get_test_count())
	print("Assertions: ", gut.get_assert_count())
	print("Failures: ", gut.get_fail_count())
	
	if gut.get_fail_count() == 0:
		print("🎉 All tests passed!")
	else:
		print("❌ Some tests failed")
	
	# Wait a moment then quit
	await get_tree().create_timer(2.0).timeout
	get_tree().quit()
