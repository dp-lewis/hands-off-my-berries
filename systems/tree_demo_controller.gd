extends Node3D

# Simple script to test tree spawner regeneration
# Press R to regenerate trees, T to add a clearing at camera position

@onready var tree_spawner = $TreeSpawner
@onready var camera = $Camera3D

func _ready():
	print("Tree Spawner Demo loaded!")
	print("Press R to regenerate trees")
	print("Press N to regenerate with new noise seed")
	print("Press T to add clearing at camera position")
	print("Press C to clear all additional clearings")
	print("Press 1-5 to adjust noise threshold")
	print("Press Q/A to adjust noise scale")
	print("Press W/S to adjust cluster density")
	print("Press V to toggle noise visualization")
	print("Press G to toggle tree variety mode")
	print("Press I to show tree type statistics")

func _input(event):
	if event.is_action_pressed("ui_cancel"):  # Escape key
		get_tree().quit()
	
	if event.is_action_pressed("ui_accept"):  # Enter key
		if tree_spawner:
			tree_spawner.regenerate_trees()
			print("Trees regenerated!")
	
	# Handle key presses
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_R:
				if tree_spawner:
					tree_spawner.regenerate_trees()
					print("Trees regenerated!")
			
			KEY_N:
				if tree_spawner:
					tree_spawner.regenerate_with_new_seed()
					print("Trees regenerated with new seed: ", tree_spawner.noise_seed)
			
			KEY_T:
				if tree_spawner and camera:
					var cam_pos = camera.global_position
					cam_pos.y = 0  # Project to ground level
					tree_spawner.add_clearing(cam_pos, 10.0)
					tree_spawner.regenerate_trees()
					print("Added clearing at: ", cam_pos)
			
			KEY_C:
				if tree_spawner:
					tree_spawner.additional_clearings.clear()
					tree_spawner.regenerate_trees()
					print("Cleared all additional clearings!")
			
			# Noise threshold adjustment (1-5 keys)
			KEY_1:
				adjust_noise_threshold(0.1)
			KEY_2:
				adjust_noise_threshold(0.3)
			KEY_3:
				adjust_noise_threshold(0.5)
			KEY_4:
				adjust_noise_threshold(0.7)
			KEY_5:
				adjust_noise_threshold(0.9)
			
			# Noise scale adjustment
			KEY_Q:
				adjust_noise_scale(-0.01)
			KEY_A:
				adjust_noise_scale(0.01)
			
			# Cluster density adjustment
			KEY_W:
				adjust_cluster_density(0.1)
			KEY_S:
				adjust_cluster_density(-0.1)
			
			# Tree variety controls
			KEY_G:
				toggle_tree_variety()
			KEY_I:
				show_tree_stats()

func adjust_noise_threshold(new_threshold: float):
	if tree_spawner:
		tree_spawner.noise_threshold = new_threshold
		tree_spawner.regenerate_trees()
		print("Noise threshold set to: ", new_threshold)

func adjust_noise_scale(delta: float):
	if tree_spawner:
		tree_spawner.noise_scale = max(0.01, tree_spawner.noise_scale + delta)
		tree_spawner.setup_noise()
		tree_spawner.regenerate_trees()
		print("Noise scale set to: ", tree_spawner.noise_scale)

func adjust_cluster_density(delta: float):
	if tree_spawner:
		tree_spawner.cluster_density = clamp(tree_spawner.cluster_density + delta, 0.1, 1.0)
		tree_spawner.regenerate_trees()
		print("Cluster density set to: ", tree_spawner.cluster_density)

func toggle_tree_variety():
	if tree_spawner:
		tree_spawner.use_tree_variety = !tree_spawner.use_tree_variety
		tree_spawner.regenerate_trees()
		print("Tree variety: ", "ON" if tree_spawner.use_tree_variety else "OFF")
		if tree_spawner.use_tree_variety:
			show_tree_stats()

func show_tree_stats():
	if tree_spawner:
		var stats = tree_spawner.get_tree_type_stats()
		if stats.is_empty():
			print("Tree variety disabled or no tree types configured")
		else:
			print("Tree type distribution:")
			for tree_name in stats:
				var data = stats[tree_name]
				print("  ", tree_name, ": ", data.weight, " weight (", "%.1f" % data.percentage, "%)")

# Setup example tree variety (you can add different tree scenes here later)
func setup_example_tree_variety():
	if tree_spawner and tree_spawner.tree_scene:
		# For now, just use the same tree with different weights as an example
		tree_spawner.tree_scenes = [tree_spawner.tree_scene]
		tree_spawner.tree_weights = [1.0]
		tree_spawner.setup_tree_weights()
		print("Example tree variety setup complete")
