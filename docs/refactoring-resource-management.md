# Resource Management System Refactoring Plan

## Overview

This document outlines the plan to extract resource management logic from the monolithic `player.gd` script into a dedicated, reusable component system. This refactoring will improve code organization, testability, and maintainability.

## Current State Analysis

### Problems with Current Implementation

1. **Mixed Responsibilities**: Resource logic is scattered throughout the 599-line player script
2. **Tight Coupling**: Resource management is directly embedded in player movement/interaction code
3. **Hard to Test**: Cannot test inventory logic independently from player physics
4. **Code Duplication**: Similar inventory checks repeated in multiple methods
5. **Difficult to Extend**: Adding new resource types requires modifying core player logic

### Current Resource Code Locations

```gdscript
# Resource variables (lines 8-11)
var wood: int = 0
var food: int = 0
var max_inventory: int = 10
var max_food_inventory: int = 5

# Resource methods (lines 520-580)
func add_wood(amount: int)
func add_food(amount: int) -> bool
func get_inventory_space() -> int
func is_inventory_full() -> bool
func get_food_inventory_space() -> int
func is_food_inventory_full() -> bool
```

## Refactoring Plan

### Phase 1: Create Resource Manager Component

#### 1.1 Create ResourceManager Class

**File**: `components/resource_manager.gd`

```gdscript
class_name ResourceManager
extends Node

# Resource storage
var resources: Dictionary = {}
var max_capacities: Dictionary = {}

# Signals for reactive programming
signal resource_changed(resource_type: String, old_amount: int, new_amount: int)
signal resource_full(resource_type: String)
signal resource_empty(resource_type: String)

# Configuration
func setup_resource_type(type: String, max_capacity: int, initial_amount: int = 0)
func add_resource(type: String, amount: int) -> int  # Returns amount actually added
func remove_resource(type: String, amount: int) -> int  # Returns amount actually removed
func get_resource_amount(type: String) -> int
func get_available_space(type: String) -> int
func is_resource_full(type: String) -> bool
func is_resource_empty(type: String) -> bool
func get_resource_percentage(type: String) -> float
```

#### 1.2 Create Resource Configuration System

**File**: `config/resource_config.gd`

```gdscript
class_name ResourceConfig
extends Resource

@export var wood_max_capacity: int = 10
@export var food_max_capacity: int = 5
@export var stone_max_capacity: int = 8  # Future expansion
@export var tools_max_capacity: int = 3  # Future expansion

func get_max_capacity(resource_type: String) -> int
func get_all_resource_types() -> Array[String]
```

### Phase 2: Integration with Player System

#### 2.1 Update Player Script

Remove resource variables and methods from `player.gd`, replace with:

```gdscript
# Add component reference
@onready var resource_manager: ResourceManager = $ResourceManager
@export var resource_config: ResourceConfig

func _ready():
    setup_resource_system()
    # ... existing code

func setup_resource_system():
    resource_manager.setup_resource_type("wood", resource_config.wood_max_capacity)
    resource_manager.setup_resource_type("food", resource_config.food_max_capacity)
    
    # Connect signals for UI updates
    resource_manager.resource_changed.connect(_on_resource_changed)
```

#### 2.2 Update Resource Collection Methods

Replace direct variable access with component calls:

```gdscript
# OLD CODE (to be removed):
func add_wood(amount: int):
    var space_available = max_inventory - wood
    # ... complex logic

# NEW CODE:
func add_wood(amount: int) -> bool:
    var amount_added = resource_manager.add_resource("wood", amount)
    return amount_added == amount
```

### Phase 3: Update Dependent Systems

#### 3.1 Update Building System

```gdscript
# OLD CODE:
func enter_build_mode():
    if wood < 8:
        print("Player ", player_id, " needs 8 wood to build tent (have ", wood, ")")
        return

# NEW CODE:
func enter_build_mode():
    if resource_manager.get_resource_amount("wood") < 8:
        print("Player ", player_id, " needs 8 wood to build tent (have ", 
              resource_manager.get_resource_amount("wood"), ")")
        return
```

