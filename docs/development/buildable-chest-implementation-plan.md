# Buildable Chest Implementation Plan

## Overview
This document outlines the plan to add buildable chests with storage functionality to the game. Players will be able to build chests to store items like food and wood.

## Current State Analysis

### Existing Building System
- **PlayerBuilder Component**: Handles building mode, ghost previews, and construction
- **Tent System**: Currently the only buildable structure
- **Resource System**: Tracks wood and other resources
- **Ghost Preview**: Semi-transparent preview system for placement

### Current Building Workflow
1. Player toggles build mode (checks resources)
2. Ghost preview appears in front of player
3. Player positions and places building
4. Resources are deducted, tiredness applied
5. Actual building is created and functional

## Implementation Plan

### Phase 1: Basic Chest Building (Foundation)

#### 1.1 Update PlayerBuilder Component
**File**: `components/player_builder.gd`

**Changes Needed**:
```gdscript
# Add chest-specific properties
@export var chest_scene: PackedScene = preload("res://scenes/buildables/chest.tscn")
@export var chest_wood_cost: int = 4  # Lower cost than tent
var chest_ghost: Node3D = null

# Update building type support
func can_afford_building(building_type: String) -> bool:
    match building_type:
        "tent":
            return resource_manager.get_resource_amount("wood") >= tent_wood_cost
        "chest":
            return resource_manager.get_resource_amount("wood") >= chest_wood_cost
        _:
            return false

func get_building_cost(building_type: String) -> Dictionary:
    match building_type:
        "tent":
            return {"wood": tent_wood_cost}
        "chest":
            return {"wood": chest_wood_cost}
        _:
            return {}

# Add chest ghost creation
func create_building_ghost(building_type: String) -> void:
    match building_type:
        "tent":
            create_tent_ghost()
        "chest":
            create_chest_ghost()
        _:
            print("PlayerBuilder: Unknown building type: ", building_type)

func create_actual_building(building_type: String) -> Node3D:
    match building_type:
        "tent":
            return create_actual_tent()
        "chest":
            return create_actual_chest()
        _:
            return null
```

#### 1.2 Create Chest Script
**File**: `scenes/buildables/chest.gd`

**Core Features**:
- Buildable structure (similar to tent blueprint → built progression)
- Interaction area for opening/closing
- Basic chest functionality (open/close animations)
- Integration with building system

#### 1.3 Inventory/Storage System Foundation
**File**: `components/inventory_system.gd` (new)

**Purpose**: 
- Handle item storage/retrieval
- Manage storage capacity
- Provide consistent interface for chests and player inventory

### Phase 2: Storage Functionality

#### 2.1 Storage Interface
- Add storage capacity to chest (e.g., 20 slots)
- Create interaction prompts ("Press E to open chest")
- Basic storage UI (simple for now, can be enhanced later)

#### 2.2 Item Integration
- Allow storing wood, food items
- Implement stack limits and item types
- Add item transfer between player and chest

#### 2.3 Save/Load Support
- Persist chest contents between sessions
- Track chest positions and inventories

### Phase 3: Enhanced Features (Future)

#### 3.1 Chest Varieties
- Different chest sizes (small/medium/large)
- Different wood costs and capacities
- Visual variations

#### 3.2 Advanced Storage Features
- Item sorting and filtering
- Quick-transfer buttons
- Storage labels/categories

#### 3.3 Security Features
- Player ownership of chests
- Lock/unlock functionality
- Shared chests for multiplayer

## Technical Details

### Building Costs
```
Chest: 4 wood (vs tent: 8 wood)
Small Chest: 3 wood, 10 slots
Medium Chest: 4 wood, 20 slots  
Large Chest: 6 wood, 30 slots
```

### File Structure
```
scenes/buildables/
├── chest.tscn (already exists)
├── chest.gd (to create)
├── tent.gd (existing)
└── tent.tscn (existing)

components/
├── inventory_system.gd (new)
├── player_builder.gd (update)
└── storage_interface.gd (new, for UI)

ui/
└── chest_inventory.tscn (new, for storage UI)
```

### Ghost Preview System
- Reuse existing ghost transparency system
- Position chest ghost in front of player
- Remove collision from ghost version
- Standard ghost controls (move, place, cancel)

### Integration Points
- **Input System**: Add chest building hotkey
- **UI System**: Building mode indicators
- **Resource System**: Wood deduction
- **Save System**: Chest positions and contents

## Implementation Priority

### High Priority (Phase 1)
1. ✅ Update PlayerBuilder with chest support
2. ✅ Create basic chest.gd script  
3. ✅ Implement chest building workflow (with cycling)
4. ⏳ Test ghost preview and placement

### Medium Priority (Phase 2)
1. Basic storage functionality
2. Simple interaction system
3. Item transfer mechanics

### Low Priority (Phase 3)
1. Advanced UI features
2. Multiple chest types
3. Security/ownership features

## Testing Strategy

### Unit Tests
- Test building cost calculations
- Test ghost creation/destruction
- Test resource deduction

### Integration Tests
- Test complete building workflow
- Test chest-player interactions
- Test save/load with chests

### User Experience Tests
- Building feels intuitive
- Storage interface is clear
- Performance with multiple chests

## Success Criteria

### Phase 1 Complete When:
- [x] Players can toggle to chest building mode
- [x] Chest ghost preview appears correctly
- [x] Players can place chests with wood cost
- [x] Placed chests are functional (basic interaction)

### Phase 2 Complete When:
- [ ] Players can open/close chest with interaction
- [ ] Players can store/retrieve wood and food
- [ ] Chest contents persist between sessions
- [ ] Storage capacity limits work correctly

### Final Success When:
- [ ] Chest building feels as polished as tent building
- [ ] Storage system enhances gameplay experience
- [ ] System is extensible for future item types
- [ ] Performance remains good with multiple chests

## Notes

- Leverage existing tent building patterns for consistency
- Keep storage system simple initially, expand later
- Consider future multiplayer implications
- Plan for eventual crafting system integration
