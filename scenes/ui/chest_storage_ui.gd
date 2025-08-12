extends Control
class_name ChestStorageUI

# UI elements - assign these in the editor
@export var background_panel: Panel
@export var title_label: Label
@export var player_resources_label: Label
@export var chest_contents_label: Label
@export var option_container: VBoxContainer
@export var current_option_label: Label
@export var instruction_label: Label
@export var close_button: Button

# Storage data
var current_chest: Node3D
var current_player: Node
var storage_options: Array[String] = []
var current_option_index: int = 0

# Input handling
var input_cooldown: float = 0.0
var input_cooldown_time: float = 0.15  # Prevent rapid input
var is_handling_input: bool = false  # Prevent recursion
var is_closing: bool = false  # Prevent recursion in close signal

# Signals
signal option_selected(option_index: int)
signal storage_closed

func _ready():
	# Hide initially
	visible = false
	
	# Auto-assign UI elements by finding them in the scene tree
	if not background_panel:
		background_panel = find_child("BackgroundPanel")
	if not title_label:
		title_label = find_child("TitleLabel")
	if not player_resources_label:
		player_resources_label = find_child("PlayerResourcesLabel")
	if not chest_contents_label:
		chest_contents_label = find_child("ChestContentsLabel")
	if not option_container:
		option_container = find_child("OptionContainer")
	if not current_option_label:
		current_option_label = find_child("CurrentOptionLabel")
	if not instruction_label:
		instruction_label = find_child("InstructionLabel")
	if not close_button:
		close_button = find_child("CloseButton")
	
	# Connect close button if available
	if close_button:
		close_button.pressed.connect(_on_close_pressed)
	
	# Set up UI styling
	setup_ui_styling()

func _process(delta):
	# Update input cooldown
	if input_cooldown > 0:
		input_cooldown -= delta
	
	# Handle input while UI is visible
	if visible and current_player and input_cooldown <= 0:
		handle_ui_input()

func handle_ui_input():
	"""Handle UI input using polling instead of event interception"""
	# Prevent recursive input handling
	if is_handling_input:
		return
	
	is_handling_input = true
	
	# Get the player's input handler
	var player_input_handler = current_player.get_component("input_handler") if current_player.has_method("get_component") else null
	if not player_input_handler:
		is_handling_input = false
		return
	
	# Check for navigation input using player-specific controls
	if player_input_handler.has_method("is_up_just_pressed") and player_input_handler.is_up_just_pressed():
		navigate_up()
		input_cooldown = input_cooldown_time
	elif player_input_handler.has_method("is_down_just_pressed") and player_input_handler.is_down_just_pressed():
		navigate_down()
		input_cooldown = input_cooldown_time
	elif player_input_handler.has_method("is_left_just_pressed") and player_input_handler.is_left_just_pressed():
		navigate_up()
		input_cooldown = input_cooldown_time
	elif player_input_handler.has_method("is_right_just_pressed") and player_input_handler.is_right_just_pressed():
		navigate_down()
		input_cooldown = input_cooldown_time
	
	# Check for player-specific action buttons
	elif player_input_handler.has_method("is_action_just_pressed") and player_input_handler.is_action_just_pressed():
		execute_current_option()
		input_cooldown = input_cooldown_time
	
	# Check for build button (close interface)
	elif player_input_handler.has_method("is_build_mode_just_pressed") and player_input_handler.is_build_mode_just_pressed():
		hide_storage_interface()
	
	is_handling_input = false

func setup_ui_styling():
	"""Setup basic UI styling"""
	if background_panel:
		# Make background semi-transparent
		var style_box = StyleBoxFlat.new()
		style_box.bg_color = Color(0.1, 0.1, 0.1, 0.8)  # Dark semi-transparent
		style_box.border_width_left = 2
		style_box.border_width_right = 2
		style_box.border_width_top = 2
		style_box.border_width_bottom = 2
		style_box.border_color = Color(0.6, 0.4, 0.2, 1.0)  # Brown border
		style_box.corner_radius_top_left = 8
		style_box.corner_radius_top_right = 8
		style_box.corner_radius_bottom_left = 8
		style_box.corner_radius_bottom_right = 8
		background_panel.add_theme_stylebox_override("panel", style_box)

func show_storage_interface(chest: Node3D, player: Node):
	"""Show the storage interface for the given chest and player"""
	# Reset closing flag when showing
	is_closing = false
	
	current_chest = chest
	current_player = player
	current_option_index = 0
	
	# Update UI content
	update_interface_content()
	
	# Show the UI
	visible = true
	
	print("Chest storage UI shown")

func hide_storage_interface():
	"""Hide the storage interface"""
	# Prevent recursion
	if is_closing:
		return
	
	is_closing = true
	visible = false
	
	# Clear input state to prevent any stuck inputs
	input_cooldown = 0.0
	is_handling_input = false
	
	# Clear references
	current_chest = null
	current_player = null
	
	# Only emit signal if we're not already in a closing process
	storage_closed.emit()
	print("Chest storage UI hidden")
	
	# Reset closing flag after a brief delay to allow signal processing
	call_deferred("_reset_closing_flag")

func _reset_closing_flag():
	"""Reset the closing flag to allow future close operations"""
	is_closing = false

