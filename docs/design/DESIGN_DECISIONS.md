# Metropolis - Design Decisions Document

## 📋 Overview
This document outlines the key design decisions made during the development of Metropolis, providing context and rationale for implementation choices.

---

## 🎮 Core Game Systems

### Survival Mechanics
**Decision: Implemented comprehensive survival stats (Health, Hunger, Tiredness)**
- **Rationale**: Creates meaningful gameplay pressure and resource management challenges
- **Implementation**: Three interconnected meters that decrease over time and affect each other
- **Key Values**:
  - Hunger decrease: 2.0 per minute (increased from 0.5 for faster gameplay)
  - Tiredness decrease: 3.0 base per minute + 0.3 per second while moving
  - Night tiredness penalty: Additional 2.0 per minute when exposed at night
  - Auto-eat threshold: 30% hunger triggers automatic food consumption

**Decision: Tiredness penalty during nighttime exposure**
- **Rationale**: Reinforces the importance of shelter and creates day/night gameplay rhythm
- **Implementation**: Players lose extra tiredness at night when not in tent shelter
- **Impact**: Forces strategic planning around shelter construction and nighttime safety

### Day/Night Cycle
**Decision: 60-second day + 30-second night cycles**
- **Rationale**: Short enough to maintain engagement, long enough for meaningful activities
- **Implementation**: Fixed timing with lighting changes and survival pressure
- **Features**:
  - Visual day counter displayed prominently at bottom-center of screen
  - Console logging for day transitions with emoji feedback
  - Night adds survival pressure through increased tiredness loss

### Resource Management
**Decision: Separate inventories for different resource types**
- **Rationale**: Prevents single resource from dominating strategy
- **Implementation**:
  - Wood inventory: 10 items maximum
  - Food inventory: 5 items maximum
  - Prevents inventory overflow and encourages consumption/usage

**Decision: Auto-consumption system for food**
- **Rationale**: Reduces micromanagement while maintaining resource pressure
- **Implementation**: Automatically eats food when hunger drops below 30%
- **Impact**: Players can focus on gathering rather than manual eating

### Building System
**Decision: Ghost preview system for tent placement**
- **Rationale**: Provides clear visual feedback before committing resources
- **Implementation**: Semi-transparent tent preview follows player in build mode
- **Features**:
  - Tab key toggles build mode for keyboard player
  - Requires 8 wood to enter build mode
  - Ghost is non-interactive and purely visual

**Decision: Tent construction is progress-based**
- **Rationale**: Makes building feel substantial and provides visual feedback
- **Implementation**: Players must hold action key to build over time
- **Benefits**: Creates collaborative building opportunities

### Shelter System
**Decision: Tents provide multiple benefits**
- **Rationale**: Makes shelter construction rewarding beyond basic protection
- **Implementation**:
  - Tiredness recovery: 10.0 per minute (offsets all penalties)
  - Safety from night dangers
  - Clear shelter status feedback in UI

---

## 🎨 User Interface Design

### UI Philosophy
**Decision: "Keep it super basic" approach**
- **Rationale**: User specifically requested simple, minimal UI design
- **Implementation**: Text-based displays with essential information only
- **Benefits**: Clean, readable interface that doesn't overwhelm

### Player UI Layout
**Decision: Individual player stats in top-left corner**
- **Rationale**: Personal information should be easily accessible to each player
- **Implementation**: Simple text display with color coding for each player
- **Contents**: Health, Hunger, Tiredness, Wood, Food inventories

### Global UI Elements
**Decision: Prominent day counter at bottom-center**
- **Rationale**: Day progression affects all players equally and needed high visibility
- **Implementation**: Large 32px font, center-anchored positioning
- **Features**: Real-time updates, clear "Day X" format

### UI Creation Strategy
**Decision: Deferred UI creation using call_deferred()**
- **Rationale**: Prevents "parent node is busy" errors during scene initialization
- **Implementation**: All UI elements created with deferred calls
- **Benefits**: Reliable UI creation without timing conflicts

---

## 🏗️ Technical Architecture

### Node Organization
**Decision: Group-based node finding system**
- **Rationale**: Enables loose coupling between game systems
- **Implementation**: Players join "players" group, day/night system accessible via groups
- **Benefits**: Systems can find each other without direct references

