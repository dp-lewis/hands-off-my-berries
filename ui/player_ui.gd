extends Control
class_name PlayerUI

# Manual node references (not @onready)
var player_label: Label
var health_bar: ProgressBar
var hunger_bar: ProgressBar
var tiredness_bar: ProgressBar
var wood_label: Label
var food_label: Label

var player_id: int = 0
var target_player: Node3D = null

func _ready():
	# Get node references manually
	get_node_references()
	
	# Only position if we have valid viewport access
	if get_viewport():
		position_ui_for_player()
	else:
		# Defer positioning until viewport is available
		call_deferred("position_ui_for_player")
	
	# Debug: Check if all node references are valid
	print("UI Debug - player_label: ", player_label)
	print("UI Debug - health_bar: ", health_bar)
	print("UI Debug - hunger_bar: ", hunger_bar)
	print("UI Debug - tiredness_bar: ", tiredness_bar)
	print("UI Debug - wood_label: ", wood_label)
	print("UI Debug - food_label: ", food_label)

func get_node_references():
	player_label = $VBoxContainer/PlayerLabel
	health_bar = $VBoxContainer/HealthContainer/HealthBar
	hunger_bar = $VBoxContainer/HungerContainer/HungerBar
	tiredness_bar = $VBoxContainer/TirednessContainer/TirednessBar
	wood_label = $VBoxContainer/InventoryContainer/WoodLabel
	food_label = $VBoxContainer/InventoryContainer/FoodLabel

func setup_for_player(player: Node3D):
	target_player = player
	player_id = player.player_id
	
	# Use call_deferred to ensure all nodes are ready
	call_deferred("setup_ui_elements")

func setup_ui_elements():
	# Check if all UI elements exist before setting values
	if player_label:
		player_label.text = "Player " + str(player_id + 1)
	else:
		print("Warning: player_label not found in UI")
	
	# Only position if we're properly in the scene tree
	if is_inside_tree():
		position_ui_for_player()
	else:
		# Wait until we're in the tree, then position
		call_deferred("position_ui_for_player")

func position_ui_for_player():
	# Get viewport safely with null checks
	var viewport = get_viewport()
	if not viewport:
		print("Warning: Cannot get viewport for UI positioning - will retry later")
		# Defer the positioning to try again later
		call_deferred("position_ui_for_player")
		return
	
	var viewport_rect = viewport.get_visible_rect()
	if viewport_rect == Rect2():
		print("Warning: Viewport rect is empty - will retry later")
		call_deferred("position_ui_for_player")
		return
	
	var viewport_size = viewport_rect.size
	var ui_margin = 20
	
	# Ensure UI has a valid size before positioning
	if size == Vector2.ZERO:
		# Use a default size if size isn't set yet
		size = Vector2(200, 150)
	
	match player_id:
		0:  # Top-left
			position = Vector2(ui_margin, ui_margin)
		1:  # Top-right
			position = Vector2(viewport_size.x - size.x - ui_margin, ui_margin)
		2:  # Bottom-left
			position = Vector2(ui_margin, viewport_size.y - size.y - ui_margin)
		3:  # Bottom-right
			position = Vector2(viewport_size.x - size.x - ui_margin, viewport_size.y - size.y - ui_margin)

func _process(_delta):
	if target_player:
		update_ui_values()

func update_ui_values():
	# Check if target player and UI elements exist
	if not target_player:
		return
	
	# Update health bar
	if health_bar:
		health_bar.value = target_player.get_health_percentage() * 100
	
	# Update hunger bar  
	if hunger_bar:
		hunger_bar.value = (target_player.hunger / target_player.max_hunger) * 100
	
	# Update tiredness bar
	if tiredness_bar:
		tiredness_bar.value = target_player.get_tiredness_percentage() * 100
	
	# Update inventory labels
	if wood_label:
		wood_label.text = "🪵 " + str(target_player.wood)
	if food_label:
		food_label.text = "🍖 " + str(target_player.food)
	
	# Color-code bars based on values
	update_bar_colors()

func update_bar_colors():
	# Health bar colors
	if health_bar:
		if health_bar.value > 66:
			health_bar.modulate = Color.GREEN
		elif health_bar.value > 33:
			health_bar.modulate = Color.YELLOW
		else:
			health_bar.modulate = Color.RED
	
	# Hunger bar colors
	if hunger_bar:
		if hunger_bar.value > 66:
			hunger_bar.modulate = Color.GREEN
		elif hunger_bar.value > 33:
			hunger_bar.modulate = Color.ORANGE
		else:
			hunger_bar.modulate = Color.RED
	
	# Tiredness bar colors
	if tiredness_bar:
		if tiredness_bar.value > 66:
			tiredness_bar.modulate = Color.CYAN
		elif tiredness_bar.value > 33:
			tiredness_bar.modulate = Color.YELLOW
		else:
			tiredness_bar.modulate = Color.RED