#### 3.2 Update UI System

```gdscript
# In player_ui.gd, replace direct property access:
# OLD: player.wood, player.food
# NEW: player.resource_manager.get_resource_amount("wood")

func update_stats():
    if target_player and target_player.resource_manager:
        var rm = target_player.resource_manager
        wood_label.text = "Wood: %d/%d" % [
            rm.get_resource_amount("wood"), 
            rm.get_available_space("wood") + rm.get_resource_amount("wood")
        ]
        food_label.text = "Food: %d/%d" % [
            rm.get_resource_amount("food"),
            rm.get_available_space("food") + rm.get_resource_amount("food")
        ]
```

### Phase 4: Advanced Features

#### 4.1 Resource Transfer System

```gdscript
# Add to ResourceManager
func transfer_resource(to_manager: ResourceManager, resource_type: String, amount: int) -> int
func can_accept_transfer(resource_type: String, amount: int) -> bool
```

#### 4.2 Resource Persistence

```gdscript
# Add save/load functionality
func save_resources() -> Dictionary
func load_resources(data: Dictionary)
```

#### 4.3 Resource Categories

```gdscript
# Group resources by type
enum ResourceCategory { MATERIALS, FOOD, TOOLS, EQUIPMENT }
func get_resources_by_category(category: ResourceCategory) -> Dictionary
```

## Implementation Steps

### Step 1: Create Foundation Files (Day 1)
- [ ] Create `components/` directory
- [ ] Create `components/resource_manager.gd`
- [ ] Create `config/resource_config.gd`
- [ ] Implement basic resource storage and manipulation

### Step 1.5: Set Up GUT Tests (Day 1)
- [ ] Create `tests/test_resource_manager.gd` with comprehensive unit tests
- [ ] Create `tests/test_player_resource_integration.gd` for integration tests
- [ ] Set up test runner scene for resource refactoring
- [ ] Verify all tests pass before proceeding to next phase

### Step 2: Add Component to Player (Day 1)
- [ ] Add ResourceManager as child node to player scene
- [ ] Update player script to use component
- [ ] Test basic resource operations
- [ ] **Run GUT tests to verify integration**

### Step 3: Update Resource Collection (Day 2)
- [ ] Refactor `add_wood()` and `add_food()` methods
- [ ] Update tree and pumpkin interaction scripts
- [ ] Test resource collection still works
- [ ] **Run GUT tests to verify collection logic**

### Step 4: Update Building System (Day 2)
- [ ] Refactor building cost checks
- [ ] Update tent placement logic
- [ ] Test building still works with new system
- [ ] **Run GUT tests to verify building requirements**

### Step 5: Update UI System (Day 3)
- [ ] Refactor UI to use ResourceManager signals
- [ ] Test UI updates correctly show resource changes
- [ ] Ensure UI positioning fix still works
- [ ] **Run full GUT test suite**

### Step 6: Testing & Polish (Day 3)
- [ ] Run comprehensive tests with multiple players
- [ ] Test edge cases (full inventory, zero resources)
- [ ] **Expand GUT tests for any new edge cases discovered**
- [ ] **Final GUT test validation before merging**

## Benefits After Refactoring

### Code Quality
- **Single Responsibility**: ResourceManager only handles inventory
- **Loose Coupling**: Player script no longer tightly bound to resource logic
- **Testable**: Can unit test resource logic independently
- **Extensible**: Easy to add new resource types

### Performance
- **Signal-driven UI updates**: UI only updates when resources actually change
- **Efficient storage**: Dictionary-based storage scales better
- **Memory efficient**: Shared resource logic across multiple players

### Maintainability
- **Centralized logic**: All resource rules in one place
- **Configuration-driven**: Easy to tweak resource limits
- **Reusable**: ResourceManager can be used by NPCs, containers, etc.

