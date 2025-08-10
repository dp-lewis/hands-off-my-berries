# Player Refactoring - Unit Testing Plan

**Project:** Metropolis Player System Refactoring  
**Date Created:** August 10, 2025  
**Testing Framework:** Custom SceneTree-based tests + GUT (when available)  
**Coverage Goal:** 90%+ per component

## 🎯 Testing Strategy Overview

### **Testing Philosophy**
- **Test-Driven Component Development** - Write tests before or alongside each component
- **Isolated Unit Testing** - Each component tested independently with mocks
- **Integration Testing** - Test component communication and coordination
- **Regression Testing** - Ensure existing functionality preserved
- **Performance Testing** - Validate component overhead is minimal

### **Testing Levels**
1. **Unit Tests** - Individual component logic (90% of tests)
2. **Integration Tests** - Component communication (8% of tests)
3. **End-to-End Tests** - Full player functionality (2% of tests)

## 📋 Component-by-Component Testing Plan

### **Step 1: PlayerComponent Base Class Tests**
**File:** `tests/test_player_component.gd`

**Test Coverage:**
```gdscript
extends SceneTree

func _initialize():
    print("=== PLAYER COMPONENT BASE TESTS ===")
    
    test_component_initialization()
    test_component_lifecycle()
    test_component_error_handling()
    test_signal_emission()
    
    print("=== COMPONENT BASE TESTS COMPLETE ===")
    quit()

func test_component_initialization():
    # Test base component setup
    var component = PlayerComponent.new()
    var controller = PlayerController.new()
    
    component.initialize(controller)
    
    assert(component.player_controller == controller, "Controller reference set")
    assert(component.is_initialized, "Component marked as initialized")

func test_component_lifecycle():
    # Test proper cleanup
    var component = PlayerComponent.new()
    component.cleanup()
    
    assert(component.player_controller == null, "Controller reference cleared")

func test_component_error_handling():
    # Test error signal emission
    var component = PlayerComponent.new()
    var error_received = false
    
    component.component_error.connect(func(msg): error_received = true)
    component.emit_error("Test error")
    
    assert(error_received, "Error signal emitted properly")

func test_signal_emission():
    # Test component_ready signal
    var component = PlayerComponent.new()
    var ready_received = false
    
    component.component_ready.connect(func(): ready_received = true)
    component.mark_ready()
    
    assert(ready_received, "Ready signal emitted properly")
```

**Estimated Test Count:** 8-10 tests  
**Development Time:** 2-3 hours

---

### **Step 2: PlayerMovement Component Tests**
**File:** `tests/test_player_movement.gd`

