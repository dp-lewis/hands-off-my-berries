# Hands Off My Berries
## Complete Game Design Document

---

## 🎮 **Game Overview**

**Hands Off My Berries** is a 3D cooperative survival game where 1-4 players work together to survive in a hostile environment by gathering resources, building shelters, and developing sustainable agriculture. The game features a day/night cycle with environmental threats and emphasizes resource management, farming, and cooperative gameplay.

### **Core Vision**
A survival game that balances immediate needs (hunger, thirst, shelter) with long-term planning (agriculture, base building) in a cooperative multiplayer environment.

### **Target Audience**
- Families and friends seeking cooperative gaming experiences
- Survival game enthusiasts who enjoy resource management
- Players who appreciate farming and building mechanics
- Couch co-op gaming groups (1-4 players)

---

## 🎯 **Core Gameplay Loop**

### **Primary Loop (First 30 Minutes)**
1. **Spawn & Explore** → Players start with basic tools and seeds
2. **Immediate Survival** → Gather food and water from environment
3. **Shelter Building** → Construct tents for night protection
4. **Resource Collection** → Gather wood, food, and materials
5. **Basic Agriculture** → Plant first crops for sustainable food

### **Secondary Loop (1-2 Hours)**
1. **Farm Development** → Expand crop production systems
2. **Storage Systems** → Build chests for resource management
3. **Tool Advancement** → Craft better farming and gathering tools
4. **Base Expansion** → Create larger, more efficient settlements
5. **Cooperative Specialization** → Players focus on different roles

### **Long-term Loop (2+ Hours)**
1. **Sustainable Economy** → Self-sufficient food and resource production
2. **Advanced Building** → Complex shelter and storage networks
3. **Environmental Mastery** → Weather and seasonal challenges
4. **Exploration & Discovery** → New areas, resources, and challenges

---

## 🧩 **Core Systems**

### **1. Survival System**
**Purpose**: Creates urgency and resource pressure

**Mechanics**:
- **Health**: Damage from environment, falling, starvation
- **Hunger**: Depletes over time, restored by consuming food
- **Thirst**: Requires water collection and consumption
- **Tiredness**: Affects movement speed and gathering efficiency
- **Death State**: Complete input/movement lockdown until respawn

**Integration**: Drives all other system usage and resource prioritization

### **2. Inventory & Hotbar System**
**Purpose**: Central interface for all player interactions

**Mechanics**:
- **5-slot inventory**: Smart stacking, item states, quantity management
- **Visual feedback**: Selected slot highlighting, item name display
- **State tracking**: Tool durability, container fill levels
- **Automatic starting items**: Bucket, watering can, 5 berry seeds

**Integration**: Hub for all resource management, tool usage, and item consumption

### **3. Resource Management**
**Purpose**: Strategic decision-making around limited resources

**Mechanics**:
- **Wood**: Building material for tents and chests
- **Food**: Multiple types with varying hunger restoration
- **Water**: Essential survival resource with collection mechanics
- **Seeds**: Agricultural investment for renewable food
- **Tools**: Durability-based efficiency modifiers

**Integration**: Connects gathering, building, farming, and survival systems

### **4. Agriculture System**
**Purpose**: Sustainable food production and long-term planning

**Mechanics**:
- **4-stage crop growth**: Seed → Sprout → Bush → Harvestable
- **Care quality system**: Watering affects growth speed and yield
- **Renewable harvests**: Crops regrow after harvesting
- **Tool integration**: Hoe for soil prep, watering can for care
- **Yield calculation**: 1-6 berries per harvest based on care

**Integration**: Uses inventory for seeds/tools, provides food for survival

### **5. Building System**
**Purpose**: Environmental protection and resource storage

**Mechanics**:
- **Tents**: Provide shelter bonuses and night protection
- **Chests**: Multi-player accessible storage with interaction locks
- **Resource costs**: Wood requirements for construction
- **Placement system**: Proximity detection and world positioning

**Integration**: Consumes wood resources, provides survival benefits

