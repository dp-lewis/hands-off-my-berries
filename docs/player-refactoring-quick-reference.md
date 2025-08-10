# Player Refactoring - Quick Reference

## 🚀 Implementation Checklist

### **Step 1: Foundation** ⭐ *COMPLETE* ✅
- [x] Create `components/player_component.gd` base class
- [x] Create `components/player_controller.gd` coordinator  
- [x] Create interface definitions in `interfaces/`
- [x] Set up component lifecycle management
- [x] **Test:** Basic component instantiation and communication

### **Step 2: Movement Component** 🚶‍♂️  
- [ ] Extract movement logic from `player.gd` (~120 lines)
- [ ] Create `components/player_movement.gd`
- [ ] Migrate: `handle_movement()`, `play_animation()`, velocity logic
- [ ] **Test:** Movement speed, animation states, input processing

### **Step 3: Survival Component** ⚕️
- [ ] Extract survival logic from `player.gd` (~150 lines)  
- [ ] Create `components/player_survival.gd`
- [ ] Migrate: hunger/health/tiredness systems, auto-eat, day/night effects
- [ ] **Test:** Stat calculations, auto-eat behavior, shelter recovery

### **Step 4: Builder Component** 🏗️
- [ ] Extract building logic from `player.gd` (~200 lines)
- [ ] Create `components/player_builder.gd`  
- [ ] Migrate: build mode, ghost preview, tent construction
- [ ] **Test:** Build mode states, ghost positioning, resource validation

### **Step 5: Interaction Component** 🤝
- [ ] Extract interaction logic from `player.gd` (~100 lines)
- [ ] Create `components/player_interactor.gd`
- [ ] Migrate: gathering, shelter enter/exit, nearby object tracking  
- [ ] **Test:** Object tracking, interaction priority, shelter logic

### **Step 6: Input Handler** 🎮
- [ ] Extract input logic from `player.gd` (~50 lines)
- [ ] Create `components/player_input_handler.gd`
- [ ] Implement: Multi-device support, player-specific mappings
- [ ] **Test:** Device mapping, input isolation, action handling

## 📁 File Structure

```
metropolis/
├── components/
│   ├── player_component.gd          # Base class
│   ├── player_controller.gd         # Main coordinator (replaces player.gd)
│   ├── player_movement.gd           # Movement & animation  
│   ├── player_survival.gd           # Health/hunger/tiredness
│   ├── player_builder.gd            # Building & construction
│   ├── player_interactor.gd         # Object interactions
│   └── player_input_handler.gd      # Multi-player input
├── interfaces/
│   ├── movement_interface.gd        # Movement contract
│   ├── survival_interface.gd        # Survival contract  
│   ├── builder_interface.gd         # Builder contract
│   ├── interactor_interface.gd      # Interaction contract
│   └── input_interface.gd           # Input contract
└── tests/
    ├── test_player_movement.gd      # Movement unit tests
    ├── test_player_survival.gd      # Survival unit tests
    ├── test_player_builder.gd       # Builder unit tests  
    ├── test_player_interactor.gd    # Interaction unit tests
    ├── test_player_input.gd         # Input unit tests
    └── test_player_integration.gd   # Full integration tests
```

## 🧩 Component Interface Summary

### **PlayerComponent (Base)**
```gdscript
func initialize(controller: PlayerController) -> void
func cleanup() -> void
signal component_ready
signal component_error(message: String)
```

### **PlayerMovement**
```gdscript  
func handle_movement(input_dir: Vector2, delta: float) -> void
func update_animation(velocity: Vector3) -> void
func get_current_velocity() -> Vector3
func set_movement_enabled(enabled: bool) -> void
```

### **PlayerSurvival**
```gdscript
func process_survival(delta: float) -> void
func lose_tiredness(amount: float, activity: String) -> void
func consume_food(amount: float) -> bool
func apply_night_penalty() -> void
func apply_shelter_recovery(delta: float) -> void
```

