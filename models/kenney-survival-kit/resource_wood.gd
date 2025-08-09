extends Node3D

@export var wood_amount: int = 5

@onready var area_3d: Area3D = $Area3D

func _ready():
	# Connect area signal for player detection
	area_3d.body_entered.connect(_on_player_entered)

func _on_player_entered(body):
	# Check if it's a player that can collect wood
	if body.has_method("add_wood"):
		body.add_wood(wood_amount)
		print("Collected ", wood_amount, " wood!")
		
		# Remove the wood pile after collection
		queue_free()
