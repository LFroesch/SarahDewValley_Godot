class_name HurtComponent
extends Area2D

@export var tool: DataTypes.Tools = DataTypes.Tools.None
@export var is_enemy: bool = false

signal hurt


func _on_area_entered(area: Area2D) -> void:
	var hit_component = area as HitComponent
	
	if tool == hit_component.current_tool:
		if is_enemy:
			hurt.emit(hit_component.enemy_damage)
		else:
			hurt.emit(hit_component.hit_damage)
