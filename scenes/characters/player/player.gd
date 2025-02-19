class_name Player
extends CharacterBody2D

@onready var hit_component: HitComponent = $HitComponent
@export var current_tool: DataTypes.Tools = DataTypes.Tools.None
@onready var hurt_component: HurtComponent = $HurtComponent
@export var respawn_position: Vector2 = Vector2(250, 250)
@export var max_health: float = 100
@export var current_health: float = 100
@onready var fade_overlay: ColorRect = $CanvasLayer/FadeOverlay

var player_direction: Vector2

func _ready() -> void:
	ToolManager.tool_selected.connect(on_tool_selected)
	InventoryManager.health_recovered.connect(_on_health_recovered)
	hurt_component.hurt.connect(_on_hurt)
	await get_tree().process_frame
	if fade_overlay:
		fade_overlay.color = Color(0, 0, 0, 0)

func on_tool_selected(tool: DataTypes.Tools) -> void:
	current_tool = tool
	hit_component.current_tool = tool

func _on_max_damage_reached() -> void:
	print("Player reached max damage! You pass out!")
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
	global_position = respawn_position
	await fade_in()
	
func _on_hurt(amount: float) -> void:
	current_health -= amount
	print(amount, " damage taken, ", current_health, " player health remaining")
	if current_health <= 0:
		_on_max_damage_reached()

func _on_health_recovered(amount: int) -> void:
	current_health = min(current_health + amount, max_health)
	print("Healed for ", amount, " HP. Current health: ", current_health)	
