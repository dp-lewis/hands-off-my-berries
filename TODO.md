# Metropolis - TODO List

## ✅ Completed Features

### Survival Systems
- [x] **Comprehensive survival mechanics implemented**
  - [x] Health, Hunger, and Tiredness systems with interconnected effects
  - [x] Auto-consumption system for food when hunger is low
  - [x] Tiredness penalties from activities (gathering, building, walking)
  - [x] Health loss when hunger or tiredness reach zero
  - [x] Nighttime tiredness penalty when not in shelter

### Day/Night Cycle
- [x] **Full day/night system with survival integration**
  - [x] 60-second day + 30-second night cycles
  - [x] Visual lighting changes between day and night
  - [x] Day counter with persistent tracking across cycles
  - [x] Enhanced survival pressure during nighttime

### Resource Management
- [x] **Multi-resource inventory system**
  - [x] Separate inventories for wood (10 max) and food (5 max)
  - [x] Resource gathering from trees (wood) and pumpkins (food)
  - [x] Progress-based gathering with visual feedback
  - [x] Inventory full protection and space checking

### Building System
- [x] **Complete tent construction system**
  - [x] Ghost preview system for tent placement
  - [x] Resource cost requirement (8 wood) for tent construction
  - [x] Progress-based building with player interaction
  - [x] Build mode toggle (Tab key for keyboard player)

### Shelter System
- [x] **Functional tent shelter mechanics**
  - [x] Tent entry/exit system with area detection
  - [x] Tiredness recovery while sheltered (10.0 per minute)
  - [x] Protection from nighttime tiredness penalties
  - [x] Clear shelter status tracking and feedback

### User Interface
- [x] **Simple, functional UI system**
  - [x] Individual player stat displays (top-left corner)
  - [x] Global day counter (bottom-center, prominent display)
  - [x] Real-time stat updates with color-coded player identification
  - [x] Deferred UI creation to prevent timing errors

### Player System
- [x] **Complete player controller implementation**
  - [x] Smooth character movement with acceleration/friction
  - [x] Character rotation to face movement direction
  - [x] Animation system with state mapping (walk, idle, gather)
  - [x] Multi-interaction system (trees, pumpkins, tents, shelters)

## 🚨 Immediate Tasks

### Input System
- [ ] Set up Input Map in Project Settings for multiplayer
  - [ ] Add `p2_left`, `p2_right`, `p2_up`, `p2_down` for Player 2 (Gamepad 1)
  - [ ] Add `p3_left`, `p3_right`, `p3_up`, `p3_down` for Player 3 (Gamepad 2)
  - [ ] Add `p4_left`, `p4_right`, `p4_up`, `p4_down` for Player 4 (Gamepad 3)
  - [ ] Map keyboard controls for Player 1 (WASD/Arrow keys)
  - [ ] Test gamepad detection and input

### Player System
- [ ] Add player visual identification (colors, numbers, etc.)
- [ ] Create player spawning system for multiple players

## 🎮 Core Gameplay Features

### Camera System
- [ ] Implement fixed isometric camera
- [ ] Set up camera positioning and angle
- [ ] Add camera follow logic (center on action/settlement)
- [ ] Test camera with multiple players moving

### Resource Management
- [x] **Complete resource management system refactoring (COMPLETED Aug 10, 2025)**
  - [x] Extracted resource logic from 599-line player script into component architecture
  - [x] Implemented ResourceManager component with Dictionary-based storage
  - [x] Created signal-driven reactive UI system replacing polling
  - [x] Updated all resource collection (trees, pumpkins) to use ResourceManager
  - [x] Updated building system (tents) to use ResourceManager for costs
  - [x] Created reusable UI components with automatic capacity visualization
  - [x] Comprehensive test suite with 100% validation and performance testing
  - [x] Complete elimination of legacy code patterns and tight coupling

### Building System  
- [ ] Design additional building types beyond tents
- [ ] Expand construction requirements and recipes
- [ ] Create building collision and validation
- [ ] Add building upgrade system

### Expanded Resource System
- [ ] Expand resource types (Stone, Gold, etc.)
- [ ] Create additional resource nodes (quarries, mines, etc.)
- [ ] Add resource sharing/competition mechanics

