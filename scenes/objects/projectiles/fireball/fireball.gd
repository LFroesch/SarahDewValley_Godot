# Fireball.gd
extends Area2D

const SPEED = 100
const MAX_DISTANCE = 200  # Distance in pixels before disappearing

var direction: Vector2
var start_position: Vector2
var damage: float = randf_range(25, 40)
var is_fireball: bool = true
@onready var timeout_timer: Timer = $TimeoutTimer


func _ready():
	start_position = global_position
	monitoring = true
	monitorable = true
	timeout_timer.wait_time = 3.0
	timeout_timer.one_shot = true
	timeout_timer.timeout.connect(_on_timeout_timer_timeout)
	timeout_timer.start()

func _on_timeout_timer_timeout() -> void:
	queue_free()

func _physics_process(delta):
	position += direction * SPEED * delta
	
	# Check if we've gone too far
	if global_position.distance_to(start_position) > MAX_DISTANCE:
		queue_free()

func _on_area_entered(area: Area2D):
	if area is HurtComponent and area.is_enemy:
		area.hurt.emit(damage)
		queue_free()