**Test Coverage:**
```gdscript
extends SceneTree

func _initialize():
    print("=== PLAYER MOVEMENT TESTS ===")
    
    test_movement_speed_calculations()
    test_acceleration_and_friction()
    test_animation_state_transitions()
    test_input_direction_processing()
    test_movement_enable_disable()
    test_velocity_calculations()
    test_character_rotation()
    
    print("=== MOVEMENT TESTS COMPLETE ===")
    quit()

func test_movement_speed_calculations():
    var movement = PlayerMovement.new()
    movement.speed = 5.0
    
    var input_dir = Vector2(1, 0)  # Moving right
    var expected_velocity = Vector3(5.0, 0, 0)
    
    # Test speed calculation
    var result = movement.calculate_target_velocity(input_dir)
    assert(result.is_equal_approx(expected_velocity), "Speed calculation correct")

func test_acceleration_and_friction():
    var movement = PlayerMovement.new()
    movement.acceleration = 20.0
    movement.friction = 15.0
    
    var current_velocity = Vector3.ZERO
    var target_velocity = Vector3(5, 0, 0)
    var delta = 0.1
    
    # Test acceleration
    var result = movement.apply_acceleration(current_velocity, target_velocity, delta)
    assert(result.length() > 0, "Acceleration applied")
    assert(result.length() < target_velocity.length(), "Gradual acceleration")

func test_animation_state_transitions():
    var movement = PlayerMovement.new()
    var mock_animation_player = MockAnimationPlayer.new()
    movement.animation_player = mock_animation_player
    
    # Test idle state
    movement.update_animation(Vector3.ZERO)
    assert(mock_animation_player.current_animation == "idle", "Idle animation set")
    
    # Test walk state  
    movement.update_animation(Vector3(3, 0, 0))
    assert(mock_animation_player.current_animation == "walk", "Walk animation set")

func test_input_direction_processing():
    var movement = PlayerMovement.new()
    
    # Test input normalization
    var input = Vector2(1, 1)  # Diagonal input
    var processed = movement.process_input_direction(input)
    
    assert(processed.length() <= 1.0, "Input normalized")
    assert(processed.x > 0 and processed.y > 0, "Diagonal preserved")

func test_movement_enable_disable():
    var movement = PlayerMovement.new()
    
    movement.set_movement_enabled(false)
    var input_dir = Vector2(1, 0)
    
    var result = movement.calculate_target_velocity(input_dir)
    assert(result == Vector3.ZERO, "Movement disabled correctly")
    
    movement.set_movement_enabled(true)
    result = movement.calculate_target_velocity(input_dir)
    assert(result.length() > 0, "Movement re-enabled correctly")

func test_velocity_calculations():
    var movement = PlayerMovement.new()
    var character_body = CharacterBody3D.new()
    movement.character_body = character_body
    
    var input_dir = Vector2(0.5, 0.5)
    var delta = 1.0/60.0  # 60 FPS
    
    movement.handle_movement(input_dir, delta)
    
    var velocity = movement.get_current_velocity()
    assert(velocity.length() > 0, "Velocity calculated")

func test_character_rotation():
    var movement = PlayerMovement.new()
    var character_model = Node3D.new()
    movement.character_model = character_model
    
    var movement_direction = Vector3(1, 0, 0)
    movement.update_character_rotation(movement_direction)
    
    # Character should face movement direction
    var expected_rotation = Vector3(0, -PI/2, 0)  # Facing right
    assert(character_model.rotation.is_equal_approx(expected_rotation), "Character rotated correctly")

# Mock class for testing animation
class MockAnimationPlayer:
    var current_animation: String = ""
    func play(anim_name: String):
        current_animation = anim_name
```

**Estimated Test Count:** 15-20 tests  
**Development Time:** 6-8 hours

---

### **Step 3: PlayerSurvival Component Tests**
**File:** `tests/test_player_survival.gd`

