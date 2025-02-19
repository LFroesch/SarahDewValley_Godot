extends Node

var spawn_points: Array[Marker2D] = []
var registered_paths: Array[NodePath] = []

func register_spawn_point(point: Marker2D):
	var point_path = point.get_path()
	if not registered_paths.has(point_path):
		spawn_points.append(point)
		registered_paths.append(point_path)
		#print("Spawn point registered. Total points: ", spawn_points.size())
	else:
		return
		#print("Spawn point already registered: ", point_path)

func get_first_spawn() -> Marker2D:
	if spawn_points.is_empty():
		push_error("No spawn points registered!")
		return null
	return spawn_points[0]
	
func get_random_spawn() -> Marker2D:
	if spawn_points.is_empty():
		push_error("No spawn points registered!")
		return null
	return spawn_points[randi() % spawn_points.size()]
