extends Node2D

@export var respawn_time: float = 120.0
@export var max_skeletons: int = 1
@export var initial_spawn_delay: float = 3.0


var skeleton_scene = preload("res://scenes/characters/enemies/skeleton/skeleton_chief/skeleton_chief.tscn") 
@onready var spawn_point1: Marker2D = $SpawnPoint
@onready var spawn_point2: Marker2D = $SpawnPoint2
@onready var spawn_point3: Marker2D = $SpawnPoint3

var current_skeleton_count: int = 0
var current_spawn_index: int = 0

func _ready():
	for i in range(max_skeletons):
		await get_tree().create_timer(initial_spawn_delay).timeout
		spawn_skeleton()

func get_next_spawn_point() -> Marker2D:
	# Create array of spawn points
	var spawn_points = [spawn_point1, spawn_point2, spawn_point3]
	var spawn_point = spawn_points[current_spawn_index]
	current_spawn_index = (current_spawn_index + 1) % 3

	return spawn_point

func spawn_skeleton():
	if current_skeleton_count >= max_skeletons:
		print("Max skeletons reached!")
		return
	
	var skeleton = skeleton_scene.instantiate()
	var chosen_spawn = get_next_spawn_point()
	skeleton.global_position = chosen_spawn.global_position
	add_child(skeleton)
	
	# Connect to the died signal - fixed syntax
	skeleton.died.connect(_on_skeleton_died)
	current_skeleton_count += 1
	
# Fixed function name syntax
func _on_skeleton_died():
	current_skeleton_count -= 1
	print("Skeleton died, respawning in ", respawn_time, " seconds")
	# Create timer and wait
	await get_tree().create_timer(respawn_time).timeout
	# Spawn new goblin after wait
	spawn_skeleton()
