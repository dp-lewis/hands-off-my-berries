extends BaseFood

## Berry Bush - A fast-gathering, lower-value food
## Provides 15 hunger restoration when harvested

func _ready():
	# Set berry-specific properties
	gather_time = 1.5              # Faster to gather than pumpkins
	food_amount = 1
	hunger_restore_value = 15.0    # Less hunger restoration than pumpkins
	food_type = "berry"
	
	# Call parent _ready to set up the base functionality
	super._ready()

# Berries could have different visual effects
func update_visual_state():
	"""Custom visual effects for berry gathering"""
	if model_parent and is_being_gathered:
		var progress_ratio = gather_progress / gather_time
		
		# Berries shake more than pumpkins (they're smaller/lighter)
		var shake_intensity = 0.05 * progress_ratio
		var shake_x = sin(gather_progress * 15.0) * shake_intensity
		var shake_z = cos(gather_progress * 12.0) * shake_intensity
		
		model_parent.position = Vector3(shake_x, 0, shake_z)
		
		# Slight color change as gathering progresses (if using shader)
		var scale_factor = 1.0 - (progress_ratio * 0.05)  # Shrink by 5% max (less than pumpkins)
		model_parent.scale = Vector3(2.0, 2.0, 2.0) * scale_factor

func reset_visual_state():
	"""Reset berry visual state"""
	if model_parent:
		model_parent.scale = Vector3(2.0, 2.0, 2.0)
		model_parent.position = Vector3.ZERO
		model_parent.rotation = Vector3.ZERO
