extends Control
class_name ModularPlayerUI

# References to UI components
var player_label: Label
var health_display: Control
var hunger_display: Control
var thirst_display: Control
var tiredness_display: Control
var resource_container: VBoxContainer

var player_id: int = 0
var target_player: Node3D = null
var resource_displays: Array[Node] = []

func _ready():
	setup_ui_structure()

func setup_ui_structure():
	# Create main container
	var main_vbox = VBoxContainer.new()
	add_child(main_vbox)
	
	# Player label
	player_label = Label.new()
	player_label.text = "Player 1"
	player_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_vbox.add_child(player_label)
	
	# Health display
	health_display = create_stat_display("💚", "Health")
	main_vbox.add_child(health_display)
	
	# Hunger display  
	hunger_display = create_stat_display("🍗", "Hunger")
	main_vbox.add_child(hunger_display)
	
	# Thirst display
	thirst_display = create_stat_display("💧", "Thirst")
	main_vbox.add_child(thirst_display)
	
	# Tiredness display
	tiredness_display = create_stat_display("😴", "Tiredness")
	main_vbox.add_child(tiredness_display)
	
	# Resource container
	var resource_label = Label.new()
	resource_label.text = "Resources:"
	resource_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_vbox.add_child(resource_label)
	
	resource_container = VBoxContainer.new()
	main_vbox.add_child(resource_container)
	
	# Create resource displays
	create_resource_displays()

func create_stat_display(icon: String, stat_name: String) -> Control:
	var hbox = HBoxContainer.new()
	
	var icon_label = Label.new()
	icon_label.text = icon
	icon_label.custom_minimum_size = Vector2(30, 0)
	hbox.add_child(icon_label)
	
	var progress_bar = ProgressBar.new()
	progress_bar.custom_minimum_size = Vector2(120, 20)
	progress_bar.max_value = 100
	progress_bar.value = 100
	hbox.add_child(progress_bar)
	
	# Store reference for updates
	hbox.set_meta("progress_bar", progress_bar)
	hbox.set_meta("stat_name", stat_name)
	
	return hbox

func create_resource_displays():
	# Load the ResourceDisplay script
	var resource_display_script = load("res://ui/components/resource_display.gd")
	
	# Wood display
	var wood_display = resource_display_script.new()
	wood_display.set_resource_type("wood", "🪵")
	resource_container.add_child(wood_display)
	resource_displays.append(wood_display)
	
	# Food display
	var food_display = resource_display_script.new()
	food_display.set_resource_type("food", "🍖")
	resource_container.add_child(food_display)
	resource_displays.append(food_display)

func setup_for_player(player: Node3D):
	target_player = player
	player_id = player.player_id
	
	# Update player label
	if player_label:
		player_label.text = "Player " + str(player_id + 1)
	
	# Connect resource displays to player's ResourceManager
	if target_player.resource_manager:
		for resource_display in resource_displays:
			resource_display.connect_to_resource_manager(target_player.resource_manager)
	
	# Position UI for this player
	position_ui_for_player()

func position_ui_for_player():
	var viewport = get_viewport()
	if not viewport:
		call_deferred("position_ui_for_player")
		return
	
	var viewport_size = viewport.get_visible_rect().size
	var ui_margin = 20
	
	# Set a consistent size
	custom_minimum_size = Vector2(250, 200)
	
	match player_id:
		0:  # Top-left
			position = Vector2(ui_margin, ui_margin)
		1:  # Top-right
			position = Vector2(viewport_size.x - custom_minimum_size.x - ui_margin, ui_margin)
		2:  # Bottom-left
			position = Vector2(ui_margin, viewport_size.y - custom_minimum_size.y - ui_margin)
		3:  # Bottom-right
			position = Vector2(viewport_size.x - custom_minimum_size.x - ui_margin, viewport_size.y - custom_minimum_size.y - ui_margin)

func _process(_delta):
	if target_player:
		update_stat_displays()

func update_stat_displays():
	# Update health
	if health_display:
		var progress_bar = health_display.get_meta("progress_bar")
		if progress_bar:
			progress_bar.value = target_player.get_health_percentage() * 100
			update_stat_color(progress_bar, progress_bar.value)
	
	# Update hunger
	if hunger_display:
		var progress_bar = hunger_display.get_meta("progress_bar")
		if progress_bar:
			progress_bar.value = (target_player.hunger / target_player.max_hunger) * 100
			update_stat_color(progress_bar, progress_bar.value)
	
	# Update thirst
	if thirst_display:
		var progress_bar = thirst_display.get_meta("progress_bar")
		if progress_bar:
			progress_bar.value = target_player.get_thirst_percentage() * 100
			update_stat_color(progress_bar, progress_bar.value)
	
	# Update tiredness
	if tiredness_display:
		var progress_bar = tiredness_display.get_meta("progress_bar")
		if progress_bar:
			progress_bar.value = target_player.get_tiredness_percentage() * 100
			update_stat_color(progress_bar, progress_bar.value)

func update_stat_color(progress_bar: ProgressBar, value: float):
	if value > 66:
		progress_bar.modulate = Color.GREEN
	elif value > 33:
		progress_bar.modulate = Color.ORANGE
	else:
		progress_bar.modulate = Color.RED
