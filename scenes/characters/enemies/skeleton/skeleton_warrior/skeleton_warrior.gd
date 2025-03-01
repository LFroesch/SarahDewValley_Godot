extends NonPlayableCharacter

@onready var detection_area = $Area2D
@onready var damage_timer: Timer = $DamageTimer
@onready var hurt_component: HurtComponent = $HurtComponent
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_machine: NodeStateMachine = $StateMachine
@onready var damage_bar: Node2D = $DamageBar
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

const DROP_TABLE = [
	{"item": preload("res://scenes/objects/egg.tscn"),
	 "weight": 40,
	 "min_count": 1,
	 "max_count": 2
	},
	{"item": preload("res://scenes/objects/coin.tscn"),
	 "weight": 100,
	 "min_count": 1,
	 "max_count": 2
	},
	{"item": preload("res://scenes/objects/coin.tscn"),
	 "weight": 10,
	 "min_count": 3,
	 "max_count": 5
	},
	{"item": preload("res://scenes/objects/milk.tscn"),
	 "weight": 20,
	 "count": 1
	}
]
const MIN_DISTANCE = 7.0
const SCATTER_RADIUS = 20.0
const DROP_CHANCE = 80

var can_deal_damage = true
var player_in_range = false
var current_player = null
@export var health: float = 100
var is_dying = false

signal died

func _ready():
	walk_cycles = randi_range(min_walk_cycle, max_walk_cycle)
	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)
	damage_timer.wait_time = 2.0
	damage_timer.timeout.connect(_on_damage_timer_timeout)
	hurt_component.hurt.connect(take_damage)
	hurt_component.is_enemy = true

func _physics_process(_delta):
	if player_in_range and can_deal_damage and not is_dying and current_player != null:
		var distance = global_position.distance_to(current_player.global_position)
		if distance <= 20.0:
			attack_player(current_player)

func attack_player(player):
	state_machine.transition_to("attack")
	if player.has_node("HurtComponent"):
		var damage = randi_range(5, 10)
		var crit = snappedf(randf_range(1.0, 2.0), 0.1)
		var mitigated = randi_range(1, 5)
		var total_damage = min(int(damage * crit - mitigated), 15)
		player.get_node("HurtComponent").hurt.emit(total_damage)
		print("Player takes ", total_damage, " damage | Damage: ", damage, " | Crit %: ", crit, " | Mitigated: ", mitigated)
	can_deal_damage = false
	damage_timer.start()

func _on_body_entered(body):
	if body.is_in_group("player"):
		current_player = body
		player_in_range = true
		state_machine.transition_to("pursue")

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
		current_player = null
		state_machine.transition_to("walk")

func _on_damage_timer_timeout():
	can_deal_damage = true

func select_drops() -> Array:
	var drops = []
	for drop in DROP_TABLE:
		var loot_roll = randi_range(1, 100)
		if loot_roll <= drop.weight:
			var count = 1
			if "min_count" in drop and "max_count" in drop:
				count = randi_range(drop.min_count, drop.max_count)
			elif "count" in drop:
				count = drop.count
			for i in count:
				drops.append(drop.item.instantiate())
	return drops

func get_random_position(existing_positions: Array) -> Vector2:
	var max_attempts = 10
	var attempt = 0
	while attempt < max_attempts:
		var angle = randf() * PI * 2
		var distance = randf() * SCATTER_RADIUS
		var offset = Vector2(
			cos(angle) * distance,
			sin(angle) * distance
		)
		var is_valid = true
		for pos in existing_positions:
			if pos.distance_to(offset) < MIN_DISTANCE:
				is_valid = false
				break
		if is_valid:
			return offset
		attempt += 1
	var angle = randf() * PI * 2
	var distance = randf() * SCATTER_RADIUS
	return Vector2(cos(angle) * distance, sin(angle) * distance)

func take_damage(amount: float):
	if is_dying:
		return
	health -= amount
	if health <= 2:
		damage_bar.hide()
		is_dying = true
		collision_shape.set_deferred("disabled", true)
		detection_area.set_deferred("monitoring", false)
		detection_area.set_deferred("monitorable", false)
		velocity = Vector2.ZERO
		current_player = null
		player_in_range = false
		var drops = select_drops()
		var used_positions = []
		for loot in drops:
			var offset = get_random_position(used_positions)
			used_positions.append(offset)
			loot.global_position = global_position + offset
			get_parent().call_deferred("add_child", loot)
		died.emit()
		animated_sprite.stop()
		state_machine.set_process(false)
		state_machine.set_physics_process(false)
		if state_machine.current_node_state:
			state_machine.current_node_state._on_exit()
		if animated_sprite.animation_finished.is_connected(_on_death_animation_finished):
			animated_sprite.animation_finished.disconnect(_on_death_animation_finished)
		animated_sprite.stop()
		await get_tree().create_timer(0.1).timeout
		animated_sprite.animation_finished.connect(_on_death_animation_finished)
		animated_sprite.play("death")

func _on_death_animation_finished():
	StatisticsManager.record_kill("skeleton_warrior")
	StatisticsManager.add_experience(25)
	queue_free()
