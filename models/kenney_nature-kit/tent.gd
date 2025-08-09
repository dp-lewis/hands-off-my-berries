extends Node3D

@export var wood_cost: int = 8  # Cost to build the tent
@export var build_time: float = 3.0  # Time to construct

var players_in_range: Array[Node] = []
var current_builder: Node = null
var build_progress: float = 0.0
var is_being_built: bool = false
var is_built: bool = false

@onready var area_3d: Area3D
@onready var tent_mesh: Node3D

func _ready():
	# Set up the tent as a "blueprint" initially
	if has_node("Area3D"):
		area_3d = $Area3D
		area_3d.body_entered.connect(_on_player_entered)
		area_3d.body_exited.connect(_on_player_exited)
	
	# Find the tent mesh to hide it initially
	tent_mesh = get_child(0)  # The tmpParent from GLB
	
	# Start as blueprint (semi-transparent or hidden)
	show_as_blueprint()

func _process(delta):
	if is_being_built and current_builder:
		# Update building progress
		build_progress += delta / build_time
		
		# Check if building is complete
		if build_progress >= 1.0:
			complete_building()

func show_as_blueprint():
	# Make tent semi-transparent to show it's not built yet
	if tent_mesh:
		tent_mesh.modulate = Color(1, 1, 1, 0.5)  # 50% transparent
	print("Tent blueprint placed - needs ", wood_cost, " wood to build")

func show_as_built():
	# Make tent fully visible
	if tent_mesh:
		tent_mesh.modulate = Color(1, 1, 1, 1.0)  # Fully opaque
	print("Tent construction complete!")

func _on_player_entered(body):
	if body.has_method("start_building_tent") and not is_built:
		players_in_range.append(body)
		body.set_nearby_tent(self)

func _on_player_exited(body):
	if body in players_in_range:
		players_in_range.erase(body)
		body.clear_nearby_tent(self)
		
		# If this player was building, stop the process
		if body == current_builder:
			stop_building()

func start_building(player: Node) -> bool:
	if is_built:
		print("Tent already built!")
		return false
		
	if is_being_built:
		print("Tent already being built!")
		return false
	
	# Check if player has enough wood
	if player.wood < wood_cost:
		print("Need ", wood_cost, " wood to build tent (have ", player.wood, ")")
		return false
	
	current_builder = player
	is_being_built = true
	build_progress = 0.0
	print("Started building tent...")
	return true

func stop_building():
	if is_being_built:
		current_builder = null
		is_being_built = false
		build_progress = 0.0
		print("Stopped building tent")

func complete_building():
	if current_builder:
		# Take wood from player
		current_builder.wood -= wood_cost
		print("Tent built! Used ", wood_cost, " wood. Player has ", current_builder.wood, " wood left")
		
		# Mark as built
		is_built = true
		is_being_built = false
		show_as_built()
		
		# Could add shelter functionality here later
		# enable_shelter_benefits()

func get_build_progress() -> float:
	return build_progress

func is_tent_built() -> bool:
	return is_built
