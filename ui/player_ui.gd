extends Control
class_name PlayerUI

# Manual node references (not @onready)
var player_label: Label
var health_bar: ProgressBar
var hunger_bar: ProgressBar
var thirst_bar: ProgressBar
var tiredness_bar: ProgressBar
var wood_label: Label
var food_label: Label
var hotbar_ui: Node  # Reference to the HotbarUI component

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

func get_node_references():
	player_label = $VBoxContainer/PlayerLabel
	health_bar = $VBoxContainer/HealthContainer/HealthBar
	hunger_bar = $VBoxContainer/HungerContainer/HungerBar
	thirst_bar = $VBoxContainer/ThirstContainer/ThirstBar
	tiredness_bar = $VBoxContainer/TirednessContainer/TirednessBar
	wood_label = $VBoxContainer/InventoryContainer/WoodLabel
	food_label = $VBoxContainer/InventoryContainer/FoodLabel
	hotbar_ui = $VBoxContainer/HotbarContainer/HotbarUI

func setup_for_player(player: Node3D):
	target_player = player
	player_id = player.player_id
	
	# Connect to ResourceManager signals for reactive updates
	if target_player.resource_manager:
		target_player.resource_manager.resource_changed.connect(_on_resource_changed)
		target_player.resource_manager.resource_full.connect(_on_resource_full)
		target_player.resource_manager.resource_empty.connect(_on_resource_empty)
	
	# Use call_deferred to ensure all nodes are ready
	call_deferred("setup_ui_elements")

func setup_ui_elements():
	# Check if all UI elements exist before setting values
	if player_label:
		player_label.text = "Player " + str(player_id + 1)
	
	# Setup hotbar UI if available
	if hotbar_ui and target_player:
		# Add a small delay to ensure player components are fully initialized
		call_deferred("connect_hotbar_with_delay")
	
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
		# Defer the positioning to try again later
		call_deferred("position_ui_for_player")
		return
	
	var viewport_rect = viewport.get_visible_rect()
	if viewport_rect == Rect2():
		call_deferred("position_ui_for_player")
		return
	
	var viewport_size = viewport_rect.size
	var ui_margin = 60
	
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
		update_non_resource_ui_values()

func update_non_resource_ui_values():
	# Only update health, hunger, and tiredness - resources are updated via signals
	if not target_player:
		return
	
	# Update health bar
	if health_bar:
		health_bar.value = target_player.get_health_percentage() * 100
	
	# Update hunger bar  
	if hunger_bar:
		hunger_bar.value = (target_player.hunger / target_player.max_hunger) * 100
	
	# Update thirst bar
	if thirst_bar:
		thirst_bar.value = target_player.get_thirst_percentage() * 100
	
	# Update tiredness bar
	if tiredness_bar:
		tiredness_bar.value = target_player.get_tiredness_percentage() * 100
	
	# Color-code bars based on values
	update_bar_colors()

func update_ui_values():
	# Keep this method for initial setup - it updates everything including resources
	if not target_player:
		return
	
	# Update health bar
	if health_bar:
		health_bar.value = target_player.get_health_percentage() * 100
	
	# Update hunger bar  
	if hunger_bar:
		hunger_bar.value = (target_player.hunger / target_player.max_hunger) * 100
	
	# Update thirst bar
	if thirst_bar:
		thirst_bar.value = target_player.get_thirst_percentage() * 100
	
	# Update tiredness bar
	if tiredness_bar:
		tiredness_bar.value = target_player.get_tiredness_percentage() * 100
	
	# Update inventory labels (for initial setup)
	if wood_label:
		var wood_amount = target_player.resource_manager.get_resource_amount("wood") if target_player.resource_manager else 0
		wood_label.text = "🪵 " + str(wood_amount)
	if food_label:
		var food_amount = target_player.resource_manager.get_resource_amount("food") if target_player.resource_manager else 0
		food_label.text = "🍖 " + str(food_amount)
	
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
	
	# Thirst bar colors
	if thirst_bar:
		if thirst_bar.value > 66:
			thirst_bar.modulate = Color.BLUE
		elif thirst_bar.value > 33:
			thirst_bar.modulate = Color.YELLOW
		else:
			thirst_bar.modulate = Color.RED
	
	# Tiredness bar colors
	if tiredness_bar:
		if tiredness_bar.value > 66:
			tiredness_bar.modulate = Color.CYAN
		elif tiredness_bar.value > 33:
			tiredness_bar.modulate = Color.YELLOW
		else:
			tiredness_bar.modulate = Color.RED

# ResourceManager signal handlers for reactive UI updates
func _on_resource_changed(resource_type: String, _old_amount: int, new_amount: int):
	# Update specific resource display when it changes
	if resource_type == "wood" and wood_label:
		wood_label.text = "🪵 " + str(new_amount)
	elif resource_type == "food" and food_label:
		food_label.text = "🍖 " + str(new_amount)

func _on_resource_full(resource_type: String):
	# Visual feedback when resource inventory is full
	push_warning("Player " + str(player_id + 1) + " " + resource_type + " inventory is full!")
	# Could add visual indicators here like flashing or color changes

func _on_resource_empty(resource_type: String):
	# Visual feedback when resource runs out
	push_warning("Player " + str(player_id + 1) + " is out of " + resource_type + "!")
	# Could add visual indicators here like warning colors

func force_hotbar_update():
	"""Force hotbar to update - useful for timing issues"""
	if hotbar_ui and hotbar_ui.has_method("update_all_slots"):
		hotbar_ui.update_all_slots()

func connect_hotbar_with_delay():
	"""Connect hotbar with a small delay to ensure components are ready"""
	var max_retries = 3
	var retry_count = 0
	
	while retry_count < max_retries:
		if not target_player or not target_player.has_method("get_component"):
			retry_count += 1
			await get_tree().create_timer(0.1).timeout
			continue
		
		# Try to get the inventory component
		var inventory = target_player.get_component("inventory")
		
		if inventory:
			hotbar_ui.setup_for_player(target_player)
			return
		
		retry_count += 1
		await get_tree().create_timer(0.1).timeout
	
	push_error("PlayerUI: Failed to connect hotbar after " + str(max_retries) + " retries")
