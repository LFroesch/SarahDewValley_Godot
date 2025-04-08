class_name GameInputEvents

static var direction: Vector2
static var mouse_direction: Vector2 = Vector2.DOWN # Default facing down

static func movement_input() -> Vector2:
	if Input.is_action_pressed("walk_left"):
		direction = Vector2.LEFT
	elif Input.is_action_pressed("walk_right"):
		direction = Vector2.RIGHT
	elif Input.is_action_pressed("walk_up"):
		direction = Vector2.UP
	elif Input.is_action_pressed("walk_down"):
		direction = Vector2.DOWN
	else:
		direction = Vector2.ZERO
		
	return direction

static func is_movement_input() -> bool:
	if direction == Vector2.ZERO:
		return false
	else:
		return true
		
static func use_tool() -> bool:
	var use_tool_value: bool = Input.is_action_just_pressed("hit")	
	return use_tool_value

static func update_mouse_direction(player_position: Vector2, mouse_global_position: Vector2) -> Vector2:
	var raw_direction = (mouse_global_position - player_position).normalized()
	if abs(raw_direction.x) > abs(raw_direction.y):
		if raw_direction.x > 0:
			mouse_direction = Vector2.RIGHT
		else:
			mouse_direction = Vector2.LEFT
	else:
		if raw_direction.y > 0:
			mouse_direction = Vector2.DOWN
		else:
			mouse_direction = Vector2.UP
	return mouse_direction