**Test Coverage:**
```gdscript
extends SceneTree

func _initialize():
    print("=== PLAYER SURVIVAL TESTS ===")
    
    test_hunger_system_mechanics()
    test_health_system_mechanics()
    test_tiredness_system_mechanics()
    test_auto_eat_behavior()
    test_day_night_cycle_effects()
    test_shelter_recovery_rates()
    test_survival_stat_limits()
    test_death_conditions()
    
    print("=== SURVIVAL TESTS COMPLETE ===")
    quit()

func test_hunger_system_mechanics():
    var survival = PlayerSurvival.new()
    var mock_resource_manager = MockResourceManager.new()
    survival.resource_manager = mock_resource_manager
    
    # Initial hunger
    assert(survival.hunger == 100.0, "Initial hunger at max")
    
    # Test hunger decrease
    survival.hunger_decrease_rate = 60.0  # 60 per minute for fast testing
    survival.process_hunger(1.0)  # 1 second
    
    assert(survival.hunger < 100.0, "Hunger decreased over time")
    assert(survival.hunger == 99.0, "Hunger decreased correctly (1 per second)")

func test_health_system_mechanics():
    var survival = PlayerSurvival.new()
    
    # Test health loss when starving
    survival.hunger = 0.0
    survival.health_decrease_rate = 60.0  # 60 per minute
    
    var initial_health = survival.health
    survival.process_health(1.0)  # 1 second
    
    assert(survival.health < initial_health, "Health decreased when starving")
    assert(survival.health == initial_health - 1.0, "Health decreased correctly")

func test_tiredness_system_mechanics():
    var survival = PlayerSurvival.new()
    
    # Test tiredness loss from activity
    var initial_tiredness = survival.tiredness
    survival.lose_tiredness(10.0, "gathering")
    
    assert(survival.tiredness < initial_tiredness, "Tiredness decreased from activity")
    assert(survival.tiredness == initial_tiredness - 10.0, "Correct tiredness loss")

func test_auto_eat_behavior():
    var survival = PlayerSurvival.new()
    var mock_resource_manager = MockResourceManager.new()
    survival.resource_manager = mock_resource_manager
    
    # Set up auto-eat conditions
    survival.hunger = 25.0  # Below threshold
    survival.auto_eat_threshold = 30.0
    mock_resource_manager.resources["food"] = 5
    
    var auto_eat_triggered = false
    survival.auto_eat_triggered.connect(func(): auto_eat_triggered = true)
    
    survival.check_auto_eat()
    
    assert(auto_eat_triggered, "Auto-eat triggered at threshold")
    assert(survival.hunger > 25.0, "Hunger restored by auto-eat")
    assert(mock_resource_manager.resources["food"] < 5, "Food consumed")

func test_day_night_cycle_effects():
    var survival = PlayerSurvival.new()
    
    # Test night penalty
    var initial_tiredness = survival.tiredness
    survival.apply_night_penalty()
    
    assert(survival.tiredness < initial_tiredness, "Night penalty applied")

func test_shelter_recovery_rates():
    var survival = PlayerSurvival.new()
    
    # Test shelter recovery
    survival.tiredness = 50.0
    survival.apply_shelter_recovery(1.0)  # 1 second
    
    assert(survival.tiredness > 50.0, "Tiredness recovered in shelter")

func test_survival_stat_limits():
    var survival = PlayerSurvival.new()
    
    # Test upper limits
    survival.health = 150.0  # Over max
    survival.clamp_stats()
    assert(survival.health <= survival.max_health, "Health clamped to max")
    
    # Test lower limits
    survival.hunger = -10.0  # Below zero
    survival.clamp_stats()
    assert(survival.hunger >= 0.0, "Hunger clamped to zero")

func test_death_conditions():
    var survival = PlayerSurvival.new()
    var death_triggered = false
    
    survival.player_died.connect(func(): death_triggered = true)
    
    survival.health = 0.0
    survival.check_death_conditions()
    
    assert(death_triggered, "Death triggered at zero health")

# Mock ResourceManager for testing
class MockResourceManager:
    var resources = {"food": 10, "wood": 5}
    signal resource_changed
    
    func remove_resource(type: String, amount: int) -> int:
        var available = resources.get(type, 0)
        var removed = min(amount, available)
        resources[type] -= removed
        resource_changed.emit(type, resources[type] + removed, resources[type])
        return removed
```

**Estimated Test Count:** 20-25 tests  
**Development Time:** 8-10 hours

---

### **Step 4: PlayerBuilder Component Tests**
**File:** `tests/test_player_builder.gd`

