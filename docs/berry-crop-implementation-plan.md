# 🍓 Berry Crop Implementation Plan

**Project**: Metropolis  
**Feature**: Renewable Berry Crop System  
**Status**: Implementation Ready  
**Integration**: Seamless with existing component architecture

---

## 📋 **Overview**

This plan outlines implementing a renewable berry crop system that integrates with your existing survival, resource management, and interaction systems. The berry crop grows through 4 visual stages, can be harvested for food, and regrows over time for sustainable food production.

## 🎯 **Core Features**

### **Growth System**
- **4 Visual Stages**: Sprout → Young Bush → Mature Bush → Berry-bearing Bush
- **Time-based Progression**: Configurable growth durations for each stage
- **Care Quality**: Watering affects growth speed and harvest yield
- **Renewable Cycle**: After harvest, regrows berries for repeated harvesting

### **Integration Points**
- **Resource System**: Berries as food resource with custom hunger restoration
- **Survival System**: Renewable food source for long-term survival
- **Interaction System**: Uses existing player interaction patterns
- **Progress System**: Visual progress bars for harvesting

---

## 🔧 **Implementation Phases**

## **Phase 1: Core Berry System (Complete)**

### ✅ **Enhanced Berry Script (berries.gd)**
- Extended your basic berries.gd with full growth and harvest system
- Configurable growth stages with visual model switching
- Care system with moisture levels and growth speed modifiers
- Harvest system following existing BaseFood patterns
- Regrowth cycle for renewable harvesting

### **Key Features Implemented:**
```gdscript
# Growth Configuration
stage_durations: [30.0, 45.0, 60.0, 30.0]  # seconds per stage
harvest_amount: 3  # berries per harvest
hunger_restore_per_berry: 15.0  # hunger restoration value
regrow_time: 45.0  # berry regrowth after harvest

# Care System
moisture_level: 0.0-1.0  # affects growth speed
care_quality: 0.0-2.0    # affects harvest yield
growth_speed_multiplier  # modified by watering
```

## **Phase 2: Resource System Integration (Next Steps)**

### **Resource Type Extensions**
Add these resource types to your ResourceManager initialization:

```gdscript
# In player setup or resource configuration
resource_manager.setup_resource_type("berry_seeds", 20, 5)    # Seeds for planting
resource_manager.setup_resource_type("berries", 50, 0)       # Raw berries (alternative to generic "food")
resource_manager.setup_resource_type("watering_can", 1, 0)   # Farming tool
```

### **Integration Benefits**
- **Renewable Food Source**: Long-term food security for survival system
- **Higher Value Food**: Berries provide more hunger restoration than basic gathered food
- **Investment Gameplay**: Initial seed cost, time investment, ongoing care for higher yields

## **Phase 3: Player Interaction Integration (Week 2)**

### **Farming Actions Integration**
```gdscript
# Extend PlayerInteraction component to handle berry farming
func interact_with_berry_crop():
    if nearby_crop.is_harvestable:
        return nearby_crop.start_harvesting(player_controller)
    elif nearby_crop.needs_water() and has_watering_can():
        return nearby_crop.water_crop(player_controller)
    else:
        show_crop_status(nearby_crop)
```

### **Tool System Integration**
- **Watering Can**: Tool for crop care, stored in resource system
- **Seeds**: Plantable items for establishing new berry crops
- **Quality Tools**: Future tools for improved care and yields

## **Phase 4: Advanced Features (Month 2)**

### **Planned Enhancements**
1. **Multiple Crop Varieties**: Different berry types with unique requirements
2. **Soil System**: Tilled ground requirements for planting
3. **Seasonal Mechanics**: Growth affected by day/night cycles
4. **Processing System**: Converting berries to preserves, jams, etc.

---

## 🎮 **Gameplay Flow**

