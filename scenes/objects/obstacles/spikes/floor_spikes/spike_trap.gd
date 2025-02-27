extends Node2D

class_name SpikeTrap

@export var damage: int = 20
@export var attack_cooldown: float = 5.0
@export var active_frame: int = 2
@export var auto_cycle: bool = true
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var damage_area: Area2D = $DamageArea
@onready var cooldown_timer: Timer = $CooldownTimer
@export var initial_delay: float = 2.0

var is_active: bool = false
var has_dealt_damage: bool = false
var is_first_ready: bool = true

func _ready() -> void:
	damage_area.monitoring = false
	if animated_sprite == null:
		push_error("SpikeTrap: AnimatedSprite2D node not found!")
		return
	if damage_area == null:
		push_error("SpikeTrap: DamageArea node not found!")
		return
	if cooldown_timer == null:
		push_error("SpikeTrap: CooldownTimer node not found!")
		return

	animated_sprite.animation_finished.connect(_on_animation_finished)
	animated_sprite.frame_changed.connect(_on_frame_changed)
	cooldown_timer.wait_time = attack_cooldown
	cooldown_timer.one_shot = true
	damage_area.body_entered.connect(_on_body_entered)
	cooldown_timer.timeout.connect(_on_cooldown_timer_timeout)
	play_idle_animation()

	if auto_cycle:
		await get_tree().create_timer(initial_delay).timeout
		trigger_attack()
	else:
		pass

func _process(_delta: float) -> void:
	pass

func _on_frame_changed() -> void:
	if animated_sprite.animation == "attack":
		var current_frame = animated_sprite.frame
		if current_frame >= active_frame and not is_active:
			activate_trap()
		elif current_frame < active_frame and is_active:
			deactivate_trap()

func activate_trap() -> void:
	is_active = true
	damage_area.monitoring = true
	has_dealt_damage = false

func deactivate_trap() -> void:
	is_active = false
	damage_area.monitoring = false

func trigger_attack() -> void:
	if animated_sprite.animation != "attack" and cooldown_timer.is_stopped():
		play_attack_animation()
		cooldown_timer.start()

func play_idle_animation() -> void:
	if !animated_sprite.sprite_frames.has_animation("idle"):
		push_error("SpikeTrap: 'idle' animation not found in SpriteFrames!")
		return
		
	animated_sprite.play("idle")

func play_attack_animation() -> void:
	if !animated_sprite.sprite_frames.has_animation("attack"):
		push_error("SpikeTrap: 'attack' animation not found in SpriteFrames!")
		return
		
	animated_sprite.play("attack")

func _on_animation_finished() -> void:
	if animated_sprite.animation == "attack":
		play_idle_animation()
		deactivate_trap()
		
func _on_cooldown_timer_timeout() -> void:
	if auto_cycle:
		trigger_attack()

func _on_body_entered(body: Node2D) -> void:
	if is_active and not has_dealt_damage:
		if body.has_method("_on_hurt"):
			body._on_hurt(damage)
			has_dealt_damage = true

func set_auto_cycle(value: bool) -> void:
	auto_cycle = value
	if auto_cycle and animated_sprite.animation == "idle" and cooldown_timer.is_stopped():
		trigger_attack()
