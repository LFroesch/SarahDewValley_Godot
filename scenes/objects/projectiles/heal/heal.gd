# heal.gd
extends Area2D

const BASE_DAMAGE_AMOUNT = 20
const DAMAGE_PER_TALENT_LEVEL = 5

var damage: float
var is_holy_nova: bool = true
var player: Node2D
var duration: float = 1.0

func _ready():
	monitoring = true
	monitorable = true
	player = get_parent()
	calculate_damage()
	var timer = get_tree().create_timer(duration)
	timer.timeout.connect(queue_free)

func _physics_process(_delta: float) -> void:
	if player:
		global_position = player.global_position
	
func calculate_damage() -> void:
	# Get talent level
	var talent_level = 0
	if StatisticsManager and StatisticsManager.stats.has("talents"):
		talent_level = StatisticsManager.stats.talents.get("heal", 0)
	
	# Calculate base healing
	var base_damage = BASE_DAMAGE_AMOUNT
	
	# Add talent bonus
	var talent_bonus = talent_level * DAMAGE_PER_TALENT_LEVEL
	
	# Set final healing amount
	damage = base_damage + talent_bonus
	
