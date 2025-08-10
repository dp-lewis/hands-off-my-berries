extends Node3D

@export var wood_cost: int = 8  # Cost to build the tent
@export var build_time: float = 5.0  # Time to construct (increased for background building)
@export var start_built: bool = false  # For testing - start as built tent

var current_builder: Node = null
var build_progress: float = 0.0
var is_being_built: bool = false
var is_built: bool = false
var is_night_time: bool = false

# Shelter functionality
var players_inside: Array[Node] = []
var progress_bar: Node3D

@onready var build_area: Area3D
@onready var shelter_area: Area3D
@onready var tent_mesh: Node3D
@export var tent_light:Light3D = null  # Reference to the tent light

func _ready():
	# Add to tents group for game manager to find
	add_to_group("tents")
	
	# Find the tent mesh
	tent_mesh = get_child(0)  # The tmpParent from GLB
	
	if tent_light:
		print("Tent light found: ", tent_light.name)
		tent_light.visible = false  # Start with light off
	
	# Set up areas
	setup_areas()
	
	# Initialize tent state
	if start_built:
		# Start as built tent for testing
		is_built = true
		show_as_built()
		print("Tent started as built (testing mode)")
	else:
		# Start as blueprint (semi-transparent)
		show_as_blueprint()
		print("Tent started as blueprint (needs building)")

func setup_areas():
	# Find existing areas or create them
	var areas = []
	for child in get_children():
		if child is Area3D:
			areas.append(child)
	
	if areas.size() >= 2:
		# Use existing areas - first for building, second for shelter
		build_area = areas[0]
		shelter_area = areas[1]
	elif areas.size() == 1:
		# One area exists, use it for building, create shelter area
		build_area = areas[0]
		create_shelter_area()
	else:
		# No areas exist, create both
		create_build_area()
		create_shelter_area()
	
	# Connect signals
	build_area.body_entered.connect(_on_build_area_entered)
	build_area.body_exited.connect(_on_build_area_exited)
	
	shelter_area.body_entered.connect(_on_shelter_entered)
	shelter_area.body_exited.connect(_on_shelter_exited)

func create_build_area():
	build_area = Area3D.new()
	build_area.name = "BuildArea"
	add_child(build_area)
	
	var collision_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(4, 2, 4)  # Large interaction area
	collision_shape.shape = box_shape
	build_area.add_child(collision_shape)

func create_shelter_area():
	shelter_area = Area3D.new()
	shelter_area.name = "ShelterArea"
	add_child(shelter_area)
	
	var collision_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(1.5, 1, 1.5)  # Smaller, inside tent
	collision_shape.shape = box_shape
	collision_shape.position = Vector3(0, 0.5, 0)  # Center of tent
	shelter_area.add_child(collision_shape)

func _process(delta):
	if is_being_built:
		# Continue building in background
		build_progress += delta / build_time
		
		# Update visual building progress
		update_building_visuals()
		
		# Check if building is complete
		if build_progress >= 1.0:
			complete_building()

func show_as_blueprint():
	# Blueprint state - just print status, no visual changes
	print("Tent blueprint placed - needs ", wood_cost, " wood to build")

func show_as_built():
	# Built state - just print status, no visual changes
	print("Tent construction complete!")

func update_building_visuals():
	if is_being_built:
		# Update progress bar only
		if progress_bar:
			progress_bar.call("set_progress", build_progress)

func create_building_progress_bar():
	if not progress_bar:
		progress_bar = Node3D.new()
		progress_bar.name = "BuildProgressBar"
		add_child(progress_bar)
		
		# Load and add the progress bar script
		var script = load("res://components/progress_bar_3d.gd")
		progress_bar.set_script(script)
		progress_bar.call("set_target", self)
		progress_bar.call("set_color", Color.BLUE)  # Blue for building

func destroy_building_progress_bar():
	if progress_bar:
		progress_bar.queue_free()
		progress_bar = null

func find_light_component(node: Node) -> Light3D:
	"""Recursively find the first Light3D component in the node tree"""
	if node is Light3D:
		return node
	
	for child in node.get_children():
		var light = find_light_component(child)
		if light:
			return light
	
	return null

func _on_player_entered(body):
	if body.has_method("start_building_tent") and not is_built and not is_being_built:
		body.set_nearby_tent(self)

func _on_player_exited(body):
	if body.has_method("clear_nearby_tent"):
		body.clear_nearby_tent(self)

# Building area functions
func _on_build_area_entered(body):
	var player_id = body.player_id if body.has_method("get_player_id") or "player_id" in body else "unknown"
	print("DEBUG: Tent build area entered by: ", body.name, " (player_id: ", player_id, ")")
	print("DEBUG: Tent state - is_built: ", is_built, ", is_being_built: ", is_being_built)
	if body.has_method("start_building_tent") and not is_built and not is_being_built:
		print("DEBUG: Setting nearby tent for building")
		body.set_nearby_tent(self)
	else:
		print("DEBUG: Not setting nearby tent - conditions not met")