**Test Coverage:**
```gdscript
extends SceneTree

func _initialize():
    print("=== PLAYER BUILDER TESTS ===")
    
    test_build_mode_state_transitions()
    test_ghost_preview_positioning()
    test_resource_cost_validation()
    test_building_placement_validation()
    test_build_mode_cancellation()
    test_building_collision_detection()
    test_multiple_building_types()
    
    print("=== BUILDER TESTS COMPLETE ===")
    quit()

func test_build_mode_state_transitions():
    var builder = PlayerBuilder.new()
    var mode_entered = false
    var mode_exited = false
    
    builder.build_mode_entered.connect(func(): mode_entered = true)
    builder.build_mode_exited.connect(func(): mode_exited = true)
    
    # Enter build mode
    builder.toggle_build_mode()
    assert(builder.is_in_build_mode, "Build mode enabled")
    assert(mode_entered, "Build mode entered signal emitted")
    
    # Exit build mode
    builder.toggle_build_mode()
    assert(not builder.is_in_build_mode, "Build mode disabled")
    assert(mode_exited, "Build mode exited signal emitted")

func test_ghost_preview_positioning():
    var builder = PlayerBuilder.new()
    var mock_scene_tree = MockSceneTree.new()
    builder.scene_tree = mock_scene_tree
    
    var player_position = Vector3(5, 0, 5)
    builder.update_ghost_position(player_position)
    
    assert(builder.current_ghost != null, "Ghost created")
    var expected_position = Vector3(5, 0, 7)  # 2 units in front
    assert(builder.current_ghost.position.is_equal_approx(expected_position), "Ghost positioned correctly")

func test_resource_cost_validation():
    var builder = PlayerBuilder.new()
    var mock_resource_manager = MockResourceManager.new()
    builder.resource_manager = mock_resource_manager
    
    # Test with sufficient resources
    mock_resource_manager.resources["wood"] = 10
    assert(builder.can_afford_building("tent"), "Can afford tent with enough wood")
    
    # Test with insufficient resources
    mock_resource_manager.resources["wood"] = 2
    assert(not builder.can_afford_building("tent"), "Cannot afford tent with insufficient wood")

func test_building_placement_validation():
    var builder = PlayerBuilder.new()
    var mock_resource_manager = MockResourceManager.new()
    var mock_scene_tree = MockSceneTree.new()
    builder.resource_manager = mock_resource_manager
    builder.scene_tree = mock_scene_tree
    
    # Set up valid placement conditions
    mock_resource_manager.resources["wood"] = 10
    builder.create_ghost_preview("tent")
    
    var placement_success = builder.place_building()
    assert(placement_success, "Building placed successfully")
    assert(mock_resource_manager.resources["wood"] < 10, "Resources consumed")

func test_build_mode_cancellation():
    var builder = PlayerBuilder.new()
    
    builder.enter_build_mode()
    builder.create_ghost_preview("tent")
    
    builder.cancel_building()
    
    assert(not builder.is_in_build_mode, "Build mode cancelled")
    assert(builder.current_ghost == null, "Ghost removed")

func test_building_collision_detection():
    var builder = PlayerBuilder.new()
    var mock_collision_detector = MockCollisionDetector.new()
    builder.collision_detector = mock_collision_detector
    
    # Test collision detection
    mock_collision_detector.has_collision = true
    assert(not builder.is_valid_placement_position(Vector3.ZERO), "Invalid placement with collision")
    
    mock_collision_detector.has_collision = false
    assert(builder.is_valid_placement_position(Vector3.ZERO), "Valid placement without collision")

func test_multiple_building_types():
    var builder = PlayerBuilder.new()
    
    # Test different building configurations
    var tent_config = builder.get_building_config("tent")
    assert(tent_config.wood_cost == 8, "Tent wood cost correct")
    
    var house_config = builder.get_building_config("house")
    assert(house_config.wood_cost == 20, "House wood cost correct")

# Mock classes for testing
class MockSceneTree:
    func instantiate_scene(scene_path: String) -> Node3D:
        var node = Node3D.new()
        node.name = scene_path.get_file().get_basename()
        return node

class MockCollisionDetector:
    var has_collision: bool = false
    func check_collision(position: Vector3, size: Vector3) -> bool:
        return has_collision
```

**Estimated Test Count:** 18-22 tests  
**Development Time:** 8-10 hours

---

### **Step 5: PlayerInteractor Component Tests**  
**File:** `tests/test_player_interactor.gd`

