# Metropolis - Game Design Document

## 1. Game Overview

### 1.1 Game Title
**Metropolis** (Working Title)

### 1.2 Genre
Local Multiplayer City Builder / Survival RTS

### 1.3 Platform
PC (Windows, macOS, Linux)

### 1.4 Target Audience
- Primary: Couch co-op enthusiasts (ages 8+)
- Secondary: Casual strategy and survival game players
- Family-friendly multiplayer gaming

### 1.5 Core Concept
Metropolis is a couch-based local multiplayer game where players collaborate and compete to build the most successful town. Combining survival mechanics reminiscent of Minecraft's survival mode with real-time strategy elements, players must gather resources, construct buildings, and manage villagers while working together to overcome environmental challenges.

## 2. Gameplay Overview

### 2.1 Core Gameplay Loop
1. **Resource Gathering** - Players explore and collect materials (wood, stone, food, etc.)
2. **Construction** - Build essential structures (houses, workshops, defenses)
3. **Population Management** - Spawn and direct villagers to assist with tasks
4. **Survival Challenges** - Overcome weather, monsters, or resource scarcity
5. **Town Development** - Expand and improve the settlement
6. **Victory Conditions** - Achieve specific goals or outlast other players

### 2.2 Player Count
- 2-4 players (local multiplayer only)
- Each player controls their own character/faction
- Shared camera view ensures all players see the same game state

### 2.3 Game Modes
- **Cooperative Mode** - Players work together to build a thriving metropolis
- **Competitive Mode** - Players compete for resources and territory
- **Mixed Mode** - Cooperation required for survival, competition for victory points

## 3. Visual Design

### 3.1 Camera System
- **Fixed isometric camera** at a slight top-down angle
- **Single shared viewport** - all players see the same view
- Camera follows the action or centers on the main settlement
- Zoom levels may be adjustable but affect all players equally

### 3.2 Art Style
- **3D graphics** with a clean, colorful aesthetic
- **Isometric/3/4 perspective** for optimal visibility and strategy planning
- Stylized rather than realistic (think Civilization VI meets Stardew Valley)
- Clear visual distinction between player territories and neutral areas

### 3.3 UI Design
- **Split-screen UI elements** for individual player information
- **Shared central UI** for common information (time, weather, shared objectives)
- **Controller-friendly interface** with large, clear buttons and icons
- **Color-coded player identification** throughout the interface

## 4. Control Scheme

### 4.1 Primary Input
- **Gamepad Support** - Up to 4 Xbox/PlayStation controllers
- Each player assigned a specific controller
- Intuitive button mapping for building, selecting, and managing

### 4.2 Secondary Input
- **Keyboard Support** - One player can use keyboard + mouse
- WASD movement, mouse for selection and building placement
- Hotkeys for common actions and building types

### 4.3 Control Mapping
- **Movement** - Left stick/WASD
- **Select/Interact** - A button/Left click
- **Cancel** - B button/Right click
- **Building Menu** - Y button/Tab
- **Villager Commands** - X button/Space
- **Resource Panel** - Shoulder buttons/Number keys

## 5. Core Mechanics

### 5.1 Resource System
- **Primary Resources**: Wood, Stone, Food, Gold
- **Advanced Resources**: Iron, Tools, Luxury Goods
- **Resource Nodes**: Trees, quarries, farms, mines scattered across the map
- **Inventory Limits**: Players have limited carrying capacity

### 5.2 Building System
- **Construction Requirements**: Specific resources needed for each building type
- **Building Categories**:
  - **Housing**: Increases population capacity
  - **Production**: Workshops, farms, mines
  - **Defense**: Walls, towers, barracks
  - **Utility**: Storage, roads, decorations

### 5.3 Villager System
- **Recruitment**: Spend resources to spawn villagers
- **Specialization**: Assign villagers to specific roles (builder, farmer, guard)
- **Automation**: Villagers work independently but can be directed
- **Happiness**: Villager efficiency depends on housing, food, and safety

### 5.4 Survival Elements
- **Day/Night Cycle**: Monsters appear at night, reduced visibility
- **Weather System**: Rain affects farming, snow slows movement
- **Hunger**: Players and villagers need regular food
- **Health**: Combat and environmental hazards can damage players

## 6. Victory Conditions

### 6.1 Cooperative Victory
- **Population Milestone**: Reach a target number of happy villagers
- **Wonder Construction**: Build a massive collaborative structure
- **Survival Challenge**: Survive for a set number of days/seasons

### 6.2 Competitive Victory
- **Economic Victory**: First to accumulate specified wealth/resources
- **Population Victory**: Largest thriving settlement
- **Territorial Victory**: Control the most valuable land
- **Points Victory**: Most points from various achievements after time limit

## 7. Technical Specifications

### 7.1 Engine
- **Godot 4** - Open source, excellent 3D support, good for indie development

### 7.2 Performance Targets
- **60 FPS** at 1080p with 4 players active
- **Scalable graphics** settings for various hardware
- **Local multiplayer optimization** - single instance handling multiple inputs

### 7.3 Save System
- **Session-based gameplay** - matches last 30-90 minutes
- **Quick save/load** for pausing long sessions
- **Statistics tracking** for player progression and achievements

## 8. Development Phases

### 8.1 Phase 1 - Core Foundation (Weeks 1-4)
- Basic player movement and camera system
- Simple resource gathering mechanics
- Basic building placement system
- Single player prototype

### 8.2 Phase 2 - Multiplayer Integration (Weeks 5-8)
- Local multiplayer input handling
- UI for multiple players
- Basic villager spawning and management
- Resource sharing/competition mechanics

### 8.3 Phase 3 - Content and Polish (Weeks 9-12)
- Additional building types and mechanics
- Survival elements (day/night, weather)
- Multiple game modes
- Audio and visual polish

### 8.4 Phase 4 - Testing and Balancing (Weeks 13-16)
- Playtesting with target audience
- Balance adjustments
- Bug fixes and optimization
- Final polish and release preparation

## 9. Potential Expansions

### 9.1 Additional Content
- **New Biomes**: Desert, arctic, coastal environments
- **Advanced Technologies**: Research trees, new building types
- **Seasonal Events**: Special challenges and rewards
- **Scenario Mode**: Pre-designed challenges and maps

### 9.2 Quality of Life
- **Replay System**: Record and watch previous matches
- **Custom Maps**: Level editor for community content
- **Achievement System**: Unlockable rewards and progression
- **Accessibility Options**: Colorblind support, input alternatives

## 10. Risk Assessment

### 10.1 Technical Risks
- **Performance**: Multiple AI villagers with 4 players may impact framerate
- **Input Handling**: Managing 4 simultaneous controller inputs smoothly
- **Camera System**: Ensuring all players can see relevant action

### 10.2 Design Risks
- **Complexity Balance**: Keeping mechanics accessible while engaging
- **Player Conflict**: Balancing cooperation vs competition
- **Session Length**: Finding optimal match duration for couch play

### 10.3 Mitigation Strategies
- Early prototyping of risky technical elements
- Regular playtesting with target audience
- Modular design allowing feature adjustment
- Performance profiling throughout development

---

*This document is a living design guide and will be updated as development progresses and feedback is incorporated.*
