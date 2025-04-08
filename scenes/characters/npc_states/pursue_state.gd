extends NodeState
@export var character: NonPlayableCharacter
@export var animated_sprite_2d: AnimatedSprite2D
@export var navigation_agent_2d: NavigationAgent2D
@export var pursuit_speed: float = 20.0
@export var attack_range: float = 20.0
@export var stop_distance: float = 17.0

func _ready() -> void:
	if navigation_agent_2d:
		navigation_agent_2d.path_desired_distance = 4.0
		navigation_agent_2d.target_desired_distance = stop_distance
		navigation_agent_2d.path_max_distance = 200.0

func _on_physics_process(_delta: float) -> void:
	if not character or character.is_dying:
		animated_sprite_2d.stop()
		character.velocity = Vector2.ZERO
		return
		
	if not character.current_player:
		print("No current player")
		return
		
	var player_pos = character.current_player.global_position
	var current_pos = character.global_position
	var distance = current_pos.distance_to(player_pos)
	
	if distance <= attack_range and character.can_deal_damage:
		transition.emit("attack")
		return
	
	if distance <= stop_distance:
		character.velocity = Vector2.ZERO
		return
	
	navigation_agent_2d.target_position = player_pos
	var next_position = navigation_agent_2d.get_next_path_position()
	var direction = current_pos.direction_to(next_position)
	
	character.velocity = direction * pursuit_speed
	animated_sprite_2d.flip_h = direction.x < 0
	character.move_and_collide(character.velocity * _delta)

func _on_enter() -> void:
	if animated_sprite_2d:
		animated_sprite_2d.play("walk")
		
func _on_exit() -> void:
	if animated_sprite_2d:
		animated_sprite_2d.stop()
