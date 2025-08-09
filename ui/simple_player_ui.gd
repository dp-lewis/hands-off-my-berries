extends Control

var player_ref: Node3D = null
var stats_label: Label

func _ready():
	stats_label = $StatsLabel

func setup_for_player(player: Node3D):
	player_ref = player
	
	# Connect to ResourceManager signals for reactive resource updates
	if player_ref.resource_manager:
		player_ref.resource_manager.resource_changed.connect(_on_resource_changed)
	
	if stats_label:
		stats_label.text = "Player " + str(player.player_id + 1) + "\nHealth: 100\nHunger: 100\nTiredness: 100"

func _process(_delta):
	if player_ref and stats_label:
		update_stats()

func update_stats():
	var health_val = int(player_ref.health)
	var hunger_val = int(player_ref.hunger)
	var tiredness_val = int(player_ref.tiredness)
	
	# Get resource amounts from ResourceManager
	var wood_amount = player_ref.resource_manager.get_resource_amount("wood") if player_ref.resource_manager else 0
	var food_amount = player_ref.resource_manager.get_resource_amount("food") if player_ref.resource_manager else 0
	
	stats_label.text = "Player " + str(player_ref.player_id + 1) + "\nHealth: " + str(health_val) + "\nHunger: " + str(hunger_val) + "\nTiredness: " + str(tiredness_val) + "\nWood: " + str(wood_amount) + "\nFood: " + str(food_amount)

# ResourceManager signal handler for reactive resource updates
func _on_resource_changed(_resource_type: String, _old_amount: int, _new_amount: int):
	# Trigger a stats update when resources change
	if player_ref and stats_label:
		update_stats()
