extends Node

var game_menu_screen = preload("res://scenes/ui/game_menu_screen.tscn")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("game_menu"):
		#SaveGameManager.save_game()
		show_game_menu_screen()

func start_game() -> void:
	SceneManager.load_main_scene_container()
	await SceneManager.load_level("Level1")
	await get_tree().process_frame
	SaveGameManager.load_game()
	SaveGameManager.allow_save_game = true

func exit_game() -> void:
	get_tree().quit()
	
func save_game() -> void:
	pass

func show_game_menu_screen() -> void:
	var game_menu_screen_instance = game_menu_screen.instantiate()
	get_tree().root.add_child(game_menu_screen_instance)
