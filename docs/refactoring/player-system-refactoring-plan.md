# Player System Refactoring Plan

**Project:** Metropolis  
**Date Created:** August 10, 2025  
**Status:** Planning Phase  
**Priority:** High (Foundation for Multiplayer)

## 📋 Executive Summary

The current player system is a monolithic 639-line script that combines movement, survival, building, interaction, and input handling in a single file. This refactoring plan transforms it into a clean, component-based architecture that supports multiplayer, improves maintainability, and enables easier feature development.

## 🎯 Refactoring Goals

### **Primary Objectives**
- **Component-based architecture** with single responsibility principle
- **Multiplayer-ready** input and player management
- **Improved testability** with isolated components
- **Enhanced maintainability** through clear separation of concerns
- **Easier feature extension** for new gameplay mechanics

### **Success Criteria**
- [ ] Player script reduced from 639 lines to ~50-line coordinator
- [ ] 5 focused components (~100-150 lines each)
- [ ] 100% existing functionality preserved
- [ ] Multiplayer input support implemented
- [ ] Comprehensive test coverage for each component
- [ ] Performance equivalent or improved

## 📊 Current State Analysis

### **Problems with Current Architecture**
```gdscript
extends CharacterBody3D  # 639 lines - TOO MANY RESPONSIBILITIES

# Mixed concerns in single file:
- Movement & Physics (input, velocity, animation)
- Survival System (health, hunger, tiredness)
- Building System (ghost preview, construction, build mode)
- Interaction System (trees, pumpkins, tents, shelters)
- Input Management (hardcoded player 1 controls)
```

### **Specific Issues**
1. **Tight Coupling**: Movement logic mixed with survival mechanics
2. **Hard to Test**: Cannot test systems independently
3. **Multiplayer Blocker**: Hardcoded input prevents multiple players
4. **Maintenance Burden**: Changes risk breaking unrelated systems
5. **Feature Addition Complexity**: New features require modifying core player script

## 🏗️ Target Architecture

### **Component-Based Design**
```
PlayerController (50 lines)
├── PlayerMovement (120 lines)
├── PlayerSurvival (150 lines)
├── PlayerBuilder (200 lines)
├── PlayerInteractor (100 lines)
└── PlayerInputHandler (50 lines)
```

### **Communication Pattern**
```gdscript
# Clean component coordination
PlayerController:
  - Owns all components
  - Coordinates communication
  - Handles component lifecycle
  - Minimal game logic

Components:
  - Single responsibility
  - Clear interfaces
  - Signal-based communication
  - Independent testability
```

## 📋 6-Step Implementation Plan

### **Step 1: Create Component Foundation** ⭐
**Duration:** 4-6 hours  
**Priority:** Critical - Required for all other steps

**Deliverables:**
- [ ] `PlayerComponent` base class
- [ ] `PlayerController` coordinator
- [ ] Component interface definitions
- [ ] Basic component lifecycle management

**Files to Create:**
```
components/
├── player_component.gd          # Base class for all player components
└── player_controller.gd         # Main coordinator replacing player.gd

interfaces/
├── movement_interface.gd        # Movement component contract
├── survival_interface.gd        # Survival component contract
├── builder_interface.gd         # Builder component contract
├── interactor_interface.gd      # Interaction component contract
└── input_interface.gd           # Input component contract
```

**Key Implementation Details:**
```gdscript
# Base component with common functionality
class_name PlayerComponent
extends Node

var player_controller: PlayerController
signal component_ready
signal component_error(message: String)

func initialize(controller: PlayerController) -> void
func cleanup() -> void
```

---

### **Step 2: Extract Movement Component** 🚶‍♂️
**Duration:** 6-8 hours  
**Dependencies:** Step 1  
**Priority:** High - Most isolated system

**Scope - Extract from player.gd:**
```gdscript
# Movement & Physics (~120 lines)
func handle_movement(input_dir: Vector2, delta: float)
func get_input_direction() -> Vector2
func find_animation_player()
func play_animation(anim_name: String)
# Velocity calculations
# Acceleration/friction logic
# Character rotation
```

**New Component:**
```gdscript
# components/player_movement.gd
class_name PlayerMovement
extends PlayerComponent

@export var speed: float = 5.0
@export var acceleration: float = 20.0
@export var friction: float = 15.0

func handle_movement(input_dir: Vector2, delta: float) -> void
func update_animation(velocity: Vector3) -> void
func get_current_velocity() -> Vector3
func set_movement_enabled(enabled: bool) -> void
```

