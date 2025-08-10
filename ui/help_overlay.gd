extends Control

## In-game help overlay
## Shows basic controls and can link to full instructions

@onready var help_panel: Panel = $HelpPanel
@onready var close_button: Button = $HelpPanel/VBoxContainer/CloseButton
@onready var full_instructions_button: Button = $HelpPanel/VBoxContainer/FullInstructionsButton

var help_is_showing: bool = false

func _ready():
	"""Initialize the help overlay"""
	# Start hidden
	visible = false
	help_is_showing = false
	
	# Connect buttons
	if close_button:
		close_button.pressed.connect(hide_help)
	
	if full_instructions_button:
		full_instructions_button.pressed.connect(show_full_instructions)
	
	print("Help overlay ready")

func _input(event):
	"""Handle input for showing/hiding help"""
	if event.is_action_pressed("show_help"):
		toggle_help()

func show_help():
	"""Show the help overlay"""
	visible = true
	help_is_showing = true
	
	# Pause the game when showing help
	if get_tree():
		get_tree().paused = true

func hide_help():
	"""Hide the help overlay"""
	visible = false
	help_is_showing = false
	
	# Unpause the game when hiding help
	if get_tree():
		get_tree().paused = false

func toggle_help():
	"""Toggle help visibility"""
	if help_is_showing:
		hide_help()
	else:
		show_help()

func show_full_instructions():
	"""Switch to full instructions scene"""
	print("Opening full instructions...")
	
	# Unpause before switching scenes
	if get_tree():
		get_tree().paused = false
	
	# Load the instructions scene
	var instructions_scene = "res://instructions/instructions.tscn"
	if ResourceLoader.exists(instructions_scene):
		get_tree().change_scene_to_file(instructions_scene)
	else:
		print("Error: Instructions scene not found")
