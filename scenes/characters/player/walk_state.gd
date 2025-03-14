extends NodeState

@export var player: Player
@export var animated_sprite_2d: AnimatedSprite2D
@export var base_speed: int = 48
var cached_talent_level: int = -1
var speed: int = 48

func _on_process(_delta : float) -> void:
	pass

func _on_physics_process(_delta : float) -> void:
	var current_talent_level = 0
	if StatisticsManager and StatisticsManager.stats.has("talents"):
		current_talent_level = StatisticsManager.stats.talents.get("speed", 0)
	
	# Update speed if talent level changed
	if current_talent_level != cached_talent_level:
		cached_talent_level = current_talent_level
		speed = base_speed + (current_talent_level * 8) 
	var direction: Vector2 = GameInputEvents.movement_input()
	
	if direction == Vector2.UP:
		animated_sprite_2d.play("walk_back")
	elif direction == Vector2.LEFT:
		animated_sprite_2d.play("walk_left")
	elif direction == Vector2.RIGHT:
		animated_sprite_2d.play("walk_right")
	elif direction == Vector2.DOWN:
		animated_sprite_2d.play("walk_front")
	
	if direction != Vector2.ZERO:
		player.player_direction = direction
	
	player.velocity = direction * speed * (_delta * 100)
	player.move_and_slide()


func _on_next_transitions() -> void:
	if !GameInputEvents.is_movement_input():
		transition.emit("Idle")


func _on_enter() -> void:
	pass


func _on_exit() -> void:
	animated_sprite_2d.stop()
