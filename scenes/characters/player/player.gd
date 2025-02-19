class_name Player
extends CharacterBody2D

@onready var hit_component: HitComponent = $HitComponent
@export var current_tool: DataTypes.Tools = DataTypes.Tools.None
@onready var hurt_component: HurtComponent = $HurtComponent

@export var max_health: float = 100
@export var current_health: float = 100

var player_direction: Vector2

func _ready() -> void:
	ToolManager.tool_selected.connect(on_tool_selected)
	hurt_component.hurt.connect(_on_hurt)

	
func on_tool_selected(tool: DataTypes.Tools) -> void:
	current_tool = tool
	hit_component.current_tool = tool

func _on_max_damage_reached() -> void:
	print("Player reached max damage! You pass out!")
	
func _on_hurt(amount: float) -> void:
	current_health -= amount
	print(amount, " damage taken, ", current_health, " player health remaining")
	if current_health <= 0:
		_on_max_damage_reached()
