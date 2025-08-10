# Tiredness-Accelerated Hunger and Thirst System

## Overview
Enhanced the survival system so that when players become tired, their hunger and thirst deplete faster. This creates a realistic feedback loop where exhaustion leads to increased metabolic demands.

## Mechanic Details

### Tiredness Acceleration Formula
The system uses an inverse relationship between tiredness and consumption rates:

- **100% Tiredness (Well-rested)**: 1.0x multiplier (normal consumption rate)
- **50% Tiredness (Getting tired)**: 1.5x multiplier (50% faster consumption)  
- **0% Tiredness (Exhausted)**: 2.0x multiplier (double consumption rate)

### Implementation
**Formula:** `acceleration_multiplier = 1.0 + (1.0 - tiredness_percentage)`

This creates a smooth scaling where:
- Fresh players consume resources normally
- Tired players need more food and water to maintain their energy
- Exhausted players burn through resources rapidly

### Affected Systems
- **Hunger System**: Base hunger decrease rate multiplied by tiredness acceleration
- **Thirst System**: Base thirst decrease rate multiplied by tiredness acceleration
- **Logging**: Shows current acceleration rate when significant (>110%)

### Gameplay Impact

**Strategic Depth:**
- Players must balance activity with rest to maintain efficient resource usage
- Overworking leads to resource waste through accelerated consumption
- Rest becomes a strategic resource management tool

**Realistic Simulation:**
- Tired bodies require more energy and hydration
- Creates natural pressure to seek shelter and rest
- Reinforces the importance of the tiredness meter

**Resource Management:**
- Well-rested players are more resource-efficient
- Tired players face resource pressure, encouraging rest
- Creates meaningful trade-offs between activity and efficiency

### Example Scenarios

**Well-Rested Player (90% tiredness):**
- Acceleration: 1.1x (10% faster consumption)
- Can work efficiently with minimal resource penalty

**Moderately Tired Player (40% tiredness):**
- Acceleration: 1.6x (60% faster consumption) 
- Noticeable resource drain, should consider resting soon

**Exhausted Player (5% tiredness):**
- Acceleration: 1.95x (nearly double consumption)
- Rapid resource depletion, urgent need for rest

### Visual Feedback
The logging system now shows acceleration when significant:
```
Player 1 - Hunger: 45/100 Food: 3 (Tired: 160% rate)
Player 1 - Thirst: 32/100 (Tired: 160% rate)
```

This helps players understand when tiredness is affecting their resource consumption.

## Technical Implementation

### Modified Functions
- `handle_hunger_system()` - Now calculates and applies tiredness acceleration
- `handle_thirst_system()` - Now calculates and applies tiredness acceleration
- `calculate_tiredness_acceleration()` - New helper function for acceleration calculation

### Code Structure
```gdscript
# Calculate dynamic consumption rate
var base_rate = hunger_decrease_rate / 60.0
var tiredness_multiplier = calculate_tiredness_acceleration()
var actual_rate = base_rate * tiredness_multiplier

# Apply accelerated consumption
hunger -= actual_rate * delta
```

## Balancing Considerations

**Current Balance:**
- Maximum 2x acceleration prevents extreme resource drain
- Smooth scaling avoids sudden consumption spikes
- Affects both hunger and thirst equally

**Future Tuning Options:**
- Adjust maximum multiplier (currently 2.0x)
- Create different curves for hunger vs thirst
- Add exhaustion threshold for extreme acceleration
- Consider movement-based acceleration modifiers

This mechanic adds strategic depth while maintaining realistic survival simulation, encouraging players to balance work and rest for optimal resource efficiency.
