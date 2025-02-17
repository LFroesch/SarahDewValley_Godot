extends NonPlayableCharacter

@onready var milk_timer: Timer = $MilkTimer
var milk_scene = preload("res://scenes/objects/milk.tscn")


func _ready() -> void:
	walk_cycles = randi_range(min_walk_cycle, max_walk_cycle)
	if milk_timer != null:
		milk_timer.timeout.connect(_spawn_milk)
		_start_milk_timer()
	else:
		return

func _start_milk_timer() -> void:
	milk_timer.start(randf_range(180.0, 300.0))
	var milk_instance = milk_scene.instantiate() as Node2D
	milk_instance.global_position = global_position
	get_parent().add_child(milk_instance)
	
func _spawn_milk() -> void:
	var milk_instance = milk_scene.instantiate() as Node2D
	milk_instance.global_position = global_position
	get_parent().add_child(milk_instance)
	_start_milk_timer()
