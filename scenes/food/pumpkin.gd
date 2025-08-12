extends BaseFood

## Pumpkin - A specific type of food
## Provides 25 hunger restoration when harvested

func _ready():
	# Set pumpkin-specific properties
	gather_time = 3.0
	food_amount = 1
	hunger_restore_value = 25.0
	food_type = "pumpkin"
	
	# Call parent _ready to set up the base functionality
	super._ready()

# Override the body detection methods to maintain backward compatibility
# while transitioning to the new food system
func _on_body_entered(body):
	# Call both old and new methods for backward compatibility
	if body.has_method("set_nearby_pumpkin"):
		body.set_nearby_pumpkin(self)
	if body.has_method("set_nearby_food"):
		body.set_nearby_food(self)

func _on_body_exited(body):
	# Call both old and new methods for backward compatibility  
	if body.has_method("clear_nearby_pumpkin"):
		body.clear_nearby_pumpkin(self)
	if body.has_method("clear_nearby_food"):
		body.clear_nearby_food(self)
