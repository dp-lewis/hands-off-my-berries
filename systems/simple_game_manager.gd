extends Node

var day_night_system: Node
var players: Array[Node] = []
var day_display: Control = null

func _ready():
	# Create the day/night system
	day_night_system = preload("res://systems/simple_day_night.gd").new()
	day_night_system.name = "DayNightCycle"
	add_child(day_night_system)
	
	# Connect to day/night signals
	day_night_system.day_started.connect(_on_day_started)
	day_night_system.night_started.connect(_on_night_started)
	
	# Create global day display
	create_day_display()
	
	# Find all players
	call_deferred("find_players")
	
	print("Simple game manager started")

func find_players():
	# Wait a frame for players to be ready
	await get_tree().process_frame
	
	players = get_tree().get_nodes_in_group("players")
	print("Found ", players.size(), " players")

func create_day_display():
	# Create the global day display UI
	var day_display_scene = preload("res://ui/day_display.tscn")
	if day_display_scene:
		day_display = day_display_scene.instantiate()
		get_tree().current_scene.add_child.call_deferred(day_display)
		print("Created global day display")

func _on_day_started():
	# Tell all players it's day
	for player in players:
		if player.has_method("on_day_started"):
			player.on_day_started()
	
	# Tell all tents it's day
	var tents = get_tree().get_nodes_in_group("tents")
	for tent in tents:
		if tent.has_method("on_day_started"):
			tent.on_day_started()

func _on_night_started():
	# Tell all players it's night
	for player in players:
		if player.has_method("on_night_started"):
			player.on_night_started()
	
	# Tell all tents it's night
	var tents = get_tree().get_nodes_in_group("tents")
	for tent in tents:
		if tent.has_method("on_night_started"):
			tent.on_night_started()

# Debug input
func _input(event):
	if event.is_action_pressed("ui_select") and Input.is_key_pressed(KEY_CTRL):
		# Ctrl+Enter to toggle day/night
		if day_night_system.get_is_day():
			day_night_system.force_night()
			print("DEBUG: Forced night")
		else:
			day_night_system.force_day()
			print("DEBUG: Forced day")