### Villager System
- [ ] Design villager AI and behavior
- [ ] Implement villager spawning
- [ ] Add villager job assignment system
- [ ] Create villager automation (gathering, building, etc.)
- [ ] Add villager happiness/efficiency system

## 🎨 Visual and Audio

### Graphics
- [ ] Create proper player models/sprites
- [ ] Design building models and textures
- [ ] Create resource node visuals
- [ ] Design UI elements for multiplayer
- [ ] Add particle effects and visual feedback

### Audio
- [ ] Add background music
- [ ] Create sound effects for actions
- [ ] Add audio feedback for building/gathering
- [ ] Implement spatial audio for multiplayer

## 🕹️ Game Modes and Features

### Game Modes
- [ ] Implement Cooperative Mode
- [ ] Create Competitive Mode
- [ ] Design Mixed Mode (cooperation + competition)
- [ ] Add victory condition systems

### Survival Elements
- [x] Implement day/night cycle
- [x] Create hunger/health mechanics  
- [x] Add tiredness/fatigue system
- [ ] Add weather system
- [ ] Design monster/threat system

### Map and World
- [ ] Design map size and boundaries
- [ ] Create terrain generation or fixed maps
- [ ] Add biome variety (if applicable)
- [ ] Implement resource node placement

## 🔧 Technical Tasks

### Performance
- [ ] Profile performance with 4 players + villagers
- [ ] Optimize rendering for isometric view
- [ ] Implement object pooling for frequent spawns
- [ ] Add graphics quality settings

### UI/UX
- [ ] Design multiplayer-friendly UI layout
- [ ] Create controller-friendly interface
- [ ] Add split-screen UI elements for players
- [ ] Implement accessibility features

### Save System
- [ ] Implement session save/load
- [ ] Add game state persistence
- [ ] Create statistics tracking
- [ ] Design achievement system

## 📋 Polish and Testing

### Gameplay Testing
- [ ] Conduct couch multiplayer playtests
- [ ] Balance resource economy
- [ ] Tune game pacing and session length
- [ ] Test all victory conditions

### Bug Fixes and Polish
- [ ] Fix any movement or input issues
- [ ] Polish animations and transitions
- [ ] Add juice and game feel improvements
- [ ] Optimize for target framerate (60 FPS)

## 📚 Documentation

### Development Docs
- [x] Update Game Design Document based on implementation
- [x] Create technical architecture documentation
- [x] Document design decisions and rationale
- [ ] Document input mapping and controls
- [ ] Write gameplay mechanics documentation

### Player Documentation
- [ ] Create player manual/tutorial
- [ ] Design in-game help system
- [ ] Add control scheme reference
- [ ] Create quick start guide

## 🎯 Future Considerations

### Potential Features
- [ ] Custom map editor
- [ ] Replay system
- [ ] Additional biomes/environments
- [ ] Research/technology trees
- [ ] Seasonal events and challenges

### Quality of Life
- [ ] Colorblind accessibility options
- [ ] Alternative input methods
- [ ] Difficulty settings
- [ ] Practice/tutorial mode

---

## 📝 Notes

### Current Status
- ✅ Basic project structure created
- ✅ Player movement system implemented 
- ✅ Game Design Document written
- ✅ Development environment set up
- ✅ Complete survival mechanics (health, hunger, tiredness)
- ✅ Day/night cycle with visual feedback and day counter
- ✅ Resource gathering system (wood from trees, food from pumpkins)
- ✅ Building system with tent construction and ghost preview
- ✅ Shelter system with tent entry/exit and recovery mechanics
- ✅ Simple UI system with player stats and global day display
- ✅ Design decisions documented in /docs/ folder
- ✅ **Complete resource management refactoring (Aug 10, 2025)**
  - ✅ Component-based architecture with ResourceManager
  - ✅ Signal-driven reactive UI system
  - ✅ Comprehensive test suite with performance validation
  - ✅ All legacy code eliminated, 100% test pass rate

### Next Priority
Set up input mapping for multiplayer controllers and test local multiplayer with multiple players. The resource management foundation is now solid and ready for multiplayer expansion.

### Important Reminders
- Test frequently with actual controllers
- Keep multiplayer experience in mind for all features
- Maintain 60 FPS target throughout development
- Regular playtesting with target audience
- Resource management architecture can now support multiple players seamlessly

---

*Last Updated: August 10, 2025 - Complete resource management refactoring completed with component-based architecture*
