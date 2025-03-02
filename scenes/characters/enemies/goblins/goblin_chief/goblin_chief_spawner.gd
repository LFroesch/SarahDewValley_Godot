extends Node2D

@export var respawn_time: float = 120.0
@export var max_goblins: int = 1
@export var initial_spawn_delay: float = 3.0

var goblin_scene = preload("res://scenes/characters/enemies/goblins/goblin_chief/goblin_chief.tscn") 
var spawn_points = []
var current_goblin_count: int = 0
var current_spawn_index: int = 0

func _ready():
	# Find all spawn points (all child nodes that are Marker2D)
	for child in get_children():
		if child is Marker2D:
			spawn_points.append(child)
	
	# Make sure we have at least one spawn point
	if spawn_points.size() == 0:
		push_error("No spawn points found! Add at least one Marker2D as a child.")
		return
	
	# Initial spawning
	for i in range(max_goblins):
		await get_tree().create_timer(initial_spawn_delay).timeout
		spawn_goblin()

func get_next_spawn_point() -> Marker2D:
	# Return null if no spawn points exist
	if spawn_points.size() == 0:
		return null
	
	var spawn_point = spawn_points[current_spawn_index]
	current_spawn_index = (current_spawn_index + 1) % spawn_points.size()
	return spawn_point

func spawn_goblin():
	if current_goblin_count >= max_goblins:
		return
	
	var chosen_spawn = get_next_spawn_point()
	if chosen_spawn == null:
		return
	
	var goblin = goblin_scene.instantiate()
	goblin.global_position = chosen_spawn.global_position
	add_child(goblin)
	goblin.died.connect(_on_goblin_died)
	current_goblin_count += 1
	
func _on_goblin_died():
	current_goblin_count -= 1
	await get_tree().create_timer(respawn_time).timeout
	spawn_goblin()
