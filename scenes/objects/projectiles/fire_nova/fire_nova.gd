# FireNova.gd
extends Area2D

var damage: float = randf_range(30, 45)
var is_fire_nova: bool = true
var player: Node2D
var duration: float = 1.0

func _ready():
	monitoring = true
	monitorable = true
	
	player = get_parent()
	z_index = 0
	
	var timer = get_tree().create_timer(duration)
	timer.timeout.connect(queue_free)

func _physics_process(_delta: float) -> void:
	if player:
		global_position = player.global_position
	