**Test Coverage:**
```gdscript
extends SceneTree

func _initialize():
    print("=== PLAYER INTERACTOR TESTS ===")
    
    test_nearby_object_tracking()
    test_interaction_priority_handling()
    test_gathering_mechanics()
    test_shelter_enter_exit_logic()
    test_interaction_range_validation()
    test_multiple_interaction_types()
    test_interaction_cancellation()
    
    print("=== INTERACTOR TESTS COMPLETE ===")
    quit()

func test_nearby_object_tracking():
    var interactor = PlayerInteractor.new()
    var mock_tree = MockTree.new()
    var mock_tent = MockTent.new()
    
    # Add nearby objects
    interactor.add_nearby_object(mock_tree, "gathering")
    interactor.add_nearby_object(mock_tent, "shelter")
    
    assert(interactor.nearby_objects.has("gathering"), "Gathering objects tracked")
    assert(interactor.nearby_objects.has("shelter"), "Shelter objects tracked")
    assert(interactor.nearby_objects["gathering"].size() == 1, "One gathering object")
    
    # Remove objects
    interactor.remove_nearby_object(mock_tree, "gathering")
    assert(interactor.nearby_objects["gathering"].is_empty(), "Gathering object removed")

func test_interaction_priority_handling():
    var interactor = PlayerInteractor.new()
    var close_tree = MockTree.new()
    var far_tree = MockTree.new()
    
    close_tree.position = Vector3(1, 0, 0)
    far_tree.position = Vector3(5, 0, 0)
    
    interactor.add_nearby_object(far_tree, "gathering")
    interactor.add_nearby_object(close_tree, "gathering")
    
    var nearest = interactor.get_nearest_object("gathering", Vector3.ZERO)
    assert(nearest == close_tree, "Closest object prioritized")

func test_gathering_mechanics():
    var interactor = PlayerInteractor.new()
    var mock_tree = MockTree.new()
    var interaction_started = false
    
    interactor.interaction_started.connect(func(target, type): interaction_started = true)
    
    interactor.start_gathering(mock_tree)
    
    assert(interaction_started, "Gathering interaction started")
    assert(interactor.current_interaction == mock_tree, "Current interaction set")

func test_shelter_enter_exit_logic():
    var interactor = PlayerInteractor.new()
    var mock_tent = MockTent.new()
    var entered_shelter = false
    var exited_shelter = false
    
    interactor.shelter_entered.connect(func(shelter): entered_shelter = true)
    interactor.shelter_exited.connect(func(shelter): exited_shelter = true)
    
    # Enter shelter
    interactor.enter_shelter(mock_tent)
    assert(entered_shelter, "Shelter entered signal emitted")
    assert(interactor.current_shelter == mock_tent, "Current shelter set")
    
    # Exit shelter
    interactor.exit_shelter()
    assert(exited_shelter, "Shelter exited signal emitted")
    assert(interactor.current_shelter == null, "Current shelter cleared")

func test_interaction_range_validation():
    var interactor = PlayerInteractor.new()
    interactor.interaction_range = 2.0
    
    var close_object = MockTree.new()
    close_object.position = Vector3(1, 0, 0)
    
    var far_object = MockTree.new()
    far_object.position = Vector3(5, 0, 0)
    
    var player_position = Vector3.ZERO
    
    assert(interactor.is_in_range(close_object, player_position), "Close object in range")
    assert(not interactor.is_in_range(far_object, player_position), "Far object out of range")

func test_multiple_interaction_types():
    var interactor = PlayerInteractor.new()
    
    # Test different interaction types don't interfere
    var tree = MockTree.new()
    var tent = MockTent.new()
    var pumpkin = MockPumpkin.new()
    
    interactor.add_nearby_object(tree, "gathering")
    interactor.add_nearby_object(tent, "shelter")
    interactor.add_nearby_object(pumpkin, "gathering")
    
    assert(interactor.nearby_objects["gathering"].size() == 2, "Multiple gathering objects")
    assert(interactor.nearby_objects["shelter"].size() == 1, "Shelter object separate")

func test_interaction_cancellation():
    var interactor = PlayerInteractor.new()
    var mock_tree = MockTree.new()
    var interaction_cancelled = false
    
    interactor.interaction_cancelled.connect(func(target, type): interaction_cancelled = true)
    
    interactor.start_gathering(mock_tree)
    interactor.cancel_current_interaction()
    
    assert(interaction_cancelled, "Interaction cancelled signal emitted")
    assert(interactor.current_interaction == null, "Current interaction cleared")

# Mock classes for testing
class MockTree:
    var position: Vector3 = Vector3.ZERO
    func get_interaction_type() -> String:
        return "gathering"

class MockTent:
    var position: Vector3 = Vector3.ZERO
    func get_interaction_type() -> String:
        return "shelter"

class MockPumpkin:
    var position: Vector3 = Vector3.ZERO
    func get_interaction_type() -> String:
        return "gathering"
```

**Estimated Test Count:** 15-18 tests  
**Development Time:** 6-8 hours

---

### **Step 6: PlayerInputHandler Component Tests**
**File:** `tests/test_player_input.gd`

