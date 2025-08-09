extends Node3D

@export var wood_amount: int = 5

@onready var area_3d: Area3D = $Area3D

func _ready():
	# Connect area signal for player detection
	area_3d.body_entered.connect(_on_player_entered)

func _on_player_entered(body):
	# Check if it's a player that can collect wood
	if body.has_method("add_wood"):
		var space_available = body.get_inventory_space()
		
		if space_available <= 0:
			print("Player inventory full - can't collect wood!")
			return
		
		# Try to give the wood to the player
		var amount_to_give = min(wood_amount, space_available)
		var successfully_added = body.add_wood(amount_to_give)
		
		if successfully_added:
			# Player took all the wood
			queue_free()
		else:
			# Player couldn't take all wood, reduce pile amount
			wood_amount -= amount_to_give
			print("Wood pile now has ", wood_amount, " wood remaining")
