# Metropolis Inventory & Hotbar Development Plan
## Phase 2 Complete → Farming System Implementation

---

## 🎉 **COMPLETED: Inventory & Hotbar System (Phase 2)**

### **✅ Core Achievements**
- **4-slot hotbar navigation** with left/right controls (simplified from 8 number keys)
- **Visual feedback system** with highlighted selection and state display
- **Automatic starting items** - players spawn with bucket, watering can, and seeds
- **Complete item management** - add, remove, stack, use items with full state support
- **Multi-player ready** - hotbar works for all 4 players with isolated controls

### **✅ Technical Implementation**
```gdscript
# Component Architecture Integration
PlayerController
├── PlayerMovement      ✅ Complete
├── PlayerSurvival      ✅ Complete  
├── PlayerBuilder       ✅ Complete
├── PlayerInteraction   ✅ Complete
├── PlayerInputHandler  ✅ Complete (hotbar navigation signals)
└── PlayerInventory     ✅ COMPLETE (20 slots, 4-slot hotbar)
```

### **✅ Player Experience**
1. **Spawn with items** - Bucket, watering can, 5 berry seeds automatically given
2. **Navigate hotbar** - Use `hud_left`/`hud_right` to select tools
3. **Visual feedback** - See active slot highlighted in UI
4. **Use items** - Tools and consumables ready for interaction
5. **Inventory management** - 20 total slots with smart stacking

---

## 🚀 **NEXT PHASE: Farming System Integration**

### **🎯 Core Objective**
Integrate farming mechanics with the existing inventory/hotbar system to create a complete plant-grow-harvest cycle.

### **📋 Development Priority Order**

#### **Week 1: Farming Foundation (HIGH Priority)**

##### **1. PlayerFarming Component** 
Create new component following existing architecture pattern:

```gdscript
# Target: components/player_farming.gd
class_name PlayerFarming
extends "res://components/player_component.gd"

# Integration points:
# - Connect to PlayerInventory for seed/tool checking
# - Connect to PlayerInteraction for soil interaction
# - Emit signals for farming actions (plant, water, harvest)
```

**Implementation Steps:**
- [ ] Create `components/player_farming.gd` following PlayerComponent pattern
- [ ] Add to PlayerController component initialization in `scenes/players/player_new.gd`
- [ ] Implement farming state tracking (planted crops, growth stages)
- [ ] Add signal connections for inventory integration

##### **2. Soil System**
Extend ground interaction for farming:

```gdscript
# Target: Ground nodes with farming states
# States: untilled, tilled, planted, watered, ready_to_harvest
```

**Implementation Steps:**
- [ ] Create soil state management system
- [ ] Add ground interaction detection in PlayerInteraction
- [ ] Implement hoe tool usage for soil preparation
- [ ] Visual indicators for soil states (texture changes)

##### **3. Inventory-Farming Integration**
Connect existing hotbar system to farming actions:

**Key Integration Points:**
- **Seed Usage**: `inventory.use_selected_item()` → planting action
- **Tool Selection**: Hoe, watering can from hotbar selection
- **Harvest Collection**: Automatically add crops to inventory
- **Tool Durability**: Use existing durability system

**Implementation Steps:**
- [ ] Extend `item_used` signal handling for farming tools
- [ ] Add crop item definitions to ItemRegistry
- [ ] Implement harvest → inventory addition workflow
- [ ] Tool usage cost integration (durability/water)

#### **Week 2: Growth & Lifecycle (HIGH Priority)**

##### **4. Crop Growth System**
Time-based progression using existing game timer:

```gdscript
# Growth stages: seed → sprout → growing → mature → harvestable
# Integration: Use existing survival system timer for growth ticks
```

**Implementation Steps:**
- [ ] Create crop growth state machine
- [ ] Timer integration with existing survival updates
- [ ] Visual representation for growth stages
- [ ] Growth rate factors (water, soil quality)

##### **5. Watering Integration**
Connect existing watering tools to crop care:

**Leverage Existing Systems:**
- **Bucket states**: Use existing "empty"/"full" state system
- **Tool efficiency**: Use existing tool efficiency calculations
- **PlayerInventory.can_water_crops()**: Already implemented!
- **PlayerInventory.get_watering_tool()**: Already implemented!

**Implementation Steps:**
- [ ] Connect watering tool usage to crop moisture
- [ ] Soil moisture tracking and visual feedback
- [ ] Water source interaction (fill bucket from water bodies)
- [ ] Watering can durability consumption

#### **Week 3: Harvest & Economy (MEDIUM Priority)**

##### **6. Harvest System**
Complete the farming loop with inventory integration:

**Implementation Steps:**
- [ ] Harvest action → `add_item()` integration
- [ ] Yield calculation based on care quality
- [ ] Tool-based harvesting (hands vs. scythe efficiency)
- [ ] Replanting cycle preparation

##### **7. Food Security Integration**
Connect farming output to survival system:

**Implementation Steps:**
- [ ] Crop → food resource conversion
- [ ] Integrate with existing hunger/food system
- [ ] Balance farming effort vs. gathering
- [ ] Long-term food sustainability mechanics

---

## 🔧 **Implementation Strategy**

### **Architecture Integration Approach**

