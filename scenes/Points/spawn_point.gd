extends Marker2D

func _ready():
	# Add a small delay to ensure SpawnManager is ready
	call_deferred("_register_self")

func _register_self():
	# Access the SpawnManager through the proper autoload path
	var spawn_manager = get_node("/root/SpawnManager")
	if not spawn_manager:
		push_error("SpawnManager not found! Make sure it's added as an AutoLoad.")
		return
	spawn_manager.register_spawn_point(self)
