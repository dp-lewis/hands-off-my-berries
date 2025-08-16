extends Node3D
class_name BerryCrop

## Berry crop that grows through stages and provides renewable food
## Integrates with existing resource and survival systems

# Growth stage models (set in editor)
@export var stage1: Node3D  # Seed/small sprout
@export var stage2: Node3D  # Young bush
@export var stage3: Node3D  # Mature bush (no berries)
@export var stage4: Node3D  # Berry-bearing bush

# Growth configuration
@export var stage_durations: Array[float] = [30.0, 45.0, 60.0, 30.0]  # Time in seconds for each stage
@export var harvest_time: float = 3.0  # Time to harvest berries
@export var harvest_amount: int = 3  # Berries per harvest
@export var hunger_restore_per_berry: float = 15.0  # Hunger restored per berry
@export var regrow_time: float = 45.0  # Time for berries to regrow after harvest

# Growth state
var current_stage: int = 0  # 0=stage1, 1=stage2, 2=stage3, 3=stage4
var stage_timer: float = 0.0
var is_harvestable: bool = false
var is_growing: bool = true
var can_be_watered: bool = true

# Care system
var moisture_level: float = 1.0  # 0.0 to 1.0, affects growth speed
var last_watered_time: float = 0.0
var care_quality: float = 1.0  # Overall care quality, affects yield
var growth_speed_multiplier: float = 1.0  # Modified by watering and care

# Harvesting state (follows BaseFood pattern)
var is_being_harvested: bool = false
var harvest_progress: float = 0.0
var current_harvester: Node3D = null
var progress_bar: Node3D = null

# Player detection
@onready var area_3d: Area3D = $Area3D

signal growth_stage_changed(new_stage: int)
signal ready_for_harvest()
signal harvest_completed(berries_harvested: int)

func _ready():
	# Set initial state - only stage1 visible
	update_visual_stage()
	
	# Connect area signals for player detection
	if area_3d:
		area_3d.body_entered.connect(_on_body_entered)
		area_3d.body_exited.connect(_on_body_exited)
	
	print("Berry crop planted and beginning growth")

func _process(delta):
	# Handle growth progression
	if is_growing and current_stage < 3:
		handle_growth(delta)
	
	# Handle harvest interaction
	if is_being_harvested and current_harvester:
		handle_harvesting(delta)
	
	# Handle moisture decrease over time
	handle_moisture_system(delta)

# === GROWTH SYSTEM ===

func handle_growth(delta: float):
	"""Process growth through stages"""
	stage_timer += delta * growth_speed_multiplier
	
	# Check if ready to advance to next stage
	if stage_timer >= stage_durations[current_stage]:
		advance_growth_stage()

func advance_growth_stage():
	"""Move to next growth stage"""
	if current_stage < 3:
		current_stage += 1
		stage_timer = 0.0
		update_visual_stage()
		growth_stage_changed.emit(current_stage)
		
		if current_stage == 3:  # Reached berry-bearing stage
			is_harvestable = true
			is_growing = false
			ready_for_harvest.emit()
			print("Berry bush ready for harvest!")

func update_visual_stage():
	"""Show only the current stage model"""
	var stages = [stage1, stage2, stage3, stage4]
	
	for i in range(stages.size()):
		if stages[i]:
			stages[i].visible = (i == current_stage)

# === CARE SYSTEM ===

func handle_moisture_system(delta: float):
	"""Handle moisture level and its effects on growth"""
	# Moisture decreases over time
	moisture_level = max(moisture_level - (delta * 0.01), 0.0)  # Loses 1% per second
	last_watered_time += delta
	
	# Update growth speed based on moisture
	if moisture_level > 0.7:
		growth_speed_multiplier = 1.5  # Well watered = fast growth
	elif moisture_level > 0.3:
		growth_speed_multiplier = 1.0  # Normal growth
	else:
		growth_speed_multiplier = 0.5  # Dry = slow growth
	
	# Update care quality based on consistent watering
	var watering_consistency = 1.0 - min(last_watered_time / 120.0, 1.0)  # Optimal watering every 2 minutes
	care_quality = (care_quality + watering_consistency) / 2.0  # Running average

