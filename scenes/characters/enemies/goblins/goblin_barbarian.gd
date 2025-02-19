extends NonPlayableCharacter

@onready var detection_area = $Area2D
@onready var damage_timer: Timer = $DamageTimer
@onready var hurt_component: HurtComponent = $HurtComponent
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
var loot_scene = preload("res://scenes/objects/egg.tscn")
@onready var state_machine: NodeStateMachine = $StateMachine  # Adjust path as needed

var can_deal_damage = true
@export var health: float = 50

signal died

func _ready():
	walk_cycles = randi_range(min_walk_cycle, max_walk_cycle)

	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)
	
	damage_timer.wait_time = 3.0
	damage_timer.timeout.connect(_on_damage_timer_timeout)
	hurt_component.hurt.connect(take_damage)
	hurt_component.is_enemy = true
	
func _on_body_entered(body):
	if body.is_in_group("player") and can_deal_damage:
		state_machine.transition_to("attack")

		if body.has_node("HurtComponent"):
			body.get_node("HurtComponent").hurt.emit(10.0)
		can_deal_damage = false
		damage_timer.start()
		
func _on_body_exited(body):
	pass

func _on_damage_timer_timeout():
	can_deal_damage = true
		
func take_damage(amount: float):
	health -= amount
	if health <= 0:
		if loot_scene:
			var loot = loot_scene.instantiate()
			loot.global_position = global_position
			get_parent().add_child(loot)
		died.emit()
		queue_free()
