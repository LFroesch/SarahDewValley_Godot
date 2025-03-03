extends NonPlayableCharacter

@onready var detection_area = $Area2D
@onready var damage_timer: Timer = $DamageTimer
@onready var hurt_component: HurtComponent = $HurtComponent
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_machine: NodeStateMachine = $StateMachine
@onready var damage_bar: Node2D = $DamageBar
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var can_deal_damage = true
var player_in_range = false
var current_player = null
@export var health: float = 80
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
		DropManager.drop_for_enemy("goblin_barbarian", global_position, get_parent())
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
	StatisticsManager.record_kill("goblin_barbarian")
	StatisticsManager.add_experience(25)
	queue_free()
