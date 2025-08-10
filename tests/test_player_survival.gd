# Player Survival Component Tests
extends Node

func test_assert(condition: bool, message: String):
	if condition:
		print("✓ ", message)
	else:
		print("✗ FAILED: ", message)
		push_error("Test failed: " + message)

func _ready():
	print("=== SURVIVAL COMPONENT TEST ===")
	
	# Test 1: Basic component creation
	test_survival_component_creation()
	
	# Test 2: Survival initialization
	test_survival_initialization()
	
	# Test 3: Health system
	test_health_system()
	
	# Test 4: Hunger system
	test_hunger_system()
	
	# Test 5: Tiredness system
	test_tiredness_system()
	
	# Test 6: Shelter system
	test_shelter_system()
	
	print("=== SURVIVAL COMPONENT TEST COMPLETE ===")
	get_tree().quit()

func test_survival_component_creation():
	var survival_script = load("res://components/player_survival.gd")
	test_assert(survival_script != null, "PlayerSurvival script loads successfully")
	
	var survival = survival_script.new()
	test_assert(survival != null, "PlayerSurvival instance created")
	test_assert(survival.health == 100.0, "Default health is 100")
	test_assert(survival.hunger == 100.0, "Default hunger is 100")
	test_assert(survival.tiredness == 100.0, "Default tiredness is 100")
	test_assert(survival.is_night_time == false, "Default is day time")
	test_assert(survival.is_in_shelter == false, "Default not in shelter")
	
	survival.queue_free()

func test_survival_initialization():
	var survival_script = load("res://components/player_survival.gd")
	var controller_script = load("res://components/player_controller.gd")
	
	var survival = survival_script.new()
	var controller = controller_script.new()
	controller.player_id = 1
	
	# Initialize survival component
	survival.initialize(controller)
	
	test_assert(survival.is_component_ready(), "Survival component initialized successfully")
	test_assert(survival.get_player_id() == 1, "Survival component has correct player ID")
	
	survival.cleanup()
	survival.queue_free()
	controller.queue_free()

func test_health_system():
	var survival_script = load("res://components/player_survival.gd")
	var survival = survival_script.new()
	
	# Test health getters
	test_assert(survival.get_health() == 100.0, "Initial health getter works")
	test_assert(survival.get_health_percentage() == 1.0, "Health percentage is 100%")
	test_assert(not survival.is_critical_health(), "Initial health is not critical")
	
	# Test damage
	survival.take_damage(30.0)
	test_assert(survival.get_health() == 70.0, "Damage reduces health correctly")
	test_assert(survival.get_health_percentage() == 0.7, "Health percentage updates after damage")
	
	# Test critical health
	survival.take_damage(50.0)
	test_assert(survival.is_critical_health(), "Health becomes critical below 25")
	
	# Test healing
	survival.heal(30.0)
	test_assert(survival.get_health() == 50.0, "Healing increases health")
	test_assert(not survival.is_critical_health(), "Health no longer critical after healing")
	
	# Test max health cap
	survival.heal(100.0)
	test_assert(survival.get_health() == 100.0, "Health cannot exceed maximum")
	
	survival.queue_free()

func test_hunger_system():
	var survival_script = load("res://components/player_survival.gd")
	var survival = survival_script.new()
	
	# Test hunger getters
	test_assert(survival.get_hunger() == 100.0, "Initial hunger getter works")
	test_assert(survival.get_hunger_percentage() == 1.0, "Hunger percentage is 100%")
	test_assert(not survival.is_starving(), "Initially not starving")
	
	# Test hunger decrease
	survival.hunger = 0.0  # Simulate starvation
	test_assert(survival.is_starving(), "Starving when hunger is 0")
	test_assert(survival.get_hunger_percentage() == 0.0, "Hunger percentage is 0% when starving")
	
	# Test consume food (without resource manager)
	var consumed = survival.consume_food()
	test_assert(not consumed, "Cannot consume food without resource manager")
	
	survival.queue_free()

func test_tiredness_system():
	var survival_script = load("res://components/player_survival.gd")
	var survival = survival_script.new()
	
	# Test tiredness getters
	test_assert(survival.get_tiredness() == 100.0, "Initial tiredness getter works")
	test_assert(survival.get_tiredness_percentage() == 1.0, "Tiredness percentage is 100%")
	test_assert(not survival.is_exhausted(), "Initially not exhausted")
	
	# Test lose tiredness
	survival.lose_tiredness(50.0, "testing")
	test_assert(survival.get_tiredness() == 50.0, "Lose tiredness reduces tiredness")
	test_assert(survival.get_tiredness_percentage() == 0.5, "Tiredness percentage updates")
	
	# Test exhaustion
	survival.tiredness = 0.0
	test_assert(survival.is_exhausted(), "Exhausted when tiredness is 0")
	
	survival.queue_free()

func test_shelter_system():
	var survival_script = load("res://components/player_survival.gd")
	var survival = survival_script.new()
	var mock_shelter = Node3D.new()
	mock_shelter.name = "TestShelter"
	
	# Test initial shelter state
	test_assert(not survival.is_sheltered(), "Initially not sheltered")
	test_assert(survival.get_current_shelter() == null, "No initial shelter")
	
	# Test entering shelter
	survival.enter_shelter(mock_shelter)
	test_assert(survival.is_sheltered(), "Sheltered after entering")
	test_assert(survival.get_current_shelter() == mock_shelter, "Current shelter is correct")
	
	# Test night penalties
	survival.apply_night_penalty()
	test_assert(survival.is_night_time == true, "Night time set correctly")
	
	survival.apply_day_recovery()
	test_assert(survival.is_night_time == false, "Day time set correctly")
	
	# Test exiting shelter
	survival.exit_shelter()
	test_assert(not survival.is_sheltered(), "Not sheltered after exiting")
	test_assert(survival.get_current_shelter() == null, "No current shelter after exiting")
	
	mock_shelter.queue_free()
	survival.queue_free()
