extends Control

## Instructions scene for the survival game
## Shows comprehensive how-to-play information and navigation

# UI References
@onready var start_game_button: Button = $MainPanel/VBoxContainer/ButtonContainer/StartGameButton
@onready var back_button: Button = $MainPanel/VBoxContainer/ButtonContainer/BackButton
@onready var instructions_text: RichTextLabel = $MainPanel/VBoxContainer/ScrollContainer/InstructionsText

func _ready():
	"""Initialize the instructions scene"""
	# Connect button signals
	if start_game_button:
		start_game_button.pressed.connect(_on_start_game_pressed)
	
	if back_button:
		back_button.pressed.connect(_on_back_pressed)
	
	# Set up text formatting
	setup_instructions_text()
	
	print("Instructions scene ready")

func setup_instructions_text():
	"""Configure the instructions text formatting"""
	if instructions_text:
		instructions_text.scroll_to_line(0)  # Start at top
		
func _on_start_game_pressed():
	"""Start the main game"""
	print("Starting game from instructions...")
	
	# Load the main game scene
	var game_scene = "res://levels/level-test.tscn"
	
	if ResourceLoader.exists(game_scene):
		get_tree().change_scene_to_file(game_scene)
	else:
		print("Error: Game scene not found at ", game_scene)

func _on_back_pressed():
	"""Go back to main menu"""
	print("Going back to main menu...")
	
	# Try to load main menu scene - you can customize this path
	var main_menu_scene = "res://ui/main_menu.tscn"
	
	if ResourceLoader.exists(main_menu_scene):
		get_tree().change_scene_to_file(main_menu_scene)
	else:
		# If no main menu exists, just go to game
		print("No main menu found, going to game...")
		_on_start_game_pressed()

func _input(event):
	"""Handle input events"""
	if event.is_action_pressed("ui_cancel"):  # ESC key
		_on_back_pressed()
	elif event.is_action_pressed("ui_accept"):  # Enter key
		_on_start_game_pressed()

# Public methods for external access
func show_instructions():
	"""Show the instructions scene"""
	visible = true

func hide_instructions():
	"""Hide the instructions scene"""
	visible = false

func update_instructions_text(new_text: String):
	"""Update the instructions text content"""
	if instructions_text:
		instructions_text.text = new_text
