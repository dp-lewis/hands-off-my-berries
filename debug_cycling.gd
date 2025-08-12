extends Control

func _ready():
	print("=== Detailed Cycling Analysis ===")
	
	# Simulate the exact PlayerBuilder logic
	var available_building_types: Array[String] = ["tent", "chest"]
	var current_building_index: int = 0
	var cycle_count: int = 0
	var is_in_build_mode: bool = false
	var current_building_type: String = available_building_types[current_building_index]
	
	print("INITIAL STATE:")
	print("  current_building_index: ", current_building_index)
	print("  cycle_count: ", cycle_count)
	print("  is_in_build_mode: ", is_in_build_mode)
	print("  current_building_type: ", current_building_type)
	print("  available_building_types: ", available_building_types)
	print()
	
	# Simulate 6 consecutive toggle calls
	for i in range(6):
		print("=== TOGGLE ", i + 1, " ===")
		
		if is_in_build_mode:
			print("Already in build mode, cycling to next building...")
			
			# Move to next building type
			current_building_index = (current_building_index + 1) % available_building_types.size()
			cycle_count += 1
			
			print("  After increment: index=", current_building_index, " cycle_count=", cycle_count)
			print("  New building would be: ", available_building_types[current_building_index])
			
			# Check if we've cycled through all options
			if cycle_count >= available_building_types.size():
				print("  CYCLE COMPLETE - exiting build mode")
				cycle_count = 0
				current_building_index = 0  # Reset to first building type for next time
				is_in_build_mode = false
				current_building_type = available_building_types[current_building_index]
				print("  Reset: index=", current_building_index, " building=", current_building_type)
			else:
				var new_building_type = available_building_types[current_building_index]
				current_building_type = new_building_type
				print("  Switched to building: ", new_building_type)
		else:
			print("Not in build mode, entering...")
			cycle_count = 0  # Reset cycle count when entering build mode
			is_in_build_mode = true
			current_building_type = available_building_types[current_building_index]
			print("  Entered build mode with: ", current_building_type)
		
		print("FINAL STATE after toggle ", i + 1, ":")
		print("  current_building_index: ", current_building_index)
		print("  cycle_count: ", cycle_count)
		print("  is_in_build_mode: ", is_in_build_mode)
		print("  current_building_type: ", current_building_type)
		print()
