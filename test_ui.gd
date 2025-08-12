extends Control

func _ready():
	print("Testing cycling behavior...")
	
	# Simulate the cycling logic
	var available_building_types: Array[String] = ["tent", "chest"]
	var current_building_index: int = 0
	var cycle_count: int = 0
	var is_in_build_mode: bool = false
	
	print("Initial state: index=", current_building_index, " cycle_count=", cycle_count, " is_in_build_mode=", is_in_build_mode)
	
	# Simulate multiple toggle calls
	for i in range(8):
		print("\n--- Toggle ", i + 1, " ---")
		
		if is_in_build_mode:
			# If already in build mode, cycle to next building type
			# Move to next building type
			current_building_index = (current_building_index + 1) % available_building_types.size()
			cycle_count += 1
			
			print("Cycling: new index=", current_building_index, " cycle_count=", cycle_count, " building=", available_building_types[current_building_index])
			
			# Check if we've cycled through all options
			if cycle_count >= available_building_types.size():
				# We've cycled through all building types, exit build mode
				cycle_count = 0
				current_building_index = 0  # Reset to first building type for next time
				print("Cycled through all building types, exiting build mode")
				is_in_build_mode = false
			else:
				var new_building_type = available_building_types[current_building_index]
				print("Switched to building: ", new_building_type)
		else:
			# If not in build mode, enter with current building type
			cycle_count = 0  # Reset cycle count when entering build mode
			is_in_build_mode = true
			var building_type = available_building_types[current_building_index]
			print("Entered build mode - Building: ", building_type)
		
		print("After toggle: index=", current_building_index, " cycle_count=", cycle_count, " is_in_build_mode=", is_in_build_mode)