### **6. Interaction System**
**Purpose**: World interaction and proximity-based actions

**Mechanics**:
- **Proximity detection**: Automatic detection of interactable objects
- **Progress bars**: Visual feedback for timed actions
- **Multi-object handling**: Food gathering, building placement, farming
- **Player isolation**: Prevents interaction conflicts in multiplayer

**Integration**: Enables all world interactions across systems

### **7. Component Architecture**
**Purpose**: Modular, maintainable system organization

**Structure**:
```
PlayerController (Central coordinator)
├── PlayerMovement      (Physics, animation, navigation)
├── PlayerSurvival      (Health, hunger, thirst, death states)
├── PlayerInventory     (Items, hotbar, resource management)
├── PlayerBuilder       (Construction, placement, resource costs)
├── PlayerInteraction   (World objects, proximity, actions)
└── PlayerInputHandler  (Multi-player input isolation)
```

**Benefits**: Zero breaking changes, signal-based communication, independent testing

---

## 🎮 **Player Experience Design**

### **Onboarding (First 5 Minutes)**
1. **Spawn with tools** → Immediate capability to interact
2. **Visual hotbar** → Clear interface for tool selection
3. **Nearby resources** → Food and water within walking distance
4. **Simple building** → One tent provides immediate shelter
5. **Guided farming** → Seeds ready to plant for first crops

### **Early Game (5-30 Minutes)**
1. **Resource pressure** → Hunger/thirst create urgency
2. **Discovery** → Find gathering spots and building locations
3. **First agriculture** → Plant and tend initial crops
4. **Shelter establishment** → Build tents for night survival
5. **Tool familiarity** → Learn hotbar navigation and tool usage

### **Mid Game (30 Minutes - 2 Hours)**
1. **System mastery** → Efficient resource gathering and farming
2. **Base development** → Expand shelter and storage networks
3. **Specialization** → Players develop preferred roles
4. **Sustainability** → Achieve self-sufficient food production
5. **Exploration** → Venture further for rare resources

### **Late Game (2+ Hours)**
1. **Optimization** → Perfect base layouts and farming efficiency
2. **Collaboration** → Complex multi-player coordination
3. **Challenges** → Environmental threats and resource scarcity
4. **Mastery** → Complete understanding of all systems

---

## 🏗️ **Technical Architecture**

### **Component-Based Design**
- **Signal-driven communication**: Loose coupling between systems
- **Modular components**: Each system independently testable
- **Zero breaking changes**: Additive development only
- **Multi-player isolation**: Input and state separation per player

### **Performance Considerations**
- **Efficient resource tracking**: O(1) inventory operations
- **Optimized interaction detection**: Spatial partitioning for proximity
- **Minimal state synchronization**: Component-level state management
- **Scalable agriculture**: Handles 20+ crops without performance impact

### **Save/Load System**
- **Component state preservation**: Each system saves/loads independently
- **World persistence**: Building and crop states maintained
- **Player progress**: Inventory and advancement tracking
- **Session continuity**: Resume exactly where players left off

---

## 🎯 **Progression Systems**

### **Skill Development**
- **Gathering efficiency**: Learn optimal resource collection patterns
- **Agricultural expertise**: Master crop care and yield optimization
- **Building mastery**: Efficient base layout and construction
- **Survival optimization**: Resource management and planning skills

### **Tool Advancement**
- **Basic tools**: Starting bucket and watering can
- **Specialized tools**: Hoe for farming, better gathering implements
- **Durability management**: Strategic tool use and maintenance
- **Efficiency gains**: Better tools provide superior results

### **Base Development**
- **Shelter progression**: From single tent to compound structures
- **Storage expansion**: Multiple chests for resource organization
- **Agricultural development**: From survival farming to surplus production
- **Defensive structures**: Protection from environmental threats

---

## 🌍 **World & Environment**

### **Day/Night Cycle**
- **Day**: Safe exploration and resource gathering
- **Night**: Environmental threats requiring shelter
- **Shelter benefits**: Protection and survival bonuses
- **Time pressure**: Limited daylight for outdoor activities