func _on_build_area_exited(body):
	print("DEBUG: Tent build area exited by: ", body.name)
	if body.has_method("clear_nearby_tent"):
		body.clear_nearby_tent(self)

# Shelter area functions
func _on_shelter_entered(body):
	var player_id = body.player_id if body.has_method("get_player_id") or "player_id" in body else "unknown"
	print("DEBUG: Tent shelter area entered by: ", body.name, " (player_id: ", player_id, ")")
	print("DEBUG: Tent state - is_built: ", is_built, ", is_being_built: ", is_being_built)
	print("DEBUG: Tent occupancy - ", players_inside.size(), " players inside")
	
	if is_built and body.has_method("set_nearby_shelter"):
		# Check if tent is already occupied
		if players_inside.size() > 0 and body not in players_inside:
			var occupant = players_inside[0]
			print("DEBUG: Tent occupied by Player ", occupant.player_id, " - not setting nearby shelter")
			# Don't set nearby shelter if tent is occupied by someone else
			return
		
		print("DEBUG: Setting nearby shelter for player")
		body.set_nearby_shelter(self)
		print("Player ", body.player_id, " can now enter tent shelter")
	else:
		print("DEBUG: Not setting nearby shelter - tent not built or player lacks method")

func _on_shelter_exited(body):
	print("DEBUG: Tent shelter area exited by: ", body.name)
	if body.has_method("clear_nearby_shelter"):
		body.clear_nearby_shelter(self)
		print("Player ", body.player_id, " left tent shelter area")
		
		# If player was sheltered, remove them from shelter
		if body in players_inside:
			players_inside.erase(body)
			update_tent_light()  # Update light when player exits
			if body.has_method("exit_tent_shelter"):
				body.exit_tent_shelter(self)

func shelter_player(player: Node) -> bool:
	if not is_built:
		print("Tent is not built yet!")
		return false
	
	if player in players_inside:
		print("Player ", player.player_id, " is already in this tent!")
		return false
	
	# Check if tent is already occupied (limit to 1 player per tent)
	if players_inside.size() > 0:
		var occupant = players_inside[0]
		print("Tent is occupied by Player ", occupant.player_id, "! Player ", player.player_id, " cannot enter.")
		return false
	
	players_inside.append(player)
	update_tent_light()  # Update light when player enters
	print("Player ", player.player_id, " manually entered tent shelter")
	return true

func start_building(player: Node) -> bool:
	if is_built:
		print("Tent already built!")
		return false
		
	if is_being_built:
		print("Tent already being built!")
		return false
	
	# Check if player has enough wood using ResourceManager
	var resource_manager = player.get_node("ResourceManager")
	if not resource_manager:
		print("Error: Player has no ResourceManager component!")
		return false
	
	var current_wood = resource_manager.get_resource_amount("wood")
	if current_wood < wood_cost:
		print("Need ", wood_cost, " wood to build tent (have ", current_wood, ")")
		return false
	
	# Deduct wood and start building
	if not resource_manager.remove_resource("wood", wood_cost):
		print("Error: Failed to deduct wood for tent construction!")
		return false
	
	current_builder = player
	is_being_built = true
	build_progress = 0.0
	
	# Create progress bar for building
	create_building_progress_bar()
	
	var remaining_wood = resource_manager.get_resource_amount("wood")
	print("Started building tent... (", build_time, " seconds)")
	print("Player has ", remaining_wood, " wood remaining")
	return true

func complete_building():
	print("Tent construction complete!")
	
	# Mark as built
	is_built = true
	is_being_built = false
	current_builder = null
	
	# Remove progress bar and show final state
	destroy_building_progress_bar()
	show_as_built()
	
	# Update light availability now that tent is built
	update_tent_light()

func get_build_progress() -> float:
	return build_progress

func is_tent_built() -> bool:
	return is_built

func get_players_inside() -> Array[Node]:
	return players_inside

func has_player_inside(player: Node) -> bool:
	return player in players_inside

func get_shelter_count() -> int:
	return players_inside.size()

# Light control system
func update_tent_light():
	"""Update tent light based on occupancy and night time"""
	if not tent_light:
		return
	
	var should_light_be_on = is_night_time and players_inside.size() > 0 and is_built
	
	if should_light_be_on and not tent_light.visible:
		tent_light.visible = true
		print("Tent light turned ON (night time, occupied)")
	elif not should_light_be_on and tent_light.visible:
		tent_light.visible = false
		var reason = ""
		if not is_night_time:
			reason = "day time"
		elif players_inside.size() == 0:
			reason = "unoccupied"
		elif not is_built:
			reason = "not built"
		print("Tent light turned OFF (", reason, ")")

# Day/Night system interface
func on_night_started():
	"""Called when night begins"""
	is_night_time = true
	update_tent_light()
	print("Tent: Night started")

func on_day_started():
	"""Called when day begins"""
	is_night_time = false
	update_tent_light()
	print("Tent: Day started")
