extends Node3D

@export var thirst_restore_amount: float = 40.0  # How much thirst drinking restores
@export var drink_time: float = 2.0  # Time to drink water
@export var drink_tiredness_cost: float = 0.2  # Tiredness lost per second while drinking

var players_in_range: Array[Node] = []
var current_drinker: Node = null
var drink_progress: float = 0.0
var is_being_used: bool = false

# Visual components
var progress_bar: Node3D
@export var area_3d:Area3D

func _ready():
	# Configure Area3D to monitor the right types of bodies
	if area_3d:
		area_3d.monitoring = true
		area_3d.monitorable = true
		
		# Connect area signals for player detection
		area_3d.body_entered.connect(_on_player_entered)
		area_3d.body_exited.connect(_on_player_exited)
		print("Water source ready for drinking")
	else:
		print("ERROR: No Area3D found for water source!")

func _process(delta):
	if is_being_used and current_drinker:
		# Update drinking progress
		drink_progress += delta / drink_time
		
		# Apply continuous tiredness drain to the drinker
		var survival_component = current_drinker.get_component("survival") if current_drinker.has_method("get_component") else null
		if survival_component and survival_component.has_method("lose_tiredness"):
			survival_component.lose_tiredness(drink_tiredness_cost * delta, "drinking water")
		
		# Update progress bar
		if progress_bar:
			progress_bar.set_progress(drink_progress)
		
		# Check if drinking is complete
		if drink_progress >= 1.0:
			complete_drinking()

func _on_player_entered(body):
	# Use the same pattern as tree system - check for start_drinking_water method
	if body.has_method("start_drinking_water"):
		players_in_range.append(body)
		body.set_nearby_water(self)
		print("Player ", body.player_id, " can now drink water")

func _on_player_exited(body):
	if body in players_in_range:
		players_in_range.erase(body)
		if body.has_method("clear_nearby_water"):
			body.clear_nearby_water(self)
		print("Player ", body.player_id, " left water source")
		
		# If this player was drinking, stop the process
		if body == current_drinker:
			stop_drinking()

func start_drinking(player: Node) -> bool:
	if is_being_used:
		return false  # Already being used
	
	# Check if player needs water (not at full thirst)
	var survival_component = player.get_component("survival") if player.has_method("get_component") else null
	if survival_component and survival_component.has_method("get_thirst"):
		var current_thirst = survival_component.get_thirst()
		var max_thirst = survival_component.get_max_thirst()
		
		if current_thirst >= max_thirst:
			print("Player ", player.player_id, " is not thirsty!")
			return false
	
	current_drinker = player
	is_being_used = true
	drink_progress = 0.0
	
	# Create progress bar
	create_progress_bar()
	
	print("Player ", player.player_id, " started drinking water...")
	return true

func stop_drinking():
	if is_being_used:
		current_drinker = null
		is_being_used = false
		drink_progress = 0.0
		
		# Remove progress bar
		destroy_progress_bar()
		print("Stopped drinking water")

func complete_drinking():
	if current_drinker:
		print("DEBUG: Attempting to restore thirst for player ", current_drinker.player_id)
		
		# Restore thirst
		var survival_component = current_drinker.get_component("survival") if current_drinker.has_method("get_component") else null
		print("DEBUG: Survival component found: ", survival_component != null)
		
		if survival_component:
			print("DEBUG: Component has restore_thirst method: ", survival_component.has_method("restore_thirst"))
			
			if survival_component.has_method("restore_thirst"):
				var old_thirst = survival_component.get_thirst() if survival_component.has_method("get_thirst") else -1
				survival_component.restore_thirst(thirst_restore_amount)
				var new_thirst = survival_component.get_thirst() if survival_component.has_method("get_thirst") else -1
				
				print("Player ", current_drinker.player_id, " finished drinking water! Thirst: ", old_thirst, " -> ", new_thirst, " (restored: ", thirst_restore_amount, ")")
			else:
				print("ERROR: Survival component missing restore_thirst method")
		else:
			print("ERROR: Could not access survival component to restore thirst for player ", current_drinker.player_id)
		
		stop_drinking()

func create_progress_bar():
	if not progress_bar:
		# Load the progress bar scene
		var progress_bar_scene = load("res://components/progress_bar_3d.tscn")
		if progress_bar_scene:
			progress_bar = progress_bar_scene.instantiate()
			
			# Position above the water source
			progress_bar.position = Vector3(0, 1.5, 0)
			add_child(progress_bar)
			
			progress_bar.set_progress(0.0)
		else:
			print("Warning: Could not load progress bar scene")

func destroy_progress_bar():
	if progress_bar:
		progress_bar.queue_free()
		progress_bar = null

func get_drink_progress() -> float:
	return drink_progress