**Testing Strategy:**
- [ ] Unit test: Movement speed calculations
- [ ] Unit test: Animation state transitions
- [ ] Unit test: Input direction processing
- [ ] Integration test: Movement + PlayerController

---

### **Step 3: Extract Survival Component** ⚕️
**Duration:** 6-8 hours  
**Dependencies:** Step 1  
**Priority:** High - Core gameplay system

**Scope - Extract from player.gd:**
```gdscript
# Survival System (~150 lines)
func handle_hunger_system(delta: float)
func handle_tiredness_system(delta: float)
func lose_tiredness(amount: float, activity: String)
# Health/hunger/tiredness variables
# Auto-eat logic
# Day/night effects
# Shelter recovery
```

**New Component:**
```gdscript
# components/player_survival.gd
class_name PlayerSurvival
extends PlayerComponent

# Stats
@export var max_health: float = 100.0
@export var max_hunger: float = 100.0
@export var max_tiredness: float = 100.0

# Configuration
@export var hunger_decrease_rate: float = 2.0
@export var health_decrease_rate: float = 5.0
@export var auto_eat_threshold: float = 30.0

func process_survival(delta: float) -> void
func lose_tiredness(amount: float, activity: String) -> void
func consume_food(amount: float) -> bool
func apply_night_penalty() -> void
func apply_shelter_recovery(delta: float) -> void
```

**Signals:**
```gdscript
signal health_changed(old_value: float, new_value: float)
signal hunger_changed(old_value: float, new_value: float)  
signal tiredness_changed(old_value: float, new_value: float)
signal player_died()
signal auto_eat_triggered()
```

**Testing Strategy:**
- [ ] Unit test: Hunger/health/tiredness calculations
- [ ] Unit test: Auto-eat threshold behavior
- [ ] Unit test: Day/night cycle effects
- [ ] Unit test: Shelter recovery rates

---

### **Step 4: Extract Builder Component** 🏗️
**Duration:** 8-10 hours  
**Dependencies:** Steps 1, 2 (movement for ghost positioning)  
**Priority:** Medium - Complex but isolated

**Scope - Extract from player.gd:**
```gdscript
# Building System (~200 lines)
func handle_build_mode_input()
func toggle_build_mode()
func create_tent_ghost()
func update_ghost_position()
func place_tent_blueprint()
func make_ghost_transparent()
func remove_ghost_functionality()
func destroy_tent_ghost()
# Build mode variables
# Ghost preview logic
```

**New Component:**
```gdscript
# components/player_builder.gd
class_name PlayerBuilder
extends PlayerComponent

# State
var is_in_build_mode: bool = false
var current_ghost: Node3D = null
var buildable_structures: Dictionary = {}

# Configuration
@export var tent_scene: PackedScene
@export var building_range: float = 5.0

func toggle_build_mode() -> void
func update_ghost_preview() -> void
func place_building() -> bool
func can_afford_building(building_type: String) -> bool
func cancel_building() -> void
```

**Signals:**
```gdscript
signal build_mode_entered()
signal build_mode_exited()
signal building_placed(building_type: String, position: Vector3)
signal building_failed(reason: String)
```

**Testing Strategy:**
- [ ] Unit test: Build mode state transitions
- [ ] Unit test: Ghost positioning calculations
- [ ] Unit test: Resource cost validation
- [ ] Unit test: Building placement validation

---

### **Step 5: Extract Interaction Component** 🤝
**Duration:** 6-8 hours  
**Dependencies:** Steps 1, 2 (movement for interaction positioning)  
**Priority:** Medium - Moderate complexity

**Scope - Extract from player.gd:**
```gdscript
# Interaction System (~100 lines)
func start_gathering_tree()
func start_gathering_pumpkin()
func start_building_tent()
func set_nearby_tree/tent/shelter/pumpkin()
func clear_nearby_*()
func enter/exit_tent_shelter()
# Nearby object tracking
# Interaction state management
```

