#LevelTransitionArea.gd
extends Area2D

@export var transition_id: String = "to_city"
var is_transitioning := false

func _ready():
	pass
	
func _on_body_entered(body: Node2D) -> void:
	#InventoryManager.remove_collectible("skeleton_key")
	SaveGameManager.save_game()
	if body.is_in_group("player") and not is_transitioning:
		is_transitioning = true
		var transitions = SceneManager.level_transitions.get(SceneManager.current_level)
		if transitions:
			var transition_data = transitions.get(transition_id)
			if transition_data:
				await body.fade_out()
				await get_tree().create_timer(0.2).timeout
				var target_level = transition_data.target_level
				var target_point = transition_data.entry_point
				
				if target_level != SceneManager.current_level:
					SceneManager.load_level(target_level, target_point)
					if target_level.begins_with("the_sewers_floor_"):
						print("Transitioning to sewer level: " + target_level)
						if DungeonRunManager:
							DungeonRunManager.update_current_level(target_level)
				else:
					body.global_position = target_point
					
				var player = get_tree().get_first_node_in_group("player")
				SaveGameManager.save_game()
				if player:
					await player.fade_in()
				await get_tree().process_frame
				await get_tree().create_timer(1.0).timeout
				
				is_transitioning = false
				