### Script Structure
**Decision: Single comprehensive player script**
- **Rationale**: Keeps all player functionality centralized and manageable
- **Implementation**: player.gd contains movement, survival, building, interaction systems
- **Benefits**: Easier debugging and modification of player behavior

### Interaction System
**Decision: Area-based proximity detection**
- **Rationale**: Simple and reliable way to handle object interactions
- **Implementation**: Objects detect player entry/exit and register themselves
- **Features**: Multiple interaction types (trees, pumpkins, tents, shelters)

### Animation System
**Decision: Flexible animation mapping**
- **Rationale**: Accommodates different character models with varying animation names
- **Implementation**: Maps logical states (walk, idle, gather) to potential animation names
- **Benefits**: Works with different character assets without hardcoded names

---

## 🎯 Gameplay Balance

### Resource Gathering
**Decision: Different gathering costs for different activities**
- **Rationale**: Makes different activities feel distinct and encourages variety
- **Implementation**:
  - Tree chopping: 5.0 tiredness cost
  - Pumpkin gathering: 2.0 tiredness cost
  - Building: 3.0 tiredness cost per action
- **Impact**: Players must balance resource gathering with rest needs

### Food System
**Decision: Pumpkins restore 25% hunger**
- **Rationale**: Makes individual food items meaningful without being overpowered
- **Implementation**: Each pumpkin restores 25 out of 100 hunger points
- **Balance**: Requires multiple food items to fully satisfy hunger

### Recovery Mechanics
**Decision: Tent recovery significantly outpaces all penalties**
- **Rationale**: Shelter should feel genuinely safe and restorative
- **Implementation**: 10.0 tiredness recovery per minute vs. maximum 5.0 loss per minute
- **Impact**: Night in shelter is genuinely restful and strategic

---

## 🔧 Configuration Philosophy

### Exposed Variables
**Decision: Export all balance parameters**
- **Rationale**: Enables easy tweaking without code changes
- **Implementation**: @export variables for all rates, costs, and thresholds
- **Benefits**: Rapid iteration and playtesting of different balance values

### Rate Conversions
**Decision: Rates specified per-minute, converted to per-second internally**
- **Rationale**: More intuitive for designers to think in minutes
- **Implementation**: Division by 60.0 for per-second rates
- **Benefits**: Human-readable configuration values

---

## 🚀 Performance Considerations

### Update Frequency
**Decision: Survival systems update every frame**
- **Rationale**: Smooth progression and immediate feedback
- **Implementation**: Delta-time based calculations in _physics_process
- **Optimization**: Logging throttled to prevent console spam

### UI Updates
**Decision: Real-time UI updates with smart refresh**
- **Rationale**: Players need immediate feedback on stat changes
- **Implementation**: UI polls player stats continuously
- **Optimization**: Could be optimized with signal-based updates if needed

---

## 📈 Evolution and Iteration

### Progressive Enhancement
**Decision: Start simple, add complexity gradually**
- **Rationale**: Ensures core systems work before adding features
- **Implementation**: Basic survival → UI → day/night → advanced mechanics
- **Benefits**: Stable foundation for additional features

### User Feedback Integration
**Decision: Responsive to user preferences**
- **Examples**:
  - Simplified UI based on "keep it super basic" request
  - Faster hunger/tiredness rates for more engaging gameplay
  - Prominent day counter positioning for better visibility
- **Benefits**: User-driven design ensures good player experience

---

## 🎮 Player Experience Goals

### Survival Pressure
**Goal: Create meaningful but not overwhelming survival pressure**
- **Achievement**: Balanced rates that require attention but allow exploration
- **Feedback**: Players must actively manage resources but aren't constantly struggling

### Shelter Importance
**Goal: Make shelter construction feel essential, not optional**
- **Achievement**: Night penalties make shelter genuinely valuable
- **Result**: Natural gameplay rhythm of day (gather) / night (shelter)

### Visual Clarity
**Goal: Players always understand their current state**
- **Achievement**: Clear UI, prominent day counter, descriptive console messages
- **Result**: No confusion about survival status or game progression

---

*This document will be updated as new design decisions are made during development.*

*Last Updated: August 9, 2025*
