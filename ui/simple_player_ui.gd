extends Control

var player_ref: Node3D = null
var stats_label: Label

func _ready():
	stats_label = $StatsLabel

func setup_for_player(player: Node3D):
	player_ref = player
	if stats_label:
		stats_label.text = "Player " + str(player.player_id + 1) + "\nHealth: 100\nHunger: 100\nTiredness: 100"

func _process(_delta):
	if player_ref and stats_label:
		update_stats()

func update_stats():
	var health_val = int(player_ref.health)
	var hunger_val = int(player_ref.hunger)
	var tiredness_val = int(player_ref.tiredness)
	
	stats_label.text = "Player " + str(player_ref.player_id + 1) + "\nHealth: " + str(health_val) + "\nHunger: " + str(hunger_val) + "\nTiredness: " + str(tiredness_val)
