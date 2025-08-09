extends Control
class_name ResourceDisplay

# A reusable component for displaying a single resource with capacity
@export var resource_type: String = "wood"
@export var resource_icon: String = "🪵"
@export var show_capacity: bool = true

var resource_manager: Node = null
var amount_label: Label
var progress_bar: ProgressBar

signal resource_clicked(resource_type: String)

func _ready():
	setup_ui_elements()

func setup_ui_elements():
	# Create container
	var hbox = HBoxContainer.new()
	add_child(hbox)
	
	# Create icon label
	var icon_label = Label.new()
	icon_label.text = resource_icon
	icon_label.custom_minimum_size = Vector2(30, 0)
	hbox.add_child(icon_label)
	
	# Create amount label
	amount_label = Label.new()
	amount_label.text = "0"
	amount_label.custom_minimum_size = Vector2(60, 0)
	hbox.add_child(amount_label)
	
	# Create progress bar if showing capacity
	if show_capacity:
		progress_bar = ProgressBar.new()
		progress_bar.custom_minimum_size = Vector2(100, 20)
		progress_bar.max_value = 100
		progress_bar.value = 0
		hbox.add_child(progress_bar)

func connect_to_resource_manager(manager: Node):
	if resource_manager and resource_manager.is_connected("resource_changed", _on_resource_changed):
		resource_manager.disconnect("resource_changed", _on_resource_changed)
	
	resource_manager = manager
	if resource_manager:
		resource_manager.resource_changed.connect(_on_resource_changed)
		update_display()

func update_display():
	if not resource_manager:
		return
	
	var current_amount = resource_manager.get_resource_amount(resource_type)
	var max_capacity = resource_manager.get_max_capacity(resource_type)
	
	# Update amount label
	if amount_label:
		if show_capacity and max_capacity > 0:
			amount_label.text = str(current_amount) + "/" + str(max_capacity)
		else:
			amount_label.text = str(current_amount)
	
	# Update progress bar
	if progress_bar and max_capacity > 0:
		progress_bar.max_value = max_capacity
		progress_bar.value = current_amount
		
		# Color code based on fullness
		var percentage = float(current_amount) / float(max_capacity)
		if percentage >= 1.0:
			progress_bar.modulate = Color.RED  # Full
		elif percentage >= 0.8:
			progress_bar.modulate = Color.ORANGE  # Nearly full
		else:
			progress_bar.modulate = Color.GREEN  # Normal

func _on_resource_changed(changed_resource_type: String, _old_amount: int, _new_amount: int):
	if changed_resource_type == resource_type:
		update_display()

func set_resource_type(new_type: String, new_icon: String = ""):
	resource_type = new_type
	if new_icon != "":
		resource_icon = new_icon
	update_display()

# Optional: Make the resource display clickable
func _gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		resource_clicked.emit(resource_type)
