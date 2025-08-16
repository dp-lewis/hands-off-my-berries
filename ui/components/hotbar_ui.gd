class_name HotbarUI
extends HBoxContainer

## Visual hotbar UI component for displaying and selecting inventory items
## Shows the first 4 slots of player inventory with selection feedback

# Configuration
var hotbar_size: int = 4
var slot_size: Vector2 = Vector2(48, 48)
var selected_slot: int = 0

# Component references
var target_inventory # : PlayerInventory
var hotbar_slots: Array = []  # Array of HotbarSlotUI controls

# Signals
signal slot_clicked(slot_index: int)
signal slot_right_clicked(slot_index: int)

# Styles for slots
var normal_style: StyleBoxFlat
var selected_style: StyleBoxFlat
var empty_style: StyleBoxFlat

func _ready():
	# Initialize hotbar UI
	hotbar_size = 4
	selected_slot = 0
	create_hotbar_slots()

func setup_for_player(player: Node3D):
	"""Connect this hotbar to a specific player's inventory"""
	if player and player.has_method("get_component"):
		target_inventory = player.get_component("inventory")
		if target_inventory:
			# Connect to inventory signals for updates
			if target_inventory.has_signal("inventory_changed"):
				target_inventory.inventory_changed.connect(_on_inventory_changed)
			if target_inventory.has_signal("hotbar_slot_selected"):
				target_inventory.hotbar_slot_selected.connect(_on_hotbar_selection_changed)
			
			# Update the display to show current items
			update_all_slots()
		else:
			push_error("HotbarUI: Failed to get inventory component from player")

func _on_inventory_changed(slot_index: int):
	"""Called when inventory slot changes"""
	if slot_index < hotbar_size:
		update_slot_display(slot_index)
	# Ignore non-hotbar slots

func _on_hotbar_selection_changed(slot_index: int):
	"""Handle hotbar selection changes"""
	set_selected_slot(slot_index)  # Just update the visual display

func setup_styles():
	"""Create visual styles for hotbar slots"""
	# Normal slot style
	normal_style = StyleBoxFlat.new()
	normal_style.bg_color = Color(0.2, 0.2, 0.2, 0.8)
	normal_style.border_width_left = 2
	normal_style.border_width_right = 2
	normal_style.border_width_top = 2
	normal_style.border_width_bottom = 2
	normal_style.border_color = Color(0.5, 0.5, 0.5, 1.0)
	normal_style.corner_radius_top_left = 4
	normal_style.corner_radius_top_right = 4
	normal_style.corner_radius_bottom_left = 4
	normal_style.corner_radius_bottom_right = 4
	
	# Selected slot style (highlighted)
	selected_style = StyleBoxFlat.new()
	selected_style.bg_color = Color(0.3, 0.3, 0.1, 0.9)
	selected_style.border_width_left = 3
	selected_style.border_width_right = 3
	selected_style.border_width_top = 3
	selected_style.border_width_bottom = 3
	selected_style.border_color = Color(1.0, 1.0, 0.0, 1.0)  # Yellow border
	selected_style.corner_radius_top_left = 4
	selected_style.corner_radius_top_right = 4
	selected_style.corner_radius_bottom_left = 4
	selected_style.corner_radius_bottom_right = 4
	
	# Empty slot style (dimmed)
	empty_style = StyleBoxFlat.new()
	empty_style.bg_color = Color(0.1, 0.1, 0.1, 0.6)
	empty_style.border_width_left = 1
	empty_style.border_width_right = 1
	empty_style.border_width_top = 1
	empty_style.border_width_bottom = 1
	empty_style.border_color = Color(0.3, 0.3, 0.3, 0.8)
	empty_style.corner_radius_top_left = 4
	empty_style.corner_radius_top_right = 4
	empty_style.corner_radius_bottom_left = 4
	empty_style.corner_radius_bottom_right = 4

