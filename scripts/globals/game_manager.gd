extends Node

var game_menu_screen = preload("res://scenes/ui/game_menu_screen.tscn")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("game_menu"):
		show_game_menu_screen()

func start_game() -> void:
	SceneManager.load_main_scene_container()
	var saved_level = SceneManager.load_level_state()
	await SceneManager.load_level(saved_level)
	await get_tree().process_frame
	SaveGameManager.load_game()
	SaveGameManager.allow_save_game = true

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
	SaveGameManager.save_game()
	get_tree().quit()
	
func save_game() -> void:
	pass

func show_game_menu_screen() -> void:
	SaveGameManager.save_game()
	var game_menu_screen_instance = game_menu_screen.instantiate()
	get_tree().root.add_child(game_menu_screen_instance)
