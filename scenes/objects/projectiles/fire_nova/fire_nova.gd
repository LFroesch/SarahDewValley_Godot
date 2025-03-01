extends Area2D
class_name FireNova

const BASE_DAMAGE_MIN = 30
const BASE_DAMAGE_MAX = 45
const DAMAGE_PER_TALENT_LEVEL = 7

var damage: float
var is_fire_nova: bool = true
var player: Node2D
var duration: float = 1.0

func _ready():
	monitoring = true
	monitorable = true
	
	player = get_parent()
	z_index = 0
	
	# Calculate damage with talent bonuses
	calculate_damage()
	
	# Set up duration timer
	var timer = get_tree().create_timer(duration)
	timer.timeout.connect(queue_free)

func calculate_damage() -> void:
	# Get talent level
	var talent_level = 0
	if StatisticsManager and StatisticsManager.stats.has("talents"):
		talent_level = StatisticsManager.stats.talents.get("fire_nova", 0)
	
	# Calculate base damage range
	var base_damage = randf_range(BASE_DAMAGE_MIN, BASE_DAMAGE_MAX)
	
	# Add talent bonus
	var talent_bonus = talent_level * DAMAGE_PER_TALENT_LEVEL
	
	# Set final damage
	damage = base_damage + talent_bonus
	
	# Debug
	if OS.is_debug_build():
		print("Fire Nova damage: Base=", base_damage, " + Talent(", talent_level, ")=", 
			talent_bonus, " = Total:", damage)

func _physics_process(_delta: float) -> void:
	if player:
		global_position = player.global_position