## Testing Strategy with GUT Framework

### GUT Unit Tests for ResourceManager

**File**: `tests/test_resource_manager.gd`

```gdscript
extends GutTest

var resource_manager: ResourceManager
var signal_watcher: SignalWatcher

func before_each():
    resource_manager = ResourceManager.new()
    signal_watcher = SignalWatcher.new()
    add_child(resource_manager)
    signal_watcher.watch_signals(resource_manager)

func after_each():
    signal_watcher.free()
    resource_manager.queue_free()

func test_setup_resource_type():
    # Test basic resource type setup
    resource_manager.setup_resource_type("wood", 10, 5)
    
    assert_eq(resource_manager.get_resource_amount("wood"), 5, "Initial amount should be set")
    assert_eq(resource_manager.get_available_space("wood"), 5, "Available space should be calculated")
    assert_false(resource_manager.is_resource_full("wood"), "Should not be full initially")

func test_add_resource_within_capacity():
    # Test adding resources within capacity limits
    resource_manager.setup_resource_type("wood", 10, 0)
    
    var amount_added = resource_manager.add_resource("wood", 5)
    
    assert_eq(amount_added, 5, "Should add full amount when space available")
    assert_eq(resource_manager.get_resource_amount("wood"), 5, "Resource amount should increase")
    assert_signal_emitted(resource_manager, "resource_changed", "Should emit resource_changed signal")

func test_add_resource_exceeding_capacity():
    # Test adding more resources than capacity allows
    resource_manager.setup_resource_type("wood", 10, 8)
    
    var amount_added = resource_manager.add_resource("wood", 5)
    
    assert_eq(amount_added, 2, "Should only add what fits")
    assert_eq(resource_manager.get_resource_amount("wood"), 10, "Should be at max capacity")
    assert_true(resource_manager.is_resource_full("wood"), "Should be full")
    assert_signal_emitted(resource_manager, "resource_full", "Should emit resource_full signal")

func test_remove_resource_sufficient_amount():
    # Test removing resources when sufficient amount available
    resource_manager.setup_resource_type("food", 5, 3)
    
    var amount_removed = resource_manager.remove_resource("food", 2)
    
    assert_eq(amount_removed, 2, "Should remove requested amount")
    assert_eq(resource_manager.get_resource_amount("food"), 1, "Resource amount should decrease")
    assert_signal_emitted(resource_manager, "resource_changed", "Should emit resource_changed signal")

func test_remove_resource_insufficient_amount():
    # Test removing more resources than available
    resource_manager.setup_resource_type("food", 5, 2)
    
    var amount_removed = resource_manager.remove_resource("food", 5)
    
    assert_eq(amount_removed, 2, "Should only remove what's available")
    assert_eq(resource_manager.get_resource_amount("food"), 0, "Should be empty")
    assert_true(resource_manager.is_resource_empty("food"), "Should be empty")
    assert_signal_emitted(resource_manager, "resource_empty", "Should emit resource_empty signal")

func test_resource_percentage_calculation():
    # Test percentage calculations
    resource_manager.setup_resource_type("wood", 10, 7)
    
    assert_eq(resource_manager.get_resource_percentage("wood"), 0.7, "Should calculate correct percentage")

func test_unknown_resource_type():
    # Test handling of unknown resource types
    var amount = resource_manager.get_resource_amount("unknown")
    
    assert_eq(amount, 0, "Unknown resource should return 0")
    assert_false(resource_manager.is_resource_full("unknown"), "Unknown resource should not be full")

func test_signal_parameters():
    # Test that signals emit correct parameters
    resource_manager.setup_resource_type("wood", 10, 3)
    
    resource_manager.add_resource("wood", 2)
    
    assert_signal_emitted_with_parameters(
        resource_manager, 
        "resource_changed", 
        ["wood", 3, 5], 
        "Should emit signal with correct old and new amounts"
    )
```

