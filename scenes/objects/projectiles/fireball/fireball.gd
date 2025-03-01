# Fireball.gd
extends Area2D

const SPEED = 100
const MAX_DISTANCE = 300
const BASE_DAMAGE_MIN = 25
const BASE_DAMAGE_MAX = 40
const DAMAGE_PER_TALENT_LEVEL = 5

var direction: Vector2
var start_position: Vector2
var damage: float
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
	calculate_damage()

func calculate_damage() -> void:
	# Get talent level
	var talent_level = 0
	if StatisticsManager and StatisticsManager.stats.has("talents"):
		talent_level = StatisticsManager.stats.talents.get("fireball", 0)
	
	# Calculate base damage range
	var base_damage = randf_range(BASE_DAMAGE_MIN, BASE_DAMAGE_MAX)
	
	# Add talent bonus
	var talent_bonus = talent_level * DAMAGE_PER_TALENT_LEVEL
	
	# Set final damage
	damage = base_damage + talent_bonus
	
	# Debug
	if OS.is_debug_build():
		print("Fireball damage: Base=", base_damage, " + Talent(", talent_level, ")=", 
			talent_bonus, " = Total:", damage)

func _on_timeout_timer_timeout() -> void:
	queue_free()

func _physics_process(delta):
	position += direction * SPEED * delta
	
	if global_position.distance_to(start_position) > MAX_DISTANCE:
		queue_free()

func _on_area_entered(area: Area2D):
	if area is HurtComponent and area.is_enemy:
		area.hurt.emit(damage)
		queue_free()
