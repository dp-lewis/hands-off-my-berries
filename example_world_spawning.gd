func spawn_bucket_in_world(position: Vector3):
	"""Spawn a bucket item in the world for players to pick up"""
	# Create a pickup node
	var pickup = Node3D.new()
	pickup.name = "BucketPickup"
	pickup.position = position
	
	# Add visual representation (could be a 3D model)
	var mesh_instance = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(0.5, 0.3, 0.5)  # Small bucket-like shape
	mesh_instance.mesh = box_mesh
	pickup.add_child(mesh_instance)
	
	# Add pickup interaction
	pickup.set_script(preload("res://example_item_pickup.gd"))
	pickup.item_id = "bucket"
	pickup.item_state = "empty"
	
	get_tree().current_scene.add_child(pickup)
	print("Spawned bucket pickup at ", position)

# Example pickup script (save as example_item_pickup.gd):
# extends Node3D
# var item_id: String = ""
# var item_state: String = ""
# 
# func _on_area_3d_body_entered(body):
#     if body.has_method("get_component"):
#         var inventory = body.get_component("inventory")
#         if inventory:
#             ItemRegistry.give_item_to_player(body, item_id, 1, item_state)
#             queue_free()  # Remove pickup from world