### GUT Integration Tests

**File**: `tests/test_player_resource_integration.gd`

```gdscript
extends GutTest

var player_scene: PackedScene
var player: CharacterBody3D
var test_scene: Node3D

func before_all():
    # Load the player scene for testing
    player_scene = preload("res://scenes/players/player.tscn")

func before_each():
    # Create test environment
    test_scene = Node3D.new()
    add_child(test_scene)
    
    # Instantiate player
    player = player_scene.instantiate()
    test_scene.add_child(player)
    
    # Wait for player to be ready
    await get_tree().process_frame

func after_each():
    test_scene.queue_free()

func test_player_has_resource_manager():
    # Test that player has resource manager component
    assert_not_null(player.resource_manager, "Player should have resource manager")
    assert_true(player.resource_manager is ResourceManager, "Should be ResourceManager instance")

func test_player_can_collect_wood():
    # Test wood collection through player interface
    var initial_wood = player.resource_manager.get_resource_amount("wood")
    
    var success = player.add_wood(3)
    
    assert_true(success, "Should successfully add wood")
    assert_eq(
        player.resource_manager.get_resource_amount("wood"), 
        initial_wood + 3, 
        "Wood amount should increase"
    )

func test_player_cannot_collect_when_full():
    # Test collection when inventory is full
    var max_wood = player.resource_manager.get_available_space("wood") + player.resource_manager.get_resource_amount("wood")
    
    # Fill to capacity
    player.resource_manager.add_resource("wood", max_wood)
    
    var success = player.add_wood(1)
    
    assert_false(success, "Should not be able to add wood when full")
    assert_true(player.resource_manager.is_resource_full("wood"), "Should be at capacity")

func test_building_requires_sufficient_resources():
    # Test building system resource requirements
    player.resource_manager.add_resource("wood", 5)  # Less than required 8
    
    player.enter_build_mode()
    
    assert_false(player.is_in_build_mode, "Should not enter build mode without enough wood")
    
    # Add enough wood
    player.resource_manager.add_resource("wood", 5)  # Total now 10
    
    player.enter_build_mode()
    
    assert_true(player.is_in_build_mode, "Should enter build mode with enough wood")
```

### GUT Test Runner Configuration

**File**: `tests/test_runner_resource_refactor.gd`

```gdscript
extends GutTest

# Simple test runner specifically for resource refactoring tests
class_name ResourceRefactorTestRunner

func _ready():
    var gut = Gut.new()
    add_child(gut)
    
    # Configure GUT for resource manager tests
    gut.add_script("res://tests/test_resource_manager.gd")
    gut.add_script("res://tests/test_player_resource_integration.gd")
    
    # Run tests
    gut.test_scripts()
```

### Test Execution Integration

Add to implementation steps:

**Step 1.5: Set Up GUT Tests (Day 1)**
- [ ] Create `tests/test_resource_manager.gd` with comprehensive unit tests
- [ ] Create `tests/test_player_resource_integration.gd` for integration tests
- [ ] Set up test runner scene for resource refactoring
- [ ] Verify all tests pass before proceeding to next phase

**Daily Testing Protocol:**
- Run GUT tests after each major change
- All tests must pass before moving to next implementation step
- Add new tests for any edge cases discovered during development

## Migration Safety

### Backward Compatibility
- Keep old resource methods as wrappers during transition
- Add deprecation warnings to old methods
- Gradual migration allows testing each component

### Rollback Plan
- Git branch for refactoring work
- Can revert individual commits if issues arise
- Old code preserved in comments during transition

## Future Expansion Opportunities

### New Resource Types
- Stone (for advanced buildings)
- Tools (with durability)
- Equipment (armor, weapons)
- Seeds (for farming)

### Advanced Features
- Resource quality levels
- Crafting recipes
- Resource decay/spoilage
- Trade system between players

---

*This document will be updated as the refactoring progresses.*