func update_interface_content():
	"""Update all UI elements with current data"""
	if not current_chest or not current_player:
		return
	
	var player_resource_manager = current_player.get_node("ResourceManager")
	if not player_resource_manager:
		print("Error: Player has no ResourceManager!")
		return
	
	# Update title
	if title_label:
		title_label.text = "Chest Storage"
	
	# Update player resources
	if player_resources_label:
		var wood_amount = player_resource_manager.get_resource_amount("wood")
		var food_amount = player_resource_manager.get_resource_amount("food")
		player_resources_label.text = "Your Resources:\nWood: %d\nFood: %d" % [wood_amount, food_amount]
	
	# Update chest contents
	if chest_contents_label:
		var total_items = current_chest.get_total_stored_items()
		var capacity = current_chest.storage_capacity
		var wood_in_chest = current_chest.get_item_amount("wood")
		var food_in_chest = current_chest.get_item_amount("food")
		chest_contents_label.text = "Chest Contents (%d/%d):\nWood: %d\nFood: %d" % [total_items, capacity, wood_in_chest, food_in_chest]
	
	# Update storage options
	update_storage_options(player_resource_manager)
	
	# Update current selection (but don't call update_interface_content again)
	update_current_option_display_only()

func update_current_option_display_only():
	"""Update just the current option display without triggering full interface update"""
	if not current_option_label or storage_options.is_empty():
		return
	
	current_option_label.text = ">>> " + storage_options[current_option_index] + " <<<"
	current_option_label.add_theme_color_override("font_color", Color.YELLOW)
	
	# Update instruction text for player controls
	if instruction_label:
		instruction_label.text = "↑↓←→ Navigate • Action to select • Build to close"

func update_storage_options(player_resource_manager):
	"""Update the list of available storage options"""
	storage_options = [
		"Store 5 wood (%d available)" % player_resource_manager.get_resource_amount("wood"),
		"Store 5 food (%d available)" % player_resource_manager.get_resource_amount("food"),
		"Take 5 wood (%d in chest)" % current_chest.get_item_amount("wood"),
		"Take 5 food (%d in chest)" % current_chest.get_item_amount("food"),
		"Store ALL wood (%d available)" % player_resource_manager.get_resource_amount("wood"),
		"Store ALL food (%d available)" % player_resource_manager.get_resource_amount("food"),
		"Take ALL wood (%d in chest)" % current_chest.get_item_amount("wood"),
		"Take ALL food (%d in chest)" % current_chest.get_item_amount("food"),
		"Close storage"
	]
	
	# Update option container if available
	if option_container:
		# Clear existing options properly
		var children_to_remove = option_container.get_children()
		for child in children_to_remove:
			option_container.remove_child(child)
			child.queue_free()
		
		# Add new option labels
		for i in range(storage_options.size()):
			var option_label = Label.new()
			option_label.name = "Option" + str(i)
			
			# Highlight the currently selected option
			if i == current_option_index:
				option_label.text = ">>> " + storage_options[i] + " <<<"
				option_label.add_theme_color_override("font_color", Color.YELLOW)
			else:
				option_label.text = "  " + storage_options[i]
				option_label.add_theme_color_override("font_color", Color.WHITE)
			
			option_container.add_child(option_label)

func update_current_option_display():
	"""Update the display to show the currently selected option"""
	if not current_option_label or storage_options.is_empty():
		return
	
	current_option_label.text = ">>> " + storage_options[current_option_index] + " <<<"
	current_option_label.add_theme_color_override("font_color", Color.YELLOW)
	
	# Update instruction text for player controls
	if instruction_label:
		instruction_label.text = "↑↓←→ Navigate • Action to select • Build to close"

func cycle_to_next_option():
	"""Cycle to the next storage option"""
	if storage_options.is_empty():
		return
	
	current_option_index = (current_option_index + 1) % storage_options.size()
	update_current_option_display()

func execute_current_option():
	"""Execute the currently selected option"""
	if storage_options.is_empty():
		return
	
	# Close interface after selection if it's the "Close storage" option
	if current_option_index == storage_options.size() - 1:  # "Close storage" option
		hide_storage_interface()
		return
	
	# For other options, emit the signal but don't update interface immediately
	# Let the chest handle the update after the operation completes
	option_selected.emit(current_option_index)

func refresh_interface():
	"""Refresh the interface content - called externally after operations complete"""
	if visible and current_chest and current_player:
		update_interface_content()

func _on_close_pressed():
	"""Handle close button press"""
	hide_storage_interface()

func navigate_up():
	"""Navigate to previous option"""
	if storage_options.is_empty():
		return
	
	current_option_index = (current_option_index - 1 + storage_options.size()) % storage_options.size()
	update_current_option_display_only()
	update_option_list_highlighting()

func navigate_down():
	"""Navigate to next option"""
	if storage_options.is_empty():
		return
	
	current_option_index = (current_option_index + 1) % storage_options.size()
	update_current_option_display_only()
	update_option_list_highlighting()

func update_option_list_highlighting():
	"""Update the highlighting in the option list"""
	if not option_container:
		return
	
	# Update highlighting for each option
	for i in range(option_container.get_child_count()):
		var option_label = option_container.get_child(i)
		if option_label is Label:
			if i == current_option_index:
				option_label.text = ">>> " + storage_options[i] + " <<<"
				option_label.add_theme_color_override("font_color", Color.YELLOW)
			else:
				option_label.text = "  " + storage_options[i]
				option_label.add_theme_color_override("font_color", Color.WHITE)