**New Component:**
```gdscript
# components/player_interactor.gd
class_name PlayerInteractor
extends PlayerComponent

# State
var nearby_objects: Dictionary = {}  # Type -> Array[Node3D]
var current_interaction: Node3D = null
var interaction_range: float = 2.0

func add_nearby_object(obj: Node3D, interaction_type: String) -> void
func remove_nearby_object(obj: Node3D, interaction_type: String) -> void
func interact_with_nearest(interaction_type: String = "") -> void
func start_gathering(target: Node3D) -> void
func enter_shelter(shelter: Node3D) -> void
func exit_shelter() -> void
```

**Signals:**
```gdscript
signal interaction_started(target: Node3D, interaction_type: String)
signal interaction_completed(target: Node3D, interaction_type: String)
signal interaction_cancelled(target: Node3D, interaction_type: String)
signal shelter_entered(shelter: Node3D)
signal shelter_exited(shelter: Node3D)
```

**Testing Strategy:**
- [ ] Unit test: Nearby object tracking
- [ ] Unit test: Interaction priority handling
- [ ] Unit test: Shelter enter/exit logic
- [ ] Integration test: Interaction + ResourceManager

---

### **Step 6: Extract Input Handler Component** 🎮
**Duration:** 4-6 hours  
**Dependencies:** Step 1  
**Priority:** Critical for Multiplayer

**Scope - Extract from player.gd:**
```gdscript
# Input System (~50 lines)
func get_input_direction() -> Vector2
func handle_interaction_input()
func handle_build_mode_input()
# Hardcoded input actions
```

**New Component:**
```gdscript
# components/player_input_handler.gd
class_name PlayerInputHandler
extends PlayerComponent

# Configuration
@export var input_device_id: int = 0  # 0=keyboard, 1-3=gamepads
var input_map: Dictionary = {}

# Core input methods
func get_movement_input() -> Vector2
func is_action_just_pressed(action: String) -> bool
func is_action_pressed(action: String) -> bool
func setup_input_mapping(device_id: int) -> void

# Player-specific input actions
func get_interact_input() -> bool
func get_build_input() -> bool
func get_build_confirm_input() -> bool
```

**Input Mapping:**
```gdscript
# Default mappings per player
var default_mappings = {
    0: {  # Player 1 - Keyboard
        "move_left": "ui_left",
        "move_right": "ui_right", 
        "move_up": "ui_up",
        "move_down": "ui_down",
        "interact": "ui_accept",
        "build": "ui_select"
    },
    1: {  # Player 2 - Gamepad 1
        "move_left": "p2_left",
        "move_right": "p2_right",
        "move_up": "p2_up", 
        "move_down": "p2_down",
        "interact": "p2_action_1",
        "build": "p2_action_2"
    }
    # ... Player 3 & 4 mappings
}
```

**Testing Strategy:**
- [ ] Unit test: Input device mapping
- [ ] Unit test: Action state tracking
- [ ] Unit test: Multi-device input isolation
- [ ] Integration test: Input + All Components

## 🔄 Integration Strategy

### **Component Communication Pattern**
```gdscript
# PlayerController coordinates all components
class_name PlayerController
extends CharacterBody3D

# Component references
@onready var movement: PlayerMovement = $PlayerMovement
@onready var survival: PlayerSurvival = $PlayerSurvival
@onready var builder: PlayerBuilder = $PlayerBuilder
@onready var interactor: PlayerInteractor = $PlayerInteractor
@onready var input_handler: PlayerInputHandler = $PlayerInputHandler

func _physics_process(delta):
    # Get input
    var input_dir = input_handler.get_movement_input()
    
    # Process systems
    movement.handle_movement(input_dir, delta)
    survival.process_survival(delta)
    
    # Handle discrete actions
    if input_handler.is_action_just_pressed("interact"):
        interactor.interact_with_nearest()
    
    if input_handler.is_action_just_pressed("build"):
        builder.toggle_build_mode()
```

### **Signal Connections**
```gdscript
func _ready():
    # Connect survival signals to UI
    survival.health_changed.connect(_on_health_changed)
    survival.hunger_changed.connect(_on_hunger_changed)
    
    # Connect building signals to resource manager
    builder.building_placed.connect(_on_building_placed)
    
    # Connect interaction signals to systems
    interactor.interaction_started.connect(_on_interaction_started)
```

## 🧪 Testing Strategy

### **Unit Testing per Component**
Each component will have comprehensive unit tests:

