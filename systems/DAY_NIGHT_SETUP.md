# Day/Night Cycle Integration Guide

## Quick Setup Instructions

### 1. Add GameManager to Your Main Scene
1. Open your main game scene (level-test.tscn)
2. Add a new Node and attach the `game_manager.gd` script to it
3. Name it "GameManager"
4. Set the exported properties in the inspector:
   - `Enable Day Night Cycle`: true
   - `Day Duration`: 120.0 (2 minutes)
   - `Night Duration`: 60.0 (1 minute)

### 2. Optional: Add DirectionalLight3D for Better Lighting
1. Add a DirectionalLight3D node to your scene
2. Name it "Sun" 
3. Position it above your world (Y = 10)
4. Rotate it to: X = -45°, Y = -45°, Z = 0°
5. Set energy to 1.0

### 3. Test the System
- Press Ctrl+Enter during gameplay to toggle day/night for testing
- Watch the console for day/night transition messages
- Players will take damage at night when outside shelters
- Players heal when inside tents during night

## How It Works

### Day Time (Default: 2 minutes)
- ☀️ Bright lighting with warm colors
- 🔆 Sun moves across the sky
- 😌 Players are safe and can heal
- 🏃 Normal gameplay activities

### Night Time (Default: 1 minute)  
- 🌙 Dim lighting with cool blue colors
- ⭐ Moon replaces sun
- ⚠️ Players take damage when exposed (5 health/second)
- 🏠 Shelter provides safety and healing
- 📈 Danger level increases over time when exposed

### Shelter Benefits
- 🛡️ Complete protection from night damage
- ❤️ Slowly regenerates health (10 health/second)
- 📉 Reduces accumulated danger level
- 🏕️ Tents are the primary shelter type

## Customization Options

### Timing
- Change `day_duration` and `night_duration` in GameManager
- Shorter cycles = more intense survival pressure
- Longer cycles = more strategic gameplay

### Danger Level
- Modify `damage_rate` in `handle_night_survival()` 
- Change how fast danger accumulates
- Adjust healing rates in shelters

### Visual Effects
- Customize `day_color` and `night_color` in DayNightCycle
- Adjust `transition_speed` for smoother/faster changes
- Add particle effects during transitions

## Future Enhancements

### Possible Additions
- 🌅 Dawn/Dusk transition periods with special mechanics
- 🌡️ Temperature system affected by time of day
- 👹 Monsters that spawn at night
- 🔥 Campfires as temporary shelter
- 🌙 Moon phases affecting night intensity
- 📊 UI showing current time and danger level

### Advanced Features  
- ☀️ Seasonal changes (longer/shorter days)
- 🌤️ Weather system integration
- 🎯 Time-based objectives and events
- 💤 Sleep system to skip night
- 🔋 Stamina affected by time of day

## Debug Commands
- `Ctrl+Enter`: Toggle between day and night
- Check console for timing and event messages
- Monitor player health during night exposure
