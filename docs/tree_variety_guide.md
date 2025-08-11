# Tree Variety Setup Example

This document shows how to configure the tree spawner to use multiple tree types for natural forest diversity.

## Basic Setup

### 1. Enable Tree Variety
```gdscript
# In your scene or through the inspector
tree_spawner.use_tree_variety = true
```

### 2. Configure Tree Types
```gdscript
# Add multiple tree scenes with weights
tree_spawner.tree_scenes = [
    preload("res://models/trees/oak_tree.tscn"),      # Common tree
    preload("res://models/trees/pine_tree.tscn"),     # Less common
    preload("res://models/trees/birch_tree.tscn"),    # Rare tree
    preload("res://models/trees/dead_tree.tscn")      # Very rare
]

tree_spawner.tree_weights = [
    5.0,  # Oak: 50% of trees (5/10 total weight)
    3.0,  # Pine: 30% of trees 
    1.5,  # Birch: 15% of trees
    0.5   # Dead: 5% of trees
]
```

### 3. Scene Configuration (.tscn file)
```
[node name="TreeSpawner" type="Node3D" parent="."]
script = ExtResource("tree_spawner_script")
tree_scene = ExtResource("fallback_tree")  # Fallback if variety disabled
tree_scenes = Array[PackedScene]([
    ExtResource("oak_tree"),
    ExtResource("pine_tree"), 
    ExtResource("birch_tree"),
    ExtResource("dead_tree")
])
tree_weights = Array[float]([5.0, 3.0, 1.5, 0.5])
use_tree_variety = true
```

## Tree Weight System

### How Weights Work
- **Higher weight = more common**: A weight of 5.0 is 10x more common than 0.5
- **Relative weights**: Only the ratio matters, not absolute values
- **Automatic normalization**: Weights are converted to percentages internally

### Example Weight Configurations

#### Balanced Forest (Equal distribution)
```gdscript
tree_weights = [1.0, 1.0, 1.0, 1.0]  # 25% each
```

#### Realistic Forest (Dominant species)
```gdscript
tree_weights = [10.0, 3.0, 1.0, 0.5]  # Oak dominant, dead trees rare
```

#### Diverse Forest (Many species)
```gdscript
tree_weights = [2.0, 2.0, 2.0, 1.0, 1.0, 0.5]  # Many types, some rare
```

## Runtime Management

### Add Tree Types Dynamically
```gdscript
# Add a new rare tree type
var rare_tree = preload("res://models/trees/magical_tree.tscn")
tree_spawner.add_tree_type(rare_tree, 0.1)  # Very rare (0.1 weight)
```

### Modify Existing Weights
```gdscript
# Make pine trees more common (index 1)
tree_spawner.set_tree_weight(1, 5.0)
```

### Get Statistics
```gdscript
var stats = tree_spawner.get_tree_type_stats()
for tree_name in stats:
    print(tree_name, ": ", stats[tree_name].percentage, "%")
```

## Best Practices

### 1. Tree Scene Requirements
- All tree scenes should have similar collision setups
- Use consistent scaling and positioning
- Ensure proper tree.gd scripts if using interaction systems

### 2. Weight Guidelines
- Use weights between 0.1 (very rare) and 10.0 (very common)
- Consider real forest compositions for realism
- Test with different seeds to ensure good distribution

### 3. Performance Considerations
- More tree types = slightly more memory usage
- Weight calculation is done once at startup
- Random selection is very fast during spawning

### 4. Visual Balance
- Mix large and small trees for visual interest
- Use seasonal variations (green/autumn/dead)
- Consider biome-appropriate species

## Integration with Noise Clustering

Tree variety works seamlessly with noise clustering:
- Different tree types can appear in any cluster
- All trees follow the same noise pattern rules
- Weights apply uniformly across all forest areas

## Fallback Behavior

If tree variety is disabled or no tree_scenes are configured:
- System falls back to single `tree_scene`
- No errors or crashes
- Smooth transition between modes

## Demo Controls

In the tree spawner demo scene:
- **G**: Toggle tree variety on/off
- **I**: Show current tree type statistics
- All other controls work the same with variety enabled