#### **Component Communication Pattern**
```gdscript
# Signal-based integration following existing pattern
PlayerFarming.crop_planted → PlayerInventory.remove_seeds
PlayerFarming.crop_harvested → PlayerInventory.add_crops
PlayerInventory.item_used → PlayerFarming.handle_farming_tool
PlayerInteraction.ground_interacted → PlayerFarming.handle_soil_action
```

#### **Existing Systems to Leverage**
1. **PlayerInventory.has_item("berry_seeds")** - Check for seeds
2. **PlayerInventory.use_selected_item()** - Consume seeds/tools
3. **PlayerInventory.add_item(crop_def, quantity)** - Add harvested crops
4. **PlayerInteraction proximity detection** - Extend for ground/crops
5. **Tool efficiency system** - Use for farming tool effectiveness

### **Zero Breaking Changes Strategy**
- **Additive development only** - No changes to existing inventory/hotbar code
- **Signal-based integration** - Loose coupling between systems
- **Optional farming** - Players can ignore farming and use existing systems
- **Component isolation** - PlayerFarming contained, removable if needed

---

## 📚 **Technical Reference**

### **Current Inventory API (Ready for Farming Integration)**

```gdscript
# Item Management (Ready to Use)
inventory.has_item("berry_seeds", 1)          # Check for seeds
inventory.use_selected_item()                 # Plant seeds from hotbar
inventory.add_item(crop_definition, quantity) # Add harvested crops
inventory.remove_item("berry_seeds", 1)       # Consume seeds

# Tool Integration (Already Implemented)
inventory.can_water_crops()                   # Check watering capability
inventory.get_watering_tool()                 # Get best watering tool
inventory.get_selected_slot()                 # Current hotbar selection

# Hotbar Navigation (Player Controls)
# Players use hud_left/hud_right to select farming tools
# Visual feedback shows selected tool automatically
```

### **Starting Items (Available for Farming)**
Players automatically receive:
- **Bucket (empty)** - For water collection and crop watering
- **Watering Can** - More efficient crop watering tool
- **5x Berry Seeds** - Ready for immediate planting

### **Item System Extensions Needed**
```gdscript
# Add to ItemRegistry initialization:
- hoe_definition (for soil preparation)
- crop_definitions (harvested produce)
- fertilizer_definition (future enhancement)
- scythe_definition (efficient harvesting)
```

---

## 🎯 **Success Metrics**

### **Week 1 Goals**
- [ ] PlayerFarming component integrates seamlessly with existing architecture
- [ ] Players can use hoe from hotbar to prepare soil
- [ ] Soil states visually indicated and trackable
- [ ] Zero breaking changes to existing inventory/hotbar functionality

### **Week 2 Goals**
- [ ] Players can plant seeds from hotbar selection
- [ ] Crops grow automatically over time
- [ ] Watering tools work with existing tool efficiency system
- [ ] Growth visually represented and progresses correctly

### **Week 3 Goals**
- [ ] Complete plant → grow → harvest → replant cycle functional
- [ ] Harvested crops automatically added to inventory
- [ ] Farming provides meaningful food security
- [ ] Multi-player farming cooperation working

### **Technical Quality Standards**
- [ ] **Component Architecture**: Clean integration with existing 6-component system
- [ ] **Performance**: No impact on existing systems with farming additions
- [ ] **Test Coverage**: Maintain existing test quality for new farming features
- [ ] **Multi-Player**: Farming works perfectly in 4-player scenarios

---

## 🔄 **Long-Term Roadmap (Beyond Month 1)**

### **Month 2: Advanced Farming**
- **Crop Specialization**: 8-10 crop varieties with unique requirements
- **Advanced Tools**: Irrigation systems, greenhouse structures
- **Animal Integration**: Livestock for renewable resources

### **Month 3: Economic Systems**
- **Market System**: NPC trade for farming products
- **Quality Tiers**: Premium crops based on optimal care
- **Seasonal Systems**: Weather affecting crop viability

### **Beyond Month 3: Game Expansion**
- **Transportation**: Carts, roads for large-scale farming
- **Advanced Building**: Barns, silos, processing facilities
- **Story Campaign**: Guided progression through farming mastery

---

## 📋 **Immediate Next Actions**

### **Day 1-2: Foundation Design**
1. **Review existing component architecture** - Study PlayerComponent base class
2. **Design PlayerFarming component** - Plan integration points and signals
3. **Plan soil system** - Design ground state management approach
4. **Design tool integration** - Plan hoe, seeds, watering tool workflows

### **Day 3-4: Core Development**
1. **Create PlayerFarming component** - Implement basic structure
2. **Add to PlayerController** - Integrate with existing component system
3. **Implement basic soil interaction** - Ground state detection and modification
4. **Add hoe tool definition** - Extend ItemRegistry with farming tools

### **Day 5-7: Integration Testing**
1. **Test hotbar → farming tool usage** - Ensure smooth inventory integration
2. **Test soil preparation workflow** - Hoe usage from hotbar selection
3. **Validate component communication** - Signals working correctly
4. **Multi-player testing** - Ensure farming works for all 4 players

---

**🎮 The foundation is solid - your inventory and hotbar systems are production-ready for farming integration!**