### **PlayerBuilder**
```gdscript
func toggle_build_mode() -> void
func update_ghost_preview() -> void  
func place_building() -> bool
func can_afford_building(building_type: String) -> bool
func cancel_building() -> void
```

### **PlayerInteractor** 
```gdscript
func add_nearby_object(obj: Node3D, interaction_type: String) -> void
func remove_nearby_object(obj: Node3D, interaction_type: String) -> void
func interact_with_nearest(interaction_type: String = "") -> void
func start_gathering(target: Node3D) -> void
func enter_shelter(shelter: Node3D) -> void
```

### **PlayerInputHandler**
```gdscript
func get_movement_input() -> Vector2
func is_action_just_pressed(action: String) -> bool
func is_action_pressed(action: String) -> bool  
func setup_input_mapping(device_id: int) -> void
```

## 🎯 Key Migration Points

### **From player.gd → PlayerController**
```gdscript
# OLD: Direct method calls
func _physics_process(delta):
    handle_movement(get_input_direction(), delta)
    handle_hunger_system(delta)
    handle_tiredness_system(delta)

# NEW: Component coordination  
func _physics_process(delta):
    var input_dir = input_handler.get_movement_input()
    movement.handle_movement(input_dir, delta)  
    survival.process_survival(delta)
```

### **Signal Migration**
```gdscript
# OLD: Direct UI updates
player_ui.update_health(health)

# NEW: Signal-based updates
survival.health_changed.connect(player_ui.on_health_changed)
```

### **Input Migration**
```gdscript
# OLD: Hardcoded inputs
Input.get_vector("left", "right", "up", "down")

# NEW: Player-specific inputs  
input_handler.get_movement_input()  # Handles device mapping
```

## ⚡ Quick Start Commands

### **Create Foundation**
```bash
mkdir -p components interfaces tests
touch components/player_component.gd
touch components/player_controller.gd
```

### **Run Tests**
```bash
# Individual component tests
godot --headless --script tests/test_player_movement.gd
godot --headless --script tests/test_player_survival.gd
godot --headless --script tests/test_player_builder.gd

# Full test suite
godot --headless --script tests/test_runner_player_refactor.gd

# Integration tests  
godot --headless --script tests/test_player_integration.gd
```

### **Performance Check**
```bash
godot --headless --script tests/performance_validation_player.gd
```

### **Test Development (TDD Approach)**
```bash
# 1. Write tests first
touch tests/test_player_movement.gd

# 2. Implement component to pass tests
touch components/player_movement.gd

# 3. Run tests frequently during development
godot --headless --script tests/test_player_movement.gd
```

## 🔍 Common Patterns

### **Component Setup**
```gdscript
# In PlayerController._ready()
for component in get_children():
    if component is PlayerComponent:
        component.initialize(self)
        component.component_ready.connect(_on_component_ready)
```

### **Safe Component Communication**
```gdscript
# Always check component availability
func try_interact():
    if interactor and interactor.has_method("interact_with_nearest"):
        interactor.interact_with_nearest()
```

### **Error Handling**
```gdscript
# Component error handling
func _on_component_error(message: String):
    print("Component Error: ", message)
    # Graceful degradation logic
```

## 📊 Progress Tracking

### **Development + Testing Timeline**
- [ ] **Week 1:** Foundation + Movement (Steps 1-2) + 25-30 tests
- [ ] **Week 2:** Survival + Builder (Steps 3-4) + 40-50 tests  
- [ ] **Week 3:** Interaction + Input (Steps 5-6) + 30-35 tests
- [ ] **Week 4:** Integration + Testing + 15-20 tests

### **Testing Goals**
- [ ] **100+ unit tests** across all components (90%+ coverage)
- [ ] **20+ integration tests** for component communication
- [ ] **TDD approach** - write tests before/during component development
- [ ] **Performance validation** - ensure <5% overhead vs monolithic

**📋 Comprehensive Testing Plan:** See `/docs/player-refactoring-testing-plan.md`  
**Target Completion:** August 31, 2025
