# PlayerSurvival Component
# Handles player health, hunger, tiredness, and survival mechanics
extends "res://components/player_component.gd"

# Survival stats
var health: float = 100.0
var max_health: float = 100.0
var hunger: float = 100.0
var max_hunger: float = 100.0
var thirst: float = 100.0
var max_thirst: float = 100.0
var tiredness: float = 100.0
var max_tiredness: float = 100.0

# Night and shelter state
var is_night_time: bool = false
var is_in_shelter: bool = false
var current_shelter: Node3D = null
var is_dead: bool = false

# Survival configuration (export for easy tweaking)
@export var hunger_decrease_rate: float = 15.0  # Hunger lost per minute
@export var thirst_decrease_rate: float = 30.0  # Thirst lost per minute (faster than hunger)
@export var health_decrease_rate: float = 5.0  # Health lost per minute when starving
@export var auto_eat_threshold: float = 30.0  # Auto-eat when hunger drops below this
@export var pumpkin_hunger_restore: float = 25.0  # How much hunger pumpkins restore
@export var water_thirst_restore: float = 40.0  # How much thirst water restores (when implemented)

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
var thirst_log_timer: float = 0.0
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
	var movement = get_sibling_component("movement")
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
	# Don't process survival if player is dead
	if is_dead:
		return
		
	handle_hunger_system(delta)
	handle_thirst_system(delta)
	handle_tiredness_system(delta)
	update_log_timers(delta)

func handle_hunger_system(delta: float):
	"""Process hunger decrease and auto-eating"""
	var was_starving = hunger <= 0.0
	
	# Calculate hunger decrease rate with tiredness acceleration
	var base_rate = hunger_decrease_rate / 60.0  # Convert per-minute to per-second
	var tiredness_multiplier = calculate_tiredness_acceleration()
	var actual_hunger_rate = base_rate * tiredness_multiplier
	
	# Decrease hunger over time
	hunger -= actual_hunger_rate * delta
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
		var tiredness_mult = calculate_tiredness_acceleration()
		var status_text = ""
		if tiredness_mult > 1.1:  # Show when acceleration is significant
			status_text = " (Tired: " + str(round(tiredness_mult * 100)) + "% rate)"
		print("Player ", get_player_id(), " - Hunger: ", int(hunger), "/", int(max_hunger), " Food: ", current_food, status_text)
		hunger_log_timer = 5.0  # Log every 5 seconds
	
	# Auto-eat if hunger is low and we have food
	var has_food = resource_manager.get_resource_amount("food") > 0 if resource_manager else false
	if hunger <= auto_eat_threshold and has_food:
		consume_food()
	
	# If hunger reaches 0, start losing health
	if hunger <= 0.0:
		var damage_multiplier = calculate_survival_crisis_multiplier()
		take_damage((health_decrease_rate / 60.0) * damage_multiplier * delta)
		if health_log_timer <= 0.0:
			var crisis_text = " (CRISIS!)" if damage_multiplier > 1.5 else ""
			print("Player ", get_player_id(), " is starving! Health: ", int(health), crisis_text)
			health_log_timer = 3.0  # Log every 3 seconds when starving

func handle_thirst_system(delta: float):
	"""Process thirst decrease - similar to hunger but no auto-drink yet"""
	var was_dehydrated = thirst <= 0.0
	
	# Calculate thirst decrease rate with tiredness acceleration
	var base_rate = thirst_decrease_rate / 60.0  # Convert per-minute to per-second
	var tiredness_multiplier = calculate_tiredness_acceleration()
	var actual_thirst_rate = base_rate * tiredness_multiplier
	
	# Decrease thirst over time
	thirst -= actual_thirst_rate * delta
	thirst = max(thirst, 0.0)
	
	# Check for dehydration state changes
	var is_dehydrated_now = thirst <= 0.0
	if is_dehydrated_now and not was_dehydrated:
		started_dehydration.emit()
	elif not is_dehydrated_now and was_dehydrated:
		stopped_dehydration.emit()
	
	# Log thirst status occasionally
	if thirst_log_timer <= 0.0:
		var tiredness_mult = calculate_tiredness_acceleration()
		var status_text = ""
		if tiredness_mult > 1.1:  # Show when acceleration is significant
			status_text = " (Tired: " + str(round(tiredness_mult * 100)) + "% rate)"
		print("Player ", get_player_id(), " - Thirst: ", int(thirst), "/", int(max_thirst), status_text)
		thirst_log_timer = 5.0  # Log every 5 seconds
	
	# If thirst reaches 0, start losing health (dehydration is dangerous!)
	if thirst <= 0.0:
		var damage_multiplier = calculate_survival_crisis_multiplier()
		take_damage((health_decrease_rate / 60.0) * damage_multiplier * delta)
		if health_log_timer <= 0.0:
			var crisis_text = " (CRISIS!)" if damage_multiplier > 1.5 else ""
			print("Player ", get_player_id(), " is dehydrated! Health: ", int(health), crisis_text)
			health_log_timer = 3.0  # Log every 3 seconds when dehydrated

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
		var damage_multiplier = calculate_survival_crisis_multiplier()
		take_damage((tiredness_health_decrease_rate / 60.0) * damage_multiplier * delta)
		if health_log_timer <= 0.0:
			var crisis_text = " (CRISIS!)" if damage_multiplier > 1.5 else ""
			print("Player ", get_player_id(), " is exhausted! Health: ", int(health), crisis_text)
			health_log_timer = 4.0  # Log every 4 seconds when exhausted

