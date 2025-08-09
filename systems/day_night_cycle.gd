extends Node
class_name DayNightCycle

signal day_started
signal night_started
signal time_changed(current_time: float, is_day: bool)

@export var day_duration: float = 60.0  # seconds for a full day
@export var night_duration: float = 30.0  # seconds for night
@export var day_color: Color = Color(1.0, 1.0, 0.9, 1.0)  # Warm daylight
@export var night_color: Color = Color(0.2, 0.3, 0.8, 1.0)  # Cool moonlight
@export var transition_speed: float = 2.0  # How fast day/night transitions

var current_time: float = 0.0
var total_cycle_time: float
var is_day: bool = true
var was_day: bool = true
var directional_light: DirectionalLight3D
var environment: Environment

func _ready():
	total_cycle_time = day_duration + night_duration
	
	# Find the main light and environment
	find_lighting_nodes()
	
	# Start at dawn
	current_time = 0.0
	is_day = true
	
	print("Day/Night cycle initialized - Day: ", day_duration, "s, Night: ", night_duration, "s")

func _process(delta):
	# Update time
	current_time += delta
	
	# Check if we've completed a full cycle
	if current_time >= total_cycle_time:
		current_time = 0.0
	
	# Determine if it's day or night
	was_day = is_day
	is_day = current_time < day_duration
	
	# Emit signals on day/night transitions
	if is_day != was_day:
		if is_day:
			day_started.emit()
			print("Dawn breaks - Day time begins")
		else:
			night_started.emit()
			print("Night falls - Darkness approaches")
	
	# Update lighting based on time
	update_lighting()
	
	# Emit time change signal
	time_changed.emit(current_time, is_day)

func find_lighting_nodes():
	# Search for DirectionalLight3D in the scene
	directional_light = find_node_by_type(get_tree().current_scene, DirectionalLight3D) as DirectionalLight3D
	
	# Try to find environment from camera or world environment
	var camera = get_viewport().get_camera_3d()
	if camera and camera.environment:
		environment = camera.environment
	else:
		# Check world environment
		var world_env = get_viewport().find_world_3d().environment
		if world_env:
			environment = world_env
	
	if directional_light:
		print("Found DirectionalLight3D for day/night cycle")
	else:
		print("No DirectionalLight3D found - creating one")
		create_default_light()
	
	if environment:
		print("Found Environment for day/night cycle")
	else:
		print("No Environment found - day/night will only affect direct lighting")

func find_node_by_type(node: Node, node_type) -> Node:
	# Check if this node is the type we're looking for
	if node is DirectionalLight3D:
		return node
	
	# Recursively search children
	for child in node.get_children():
		var result = find_node_by_type(child, node_type)
		if result:
			return result
	
	return null

func create_default_light():
	# Create a basic directional light for day/night cycle
	directional_light = DirectionalLight3D.new()
	directional_light.name = "DayNightSun"
	directional_light.position = Vector3(0, 10, 0)
	directional_light.rotation_degrees = Vector3(-45, -45, 0)
	get_tree().current_scene.add_child(directional_light)
	print("Created default DirectionalLight3D")

func update_lighting():
	if not directional_light:
		return
	
	var time_progress: float
	var target_color: Color
	var light_intensity: float
	
	if is_day:
		# During day: 0.0 (dawn) to 1.0 (noon) back to 0.0 (dusk)
		time_progress = current_time / day_duration
		var noon_factor = 1.0 - abs(time_progress - 0.5) * 2.0  # Peak at noon
		
		target_color = day_color
		light_intensity = 0.3 + (noon_factor * 0.7)  # 0.3 to 1.0
		
		# Rotate sun across the sky during day
		var sun_angle = time_progress * 180.0 - 90.0  # -90 to 90 degrees
		directional_light.rotation_degrees.x = -sun_angle
		
	else:
		# During night: constant low light
		time_progress = (current_time - day_duration) / night_duration
		
		target_color = night_color
		light_intensity = 0.1 + (sin(time_progress * PI) * 0.1)  # Slight moon variation
		
		# Moon position (opposite of sun)
		var moon_angle = time_progress * 180.0 - 90.0
		directional_light.rotation_degrees.x = -moon_angle + 180.0
	
	# Smoothly transition light properties
	directional_light.light_color = directional_light.light_color.lerp(target_color, transition_speed * get_process_delta_time())
	directional_light.light_energy = lerp(directional_light.light_energy, light_intensity, transition_speed * get_process_delta_time())
	
	# Update environment if available
	if environment:
		update_environment_lighting(target_color, light_intensity)

func update_environment_lighting(target_color: Color, light_intensity: float):
	# Adjust ambient light if environment supports it
	if environment:
		var ambient_color = target_color * 0.3  # Dimmer ambient light
		environment.ambient_light_color = environment.ambient_light_color.lerp(ambient_color, transition_speed * get_process_delta_time())
		environment.ambient_light_energy = lerp(environment.ambient_light_energy, light_intensity * 0.5, transition_speed * get_process_delta_time())

# Utility functions for gameplay systems
func get_time_of_day() -> float:
	"""Returns current time as 0.0-1.0 where 0.0 is dawn, 0.5 is noon, 1.0 is dusk"""
	if is_day:
		return current_time / day_duration
	else:
		return 1.0  # Night time

func get_time_remaining() -> float:
	"""Returns time remaining in current period (day or night)"""
	if is_day:
		return day_duration - current_time
	else:
		return total_cycle_time - current_time

func is_dawn() -> bool:
	return is_day and current_time < (day_duration * 0.1)

func is_noon() -> bool:
	return is_day and current_time > (day_duration * 0.4) and current_time < (day_duration * 0.6)

func is_dusk() -> bool:
	return is_day and current_time > (day_duration * 0.9)

func is_midnight() -> bool:
	return not is_day and (current_time - day_duration) > (night_duration * 0.4) and (current_time - day_duration) < (night_duration * 0.6)

func set_time_scale(scale: float):
	"""Adjust how fast time passes (1.0 = normal, 2.0 = double speed, 0.5 = half speed)"""
	Engine.time_scale = scale

func force_day():
	"""Force time to day (useful for testing)"""
	current_time = day_duration * 0.5  # Set to noon
	
func force_night():
	"""Force time to night (useful for testing)"""
	current_time = day_duration + (night_duration * 0.5)  # Set to midnight
