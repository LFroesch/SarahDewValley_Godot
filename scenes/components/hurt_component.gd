class_name HurtComponent
extends Area2D

@export var tool: DataTypes.Tools = DataTypes.Tools.None
@export var is_enemy: bool = false

signal hurt

func _on_area_entered(area: Area2D) -> void:
	var hit_component = area as HitComponent
	var talent_level = 0
	
	if StatisticsManager and StatisticsManager.stats.has("talents"):
		talent_level = StatisticsManager.stats.talents.get("melee", 0)
	if hit_component:
		if tool == hit_component.current_tool:
			if is_enemy:
				var crit_modifier = randi_range(1.0, 1.8)
				var random_damage = int(crit_modifier * randi_range(hit_component.enemy_damage_min, hit_component.enemy_damage_max))
				var total_damage = random_damage + (talent_level * 10.0)
				HitSplatManager.spawn_damage_number(global_position, total_damage, DamageNumber.Type.DAMAGE_TO_ENEMY)
				hurt.emit(total_damage)
			else:
				hurt.emit(hit_component.hit_damage)
	if area.get("is_fireball") and is_enemy:
		HitSplatManager.spawn_damage_number(global_position, area.damage, DamageNumber.Type.DAMAGE_TO_ENEMY)
		hurt.emit(area.damage)
		
	if area.get("is_fire_nova") and is_enemy:
		HitSplatManager.spawn_damage_number(global_position, area.damage, DamageNumber.Type.DAMAGE_TO_ENEMY)
		hurt.emit(area.damage)
	
	if area.get("is_holy_nova") and is_enemy:
		HitSplatManager.spawn_damage_number(global_position, area.damage, DamageNumber.Type.DAMAGE_TO_ENEMY)
		hurt.emit(area.damage)
		