**Test Coverage:**
```gdscript
extends SceneTree

func _initialize():
    print("=== PLAYER INPUT TESTS ===")
    
    test_input_device_mapping()
    test_action_state_tracking()
    test_multi_device_input_isolation()
    test_input_mapping_configuration()
    test_gamepad_vs_keyboard_handling()
    test_input_validation()
    
    print("=== INPUT TESTS COMPLETE ===")
    quit()

func test_input_device_mapping():
    var input_handler = PlayerInputHandler.new()
    
    # Test keyboard mapping (Player 1)
    input_handler.setup_input_mapping(0)
    assert(input_handler.input_device_id == 0, "Keyboard device set")
    assert(input_handler.input_map.has("move_left"), "Movement mapping created")
    
    # Test gamepad mapping (Player 2)
    input_handler.setup_input_mapping(1)
    assert(input_handler.input_device_id == 1, "Gamepad device set")
    assert(input_handler.input_map["move_left"] == "p2_left", "Gamepad mapping correct")

func test_action_state_tracking():
    var input_handler = PlayerInputHandler.new()
    var mock_input = MockInput.new()
    input_handler.input_system = mock_input
    
    # Test action press detection
    mock_input.set_action_state("ui_accept", true)
    assert(input_handler.is_action_pressed("interact"), "Action press detected")
    
    mock_input.set_action_state("ui_accept", false)
    assert(not input_handler.is_action_pressed("interact"), "Action release detected")

func test_multi_device_input_isolation():
    var input_handler_p1 = PlayerInputHandler.new()
    var input_handler_p2 = PlayerInputHandler.new()
    
    input_handler_p1.setup_input_mapping(0)  # Keyboard
    input_handler_p2.setup_input_mapping(1)  # Gamepad 1
    
    var mock_input = MockInput.new()
    input_handler_p1.input_system = mock_input
    input_handler_p2.input_system = mock_input
    
    # Simulate keyboard input
    mock_input.set_action_state("ui_left", true)
    mock_input.set_action_state("p2_left", false)
    
    var p1_input = input_handler_p1.get_movement_input()
    var p2_input = input_handler_p2.get_movement_input()
    
    assert(p1_input.x < 0, "Player 1 receives keyboard input")
    assert(p2_input.x == 0, "Player 2 isolated from keyboard input")

func test_input_mapping_configuration():
    var input_handler = PlayerInputHandler.new()
    
    # Test custom mapping
    var custom_mapping = {
        "move_left": "custom_left",
        "move_right": "custom_right",
        "interact": "custom_action"
    }
    
    input_handler.set_custom_mapping(custom_mapping)
    assert(input_handler.input_map["move_left"] == "custom_left", "Custom mapping applied")

func test_gamepad_vs_keyboard_handling():
    var keyboard_handler = PlayerInputHandler.new()
    var gamepad_handler = PlayerInputHandler.new()
    
    keyboard_handler.setup_input_mapping(0)  # Keyboard
    gamepad_handler.setup_input_mapping(1)   # Gamepad
    
    # Test device-specific input processing
    var mock_input = MockInput.new()
    keyboard_handler.input_system = mock_input
    gamepad_handler.input_system = mock_input
    
    # Simulate analog stick input (gamepad)
    mock_input.set_analog_input("p2_left_stick", Vector2(-0.7, 0.3))
    
    var gamepad_input = gamepad_handler.get_movement_input()
    assert(gamepad_input.length() > 0, "Gamepad analog input processed")
    assert(gamepad_input.length() <= 1.0, "Gamepad input normalized")

func test_input_validation():
    var input_handler = PlayerInputHandler.new()
    
    # Test invalid device ID
    var result = input_handler.setup_input_mapping(99)  # Invalid device
    assert(not result, "Invalid device ID rejected")
    
    # Test invalid action
    var action_result = input_handler.is_action_pressed("invalid_action")
    assert(not action_result, "Invalid action handled gracefully")

# Mock Input system for testing
class MockInput:
    var action_states = {}
    var analog_inputs = {}
    
    func set_action_state(action: String, pressed: bool):
        action_states[action] = pressed
    
    func set_analog_input(input: String, value: Vector2):
        analog_inputs[input] = value
    
    func is_action_pressed(action: String) -> bool:
        return action_states.get(action, false)
    
    func get_vector(negative_x: String, positive_x: String, negative_y: String, positive_y: String) -> Vector2:
        var x = 0.0
        var y = 0.0
        
        if action_states.get(negative_x, false):
            x -= 1.0
        if action_states.get(positive_x, false):
            x += 1.0
        if action_states.get(negative_y, false):
            y -= 1.0
        if action_states.get(positive_y, false):
            y += 1.0
        
        return Vector2(x, y)
```