```gdscript
# tests/test_player_movement.gd
extends GutTest

func test_movement_speed_calculation():
    var movement = PlayerMovement.new()
    # Test speed calculations
    
func test_animation_state_changes():
    var movement = PlayerMovement.new()
    # Test animation logic
```

### **Integration Testing**
```gdscript
# tests/test_player_integration.gd  
extends GutTest

func test_component_communication():
    # Test PlayerController coordination
    
func test_multiplayer_input_isolation():
    # Test multiple players don't interfere
```

### **Regression Testing**
- [ ] All existing gameplay functionality preserved
- [ ] Performance benchmarks maintained
- [ ] UI integration continues working
- [ ] Resource management integration preserved

## 📅 Implementation Timeline

| Week | Focus | Deliverables |
|------|-------|--------------|
| **Week 1** | Foundation + Movement | Steps 1-2 complete |
| **Week 2** | Survival + Builder | Steps 3-4 complete |
| **Week 3** | Interaction + Input | Steps 5-6 complete |
| **Week 4** | Integration + Testing | Complete system tested |

### **Daily Breakdown - Week 1**
**Day 1-2:** Step 1 - Component Foundation
- Create base classes and interfaces
- Set up PlayerController structure
- Basic component lifecycle

**Day 3-4:** Step 2 - Movement Component  
- Extract movement logic
- Implement PlayerMovement component
- Test movement functionality

**Day 5:** Integration & Testing
- Test PlayerController + PlayerMovement
- Performance validation
- Regression testing

## 🎯 Expected Benefits

### **Code Quality Improvements**
- **639 lines → ~350 total lines** (net reduction through better organization)
- **Single Responsibility Principle** enforced
- **Testable architecture** with isolated components
- **Clear interfaces** between systems

### **Multiplayer Foundation**
- **Device-specific input handling** (keyboard + 3 gamepads)
- **Independent player instances** with isolated state
- **Scalable player spawning** system
- **Easy player identification** and management

### **Development Velocity**
- **Faster feature development** with focused components
- **Easier debugging** with isolated systems
- **Safer refactoring** with comprehensive tests
- **Clear extension points** for new features

### **Future Extensibility**
- **New building types** → extend PlayerBuilder
- **New interactions** → extend PlayerInteractor
- **New movement modes** → extend PlayerMovement  
- **New survival mechanics** → extend PlayerSurvival
- **New input devices** → extend PlayerInputHandler

## 🚨 Risk Mitigation

### **Technical Risks**
| Risk | Impact | Mitigation |
|------|--------|------------|
| Performance degradation | High | Benchmark each step, optimize component communication |
| Component coupling | Medium | Enforce interfaces, comprehensive testing |
| Integration complexity | Medium | Incremental development, extensive integration tests |
| Regression introduction | High | Maintain test coverage, careful migration |

### **Schedule Risks**
| Risk | Impact | Mitigation |
|------|--------|------------|
| Underestimated complexity | Medium | 20% time buffer, prioritize core functionality |
| Scope creep | Low | Strict adherence to plan, defer enhancements |
| Testing overhead | Medium | Parallel test development, automated testing |

## 📋 Success Metrics

### **Quantitative Measures**
- [ ] **Lines of Code**: Player script ≤ 50 lines (vs 639 current)
- [ ] **Component Count**: 5 components, each ≤ 200 lines
- [ ] **Test Coverage**: ≥ 90% for each component
- [ ] **Performance**: ≤ 5% overhead vs current system
- [ ] **Multiplayer Support**: 4 independent players working

### **Qualitative Measures**
- [ ] **Maintainability**: New features require ≤ 1 component modification
- [ ] **Testability**: Components testable in isolation
- [ ] **Readability**: Clear component responsibilities and interfaces
- [ ] **Extensibility**: New building/interaction types easy to add

## 🔄 Next Steps

### **Immediate Actions**
1. **Review and approve this plan** with team
2. **Set up development branch** for refactoring work
3. **Create initial project structure** (components/, interfaces/ folders)
4. **Begin Step 1** - Component Foundation implementation

### **Preparation Tasks**
- [ ] Backup current working player system
- [ ] Set up automated testing pipeline
- [ ] Create development documentation template
- [ ] Establish code review process

---

**Document Status:** Draft - Awaiting Review  
**Next Review Date:** August 11, 2025  
**Assigned Developer:** TBD  
**Estimated Completion:** August 31, 2025
