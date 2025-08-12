# Chest Building - Immediate Action Plan

## Quick Start Guide for Implementing Buildable Chests

### Step 1: Update PlayerBuilder Component (10 minutes)

**File**: `components/player_builder.gd`

Add these properties after the tent properties:
```gdscript
# Chest building
var chest_ghost: Node3D = null
@export var chest_scene: PackedScene = preload("res://scenes/buildables/chest.tscn")
@export var chest_wood_cost: int = 4
```

Update these functions:
1. `can_afford_building()` - add "chest" case
2. `get_building_cost()` - add "chest" case  
3. `create_building_ghost()` - add `create_chest_ghost()`
4. `create_actual_building()` - add `create_actual_chest()`

Add these new functions:
```gdscript
func create_chest_ghost():
    if chest_scene and not chest_ghost:
        chest_ghost = chest_scene.instantiate()
        make_chest_ghost_transparent()
        remove_chest_ghost_functionality()
        if player_controller and player_controller.get_parent():
            player_controller.get_parent().add_child(chest_ghost)
            update_chest_ghost_position()

func create_actual_chest() -> Node3D:
    if chest_scene:
        var new_chest = chest_scene.instantiate()
        if player_controller and player_controller.get_parent():
            player_controller.get_parent().add_child(new_chest)
        return new_chest
    return null
```

### Step 2: Create Chest Script (20 minutes)

**File**: `scenes/buildables/chest.gd`

Create basic chest functionality:
```gdscript
extends Node3D

@export var wood_cost: int = 4
@export var build_time: float = 3.0
@export var start_built: bool = false
@export var storage_capacity: int = 20

var current_builder: Node = null
var build_progress: float = 0.0
var is_being_built: bool = false
var is_built: bool = false
var storage_items: Dictionary = {}  # item_type: amount

@onready var build_area: Area3D
@onready var interaction_area: Area3D
@onready var chest_mesh: Node3D

func _ready():
    add_to_group("chests")
    setup_areas()
    
    if start_built:
        is_built = true
        show_as_built()
    else:
        show_as_blueprint()

# Similar structure to tent.gd but adapted for chest functionality
```

### Step 3: Test Basic Building (5 minutes)

1. Set player's building type to "chest": `player_builder.set_building_type("chest")`
2. Toggle build mode
3. Place chest
4. Verify chest appears and wood is deducted

### Step 4: Add Storage Interface (30 minutes)

Add basic interaction:
```gdscript
# In chest.gd
func _on_interaction_area_entered(body):
    if body.name.begins_with("Player"):
        show_interaction_prompt(body)

func open_chest(player):
    # Basic storage access
    print("Player opened chest - storage capacity: ", storage_capacity)
    # TODO: Open storage UI

func store_item(item_type: String, amount: int) -> bool:
    # Add items to chest storage
    if get_total_stored_items() + amount <= storage_capacity:
        if storage_items.has(item_type):
            storage_items[item_type] += amount
        else:
            storage_items[item_type] = amount
        return true
    return false
```

## Quick Implementation Commands

```bash
# 1. Copy tent patterns for chest
cd /Users/davidlewis/Documents/metropolis
cp scenes/buildables/tent.gd scenes/buildables/chest.gd

# 2. Edit chest.gd to replace "tent" with "chest"
# 3. Update player_builder.gd with chest support
# 4. Test in-game
```

## Testing Checklist

- [x] Player can switch to chest building mode
- [x] Build button cycles through building types (tent → chest → exit)
- [x] Chest ghost appears when entering chest build mode  
- [x] Chest can be placed with sufficient wood
- [x] Wood is deducted correctly (4 wood for chest, 8 for tent)
- [ ] Placed chest is interactive
- [ ] Multiple chests can be built

## Next Steps After Basic Implementation

1. **Simple Storage**: Add basic item storage/retrieval
2. **UI Integration**: Create simple storage interface
3. **Save/Load**: Persist chest contents
4. **Polish**: Improve animations and feedback

## Estimated Timeline

- **Phase 1 (Basic Building)**: 45 minutes
- **Phase 2 (Storage)**: 2-3 hours  
- **Phase 3 (Polish)**: 1-2 hours

**Total**: ~4-6 hours for complete chest building system

## Key Design Decisions

1. **Wood Cost**: 4 wood (half of tent cost) - makes chests accessible early game
2. **Storage Capacity**: 20 items - meaningful but not excessive
3. **Build Pattern**: Copy tent building workflow for consistency
4. **Interaction**: Simple proximity-based interaction like tent shelter

This gives you a complete storage building system that integrates seamlessly with your existing building mechanics!