func water_crop(player: Node3D):
	"""Water the crop to improve growth (enhanced for inventory system)"""
	if not can_be_watered:
		print("This crop doesn't need watering right now")
		return false
	
	# Check if player has inventory system with watering tools
	var inventory = player.get_component("inventory") if player.has_method("get_component") else null
	if inventory:
		var watering_tool = inventory.get_watering_tool()
		if watering_tool:
			# Use the tool to water
			var BucketItem = preload("res://systems/items/bucket_item.gd")
			if BucketItem.water_crop(watering_tool, player):
				moisture_level = 1.0
				last_watered_time = 0.0
				print("Berry crop watered with ", watering_tool.get_display_name(), "! Growth speed increased.")
				return true
			else:
				print("Could not use ", watering_tool.get_display_name(), " to water crop")
				return false
		else:
			print("No watering tools available (need bucket with water or watering can)")
			return false
	
	# Fallback to old system if no inventory
	moisture_level = 1.0
	last_watered_time = 0.0
	print("Berry crop watered! Growth speed increased.")
	return true

# === HARVESTING SYSTEM ===

func handle_harvesting(delta: float):
	"""Process harvesting progress"""
	harvest_progress += delta
	
	# Update progress bar if it exists
	if progress_bar:
		progress_bar.set_progress(harvest_progress / harvest_time)
	
	# Complete harvest when timer reaches harvest_time
	if harvest_progress >= harvest_time:
		complete_harvest()

func start_harvesting(harvester: Node3D) -> bool:
	"""Start harvesting berries"""
	if not is_harvestable or is_being_harvested:
		return false
	
	is_being_harvested = true
	current_harvester = harvester
	harvest_progress = 0.0
	
	# Create progress bar
	create_progress_bar()
	
	print("Started harvesting berries")
	return true

func stop_harvesting():
	"""Stop harvesting process"""
	if is_being_harvested:
		is_being_harvested = false
		current_harvester = null
		harvest_progress = 0.0
		
		# Remove progress bar
		destroy_progress_bar()
		
		print("Stopped harvesting berries")

func complete_harvest():
	"""Complete the harvest and add berries to player inventory"""
	if current_harvester:
		var resource_manager = current_harvester.get_node("ResourceManager")
		if resource_manager:
			# Calculate harvest yield based on care quality
			var berry_yield = int(harvest_amount * care_quality)
			berry_yield = max(berry_yield, 1)  # Always get at least 1 berry
			
			# Try to add berries to harvester's inventory
			if resource_manager.add_resource("food", berry_yield):
				# Notify survival system about hunger restoration value
				var survival_component = current_harvester.get_component("survival") if current_harvester.has_method("get_component") else null
				if survival_component and survival_component.has_method("set_last_food_restore_value"):
					survival_component.set_last_food_restore_value(hunger_restore_per_berry)
				
				print("Harvested ", berry_yield, " berries! (", hunger_restore_per_berry, " hunger restore each)")
				harvest_completed.emit(berry_yield)
				
				# Start regrowth cycle
				start_regrowth()
			else:
				print("Harvester's inventory is full!")
				stop_harvesting()
		else:
			print("Warning: No ResourceManager found on harvester!")
			stop_harvesting()
	else:
		stop_harvesting()

func start_regrowth():
	"""Begin regrowth cycle after harvest"""
	is_harvestable = false
	is_being_harvested = false
	current_harvester = null
	current_stage = 2  # Back to mature bush without berries
	stage_timer = 0.0
	is_growing = true
	
	# Update visual to show stage 3 (no berries)
	update_visual_stage()
	destroy_progress_bar()
	
	# Set custom duration for regrowth to berry stage
	if stage_durations.size() > 3:
		stage_durations[2] = regrow_time  # Override stage 3 duration for regrowth
	
	print("Berry bush regrowing... will be ready to harvest again in ", regrow_time, " seconds")

