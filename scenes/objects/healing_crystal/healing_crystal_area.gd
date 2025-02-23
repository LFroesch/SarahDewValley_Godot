extends Area2D
@export var heal_amount: float = 7.0
@export var heal_interval: float = 1.0
var player_in_range: Node2D = null
@onready var heal_timer: Timer = $HealTimer

func _ready() -> void:
	heal_timer.wait_time = heal_interval
	heal_timer.timeout.connect(_on_heal_timer_timeout)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = body
		heal_timer.start()

func _on_body_exited(body: Node2D) -> void:
	if body == player_in_range:
		player_in_range = null
		heal_timer.stop()

func _on_heal_timer_timeout() -> void:
	if player_in_range and player_in_range.current_health < player_in_range.max_health:
		player_in_range.current_health = min(
			player_in_range.current_health + heal_amount, 
			player_in_range.max_health
		)
