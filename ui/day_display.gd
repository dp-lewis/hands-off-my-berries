extends Control

var day_label: Label

func _ready():
	day_label = $DayLabel

func _process(_delta):
	update_day_display()

func update_day_display():
	# Get day number from the day/night system
	var day_night_system = get_tree().get_first_node_in_group("day_night_system")
	
	if day_night_system and day_night_system.has_method("get_current_day") and day_label:
		var current_day = day_night_system.get_current_day()
		day_label.text = "Day " + str(current_day)
	elif day_label:
		day_label.text = "Day 1"
