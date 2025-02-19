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
	transition.emit(previous_state)

func _on_exit() -> void:
	pass
