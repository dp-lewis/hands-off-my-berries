# Tree Spawner System Plan - Noise-Based### 4. **Runtime Features**
- **Auto-detection**: Finds player spawn points automatically
- **Random Rotation**: Trees spawn with random Y-axis rotation for variety
- **Runtime Regeneration**: Ability to regenerate trees during gameplay
- **Dynamic Clearing Addition**: Add new clearings at runtime
- **Tree Type Selection**: Weighted random selection of tree types
- **Statistics**: Get distribution statistics for tree typestering

## Overview
The tree spawner system uses Perlin noise to create natural tree clusters across the game world while ensuring proper clearings around important locations like player spawn points, water sources, and other key areas. This creates realistic forest patterns with dense clusters and natural clearings.

## Features

### 1. **Noise-Based Clustering**
- **Perlin Noise**: Uses FastNoiseLite to generate natural clustering patterns
- **Configurable Thresholds**: Control where trees spawn based on noise values
- **Natural Variation**: Creates organic forest layouts with clusters and clearings
- **Cluster Density**: Fine-tune how dense trees are within valid noise areas

### 2. **Smart Positioning**
- **Player Spawn Clearings**: Automatically detects player positions and creates clearings around them
- **Custom Clearings**: Support for additional clearings at specific locations (water sources, building areas, etc.)
- **Minimum Distance**: Ensures trees don't spawn too close to each other
- **Area Boundaries**: Respects defined spawn area boundaries

### 3. **Configurable Parameters**
- `tree_count`: Number of trees to spawn (default: 50)
- `area_size`: Size of the spawn area (default: 150x150)
- `min_distance`: Minimum distance between trees (default: 3.0)
- `player_clearing_radius`: Clearing radius around players (default: 10.0)
- `additional_clearings`: Array of Vector3 positions for custom clearings
- `clearing_radius`: Radius for additional clearings (default: 8.0)

#### Tree Variety Parameters
- `tree_scene`: Single tree scene (legacy/fallback support)
- `tree_scenes`: Array of different tree scene types
- `tree_weights`: Probability weights for each tree type
- `use_tree_variety`: Enable multiple tree types (default: false)

#### Noise Clustering Parameters
- `use_noise_clustering`: Enable/disable noise-based clustering (default: true)
- `noise_scale`: Scale of noise pattern - lower = bigger clusters (default: 0.05)
- `noise_threshold`: Threshold for tree placement - higher = fewer trees (0.0-1.0, default: 0.3)
- `cluster_density`: Chance to place tree in valid noise area (0.0-1.0, default: 0.7)
- `noise_seed`: Seed for reproducible patterns (default: 12345)

### 3. **Runtime Features**
- **Auto-detection**: Finds player spawn points automatically
- **Random Rotation**: Trees spawn with random Y-axis rotation for variety
- **Runtime Regeneration**: Ability to regenerate trees during gameplay
- **Dynamic Clearing Addition**: Add new clearings at runtime

## Implementation

### Core Files
1. **`systems/tree_spawner.gd`** - Main spawner script
2. **`levels/tree_spawner_demo.tscn`** - Demo scene for testing
3. **`systems/tree_demo_controller.gd`** - Demo controls for testing

### Integration in Level
```gdscript
[node name="TreeSpawner" type="Node3D" parent="."]
script = ExtResource("tree_spawner_script")
tree_scene = ExtResource("tree_scene")
area_size = Vector2(140, 140)
tree_count = 60
min_distance = 4.0
player_clearing_radius = 12.0
additional_clearings = Array[Vector3]([Vector3(-8, 0, 3), Vector3(21.5, 0, -16)])
clearing_radius = 8.0
```

## How It Works

### 1. **Initialization**
- Sets up Perlin noise generator with specified parameters
- Waits for scene to load completely
- Finds all player nodes (either by "players" group or "Player" name pattern)
- Records player positions as spawn points requiring clearings

### 2. **Noise-Based Tree Placement Algorithm**
For each tree position attempt:
1. Generate random X,Z coordinates within area bounds
2. **Noise Check**: Sample Perlin noise at position and convert to 0-1 range
3. **Threshold Check**: Skip if noise value < noise_threshold (creates natural clearings)
4. **Density Check**: Even in valid noise areas, use cluster_density for variation
5. Check distance from all player spawn points
6. Check distance from all additional clearings
7. Check distance from already placed trees
8. **Tree Type Selection**: Use weighted random selection if tree variety enabled
9. If all checks pass, place the tree with random rotation

### 3. **Validation Rules**
- **Noise Threshold**: `noise_value < noise_threshold` = INVALID (creates natural clearings)
- **Cluster Density**: `random() > cluster_density` = INVALID (adds variation within clusters)
- **Player Clearings**: `distance_to_player < player_clearing_radius` = INVALID
- **Custom Clearings**: `distance_to_clearing < clearing_radius` = INVALID  
- **Tree Spacing**: `distance_to_other_tree < min_distance` = INVALID

## Demo Scene Controls

### Testing the Demo (`tree_spawner_demo.tscn`)
- **Enter** or **R**: Regenerate trees with current settings
- **N**: Regenerate with new random noise seed
- **T**: Add clearing at camera position
- **C**: Clear all additional clearings
- **V**: Toggle noise visualization (shows noise pattern as colored spheres)
- **G**: Toggle tree variety on/off
- **I**: Show tree type statistics

#### Noise Parameter Controls
- **1-5 Keys**: Set noise threshold (0.1, 0.3, 0.5, 0.7, 0.9)
- **Q/A Keys**: Decrease/Increase noise scale (bigger/smaller clusters)
- **W/S Keys**: Increase/Decrease cluster density
- **Escape**: Quit demo

### Noise Visualization
Press **V** in the demo to see the noise pattern as colored spheres. Brighter spheres indicate higher noise values where trees are more likely to spawn.

## Usage Examples

### Basic Setup
```gdscript
# In your level scene
var tree_spawner = TreeSpawner.new()
tree_spawner.tree_scene = preload("res://models/tree.tscn")
tree_spawner.tree_count = 50
tree_spawner.area_size = Vector2(100, 100)
add_child(tree_spawner)
```

### Adding Clearings at Runtime
```gdscript
# Add a clearing around a water source
tree_spawner.add_clearing(water_position, 8.0)
tree_spawner.regenerate_trees()
```

### Custom Configuration
```gdscript
# Dense forest with small clearings
tree_spawner.tree_count = 100
tree_spawner.min_distance = 2.0
tree_spawner.player_clearing_radius = 15.0
```

## Benefits

1. **Procedural Generation**: Creates unique layouts each time
2. **Gameplay Balance**: Ensures players have space to move and build
3. **Performance Friendly**: Efficient placement algorithm with early termination
4. **Flexible**: Easy to configure for different gameplay needs
5. **Runtime Control**: Can regenerate or modify during gameplay

## Integration with Existing Level
The tree spawner has been integrated into `level-test.tscn` with:
- Clearings around both player spawn points (0,0,0) and (14,0,0)
- Additional clearings around water sources
- 60 trees with 4.0 minimum spacing
- 12.0 radius clearings around players

This replaces the manual tree placement and provides dynamic, balanced tree distribution that ensures good gameplay flow while maintaining visual variety.
