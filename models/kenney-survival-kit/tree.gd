extends Node3D

@export var wood_yield: int = 5
@export var gather_time: float = 2.0

var players_in_range: Array[Node] = []
var current_gatherer: Node = null
var gather_progress: float = 0.0
var is_being_gathered: bool = false

@onready var area_3d: Area3D = $Area3D

func _ready():
	# Connect area signals for player detection
	area_3d.body_entered.connect(_on_player_entered)
	area_3d.body_exited.connect(_on_player_exited)

func _process(delta):
	if is_being_gathered and current_gatherer:
		# Update gathering progress
		gather_progress += delta / gather_time
		
		# Check if gathering is complete
		if gather_progress >= 1.0:
			complete_gathering()

func _on_player_entered(body):
	if body.has_method("start_gathering_tree"):
		players_in_range.append(body)
		body.set_nearby_tree(self)

func _on_player_exited(body):
	if body in players_in_range:
		players_in_range.erase(body)
		body.clear_nearby_tree(self)
		
		# If this player was gathering, stop the process
		if body == current_gatherer:
			stop_gathering()

func start_gathering(player: Node) -> bool:
	if is_being_gathered:
		return false  # Already being gathered
	
	current_gatherer = player
	is_being_gathered = true
	gather_progress = 0.0
	print("Started gathering tree...")
	return true

func stop_gathering():
	if is_being_gathered:
		current_gatherer = null
		is_being_gathered = false
		gather_progress = 0.0
		print("Stopped gathering tree")

func complete_gathering():
	if current_gatherer and current_gatherer.has_method("add_wood"):
		current_gatherer.add_wood(wood_yield)
		print("Tree gathered! Gave ", wood_yield, " wood")
		
		# Remove the tree
		queue_free()

func get_gather_progress() -> float:
	return gather_progress
