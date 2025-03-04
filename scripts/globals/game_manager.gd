# GameManager.gd
extends Node
var game_menu_screen = preload("res://scenes/ui/game_menu_screen.tscn")
var respawn_needed = false
var allow_unstuck = false
var game_menu_open = false  # New variable to track menu state
var normal_speed = 5.0

func _ready() -> void:
	call_deferred("reset_game_speed")
	
func reset_game_speed() -> void:
	DayAndNightCycleManager.game_speed = normal_speed

func set_respawn_needed(value: bool) -> void:
	respawn_needed = value

func _process(delta: float) -> void:
	# Check if respawn is needed and game is active
	if respawn_needed and !get_tree().paused:
		respawn_needed = false
		var player = get_tree().get_first_node_in_group("player")
		if player and player.has_method("respawn"):
			player.respawn()
			
func _unhandled_input(event: InputEvent) -> void:  # Fixed method name with underscores
	if event.is_action_pressed("game_menu"):
		if game_menu_open:
			# If menu is already open, close it and resume game
			close_game_menu()
		else:
			# Otherwise, open the menu
			show_game_menu_screen()

func start_game() -> void:
	DayAndNightCycleManager.game_speed = 5
		
	SceneManager.load_main_scene_container()
	var saved_state = SceneManager.load_level_state()
	
	if saved_state.level == "Level1" and saved_state.position == Vector2.ZERO:
		saved_state.position = Vector2(250,250)
	await SceneManager.load_level(saved_state.level, saved_state.position)
	await get_tree().process_frame
	SaveGameManager.load_game()
	SaveGameManager.allow_save_game = true
	GameManager.allow_unstuck = true

func close_game_menu() -> void:  # New function to close the menu
	# Find the menu instance and remove it
	var menu = get_tree().get_first_node_in_group("game_menu")
	if menu:
		menu.queue_free()
	
	# Reset game_menu_open state
	game_menu_open = false
	
	# Reset game time to normal speed
	DayAndNightCycleManager.game_speed = 5  # Normal speed as defined in your UI

func continue_game() -> void:
	var saved_level = SceneManager.load_level_state()
	if saved_level.is_empty():
		start_game()
	else:
		start_game()

func new_game() -> void:
	var config = ConfigFile.new()
	config.set_value("game", "current_level", "Level1")
	config.save("user://game_data/game_state.cfg")
	start_game()

func exit_game() -> void:
	get_tree().quit()
	
func save_game() -> void:
	pass  # Keeping this as it was in your original code

func show_game_menu_screen() -> void:
	DayAndNightCycleManager.game_speed = 5
	SaveGameManager.save_game()
	var game_menu_screen_instance = game_menu_screen.instantiate()
	get_tree().root.add_child(game_menu_screen_instance)
	
	# Set the game_menu_open flag
	game_menu_open = true
