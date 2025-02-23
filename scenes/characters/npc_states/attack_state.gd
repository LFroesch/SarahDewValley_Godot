extends NodeState
@export var character: NonPlayableCharacter
@export var animated_sprite_2d: AnimatedSprite2D
var previous_state: String

func _ready() -> void:
	animated_sprite_2d.animation_finished.connect(_on_animation_finished)

func _on_enter() -> void:
	previous_state = get_parent().current_node_state_name
	animated_sprite_2d.play("attack")

func _on_animation_finished():
	# If player is still in range but not close enough, go back to pursuing
	if character.current_player and not character.is_dying:
		var distance = character.global_position.distance_to(character.current_player.global_position)
		if distance > 15:
			transition.emit("pursue")
		else:
			transition.emit(previous_state)
	else:
		transition.emit(previous_state)

func _on_exit() -> void:
	pass