func setup_for_inventory(inventory):
	"""Connect this UI to a PlayerInventory component"""
	target_inventory = inventory
	
	# Connect to inventory signals
	if target_inventory:
		target_inventory.inventory_changed.connect(_on_inventory_changed)
		target_inventory.selected_slot_changed.connect(_on_selected_slot_changed)
	
	# Create hotbar slot UI elements
	create_hotbar_slots()
	
	# Initial update
	update_all_slots()

func create_hotbar_slots():
	"""Create UI elements for each hotbar slot"""
	# Clear existing slots
	for child in get_children():
		child.queue_free()
	
	hotbar_slots.clear()
	
	# Create new slots
	for i in range(hotbar_size):
		var slot_ui = create_slot_ui(i)
		add_child(slot_ui)
		hotbar_slots.append(slot_ui)

func create_slot_ui(slot_index: int) -> Control:
	"""Create a single hotbar slot UI element"""
	# Main slot container
	var slot_container = PanelContainer.new()
	slot_container.custom_minimum_size = slot_size
	slot_container.tooltip_text = "Slot " + str(slot_index + 1) + " (Key: " + str(slot_index + 1) + ")"
	
	# Content container
	var content = VBoxContainer.new()
	content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	slot_container.add_child(content)
	
	# Item icon
	var icon = TextureRect.new()
	icon.custom_minimum_size = Vector2(36, 36)
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	content.add_child(icon)
	
	# Quantity/State label
	var quantity_label = Label.new()
	quantity_label.text = ""
	quantity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	quantity_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	quantity_label.add_theme_font_size_override("font_size", 12)
	quantity_label.add_theme_color_override("font_color", Color.WHITE)
	quantity_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	quantity_label.add_theme_constant_override("shadow_offset_x", 1)
	quantity_label.add_theme_constant_override("shadow_offset_y", 1)
	content.add_child(quantity_label)
	
	# Key number indicator
	var key_label = Label.new()
	key_label.text = str(slot_index + 1)
	key_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	key_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	key_label.add_theme_font_size_override("font_size", 10)
	key_label.add_theme_color_override("font_color", Color.LIGHT_GRAY)
	key_label.position = Vector2(2, 2)
	slot_container.add_child(key_label)
	
	# Mouse input handling
	slot_container.gui_input.connect(_on_slot_input.bind(slot_index))
	
	# Set initial style
	slot_container.add_theme_stylebox_override("panel", normal_style)
	
	return slot_container

func _on_slot_input(event: InputEvent, slot_index: int):
	"""Handle mouse input on slots"""
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			slot_clicked.emit(slot_index)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			slot_right_clicked.emit(slot_index)

func update_slot_display(slot_index: int):
	"""Update the visual display of a specific slot"""
	
	if slot_index >= hotbar_slots.size() or not target_inventory:
		return
	
	var slot_ui = hotbar_slots[slot_index]
	var inventory_slot = target_inventory.get_slot(slot_index)
	
	if not slot_ui or not inventory_slot:
		return
	
	# Get UI components
	var content = slot_ui.get_child(0) as VBoxContainer
	var icon = content.get_child(0) as TextureRect
	var quantity_label = content.get_child(1) as Label
	
	# Update selection style
	var is_selected = (slot_index == selected_slot)
	var is_empty = inventory_slot.is_empty()
	
	if is_selected:
		slot_ui.add_theme_stylebox_override("panel", selected_style)
	elif is_empty:
		slot_ui.add_theme_stylebox_override("panel", empty_style)
	else:
		slot_ui.add_theme_stylebox_override("panel", normal_style)
	
	# Update content
	if is_empty:
		icon.texture = null
		quantity_label.text = ""
		slot_ui.tooltip_text = "Empty Slot " + str(slot_index + 1) + " (Key: " + str(slot_index + 1) + ")"
	else:
		# Set item icon (placeholder for now)
		var item_icon = get_item_icon(inventory_slot.item_definition)
		icon.texture = item_icon
		
		# Set quantity/state text
		var display_text = ""
		if inventory_slot.quantity > 1:
			display_text = str(inventory_slot.quantity)
		elif inventory_slot.item_definition.has_states and inventory_slot.get_state() != inventory_slot.item_definition.default_state:
			display_text = inventory_slot.get_state().substr(0, 1).to_upper()  # First letter of state
		
		quantity_label.text = display_text
		
		# Update tooltip
		slot_ui.tooltip_text = inventory_slot.get_tooltip_text() + "\n(Key: " + str(slot_index + 1) + ")"
		
		# Add durability visual feedback
		if inventory_slot.item_definition.has_durability:
			var durability_percent = inventory_slot.get_durability_percentage()
			if durability_percent < 0.3:
				icon.modulate = Color.RED
			elif durability_percent < 0.6:
				icon.modulate = Color.YELLOW
			else:
				icon.modulate = Color.WHITE
		else:
			icon.modulate = Color.WHITE

