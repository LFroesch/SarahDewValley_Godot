# FireNova.gd
extends Area2D

var damage: float = randf_range(30, 45)
var is_fire_nova: bool = true
var player: Node2D  # Reference to the player
var duration: float = 1.0  # How long the nova exists for

func _ready():
	monitoring = true
	monitorable = true
	
	# Get reference to the player
	player = get_parent()
	
	var timer = get_tree().create_timer(duration)
	timer.timeout.connect(queue_free)

func _physics_process(_delta: float) -> void:
	if player:
		global_position = player.global_position
	
