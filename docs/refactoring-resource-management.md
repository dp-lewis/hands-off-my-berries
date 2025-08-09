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

### Step 2: Add Component to Player (Day 1)
- [ ] Add ResourceManager as child node to player scene
- [ ] Update player script to use component
- [ ] Test basic resource operations

### Step 3: Update Resource Collection (Day 2)
- [ ] Refactor `add_wood()` and `add_food()` methods
- [ ] Update tree and pumpkin interaction scripts
- [ ] Test resource collection still works

### Step 4: Update Building System (Day 2)
- [ ] Refactor building cost checks
- [ ] Update tent placement logic
- [ ] Test building still works with new system

### Step 5: Update UI System (Day 3)
- [ ] Refactor UI to use ResourceManager signals
- [ ] Test UI updates correctly show resource changes
- [ ] Ensure UI positioning fix still works

### Step 6: Testing & Polish (Day 3)
- [ ] Run comprehensive tests with multiple players
- [ ] Test edge cases (full inventory, zero resources)
- [ ] Update unit tests to cover ResourceManager

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

## Testing Strategy

### Unit Tests
```gdscript
# tests/test_resource_manager.gd
func test_add_resource_within_capacity()
func test_add_resource_exceeding_capacity()
func test_remove_resource_sufficient_amount()
func test_remove_resource_insufficient_amount()
func test_resource_signals_emitted()
```

### Integration Tests
```gdscript
# tests/test_player_resource_integration.gd
func test_player_can_collect_wood()
func test_player_cannot_collect_when_full()
func test_building_requires_sufficient_resources()
func test_ui_updates_when_resources_change()
```

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
