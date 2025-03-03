#hit_splat_manager.gd
extends Node

func spawn_damage_number(pos: Vector2, amount: int, type: int):
	var damage_number = DamageNumber.create(pos, amount, type)
	add_child(damage_number)

func spawn_xp_number(amount: int):
	var player = get_tree().get_first_node_in_group("player")
	if player:
		spawn_damage_number(player.global_position, amount, DamageNumber.Type.EXP)
