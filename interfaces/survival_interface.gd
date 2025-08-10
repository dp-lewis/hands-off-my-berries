## Survival component interface  
## Defines the contract for player survival components

class_name SurvivalInterface

## Process all survival mechanics (hunger, health, tiredness)
func process_survival(_delta: float) -> void:
	pass

## Reduce tiredness from player activities
func lose_tiredness(_amount: float, _activity: String = "") -> void:
	pass

## Consume food to restore hunger
func consume_food(_amount: float) -> bool:
	return false

## Apply night time penalties to survival stats
func apply_night_penalty() -> void:
	pass

## Apply shelter recovery effects
func apply_shelter_recovery(_delta: float) -> void:
	pass

## Get current health value
func get_health() -> float:
	return 0.0

## Get current hunger value  
func get_hunger() -> float:
	return 0.0

## Get current tiredness value
func get_tiredness() -> float:
	return 0.0

## Check if player has died
func is_dead() -> bool:
	return false
