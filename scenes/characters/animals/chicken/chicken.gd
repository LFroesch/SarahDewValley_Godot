extends NonPlayableCharacter

var egg_scene = preload("res://scenes/objects/egg.tscn")
@onready var egg_timer: Timer = $EggTimer

func _ready() -> void:
	walk_cycles = randi_range(min_walk_cycle, max_walk_cycle)
	if egg_timer != null:
		egg_timer.timeout.connect(_spawn_egg)
		_start_egg_timer()
	else:
		return

func _start_egg_timer() -> void:
	egg_timer.start(randf_range(30.0, 180.0))
	
func _spawn_egg() -> void:
	var egg_instance = egg_scene.instantiate() as Node2D
	egg_instance.global_position = global_position
	get_parent().call_deferred("add_child", egg_instance)
	_start_egg_timer()
