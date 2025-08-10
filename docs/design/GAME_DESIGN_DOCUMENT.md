# Metropolis - Game Design Document

## 1. Game Overview

### 1.1 Game Title
**Metropolis** (Working Title)

### 1.2 Genre
Local Multiplayer Survival / Building Game

### 1.3 Platform
PC (Windows, macOS, Linux)

### 1.4 Target Audience
- Primary: Couch co-op enthusiasts (ages 8+)
- Secondary: Casual survival and building game players
- Family-friendly multiplayer gaming

### 1.5 Core Concept
Metropolis is a couch-based local multiplayer survival game where players must work together to survive in a challenging environment. Combining resource gathering and building mechanics with survival elements, players must collect materials, construct shelters and tools, and overcome environmental threats while managing their basic needs for food, warmth, and safety.

## 2. Gameplay Overview

### 2.1 Core Gameplay Loop
1. **Resource Gathering** - Players explore and collect materials (wood, stone, food, etc.)
2. **Survival Management** - Monitor hunger, health, temperature, and fatigue
3. **Shelter Construction** - Build protective structures and safe zones
4. **Tool & Equipment Crafting** - Create better tools and survival gear
5. **Environmental Challenges** - Overcome weather, hazards, and threats
6. **Base Expansion** - Improve and expand your survival settlement

### 2.2 Player Count
- 2-4 players (local multiplayer only)
- Each player controls their own character
- Shared camera view ensures all players see the same game state

### 2.3 Game Modes
- **Cooperative Survival** - Players work together to survive as long as possible
- **Competitive Survival** - Players compete to be the last survivor or achieve survival goals first
- **Challenge Mode** - Specific survival scenarios with unique objectives

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
- **Interact/Gather** - A button/Left click
- **Cancel** - B button/Right click
- **Building Menu** - Y button/Tab
- **Inventory/Crafting** - X button/Space
- **Status Panel** - Shoulder buttons/Number keys

## 5. Core Mechanics

### 5.1 Resource System
- **Primary Resources**: Wood, Stone, Food, Fiber
- **Advanced Resources**: Metal, Tools, Medicine, Fuel
- **Resource Nodes**: Trees, quarries, berry bushes, mineral deposits scattered across the map
- **Inventory Limits**: Players have limited carrying capacity requiring strategic resource management

### 5.2 Building System
- **Construction Requirements**: Specific resources and tools needed for each structure
- **Building Categories**:
  - **Shelter**: Tents, cabins, fortified structures for protection
  - **Workstations**: Crafting benches, forges, cooking areas
  - **Storage**: Chests, silos, resource stockpiles
  - **Utilities**: Wells, fire pits, farms, defensive barriers

### 5.3 Survival Mechanics
- **Hunger System**: Players must regularly consume food or face health penalties
- **Health Management**: Combat, falls, and environmental hazards reduce health
- **Temperature**: Players must stay warm/cool depending on weather and season
- **Fatigue**: Extended activity requires rest periods for optimal performance
- **Tool Durability**: Equipment degrades with use and must be repaired or replaced

### 5.4 Environmental Threats
- **Day/Night Cycle**: Dangerous creatures emerge at night, reduced visibility
- **Weather System**: Rain, snow, and storms affect player movement and health
- **Natural Hazards**: Falling rocks, flooding, extreme temperatures
- **Resource Depletion**: Areas become less productive over time, forcing exploration

### 5.5 Crafting System
- **Tool Progression**: Start with basic tools, craft better equipment over time
- **Recipe Discovery**: Learn new crafting recipes through experimentation and exploration
- **Quality Levels**: Higher-tier materials create more durable and effective items
- **Specialization**: Different crafting stations enable unique item categories

## 6. Victory/Success Conditions

### 6.1 Cooperative Success
- **Survival Duration**: Survive together for a target number of days/seasons
- **Base Completion**: Build a fully functional and secure survival base
- **Rescue/Escape**: Reach a rescue point or build an escape vehicle
- **Resource Milestones**: Collectively gather and stockpile survival essentials

### 6.2 Competitive Success
- **Last Survivor**: Be the final player remaining alive
- **Resource Accumulation**: First to gather specified survival resources
- **Base Quality**: Build the most advanced and secure survival shelter
- **Challenge Completion**: First to complete specific survival objectives

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
- Resource gathering mechanics (wood, stone, food)
- Basic building placement system (shelters, storage)
- Single player survival prototype

### 8.2 Phase 2 - Multiplayer Integration (Weeks 5-8)
- Local multiplayer input handling
- UI for multiple players with individual status tracking
- Survival mechanics (hunger, health, temperature)
- Resource sharing and competition mechanics

### 8.3 Phase 3 - Content and Polish (Weeks 9-12)
- Additional building types and crafting systems
- Environmental threats (day/night, weather, hazards)
- Multiple game modes and win conditions
- Audio and visual polish

### 8.4 Phase 4 - Testing and Balancing (Weeks 13-16)
- Playtesting with target audience
- Survival balance adjustments
- Bug fixes and optimization
- Final polish and release preparation

## 9. Potential Expansions

### 9.1 Additional Content
- **New Biomes**: Desert, arctic, coastal environments with unique survival challenges
- **Advanced Technologies**: Tool upgrades, complex crafting recipes
- **Seasonal Events**: Weather disasters, resource bonuses, special challenges
- **Scenario Mode**: Pre-designed survival challenges and escape scenarios

### 9.2 Quality of Life
- **Replay System**: Record and watch previous matches
- **Custom Maps**: Level editor for community content
- **Achievement System**: Unlockable rewards and progression
- **Accessibility Options**: Colorblind support, input alternatives

## 10. Risk Assessment

### 10.1 Technical Risks
- **Performance**: Complex survival calculations with 4 players may impact framerate
- **Input Handling**: Managing 4 simultaneous controller inputs smoothly
- **Camera System**: Ensuring all players can see relevant survival information

### 10.2 Design Risks
- **Complexity Balance**: Keeping survival mechanics accessible while challenging
- **Player Cooperation**: Balancing individual survival vs team cooperation
- **Session Length**: Finding optimal match duration for survival gameplay

### 10.3 Mitigation Strategies
- Early prototyping of risky technical elements
- Regular playtesting with target audience
- Modular design allowing feature adjustment
- Performance profiling throughout development

---

*This document is a living design guide and will be updated as development progresses and feedback is incorporated.*