### **Planting Phase**
1. Player obtains berry seeds (from gathering, trading, etc.)
2. Prepares soil using farming tools (future: hoe for tilling)
3. Plants seeds which become stage1 berry crops

### **Growth Phase**
1. Berry crop automatically progresses through stages over time
2. Player can water crops to increase growth speed and quality
3. Neglected crops grow slower and yield fewer berries

### **Harvest Phase**
1. Stage4 crops show visual berries and become harvestable
2. Player interacts to start harvesting (3-second progress bar)
3. Berries added to player's food inventory with high hunger restoration
4. Crop returns to stage3 and begins regrowth cycle

### **Sustainability Loop**
1. Harvested crops regrow berries after regrow_time
2. Well-cared crops yield more berries per harvest
3. Provides renewable food source for long-term survival

---

## 📊 **Technical Specifications**

### **Performance Considerations**
- Efficient stage switching (only visual model changes)
- Minimal processing overhead (simple timers and progress tracking)
- Scalable to many crops (each manages own state independently)

### **Save/Load Integration**
The berry system will need save state integration:
```gdscript
# Save data structure
berry_save_data = {
    "current_stage": current_stage,
    "stage_timer": stage_timer,
    "moisture_level": moisture_level,
    "care_quality": care_quality,
    "is_harvestable": is_harvestable
}
```

### **Multiplayer Compatibility**
- Each berry crop manages its own state
- Harvest actions are atomic (one player at a time)
- Growth continues independently for all players
- Cooperative care possible (multiple players can water same crop)

---

## 🛠️ **Integration Steps**

### **Immediate Next Steps**

1. **Test Current Implementation**
   ```bash
   # Test the berry.gd script with your berry.tscn
   # Verify stage model switching works correctly
   # Test growth progression and harvest cycle
   ```

2. **Resource System Extension**
   ```gdscript
   # Add berry-related resources to ResourceManager setup
   # Test berry harvesting adds to food inventory
   # Verify hunger restoration integration
   ```

3. **Player Interaction Integration**
   ```gdscript
   # Extend PlayerInteraction to handle berry crops
   # Add berry crop to interaction types
   # Test harvest interactions work with progress bars
   ```

### **Week 2 Goals**
- [ ] Berry crops fully functional with growth and harvest
- [ ] Integration with player interaction system
- [ ] Resource system extended for berry-related items
- [ ] Basic watering system functional

### **Month 2 Goals**  
- [ ] Multiple berry varieties with different characteristics
- [ ] Soil preparation requirements for planting
- [ ] Advanced care mechanics (fertilizer, pruning, etc.)
- [ ] Economic integration (selling berries, trading systems)

---

## 🎯 **Success Metrics**

### **Technical Metrics**
- ✅ Zero breaking changes to existing systems
- ✅ Component integration follows established patterns
- ✅ Performance impact negligible with 20+ berry crops
- ✅ Full save/load state preservation

### **Gameplay Metrics**
- ✅ Complete berry lifecycle functional (plant → grow → harvest → regrow)
- ✅ Meaningful food security for survival system
- ✅ Satisfying progression and care mechanics
- ✅ Cooperative gameplay enhancement in multiplayer

---

## 🚀 **Future Expansion Opportunities**

### **Advanced Farming Features**
- **Greenhouse Systems**: Controlled environment for year-round growing
- **Irrigation Systems**: Automated watering for large-scale farming
- **Crop Breeding**: Combining varieties for improved traits
- **Market Economy**: Trading surplus crops with NPCs or other players

### **Integration with Planned Systems**
- **Building System**: Berry farms as placeable structures
- **Transportation**: Carts for moving large harvests
- **Processing**: Cooking berries into more valuable food items
- **Community Features**: Shared community farms for multiplayer cooperation

---

**🎯 Current Status**: Core berry system implemented and ready for testing. The foundation provides excellent groundwork for expanding into a comprehensive farming system that will significantly enhance the Metropolis survival and cooperation experience.
