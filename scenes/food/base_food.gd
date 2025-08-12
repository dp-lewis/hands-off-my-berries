extends Node3D
class_name BaseFood

## Base class for all food items in the game
## Provides common gathering functionality and configurable hunger restoration

# Food configuration
@export var gather_time: float = 3.0              # Time to harvest this food
@export var food_amount: int = 1                  # Quantity provided when harvested
@export var hunger_restore_value: float = 25.0    # Hunger restored per unit
@export var food_type: String = "generic"         # Type for UI/display purposes

# Gathering state
var is_being_gathered: bool = false
var gather_progress: float = 0.0
var current_gatherer: Node3D = null
var progress_bar: Node3D = null

# Common child node references (override in subclasses if needed)
@onready var area_3d: Area3D = $Area3D
@onready var static_body: StaticBody3D = $StaticBody3D
@onready var model_parent: Node3D = $tmpParent

func _ready():
	# Connect area signals for player detection
	if area_3d:
		area_3d.body_entered.connect(_on_body_entered)
		area_3d.body_exited.connect(_on_body_exited)
	
	print(food_type.capitalize(), " ready for harvesting")

func _process(delta):
	if is_being_gathered and current_gatherer:
		gather_progress += delta
		
		# Update progress bar if it exists
		if progress_bar:
			progress_bar.set_progress(gather_progress / gather_time)
		
		# Update visual state based on progress
		update_visual_state()
		
		# Check if gathering is complete
		if gather_progress >= gather_time:
			complete_gathering()

func _on_body_entered(body):
	if body.has_method("set_nearby_food"):
		body.set_nearby_food(self)

func _on_body_exited(body):
	if body.has_method("clear_nearby_food"):
		body.clear_nearby_food(self)

func start_gathering(gatherer: Node3D) -> bool:
	if is_being_gathered:
		return false
	
	is_being_gathered = true
	current_gatherer = gatherer
	gather_progress = 0.0
	
	# Create progress bar
	create_progress_bar()
	
	print("Started gathering ", food_type)
	return true

func stop_gathering():
	if is_being_gathered:
		is_being_gathered = false
		current_gatherer = null
		gather_progress = 0.0
		
		# Remove progress bar
		destroy_progress_bar()
		
		# Reset visual state
		reset_visual_state()
		
		print("Stopped gathering ", food_type)

func complete_gathering():
	if current_gatherer:
		var resource_manager = current_gatherer.get_node("ResourceManager")
		if resource_manager:
			# Try to add food to gatherer's inventory using ResourceManager
			if resource_manager.add_resource("food", food_amount):
				# Notify the gatherer's survival system about the hunger restoration value
				var survival_component = current_gatherer.get_component("survival") if current_gatherer.has_method("get_component") else null
				if survival_component and survival_component.has_method("set_last_food_restore_value"):
					survival_component.set_last_food_restore_value(hunger_restore_value)
				
				print(food_type.capitalize(), " harvested! Gave ", food_amount, " food (", hunger_restore_value, " hunger restore)")
				
				# Remove the food from the scene
				queue_free()
			else:
				print("Gatherer's food inventory is full!")
				stop_gathering()
		else:
			print("Warning: No ResourceManager found on gatherer!")
			stop_gathering()
	else:
		stop_gathering()

func create_progress_bar():
	if not progress_bar:
		# Load the progress bar scene
		var progress_bar_scene = load("res://components/progress_bar_3d.tscn")
		if progress_bar_scene:
			progress_bar = progress_bar_scene.instantiate()
			
			# Position above the food item
			progress_bar.position = Vector3(0, 1.5, 0)
			add_child(progress_bar)
			
			progress_bar.set_progress(0.0)
		else:
			print("Warning: Could not load progress bar scene")

func destroy_progress_bar():
	if progress_bar:
		progress_bar.queue_free()
		progress_bar = null

func update_visual_state():
	"""Override in subclasses for custom visual effects during gathering"""
	if model_parent and is_being_gathered:
		var progress_ratio = gather_progress / gather_time
		
		# Slightly scale down as gathering progresses
		var scale_factor = 1.0 - (progress_ratio * 0.1)  # Shrink by 10% max
		model_parent.scale = Vector3(2.0, 2.0, 2.0) * scale_factor
		
		# Add slight wobble effect
		var wobble = sin(gather_progress * 10.0) * 0.02 * progress_ratio
		model_parent.rotation.z = wobble

func reset_visual_state():
	"""Override in subclasses for custom visual reset"""
	if model_parent:
		model_parent.scale = Vector3(2.0, 2.0, 2.0)
		model_parent.rotation = Vector3.ZERO

# Getter methods for easy access to food properties
func get_hunger_restore_value() -> float:
	return hunger_restore_value

func get_food_type() -> String:
	return food_type

func get_food_amount() -> int:
	return food_amount