func update_log_timers(delta: float):
	"""Update logging timers to prevent spam"""
	hunger_log_timer = max(hunger_log_timer - delta, 0.0)
	thirst_log_timer = max(thirst_log_timer - delta, 0.0)
	tiredness_log_timer = max(tiredness_log_timer - delta, 0.0)
	health_log_timer = max(health_log_timer - delta, 0.0)

func calculate_tiredness_acceleration() -> float:
	"""Calculate acceleration multiplier for hunger and thirst based on tiredness"""
	# When tiredness is high (well-rested), multiplier is 1.0 (normal rate)
	# When tiredness is low (tired), multiplier increases up to 2.0 (double rate)
	var tiredness_percentage = get_tiredness_percentage()
	
	# Inverse relationship: lower tiredness = higher acceleration
	# At 100% tiredness: 1.0x multiplier (normal)
	# At 50% tiredness: 1.5x multiplier 
	# At 0% tiredness: 2.0x multiplier (exhausted, double consumption)
	var acceleration_multiplier = 1.0 + (1.0 - tiredness_percentage)
	
	return acceleration_multiplier

func calculate_survival_crisis_multiplier() -> float:
	"""Calculate health damage multiplier when multiple survival stats are critical"""
	var crisis_count = 0
	var low_count = 0
	var base_multiplier = 1.0
	
	# Count critical (0%) and low (below 25%) survival stats
	if hunger <= 0.0:
		crisis_count += 1
	elif hunger < 25.0:
		low_count += 1
		
	if thirst <= 0.0:
		crisis_count += 1
	elif thirst < 25.0:
		low_count += 1
		
	if tiredness <= 0.0:
		crisis_count += 1
	elif tiredness < 25.0:
		low_count += 1
	
	# Apply exponential scaling for multiple crises
	match crisis_count:
		0:
			# No critical stats, but check for low stats
			match low_count:
				1:
					base_multiplier = 1.2  # 1.2x damage for one low stat
				2:
					base_multiplier = 1.5  # 1.5x damage for two low stats
				3:
					base_multiplier = 1.8  # 1.8x damage for all three low stats
				_:
					base_multiplier = 1.0
		1:
			# One critical stat
			match low_count:
				0:
					base_multiplier = 1.0  # Normal damage for single crisis
				1:
					base_multiplier = 1.5  # 1.5x damage (1 critical + 1 low)
				2:
					base_multiplier = 2.0  # 2x damage (1 critical + 2 low)
				_:
					base_multiplier = 1.0
		2:
			# Two critical stats
			match low_count:
				0:
					base_multiplier = 2.5  # 2.5x damage for double crisis
				1:
					base_multiplier = 3.5  # 3.5x damage (2 critical + 1 low)
				_:
					base_multiplier = 2.5
		3:
			base_multiplier = 5.0  # 5x damage for triple crisis (very dangerous!)
		_:
			base_multiplier = 1.0
	
	return base_multiplier

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
	var original_tiredness = tiredness
	tiredness = max(tiredness - amount, 0.0)
	
	# If tiredness was already at zero, deduct overflow from health
	if original_tiredness <= 0.0 and amount > 0.0:
		var health_damage = amount * 2.0  # 2x conversion rate (tiredness -> health damage)
		take_damage(health_damage)
		if activity != "":
			print("Player ", get_player_id(), " is exhausted! Activity '", activity, "' caused ", int(health_damage), " health damage")
		else:
			print("Player ", get_player_id(), " is exhausted! Lost ", int(health_damage), " health from overexertion")
	elif activity != "":
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
		trigger_death_sequence()
	elif health < 25.0:
		print("Player ", get_player_id(), " is in critical condition! (", int(health), "/", int(max_health), " health)")

