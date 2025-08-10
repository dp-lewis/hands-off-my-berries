extends Control

## Main Menu for the survival game
## Provides navigation to game, instructions, and quit

# UI References
@onready var play_button: Button = $CenterContainer/VBoxContainer/PlayButton
@onready var instructions_button: Button = $CenterContainer/VBoxContainer/InstructionsButton
@onready var quit_button: Button = $CenterContainer/VBoxContainer/QuitButton

func _ready():
	"""Initialize the main menu"""
	# Connect button signals
	if play_button:
		play_button.pressed.connect(_on_play_pressed)
	
	if instructions_button:
		instructions_button.pressed.connect(_on_instructions_pressed)
	
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)
	
	print("Main menu ready")

func _on_play_pressed():
	"""Start the main game"""
	print("Starting game...")
	
	# Load the main game scene
	var game_scene = "res://levels/level-test.tscn"
	
	if ResourceLoader.exists(game_scene):
		get_tree().change_scene_to_file(game_scene)
	else:
		print("Error: Game scene not found at ", game_scene)

func _on_instructions_pressed():
	"""Show the instructions"""
	print("Opening instructions...")
	
	# Load the instructions scene
	var instructions_scene = "res://instructions/instructions.tscn"
	
	if ResourceLoader.exists(instructions_scene):
		get_tree().change_scene_to_file(instructions_scene)
	else:
		print("Error: Instructions scene not found at ", instructions_scene)

func _on_quit_pressed():
	"""Quit the game"""
	print("Quitting game...")
	get_tree().quit()

func _input(event):
	"""Handle input events"""
	if event.is_action_pressed("ui_accept"):  # Enter key
		_on_play_pressed()
	elif event.is_action_pressed("ui_cancel"):  # ESC key
		_on_quit_pressed()
