#player.gd
class_name Player
extends CharacterBody2D

@onready var hit_component: HitComponent = $HitComponent
@export var current_tool: DataTypes.Tools = DataTypes.Tools.None
@onready var hurt_component: HurtComponent = $HurtComponent
@export var respawn_position: Vector2 = Vector2(250, 250)
@export var max_health: float = 100
@export var current_health: float = 100
@onready var fade_overlay: ColorRect = $CanvasLayer/FadeOverlay if has_node("CanvasLayer/FadeOverlay") else null
@onready var fireball_scene = preload("res://scenes/objects/projectiles/fireball/fireball.tscn")
@onready var fire_nova_scene = preload("res://scenes/objects/projectiles/fire_nova/fire_nova.tscn")
@onready var heal_scene = preload("res://scenes/objects/projectiles/heal/heal.tscn")

@export var can_shoot: bool = true
@export var shoot_cooldown: float = 3.0
@export var shoot_timer: Timer

@export var fire_nova_cooldown: float = 5.0
var can_cast_nova: bool = true
@export var fire_nova_timer: Timer

@export var heal_cooldown: float = 5.0
var can_cast_heal: bool = true
@export var heal_timer: Timer

var player_direction: Vector2

func _ready() -> void:
	ToolManager.tool_selected.connect(on_tool_selected)
	InventoryManager.health_recovered.connect(_on_health_recovered)
	hurt_component.hurt.connect(_on_hurt)
	await get_tree().process_frame
	if fade_overlay:
		fade_overlay.color = Color(0, 0, 0, 0)
	heal_timer = Timer.new()
	heal_timer.wait_time = heal_cooldown
	heal_timer.one_shot = true
	heal_timer.timeout.connect(_on_heal_cooldown_timeout)
	add_child(heal_timer)
	fire_nova_timer = Timer.new()
	fire_nova_timer.wait_time = fire_nova_cooldown
	fire_nova_timer.one_shot = true
	fire_nova_timer.timeout.connect(_on_nova_cooldown_timeout)
	add_child(fire_nova_timer)
	shoot_timer = Timer.new()
	shoot_timer.wait_time = shoot_cooldown
	shoot_timer.one_shot = true
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	add_child(shoot_timer)

func cast_heal() -> void:
	var heal_amount: float = 20.0
	heal(heal_amount)
	var heal = heal_scene.instantiate()
	add_child(heal)
	can_cast_heal = false
	heal_timer.start()

func _on_heal_cooldown_timeout() -> void:
	can_cast_heal = true
	
func heal(amount: float) -> void: #Dedicated for the heal ability
	current_health = min(current_health + amount, max_health)

func cast_fire_nova() -> void:
	var nova = fire_nova_scene.instantiate()
	add_child(nova)
	can_cast_nova = false
	fire_nova_timer.start()

func _on_nova_cooldown_timeout() -> void:
	can_cast_nova = true

func _unhandled_input(event):
	if event.is_action_pressed("shoot_fireball") and can_shoot:
		shoot_fireball()
	if event.is_action_pressed("cast_fire_nova") and can_cast_nova:
		cast_fire_nova()
	if event.is_action_pressed("cast_heal") and can_cast_heal:
		cast_heal()
		
func shoot_fireball():
	if not can_shoot:
		return
		
	var fireball = fireball_scene.instantiate()
	fireball.global_position = global_position
	fireball.direction = player_direction.normalized()
	get_parent().add_child(fireball)
	
	can_shoot = false
	shoot_timer.start()

func _on_shoot_timer_timeout():
	can_shoot = true

func on_tool_selected(tool: DataTypes.Tools) -> void:
	current_tool = tool
	hit_component.current_tool = tool

func _on_max_damage_reached() -> void:
	print("Player reached max damage! You pass out!")
	InventoryManager.remove_collectible("skeleton_key")
	await respawn()

func fade_out() -> void:
	var tween = create_tween()
	tween.tween_property(fade_overlay, "color", Color(0, 0, 0, 1), 0.5)
	await tween.finished

func fade_in() -> void:
	var tween = create_tween()
	tween.tween_property(fade_overlay, "color", Color(0, 0, 0, 0), 0.5)
	await tween.finished

func respawn() -> void:
	await fade_out()
	await get_tree().create_timer(1.0).timeout
	current_health = max_health
	await SceneManager.load_level("Level1", respawn_position)
	await fade_in()
	
func _on_hurt(amount: float) -> void:
	current_health -= amount
	if current_health <= 0:
		_on_max_damage_reached()

func _on_health_recovered(amount: int) -> void:
	current_health = min(current_health + amount, max_health)	
