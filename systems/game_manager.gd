extends Node
class_name GameManager

@export var enable_day_night_cycle: bool = true
@export var day_duration: float = 120.0  # 2 minutes day
@export var night_duration: float = 60.0  # 1 minute night

var day_night_cycle: Node
var players: Array[Node] = []

func _ready():
	if enable_day_night_cycle:
		setup_day_night_cycle()
	
	# Find all players in the scene
	find_players()
	
	print("GameManager initialized with ", players.size(), " players")

func setup_day_night_cycle():
	# Create day/night cycle system
	day_night_cycle = preload("res://systems/day_night_cycle.gd").new()
	day_night_cycle.name = "DayNightCycle"
	day_night_cycle.day_duration = day_duration
	day_night_cycle.night_duration = night_duration
	
	# Connect signals for game events
	day_night_cycle.day_started.connect(_on_day_started)
	day_night_cycle.night_started.connect(_on_night_started)
	day_night_cycle.time_changed.connect(_on_time_changed)
	
	add_child(day_night_cycle)
	print("Day/Night cycle enabled - Day: ", day_duration, "s, Night: ", night_duration, "s")

func find_players():
	# Find all player nodes in the scene
	players.clear()
	var all_nodes = get_tree().get_nodes_in_group("players")
	
	if all_nodes.is_empty():
		# Fallback: search for nodes with player script
		all_nodes = find_nodes_with_script(get_tree().current_scene, "player.gd")
	
	for node in all_nodes:
		if node.has_method("get_input_direction"):  # Check if it's a player
			players.append(node)

func find_nodes_with_script(node: Node, script_name: String) -> Array:
	var found_nodes = []
	
	if node.get_script() and node.get_script().resource_path.ends_with(script_name):
		found_nodes.append(node)
	
	for child in node.get_children():
		found_nodes += find_nodes_with_script(child, script_name)
	
	return found_nodes

# Day/Night event handlers
func _on_day_started():
	print("🌅 Day begins! Players are safer now.")
	
	# Apply day benefits to players
	for player in players:
		if player.has_method("on_day_started"):
			player.on_day_started()

func _on_night_started():
	print("🌙 Night falls! Danger increases.")
	
	# Apply night challenges to players
	for player in players:
		if player.has_method("on_night_started"):
			player.on_night_started()

func _on_time_changed(_current_time: float, _is_day_time: bool):
	# Optional: Update UI or other systems with time info
	pass

# Utility functions for other systems
func get_current_time() -> float:
	if day_night_cycle:
		return day_night_cycle.current_time
	return 0.0

func is_day() -> bool:
	if day_night_cycle:
		return day_night_cycle.is_day
	return true

func is_night() -> bool:
	return not is_day()

func get_time_of_day() -> float:
	if day_night_cycle:
		return day_night_cycle.get_time_of_day()
	return 0.5  # Assume noon if no cycle

# Debug functions
func _input(event):
	if event.is_action_pressed("ui_select") and event.is_command_or_control_pressed():
		# Ctrl+Enter to toggle day/night for testing
		if day_night_cycle:
			if day_night_cycle.is_day:
				day_night_cycle.force_night()
				print("🔧 DEBUG: Forced night time")
			else:
				day_night_cycle.force_day()
				print("🔧 DEBUG: Forced day time")
