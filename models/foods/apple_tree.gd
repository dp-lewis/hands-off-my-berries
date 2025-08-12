extends "res://models/foods/base_food.gd"

## Apple Tree - A slow-gathering, high-value food
## Provides 35 hunger restoration when harvested

func _ready():
	# Set apple-specific properties
	gather_time = 4.0              # Slower to gather than pumpkins
	food_amount = 1
	hunger_restore_value = 35.0    # More hunger restoration than pumpkins
	food_type = "apple"
	
	# Call parent _ready to set up the base functionality
	super._ready()

# Apples could have different visual effects
func update_visual_state():
	"""Custom visual effects for apple gathering - subtle swaying"""
	if model_parent and is_being_gathered:
		var progress_ratio = gather_progress / gather_time
		
		# Gentle tree swaying effect
		var sway_amplitude = 0.03 * progress_ratio
		var sway = sin(gather_progress * 3.0) * sway_amplitude
		model_parent.rotation.z = sway
		
		# Minimal scaling (trees are sturdy)
		var scale_factor = 1.0 - (progress_ratio * 0.02)  # Shrink by 2% max
		model_parent.scale = Vector3(2.0, 2.0, 2.0) * scale_factor