func trigger_death_sequence():
	"""Handle player death - trigger animation and disable player"""
	# Mark player as dead to stop survival processing
	is_dead = true
	
	# Stop all survival processing by disabling movement and interactions
	if player_controller:
		# Disable movement
		var movement = get_sibling_component("movement")
		if movement and movement.has_method("set_movement_enabled"):
			movement.set_movement_enabled(false)
		
		# Disable interactions
		var interaction = get_sibling_component("interaction")
		if interaction and interaction.has_method("set_interaction_enabled"):
			interaction.set_interaction_enabled(false)
		
		# Trigger death animation through movement component
		if movement and movement.has_method("play_death_animation"):
			movement.play_death_animation()
		else:
			# Fallback: signal for death animation if method doesn't exist
			death_animation_requested.emit()
	
	# Stop processing survival systems (player is dead)
	print("Player ", get_player_id(), " death sequence initiated - no respawn")

func heal(amount: float):
	"""Heal the player"""
	health = min(health + amount, max_health)
	health_changed.emit(health, max_health)

func respawn_player():
	"""Respawn the player with full health - call manually to revive"""
	# Reset death state
	is_dead = false
	
	# Restore all stats
	health = max_health
	hunger = max_hunger
	thirst = max_thirst
	tiredness = max_tiredness
	
	# Re-enable movement and interactions
	if player_controller:
		var movement = get_sibling_component("movement")
		if movement and movement.has_method("set_movement_enabled"):
			movement.set_movement_enabled(true)
		
		var interaction = get_sibling_component("interaction")
		if interaction and interaction.has_method("set_interaction_enabled"):
			interaction.set_interaction_enabled(true)
		
		# Reset player position
		player_controller.global_position = Vector3.ZERO
	
	print("Player ", get_player_id(), " has been manually respawned")
	health_changed.emit(health, max_health)
	hunger_changed.emit(hunger, max_hunger)
	thirst_changed.emit(thirst, max_thirst)
	tiredness_changed.emit(tiredness, max_tiredness)

# Night and Day System

func on_day_started() -> void:
	"""Called when day starts - interface for PlayerController"""
	apply_day_recovery()

func on_night_started() -> void:
	"""Called when night starts - interface for PlayerController"""
	apply_night_penalty()

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

func get_max_health() -> float:
	return max_health

func get_hunger() -> float:
	return hunger

func get_hunger_percentage() -> float:
	return hunger / max_hunger if max_hunger > 0 else 0.0

func get_max_hunger() -> float:
	return max_hunger

func get_thirst() -> float:
	return thirst

func get_thirst_percentage() -> float:
	return thirst / max_thirst if max_thirst > 0 else 0.0

func get_max_thirst() -> float:
	return max_thirst

func get_tiredness() -> float:
	return tiredness

func get_tiredness_percentage() -> float:
	return tiredness / max_tiredness if max_tiredness > 0 else 0.0

func get_max_tiredness() -> float:
	return max_tiredness

func is_sheltered() -> bool:
	return is_in_shelter

func get_current_shelter() -> Node3D:
	return current_shelter

func is_starving() -> bool:
	return hunger <= 0.0

func is_dehydrated() -> bool:
	return thirst <= 0.0

func is_exhausted() -> bool:
	return tiredness <= 0.0

func is_critical_health() -> bool:
	return health < 25.0

func is_player_dead() -> bool:
	return is_dead

# Signals for UI and other components
signal health_changed(new_health: float, max_health: float)
signal hunger_changed(new_hunger: float, max_hunger: float)
signal thirst_changed(new_thirst: float, max_thirst: float)
signal tiredness_changed(new_tiredness: float, max_tiredness: float)
signal player_died
signal death_animation_requested
signal shelter_entered(shelter: Node3D)
signal shelter_exited(shelter: Node3D)

# Status change signals
signal started_starving
signal stopped_starving
signal started_dehydration
signal stopped_dehydration
signal started_exhaustion
signal stopped_exhaustion
signal critical_health_warning