# === PROGRESS BAR SYSTEM ===

func create_progress_bar():
	"""Create harvest progress bar"""
	if not progress_bar:
		var progress_bar_scene = load("res://components/progress_bar_3d.tscn")
		if progress_bar_scene:
			progress_bar = progress_bar_scene.instantiate()
			progress_bar.position = Vector3(0, 2.0, 0)  # Above the bush
			add_child(progress_bar)
			progress_bar.set_progress(0.0)

func destroy_progress_bar():
	"""Remove harvest progress bar"""
	if progress_bar:
		progress_bar.queue_free()
		progress_bar = null

# === PLAYER DETECTION ===

func _on_body_entered(body):
	"""Player entered crop area"""
	print("[Berry Crop] Body entered area: ", body.name, " (Type: ", body.get_class(), ")")
	
	# Check if it's a player and get the interaction component
	if body.name.begins_with("Player"):
		var player_interaction = body.get_component("interaction") if body.has_method("get_component") else null
		if player_interaction and player_interaction.has_method("set_nearby_food"):
			print("[Berry Crop] Setting nearby food for player: ", body.name)
			player_interaction.set_nearby_food(self)
			print("[Berry Crop] Berry crop stage: ", get_growth_stage_name(), 
				  " | Harvestable: ", is_harvestable, 
				  " | Needs water: ", needs_water())
		else:
			print("[Berry Crop] Player ", body.name, " does not have interaction component or set_nearby_food method")
	else:
		print("[Berry Crop] Non-player body entered: ", body.name)

func _on_body_exited(body):
	"""Player left crop area"""
	print("[Berry Crop] Body exited area: ", body.name, " (Type: ", body.get_class(), ")")
	
	# Check if it's a player and get the interaction component
	if body.name.begins_with("Player"):
		var player_interaction = body.get_component("interaction") if body.has_method("get_component") else null
		if player_interaction and player_interaction.has_method("clear_nearby_food"):
			print("[Berry Crop] Clearing nearby food for player: ", body.name)
			player_interaction.clear_nearby_food(self)
		else:
			print("[Berry Crop] Player ", body.name, " does not have interaction component or clear_nearby_food method")
	else:
		print("[Berry Crop] Non-player body exited: ", body.name)

# === UTILITY METHODS ===

func get_food_type() -> String:
	return "berries"

func get_growth_stage_name() -> String:
	var stage_names = ["Sprout", "Young Bush", "Mature Bush", "Berry Bush"]
	return stage_names[current_stage] if current_stage < stage_names.size() else "Unknown"

func get_harvest_yield() -> int:
	"""Get expected harvest yield based on current care quality"""
	return int(harvest_amount * care_quality) if is_harvestable else 0

func needs_water() -> bool:
	"""Check if crop needs watering"""
	return moisture_level < 0.5

func get_growth_progress() -> float:
	"""Get progress through current stage (0.0 to 1.0)"""
	if current_stage >= stage_durations.size():
		return 1.0
	return stage_timer / stage_durations[current_stage]

# === PLAYER INTERACTION INTERFACE ===
# These methods are called by PlayerInteraction component

func start_gathering(gatherer: Node3D) -> bool:
	"""Interface method called by PlayerInteraction component"""
	print("[Berry Crop] start_gathering called by: ", gatherer.name)
	print("[Berry Crop] Is harvestable: ", is_harvestable, " | Already being harvested: ", is_being_harvested)
	
	if is_harvestable and not is_being_harvested:
		return start_harvesting(gatherer)
	else:
		if not is_harvestable:
			print("[Berry Crop] Cannot harvest - not ready yet (stage: ", get_growth_stage_name(), ")")
		if is_being_harvested:
			print("[Berry Crop] Cannot harvest - already being harvested")
		return false

func stop_gathering():
	"""Interface method called by PlayerInteraction component"""
	print("[Berry Crop] stop_gathering called")
	stop_harvesting()   


