class_name HurtComponent
extends Area2D

@export var tool: DataTypes.Tools = DataTypes.Tools.None
@export var is_enemy: bool = false

signal hurt

func _on_area_entered(area: Area2D) -> void:
	var hit_component = area as HitComponent
	if hit_component:
		if tool == hit_component.current_tool:
			if is_enemy:
				var crit_modifier = randi_range(1.0, 1.8)
				var random_damage = int(crit_modifier * randi_range(hit_component.enemy_damage_min, hit_component.enemy_damage_max))
				hurt.emit(random_damage)
			else:
				hurt.emit(hit_component.hit_damage)
	if area.get("is_fireball") and is_enemy:
		hurt.emit(area.damage)
	if area.get("is_fire_nova") and is_enemy:
		hurt.emit(area.damage)
