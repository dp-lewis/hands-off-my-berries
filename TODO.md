# Metropolis - TODO List

## 🚨 Immediate Tasks

### Tent Shelter System
- [ ] **FIX: Tent entry not working** - Players can't figure out how to enter built tents for shelter
  - [ ] Debug tent shelter area detection
  - [ ] Verify action key priority system in player.gd
  - [ ] Test interaction between nearby_shelter and tent areas
  - [ ] Add clearer visual feedback when tent is enterable
  - [ ] Consider alternative entry method (automatic vs manual)

### Input System
- [ ] Set up Input Map in Project Settings for multiplayer
  - [ ] Add `p2_left`, `p2_right`, `p2_up`, `p2_down` for Player 2 (Gamepad 1)
  - [ ] Add `p3_left`, `p3_right`, `p3_up`, `p3_down` for Player 3 (Gamepad 2)
  - [ ] Add `p4_left`, `p4_right`, `p4_up`, `p4_down` for Player 4 (Gamepad 3)
  - [ ] Map keyboard controls for Player 1 (WASD/Arrow keys)
  - [ ] Test gamepad detection and input

### Player System
- [ ] Test basic player movement with current script
- [ ] Tune movement parameters (speed, acceleration, friction)
- [ ] Add player visual identification (colors, numbers, etc.)
- [ ] Create player spawning system for multiple players
- [ ] Add player interaction/action button functionality

## 🎮 Core Gameplay Features

### Camera System
- [ ] Implement fixed isometric camera
- [ ] Set up camera positioning and angle
- [ ] Add camera follow logic (center on action/settlement)
- [ ] Test camera with multiple players moving

### Resource System
- [ ] Design resource types (Wood, Stone, Food, Gold, etc.)
- [ ] Create resource nodes (trees, quarries, etc.)
- [ ] Implement resource gathering mechanics
- [ ] Add player inventory system
- [ ] Create resource sharing/competition mechanics

### Building System
- [ ] Design building types and categories
- [ ] Create building placement system
- [ ] Implement construction requirements
- [ ] Add building preview/ghost system
- [ ] Create building collision and validation

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
- [ ] Implement day/night cycle
- [ ] Add weather system
- [ ] Create hunger/health mechanics
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
- [ ] Update Game Design Document based on implementation
- [ ] Create technical architecture documentation
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
- ✅ Player movement system implemented (needs input mapping)
- ✅ Game Design Document written
- ✅ Development environment set up

### Next Priority
Focus on getting the input mapping working and testing basic multiplayer movement before moving to camera and resource systems.

### Important Reminders
- Test frequently with actual controllers
- Keep multiplayer experience in mind for all features
- Maintain 60 FPS target throughout development
- Regular playtesting with target audience

---

*Last Updated: [Date will be updated as items are completed]*
