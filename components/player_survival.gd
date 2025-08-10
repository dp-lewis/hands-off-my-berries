# PlayerSurvival Component
# Handles player health, hunger, tiredness, and survival mechanics
extends "res://components/player_component.gd"

# Survival stats
var health: float = 100.0
var max_health: float = 100.0
var hunger: float = 100.0
var max_hunger: float = 100.0
var tiredness: float = 100.0
var max_tiredness: float = 100.0

# Night and shelter state
var is_night_time: bool = false
var is_in_shelter: bool = false
var current_shelter: Node3D = null

# Survival configuration (export for easy tweaking)
@export var hunger_decrease_rate: float = 2.0  # Hunger lost per minute
@export var health_decrease_rate: float = 5.0  # Health lost per minute when starving
@export var auto_eat_threshold: float = 30.0  # Auto-eat when hunger drops below this
@export var pumpkin_hunger_restore: float = 25.0  # How much hunger pumpkins restore

@export var base_tiredness_rate: float = 3.0  # Base tiredness lost per minute
@export var walking_tiredness_rate: float = 0.3  # Tiredness lost per second while moving
@export var night_tiredness_penalty: float = 2.0  # Additional tiredness lost per minute at night without shelter
@export var tent_recovery_rate: float = 10.0  # Tiredness recovered per minute in tent
@export var tiredness_health_decrease_rate: float = 3.0  # Health lost per minute when exhausted

# Component references
var resource_manager = null
var is_player_moving: bool = false

# Logging timers (to avoid spam)
var hunger_log_timer: float = 0.0
var tiredness_log_timer: float = 0.0
var health_log_timer: float = 0.0

func _on_initialize():
	"""Initialize survival component"""
	if not player_controller:
		emit_error("PlayerSurvival: No controller provided")
		return
	
	# Find resource manager
	find_resource_manager()
	
	# Connect to movement component if available
	connect_to_movement_component()
	
	print("PlayerSurvival: Initialized for player ", get_player_id())

func _on_cleanup():
	"""Clean up survival component"""
	resource_manager = null
	current_shelter = null
	is_player_moving = false

func find_resource_manager():
	"""Find the resource manager in the controller"""
	if player_controller:
		resource_manager = player_controller.get_node_or_null("ResourceManager")
		if resource_manager:
			print("PlayerSurvival: Found ResourceManager")
		else:
			print("PlayerSurvival: No ResourceManager found")

func connect_to_movement_component():
	"""Connect to movement component signals"""
	var movement = get_sibling_component("PlayerMovement")
	if movement:
		if movement.has_signal("movement_started"):
			movement.movement_started.connect(_on_movement_started)
		if movement.has_signal("movement_stopped"):
			movement.movement_stopped.connect(_on_movement_stopped)
		print("PlayerSurvival: Connected to movement component")

func _on_movement_started():
	"""Called when player starts moving"""
	is_player_moving = true

func _on_movement_stopped():
	"""Called when player stops moving"""
	is_player_moving = false

# Survival Interface Implementation

func process_survival(delta: float) -> void:
	"""Main survival processing - call this every frame"""
	handle_hunger_system(delta)
	handle_tiredness_system(delta)
	update_log_timers(delta)

func handle_hunger_system(delta: float):
	"""Process hunger decrease and auto-eating"""
	var was_starving = hunger <= 0.0
	
	# Decrease hunger over time (convert rate from per-minute to per-second)
	hunger -= (hunger_decrease_rate / 60.0) * delta
	hunger = max(hunger, 0.0)
	
	# Check for starvation state changes
	var is_starving_now = hunger <= 0.0
	if is_starving_now and not was_starving:
		started_starving.emit()
	elif not is_starving_now and was_starving:
		stopped_starving.emit()
	
	# Log hunger status occasionally
	if hunger_log_timer <= 0.0:
		var current_food = resource_manager.get_resource_amount("food") if resource_manager else 0
		print("Player ", get_player_id(), " - Hunger: ", int(hunger), "/", int(max_hunger), " Food: ", current_food)
		hunger_log_timer = 5.0  # Log every 5 seconds
	
	# Auto-eat if hunger is low and we have food
	var has_food = resource_manager.get_resource_amount("food") > 0 if resource_manager else false
	if hunger <= auto_eat_threshold and has_food:
		consume_food()
	
	# If hunger reaches 0, start losing health
	if hunger <= 0.0:
		take_damage((health_decrease_rate / 60.0) * delta)
		if health_log_timer <= 0.0:
			print("Player ", get_player_id(), " is starving! Health: ", int(health))
			health_log_timer = 3.0  # Log every 3 seconds when starving

func handle_tiredness_system(delta: float):
	"""Process tiredness changes based on activity and environment"""
	var was_exhausted = tiredness <= 0.0
	
	# Base tiredness decrease over time
	tiredness -= (base_tiredness_rate / 60.0) * delta
	
	# Additional tiredness from walking/moving
	if is_player_moving:
		tiredness -= walking_tiredness_rate * delta
	
	# Apply night tiredness penalty if not in shelter
	if is_night_time and not is_in_shelter:
		tiredness -= (night_tiredness_penalty / 60.0) * delta
	
	# Recover tiredness if in shelter
	if is_in_shelter:
		tiredness += (tent_recovery_rate / 60.0) * delta
	
	# Clamp tiredness to valid range
	tiredness = clamp(tiredness, 0.0, max_tiredness)
	
	# Check for exhaustion state changes
	var is_exhausted_now = tiredness <= 0.0
	if is_exhausted_now and not was_exhausted:
		started_exhaustion.emit()
	elif not is_exhausted_now and was_exhausted:
		stopped_exhaustion.emit()
	
	# Log tiredness status occasionally
	if tiredness_log_timer <= 0.0:
		var status = " (Resting)" if is_in_shelter else ""
		if is_night_time and not is_in_shelter:
			status += " (Night Exhaustion)"
		print("Player ", get_player_id(), " - Tiredness: ", int(tiredness), "/", int(max_tiredness), status)
		tiredness_log_timer = 7.0  # Log every 7 seconds
	
	# If tiredness reaches 0, start losing health
	if tiredness <= 0.0:
		take_damage((tiredness_health_decrease_rate / 60.0) * delta)
		if health_log_timer <= 0.0:
			print("Player ", get_player_id(), " is exhausted! Health: ", int(health))
			health_log_timer = 4.0  # Log every 4 seconds when exhausted

