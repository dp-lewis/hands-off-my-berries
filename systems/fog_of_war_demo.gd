extends Node3D

# Fog of War Demo Controller
# Allows testing and controlling fog of war system

@onready var fog_of_war = $FogOfWar

var debug_mode: bool = false

func _ready():
	print("Fog of War Demo loaded!")
	print("Press F to toggle fog of war on/off")
	print("Press M to toggle debug mode")
	print("Press R to reveal a large area around Player 0")
	print("Press C to clear all exploration")
	print("Press + to increase vision radius")
	print("Press - to decrease vision radius")
	print("Press V to visualize grid (debug)")
	
	# Reveal starting areas around players
	if fog_of_war:
		call_deferred("reveal_starting_areas")

func _input(event):
	if not event.is_action_pressed("ui_cancel") and event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F:
				toggle_fog_of_war()
			KEY_M:
				toggle_debug_mode()
			KEY_R:
				reveal_area_around_player()
			KEY_C:
				clear_all_exploration()
			KEY_EQUAL, KEY_PLUS:  # + key
				adjust_vision_radius(2.0)
			KEY_MINUS:  # - key
				adjust_vision_radius(-2.0)
			KEY_V:
				toggle_grid_visualization()

func toggle_fog_of_war():
	if fog_of_war:
		fog_of_war.visible = !fog_of_war.visible
		print("Fog of War: ", "ON" if fog_of_war.visible else "OFF")

func toggle_debug_mode():
	debug_mode = !debug_mode
	print("Debug mode: ", "ON" if debug_mode else "OFF")
	
	if debug_mode and fog_of_war:
		var debug_info = fog_of_war.get_debug_info()
		print("Fog of War Debug Info:")
		for key in debug_info:
			print("  ", key, ": ", debug_info[key])

func reveal_area_around_player():
	if fog_of_war:
		var players = get_tree().get_nodes_in_group("players")
		if players.size() > 0:
			var player_pos = players[0].global_position
			var world_pos = Vector2(player_pos.x, player_pos.z)
			fog_of_war.reveal_area(world_pos, 20.0)
			print("Revealed large area around Player 0")

func clear_all_exploration():
	if fog_of_war:
		fog_of_war.explored_tiles.clear()
		fog_of_war.currently_visible_tiles.clear()
		print("Cleared all exploration data")

func reveal_starting_areas():
	"""Reveal small areas around player spawn points so they can see initially"""
	if not fog_of_war:
		return
	
	var players = get_tree().get_nodes_in_group("players")
	for player in players:
		var player_pos = Vector2(player.global_position.x, player.global_position.z)
		fog_of_war.reveal_area(player_pos, 3.0)  # Small starting vision
	
	print("Revealed starting areas around ", players.size(), " players")

func _process(_delta):
	if debug_mode and fog_of_war:
		# Print exploration percentage every few seconds
		if Engine.get_process_frames() % 180 == 0:  # Every 3 seconds at 60fps
			print("Exploration: ", "%.1f" % fog_of_war.get_exploration_percentage(), "%")

func adjust_vision_radius(delta: float):
	if fog_of_war:
		fog_of_war.vision_radius = max(4.0, fog_of_war.vision_radius + delta)
		print("Vision radius: ", fog_of_war.vision_radius)

func toggle_grid_visualization():
	print("Grid visualization not yet implemented")