func get_item_icon(item_definition) -> Texture2D:
	"""Get icon texture for an item (placeholder system)"""
	if not item_definition:
		return null
	
	# Use defined icon if available
	if item_definition.icon_texture:
		return item_definition.icon_texture
	
	# Placeholder icons based on item type
	match item_definition.item_id:
		"bucket":
			return create_placeholder_icon(Color.GRAY, "🪣")
		"berry_seeds":
			return create_placeholder_icon(Color.BROWN, "🌱")
		"watering_can":
			return create_placeholder_icon(Color.BLUE, "🚿")
		_:
			return create_placeholder_icon(Color.WHITE, "?")

func create_placeholder_icon(color: Color, _emoji: String) -> ImageTexture:
	"""Create a simple placeholder icon"""
	var image = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	image.fill(color)
	
	# Add a simple border
	for x in range(32):
		for y in range(32):
			if x == 0 or x == 31 or y == 0 or y == 31:
				image.set_pixel(x, y, Color.BLACK)
	
	var texture = ImageTexture.new()
	texture.set_image(image)
	return texture

func update_all_slots():
	"""Update all hotbar slot displays"""
	for i in range(hotbar_size):
		update_slot_display(i)

func set_selected_slot(slot_index: int):
	"""Set which slot is visually selected"""
	selected_slot = slot_index
	update_all_slots()

# Signal handlers
func _on_selected_slot_changed(new_slot: int, _old_slot: int):
	"""Handle hotbar selection changes"""
	set_selected_slot(new_slot)

# Hotbar interaction methods
func select_slot(slot_index: int):
	"""Programmatically select a slot"""
	if target_inventory and slot_index >= 0 and slot_index < hotbar_size:
		target_inventory.select_hotbar_slot(slot_index)

func use_selected_slot():
	"""Use the currently selected slot"""
	if target_inventory:
		return target_inventory.use_selected_item()
	return false

# Animation and effects
func animate_slot_use(slot_index: int):
	"""Animate slot usage feedback"""
	if slot_index >= hotbar_slots.size():
		return
	
	var slot_ui = hotbar_slots[slot_index]
	var tween = create_tween()
	
	# Scale animation
	tween.tween_property(slot_ui, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(slot_ui, "scale", Vector2(1.0, 1.0), 0.1)

func animate_item_added(slot_index: int):
	"""Animate when an item is added to a slot"""
	if slot_index >= hotbar_slots.size():
		return
	
	var slot_ui = hotbar_slots[slot_index]
	var content = slot_ui.get_child(0) as VBoxContainer
	var icon = content.get_child(0) as TextureRect
	
	# Fade in animation
	icon.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(icon, "modulate:a", 1.0, 0.3)

# Keyboard hint display
func show_keyboard_hints(show_hints: bool = true):
	"""Show/hide keyboard number hints on slots"""
	for i in range(hotbar_slots.size()):
		var slot_ui = hotbar_slots[i]
		var key_label = slot_ui.get_child(1) as Label  # Key label is second child
		key_label.visible = show_hints