func update_log_timers(delta: float):
	"""Update logging timers to prevent spam"""
	hunger_log_timer = max(hunger_log_timer - delta, 0.0)
	tiredness_log_timer = max(tiredness_log_timer - delta, 0.0)
	health_log_timer = max(health_log_timer - delta, 0.0)

func consume_food() -> bool:
	"""Consume food to restore hunger"""
	if resource_manager and resource_manager.get_resource_amount("food") > 0:
		resource_manager.remove_resource("food", 1)
		hunger = min(hunger + pumpkin_hunger_restore, max_hunger)
		var remaining_food = resource_manager.get_resource_amount("food")
		print("Player ", get_player_id(), " auto-ate food! Hunger restored to ", int(hunger), " (", remaining_food, " food remaining)")
		hunger_changed.emit(hunger, max_hunger)
		return true
	return false

func lose_tiredness(amount: float, activity: String = "") -> void:
	"""Manually decrease tiredness from activities"""
	tiredness = max(tiredness - amount, 0.0)
	if activity != "":
		print("Player ", get_player_id(), " is tired from ", activity, " (Tiredness: ", int(tiredness), ")")
	tiredness_changed.emit(tiredness, max_tiredness)

func take_damage(amount: float):
	"""Apply damage to the player"""
	var was_critical = health < 25.0
	health = max(health - amount, 0.0)
	health_changed.emit(health, max_health)
	
	# Check for critical health warning
	var is_critical_now = health < 25.0 and health > 0.0
	if is_critical_now and not was_critical:
		critical_health_warning.emit()
	
	if health <= 0.0:
		print("Player ", get_player_id(), " has died!")
		player_died.emit()
		respawn_player()
	elif health < 25.0:
		print("Player ", get_player_id(), " is in critical condition! (", int(health), "/", int(max_health), " health)")

func heal(amount: float):
	"""Heal the player"""
	health = min(health + amount, max_health)
	health_changed.emit(health, max_health)

func respawn_player():
	"""Respawn the player with full health"""
	health = max_health
	hunger = max_hunger
	tiredness = max_tiredness
	
	# Reset player position through controller
	if player_controller:
		player_controller.global_position = Vector3.ZERO
	
	print("Player ", get_player_id(), " has respawned")
	health_changed.emit(health, max_health)
	hunger_changed.emit(hunger, max_hunger)
	tiredness_changed.emit(tiredness, max_tiredness)

# Night and Day System

func apply_night_penalty() -> void:
	"""Apply night penalties - called by day/night system"""
	is_night_time = true
	if not is_in_shelter:
		print("Player ", get_player_id(), " is exposed to night dangers!")

func apply_day_recovery() -> void:
	"""Apply day recovery - called by day/night system"""
	is_night_time = false

# Shelter System

func apply_shelter_recovery(delta: float) -> void:
	"""Apply shelter recovery - called when in shelter"""
	if is_in_shelter:
		tiredness += (tent_recovery_rate / 60.0) * delta
		tiredness = min(tiredness, max_tiredness)

func enter_shelter(shelter: Node3D) -> void:
	"""Enter a shelter"""
	is_in_shelter = true
	current_shelter = shelter
	print("Player ", get_player_id(), " entered shelter")
	shelter_entered.emit(shelter)

func exit_shelter() -> void:
	"""Exit current shelter"""
	var old_shelter = current_shelter
	is_in_shelter = false
	current_shelter = null
	print("Player ", get_player_id(), " exited shelter")
	shelter_exited.emit(old_shelter)

# Getters for UI and other systems

func get_health() -> float:
	return health

func get_health_percentage() -> float:
	return health / max_health if max_health > 0 else 0.0

func get_hunger() -> float:
	return hunger

func get_hunger_percentage() -> float:
	return hunger / max_hunger if max_hunger > 0 else 0.0

func get_tiredness() -> float:
	return tiredness

func get_tiredness_percentage() -> float:
	return tiredness / max_tiredness if max_tiredness > 0 else 0.0

func is_sheltered() -> bool:
	return is_in_shelter

func get_current_shelter() -> Node3D:
	return current_shelter

func is_starving() -> bool:
	return hunger <= 0.0

func is_exhausted() -> bool:
	return tiredness <= 0.0

func is_critical_health() -> bool:
	return health < 25.0

# Signals for UI and other components
signal health_changed(new_health: float, max_health: float)
signal hunger_changed(new_hunger: float, max_hunger: float)
signal tiredness_changed(new_tiredness: float, max_tiredness: float)
signal player_died
signal shelter_entered(shelter: Node3D)
signal shelter_exited(shelter: Node3D)

# Status change signals
signal started_starving
signal stopped_starving
signal started_exhaustion
signal stopped_exhaustion
signal critical_health_warning
