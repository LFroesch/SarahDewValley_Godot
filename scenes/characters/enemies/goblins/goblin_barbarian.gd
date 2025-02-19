extends NonPlayableCharacter

@onready var detection_area = $Area2D
@onready var damage_timer: Timer = $DamageTimer
@onready var hurt_component: HurtComponent = $HurtComponent
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
var loot_scene = preload("res://scenes/objects/egg.tscn")
@onready var state_machine: NodeStateMachine = $StateMachine
@onready var damage_bar: Node2D = $DamageBar
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var can_deal_damage = true
var player_in_range = false
var current_player = null
@export var health: float = 75
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
		attack_player(current_player)

func attack_player(player):
	state_machine.transition_to("attack")
	if player.has_node("HurtComponent"):
		player.get_node("HurtComponent").hurt.emit(10.0)
	can_deal_damage = false
	damage_timer.start()

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true
		current_player = body
		if can_deal_damage and not is_dying:
			attack_player(body)

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
		current_player = null

func _on_damage_timer_timeout():
	can_deal_damage = true

func take_damage(amount: float):
	if is_dying:
		return
	
	health -= amount
	if health <= 0:
		damage_bar.hide()
		is_dying = true
		collision_shape.set_deferred("disabled", true)
		detection_area.monitoring = false
		detection_area.monitorable = false
		
		if loot_scene:
			var loot = loot_scene.instantiate()
			loot.global_position = global_position + Vector2(4,4)
			get_parent().add_child(loot)
		died.emit()
		state_machine.set_process(false)
		state_machine.set_physics_process(false)
		animated_sprite.animation_finished.connect(_on_death_animation_finished)
		animated_sprite.play("death")

func _on_death_animation_finished():
	queue_free()
