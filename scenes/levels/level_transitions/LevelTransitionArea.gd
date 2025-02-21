extends Area2D
@export var transition_id: String = "to_city"  

func _ready():
	print("Area2D ready, transition_id: ", transition_id)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var transitions = SceneManager.level_transitions.get(SceneManager.current_level)
		print("Transitions: ", transitions)  # Debug print
		if transitions:
			var transition_data = transitions.get(transition_id)
			print("Transition data: ", transition_data)  # Debug print
			if transition_data:
				SceneManager.load_level(transition_data.target_level, transition_data.entry_point)