**Estimated Test Count:** 12-15 tests  
**Development Time:** 4-6 hours

---

## 🔗 Integration Testing Plan

### **PlayerController Integration Tests**
**File:** `tests/test_player_integration.gd`

```gdscript
extends SceneTree

func _initialize():
    print("=== PLAYER INTEGRATION TESTS ===")
    
    test_component_coordination()
    test_signal_communication()
    test_full_player_workflow()
    test_multiplayer_isolation()
    test_performance_overhead()
    
    print("=== INTEGRATION TESTS COMPLETE ===")
    quit()

func test_component_coordination():
    # Test PlayerController coordinates all components properly
    var controller = PlayerController.new()
    
    # Add all components
    controller.add_child(PlayerMovement.new())
    controller.add_child(PlayerSurvival.new())
    controller.add_child(PlayerBuilder.new())
    controller.add_child(PlayerInteractor.new())
    controller.add_child(PlayerInputHandler.new())
    
    controller._ready()
    
    assert(controller.movement != null, "Movement component found")
    assert(controller.survival != null, "Survival component found")
    assert(controller.builder != null, "Builder component found")
    assert(controller.interactor != null, "Interactor component found")
    assert(controller.input_handler != null, "Input handler component found")

func test_signal_communication():
    # Test signals flow between components correctly
    var controller = PlayerController.new()
    var survival = PlayerSurvival.new()
    var movement = PlayerMovement.new()
    
    controller.add_child(survival)
    controller.add_child(movement)
    controller._ready()
    
    var health_changed = false
    survival.health_changed.connect(func(old, new): health_changed = true)
    
    # Trigger health change
    survival.health = 50.0
    survival.emit_signal("health_changed", 100.0, 50.0)
    
    assert(health_changed, "Health change signal propagated")

func test_full_player_workflow():
    # Test complete player interaction workflow
    var controller = PlayerController.new()
    # ... Setup complete player with all components
    
    # Simulate player approaching tree and gathering
    var mock_tree = MockTree.new()
    controller.interactor.add_nearby_object(mock_tree, "gathering")
    
    # Simulate input to interact
    controller.input_handler.simulate_input("interact", true)
    controller._process_input()
    
    # Verify interaction started
    assert(controller.interactor.current_interaction == mock_tree, "Interaction workflow complete")

func test_multiplayer_isolation():
    # Test multiple players don't interfere with each other
    var player1 = PlayerController.new()
    var player2 = PlayerController.new()
    
    player1.player_id = 0
    player2.player_id = 1
    
    # Setup both players
    # ... Setup components
    
    # Test input isolation
    player1.input_handler.setup_input_mapping(0)  # Keyboard
    player2.input_handler.setup_input_mapping(1)  # Gamepad
    
    # Simulate keyboard input
    # Verify only player 1 responds
    
    assert(true, "Players properly isolated")

func test_performance_overhead():
    # Test component architecture doesn't add significant overhead
    var start_time = Time.get_ticks_msec()
    
    var controller = PlayerController.new()
    # ... Setup all components
    
    # Simulate multiple frames
    for i in range(60):  # 1 second at 60 FPS
        controller._physics_process(1.0/60.0)
    
    var end_time = Time.get_ticks_msec()
    var duration = end_time - start_time
    
    assert(duration < 100, "Performance overhead acceptable (<100ms for 60 frames)")
```

**Estimated Test Count:** 10-12 tests  
**Development Time:** 6-8 hours

## 🧪 Testing Infrastructure

