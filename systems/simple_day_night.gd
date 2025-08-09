extends Node

@export var day_duration: float = 60.0  # seconds for day
@export var night_duration: float = 30.0  # seconds for night
@export var day_brightness: float = 1.0  # full brightness during day
@export var night_brightness: float = 0.0  # dim lighting at night
@export var day_ambient: float = 0.3  # ambient light during day
@export var night_ambient: float = 0.05  # ambient light at night

var current_time: float = 0.0
var total_cycle_time: float
var is_day: bool = true
var current_day: int = 1  # Start at day 1
var directional_light: DirectionalLight3D
var world_environment: Environment

signal day_started
signal night_started
signal new_day(day_number: int)  # New signal for day changes

func _ready():
	# Add to group for easy access
	add_to_group("day_night_system")
	
	total_cycle_time = day_duration + night_duration
	
	# Find the directional light and environment in the scene
	find_directional_light()
	find_world_environment()
	
	# Start at day
	current_time = 0.0
	is_day = true
	
	print("Simple Day/Night cycle started - Day: ", day_duration, "s, Night: ", night_duration, "s")

func _process(delta):
	# Update time
	current_time += delta
	
	# Check if we've completed a full cycle
	if current_time >= total_cycle_time:
		current_time = 0.0
		current_day += 1  # Increment day counter when cycle completes
		new_day.emit(current_day)  # Emit new day signal
	
	# Check for day/night transitions
	var was_day = is_day
	is_day = current_time < day_duration
	
	# Emit signals on transitions
	if is_day != was_day:
		if is_day:
			day_started.emit()
			print("🌅 Day ", current_day, " begins!")
		else:
			night_started.emit()
			print("🌙 Night falls on day ", current_day, "!")
	
	# Update lighting
	update_lighting()

func find_directional_light():
	# Search for DirectionalLight3D in the scene
	directional_light = find_light_recursive(get_tree().current_scene)
	
	if directional_light:
		print("Found DirectionalLight3D for day/night cycle")
	else:
		print("No DirectionalLight3D found - creating one")
		create_default_light()

func find_light_recursive(node: Node) -> DirectionalLight3D:
	if node is DirectionalLight3D:
		return node
	
	for child in node.get_children():
		var result = find_light_recursive(child)
		if result:
			return result
	
	return null

func create_default_light():
	# Create a basic directional light
	directional_light = DirectionalLight3D.new()
	directional_light.name = "DayNightLight"
	directional_light.position = Vector3(0, 10, 0)
	directional_light.rotation_degrees = Vector3(-45, -45, 0)
	get_tree().current_scene.add_child(directional_light)
	print("Created default DirectionalLight3D")

func find_world_environment():
	# Try to get the world environment from the current scene
	var world_3d = get_viewport().find_world_3d()
	if world_3d:
		world_environment = world_3d.environment
	
	if world_environment:
		print("Found World Environment for ambient lighting")
	else:
		print("No World Environment found - ambient light won't change")
		# Create a basic environment if none exists
		create_default_environment()

func create_default_environment():
	# Create a basic environment for ambient lighting control
	world_environment = Environment.new()
	world_environment.background_mode = Environment.BG_SKY
	world_environment.ambient_light_color = Color.WHITE
	world_environment.ambient_light_energy = day_ambient
	
	# Apply to the world
	get_viewport().find_world_3d().environment = world_environment
	print("Created default Environment for ambient lighting")

func update_lighting():
	if not directional_light:
		return
	
	# Simple brightness transition for directional light
	var target_brightness: float
	var target_ambient: float
	
	if is_day:
		target_brightness = day_brightness
		target_ambient = day_ambient
	else:
		target_brightness = night_brightness
		target_ambient = night_ambient
	
	# Smoothly adjust the directional light energy
	directional_light.light_energy = lerp(directional_light.light_energy, target_brightness, 2.0 * get_process_delta_time())
	
	# Smoothly adjust ambient lighting if we have an environment
	if world_environment:
		world_environment.ambient_light_energy = lerp(world_environment.ambient_light_energy, target_ambient, 2.0 * get_process_delta_time())

# Utility functions
func get_is_day() -> bool:
	return is_day

func get_is_night() -> bool:
	return not is_day

func get_current_day() -> int:
	return current_day

func get_time_remaining() -> float:
	"""Returns time remaining in current period"""
	if is_day:
		return day_duration - current_time
	else:
		return total_cycle_time - current_time

# Debug functions
func force_day():
	current_time = day_duration * 0.5

func force_night():
	current_time = day_duration + (night_duration * 0.5)