### **Resource Distribution**
- **Food sources**: Berries, pumpkins, and other natural foods
- **Water access**: Rivers, ponds, and collection points
- **Building materials**: Trees and wood gathering areas
- **Agricultural land**: Suitable areas for crop cultivation

### **Environmental Challenges**
- **Weather effects**: Impact on farming and gathering
- **Seasonal changes**: Long-term planning requirements
- **Resource scarcity**: Limited availability drives exploration
- **Cooperative requirements**: Some challenges need multiple players

---

## 🤝 **Multiplayer Design**

### **Cooperative Focus**
- **1-4 players**: Scalable from solo to full group
- **Couch co-op**: Local multiplayer with gamepad support
- **Shared resources**: Collective inventory and base building
- **Individual progress**: Personal inventory and tool management

### **Role Specialization**
- **Farmer**: Focus on agriculture and food production
- **Builder**: Specialize in construction and base development
- **Gatherer**: Excel at resource collection and exploration
- **Organizer**: Manage storage and resource distribution

### **Conflict Resolution**
- **Interaction locks**: Prevent simultaneous object use
- **Input isolation**: Individual player controls and UI
- **Resource sharing**: Chest-based storage system
- **Communication**: Visual feedback for player actions

---

## 📈 **Success Metrics**

### **Player Engagement**
- **Session length**: Target 1-2 hour play sessions
- **Return rate**: Players come back for continued development
- **Cooperation quality**: Effective multi-player coordination
- **Mastery progression**: Clear skill development over time

### **System Quality**
- **Zero breaking changes**: Stable, reliable system additions
- **Performance consistency**: Smooth gameplay with multiple systems
- **Multi-player stability**: Flawless 4-player experiences
- **Content accessibility**: All features usable solo or in groups

### **Long-term Viability**
- **Sustainable gameplay**: Systems support extended play
- **Replayability**: Different approaches and strategies viable
- **Expandability**: Architecture supports additional features
- **Community engagement**: Players share strategies and experiences

---

## 🚀 **Development Roadmap**

### **Phase 1: Foundation (COMPLETE)**
- ✅ Component architecture implementation
- ✅ Inventory and hotbar systems
- ✅ Basic survival mechanics
- ✅ Multi-player input handling
- ✅ Building system (tents, chests)

### **Phase 2: Agriculture (IN PROGRESS)**
- 🔄 Crop planting and growth systems
- 🔄 Harvesting and yield mechanics
- 🔄 Tool integration for farming
- 🔄 Seed dropping and collection
- ⏳ Complete agricultural cycle

### **Phase 3: Polish & Balance**
- ⏳ Survival system balancing
- ⏳ Resource economy tuning
- ⏳ Visual feedback improvements
- ⏳ Performance optimization
- ⏳ Bug fixes and stability

### **Phase 4: Enhancement**
- ⏳ Weather and seasons
- ⏳ Advanced building options
- ⏳ Tool crafting and advancement
- ⏳ Environmental challenges
- ⏳ Extended progression systems

---

## 💡 **Key Innovation Points**

### **Cooperative Agriculture**
Farming requires coordination - watering, harvesting, and replanting work better with multiple players sharing responsibilities.

### **Integrated Component Architecture**
Each game system is a modular component that communicates through signals, enabling robust multiplayer and easy feature additions.

### **Simplified Complexity**
Complex survival mechanics presented through intuitive hotbar interface - deep systems accessible through simple controls.

### **Renewable Progression**
Unlike traditional survival games focused on consumption, agriculture provides renewable advancement through sustainable resource production.

### **Social Pressure & Cooperation**
Survival needs create natural cooperation requirements while farming provides long-term collaborative goals.

---

**Hands Off My Berries** combines immediate survival tension with long-term agricultural planning in a cooperative environment that rewards both individual skill development and group coordination. The modular architecture ensures stable, expandable gameplay while the integrated systems create emergent cooperation and strategic depth.
