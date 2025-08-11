extends Node
class_name SimpleFogDemo

## Demo controller for Simple Fog of War

var fog_of_war: Control

func _ready():
	print("Simple Fog of War Demo loaded!")
	print("Press F to toggle fog of war on/off")
	print("Press C to clear all fog")
	print("Press R to reset fog (make everything black)")
	print("Press + to increase reveal radius")
	print("Press - to decrease reveal radius")
	
	# Find the fog of war system
	var ui_layer = get_tree().current_scene.find_child("UI", true, false)
	if ui_layer:
		fog_of_war = ui_layer.find_child("SimpleFogOfWar", true, false)
	
	if fog_of_war:
		print("Found fog of war system: ", fog_of_war.name)
	else:
		print("Warning: Could not find fog of war system!")

func _input(event):
	if not event.is_pressed():
		return
	
	if not fog_of_war:
		return
	
	# Only handle keyboard events
	if not event is InputEventKey:
		return
	
	match event.keycode:
		KEY_F:
			# Toggle fog visibility
			fog_of_war.visible = !fog_of_war.visible
			print("Fog of war toggled: ", "ON" if fog_of_war.visible else "OFF")
			# Make fog very obvious when toggled on
			if fog_of_war.visible and fog_of_war.color_rect:
				fog_of_war.color_rect.color = Color.BLACK
				fog_of_war.color_rect.modulate.a = 0.9
				print("Made fog very visible (90% black)")
		
		KEY_C:
			# Clear all fog (make transparent)
			if fog_of_war.color_rect:
				fog_of_war.color_rect.modulate.a = 0.0
			print("Fog cleared (made transparent)!")
		
		KEY_R:
			# Reset fog (make solid black)
			if fog_of_war.color_rect:
				fog_of_war.color_rect.modulate.a = 1.0
				fog_of_war.color_rect.color = Color.BLACK
			print("Fog reset (solid black)!")
		
		KEY_PLUS, KEY_EQUAL:
			# Increase reveal radius
			fog_of_war.reveal_radius += 10.0
			fog_of_war.reveal_radius = min(fog_of_war.reveal_radius, 200.0)
			print("Reveal radius: ", fog_of_war.reveal_radius)
		
		KEY_MINUS:
			# Decrease reveal radius
			fog_of_war.reveal_radius -= 10.0
			fog_of_war.reveal_radius = max(fog_of_war.reveal_radius, 20.0)
			print("Reveal radius: ", fog_of_war.reveal_radius)