### **Test Execution Framework**
```gdscript
# tests/test_runner_player_refactor.gd
extends SceneTree

var test_files = [
    "test_player_component.gd",
    "test_player_movement.gd", 
    "test_player_survival.gd",
    "test_player_builder.gd",
    "test_player_interactor.gd",
    "test_player_input.gd",
    "test_player_integration.gd"
]

func _initialize():
    print("=== PLAYER REFACTORING TEST SUITE ===")
    run_all_tests()
    quit()

func run_all_tests():
    var total_tests = 0
    var passed_tests = 0
    var failed_tests = 0
    
    for test_file in test_files:
        print("Running ", test_file, "...")
        var result = run_test_file("tests/" + test_file)
        total_tests += result.total
        passed_tests += result.passed
        failed_tests += result.failed
    
    print("=== TEST SUMMARY ===")
    print("Total Tests: ", total_tests)
    print("Passed: ", passed_tests, " (", (passed_tests * 100 / total_tests), "%)")
    print("Failed: ", failed_tests)
    
    if failed_tests == 0:
        print("🎉 ALL TESTS PASSED!")
    else:
        print("❌ TESTS FAILED - Review failures above")

func run_test_file(file_path: String) -> Dictionary:
    # Implementation to run individual test files
    # Returns {total: int, passed: int, failed: int}
    pass
```

### **Mock System for Testing**
```gdscript
# tests/mocks/mock_system.gd
class_name MockSystem

# Mock ResourceManager
class MockResourceManager:
    var resources = {"wood": 10, "food": 5}
    signal resource_changed
    
    func add_resource(type: String, amount: int) -> int:
        resources[type] = resources.get(type, 0) + amount
        resource_changed.emit(type, resources[type] - amount, resources[type])
        return amount
    
    func remove_resource(type: String, amount: int) -> int:
        var available = resources.get(type, 0)
        var removed = min(amount, available)
        resources[type] -= removed
        resource_changed.emit(type, resources[type] + removed, resources[type])
        return removed

# Mock Input System
class MockInput:
    var action_states = {}
    func set_action_state(action: String, pressed: bool):
        action_states[action] = pressed
    func is_action_pressed(action: String) -> bool:
        return action_states.get(action, false)

# More mock classes as needed...
```

## 📊 Test Coverage Goals

### **Per Component Coverage Targets**
| Component | Unit Tests | Integration Tests | Coverage Goal |
|-----------|------------|-------------------|---------------|
| PlayerComponent | 8-10 | 2-3 | 95%+ |
| PlayerMovement | 15-20 | 3-4 | 90%+ |
| PlayerSurvival | 20-25 | 4-5 | 90%+ |
| PlayerBuilder | 18-22 | 3-4 | 85%+ |
| PlayerInteractor | 15-18 | 3-4 | 90%+ |
| PlayerInputHandler | 12-15 | 4-5 | 95%+ |
| **Total** | **88-110** | **19-25** | **90%+** |

### **Testing Timeline**
| Week | Testing Focus | Deliverables |
|------|---------------|--------------|
| **Week 1** | Component Base + Movement | 25-30 tests |
| **Week 2** | Survival + Builder | 40-50 tests |
| **Week 3** | Interactor + Input | 30-35 tests |
| **Week 4** | Integration + Performance | 15-20 tests |

## 🚀 Implementation Strategy

### **Test-Driven Development Approach**
1. **Write tests first** for each component interface
2. **Implement components** to pass tests
3. **Refactor** with confidence due to test coverage
4. **Validate** performance and integration

### **Continuous Testing**
```bash
# Quick test commands
godot --headless --script tests/test_player_movement.gd
godot --headless --script tests/test_runner_player_refactor.gd

# Performance validation
godot --headless --script tests/performance_validation_player.gd
```

## 📋 Testing Checklist

### **Before Starting Each Component**
- [ ] Review component interface requirements
- [ ] Write unit tests for core functionality
- [ ] Set up mock dependencies
- [ ] Create performance benchmarks

### **During Component Development**
- [ ] Run tests frequently (TDD approach)
- [ ] Update tests as interface evolves
- [ ] Add edge case tests
- [ ] Validate error handling

### **After Component Completion**
- [ ] 90%+ test coverage achieved
- [ ] All tests passing
- [ ] Performance requirements met
- [ ] Integration tests updated
- [ ] Documentation updated

This comprehensive testing plan ensures that the player refactoring maintains quality while enabling confident development of the component-based architecture!

**Estimated Total Testing Time:** 40-50 hours (parallel with development)  
**Test Count Target:** 100+ unit tests + 20+ integration tests  
**Coverage Goal:** 90%+ across all components
