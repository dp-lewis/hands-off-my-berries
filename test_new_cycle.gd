extends Control

func _ready():
	print("=== Testing New Cycling Logic ===")
	
	var available_building_types: Array[String] = ["tent", "chest"]
	var current_building_index: int = 0
	var cycle_count: int = 0
	var is_in_build_mode: bool = false
	var current_building_type: String = available_building_types[current_building_index]
	
	print("INITIAL: index=", current_building_index, " cycle_count=", cycle_count, " building=", current_building_type)
	
	for i in range(6):
		print("\n--- TOGGLE ", i + 1, " ---")
		
		if is_in_build_mode:
			print("Cycling...")
			# Increment cycle count first
			cycle_count += 1
			
			# Check if we've cycled through all options
			if cycle_count > available_building_types.size():
				print("EXIT: cycle_count=", cycle_count, " > ", available_building_types.size())
				cycle_count = 0
				current_building_index = 0
				is_in_build_mode = false
				current_building_type = available_building_types[current_building_index]
				print("Reset to: index=", current_building_index, " building=", current_building_type)
			else:
				# Move to next building type
				current_building_index = (current_building_index + 1) % available_building_types.size()
				var new_building_type = available_building_types[current_building_index]
				current_building_type = new_building_type
				print("Switched to: index=", current_building_index, " building=", new_building_type, " cycle_count=", cycle_count)
		else:
			print("Entering build mode...")
			cycle_count = 0
			is_in_build_mode = true
			current_building_type = available_building_types[current_building_index]
			print("Entered with: index=", current_building_index, " building=", current_building_type)
		
		print("RESULT: index=", current_building_index, " cycle_count=", cycle_count, " is_in_build_mode=", is_in_build_mode, " building=", current_building_type)
