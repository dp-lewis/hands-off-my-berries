# Simple Day/Night Cycle Setup

## Quick Setup (2 minutes)

### Step 1: Add Game Manager to Your Scene
1. Open your main game scene (level-test.tscn)
2. Add a new **Node** 
3. Attach the script: `res://systems/simple_game_manager.gd`
4. Name it "GameManager"

### Step 2: Optional - Add a Directional Light
If you don't have one already:
1. Add **DirectionalLight3D** to your scene
2. Name it "Sun"
3. Set rotation to: X = -45°, Y = -45°, Z = 0°

That's it! The system will automatically:
- Find the light and adjust brightness
- Find all players in the "players" group
- Start the day/night cycle

## How It Works

### ☀️ Day Time (60 seconds)
- Light energy = 1.0 (full brightness)
- Players are safe
- Players heal slowly when in shelter (5 health/second)

### 🌙 Night Time (30 seconds)  
- Light energy = 0.2 (dim lighting)
- Players take damage when exposed (10 health/second)
- Shelter protects from damage and provides healing

### 🏠 Tents = Survival
- Complete protection from night damage
- Healing when inside (day or night)
- Makes tent building strategically important

## Customization

You can adjust timing in the `simple_day_night.gd` script:
- `day_duration`: How long day lasts (default: 60 seconds)
- `night_duration`: How long night lasts (default: 30 seconds)
- `day_brightness`: Light energy during day (default: 1.0)
- `night_brightness`: Light energy during night (default: 0.2)

## Debug Controls
- **Ctrl + Enter**: Toggle between day and night instantly

## Future Torch System
The lighting system is designed so torches can be added later as additional light sources that work alongside the main day/night cycle. Each torch would be its own light that helps brighten dark areas during night time.

## Console Messages
Watch for these messages:
- "🌅 Day begins!" 
- "🌙 Night falls!"
- "Player X feels safer in daylight"
- "Player X is exposed to night dangers!"
- Health warnings when players are dying
