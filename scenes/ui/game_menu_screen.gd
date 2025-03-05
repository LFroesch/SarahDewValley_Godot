# GameMenuScreen.gd
extends CanvasLayer
@onready var save_game_button: Button = $MarginContainer/VBoxContainer/SaveGameButton
@onready var confirmation_dialog: ConfirmationDialog = $ConfirmationDialog
@onready var unstuck_button: Button = $MarginContainer/VBoxContainer/UnstuckButton

func _ready() -> void:
	# Add this scene to a group for easier reference
	add_to_group("game_menu")
	
	save_game_button.disabled = !SaveGameManager.allow_save_game
	save_game_button.focus_mode = SaveGameManager.allow_save_game if Control.FOCUS_ALL else Control.FOCUS_NONE
	unstuck_button.disabled = !GameManager.allow_unstuck
	unstuck_button.focus_mode = GameManager.allow_unstuck if Control.FOCUS_ALL else Control.FOCUS_NONE
	confirmation_dialog.dialog_text = "Are you sure you want to delete your save file? You will restart the game. This action cannot be undone."
	confirmation_dialog.get_ok_button().text = "Delete"
	confirmation_dialog.get_cancel_button().text = "Cancel"

func _unhandled_input(event: InputEvent) -> void:  # New method to handle Escape key
	if event.is_action_pressed("game_menu"):
		get_viewport().set_input_as_handled()
		# Close menu and reset game_menu_open flag
		queue_free()
		GameManager.game_menu_open = false
		DayAndNightCycleManager.game_speed = 5

func _on_start_game_button_pressed() -> void:  # Fixed method name with underscores
	GameManager.start_game()
	queue_free()
	GameManager.game_menu_open = false  # Reset the menu state flag
	

func _on_save_game_button_pressed() -> void:  # Fixed method name with underscores
	SaveGameManager.save_game()

func _on_exit_game_button_pressed() -> void:  # Fixed method name with underscores
	GameManager.exit_game()

func _on_update_game_button_pressed() -> void:  # Fixed method name with underscores
	OS.shell_open("https://lfroesch.itch.io/sdv")

func _on_delete_save_button_pressed() -> void:  # Fixed method name with underscores
	confirmation_dialog.popup_centered()

func _on_confirmation_dialog_confirmed() -> void:
	var appdata_path = OS.get_environment("APPDATA")
	var save_path = appdata_path + "/Godot/app_userdata/SDV/game_data"
	
	var dir = DirAccess.open(save_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if !dir.current_is_dir():
				dir.remove(save_path + "/" + file_name)
			file_name = dir.get_next()
			
		dir.list_dir_end()
	ToolManager.reset_tools()
	DayAndNightCycleManager.time = 0.0
	DayAndNightCycleManager.current_minute = -1
	DayAndNightCycleManager.current_day = 0
	DayAndNightCycleManager.set_initial_time()
	DayAndNightCycleManager.game_speed = 5.0  # Reset to normal speed
	
	DayAndNightCycleManager.game_time.emit(DayAndNightCycleManager.time)
	DayAndNightCycleManager.recalculate_time()
	InventoryManager.reset_inventory()
	QuestManager.reset_quests()
	StatisticsManager.reset_statistics()
	StatisticsManager.update_ui_after_reset()
	DungeonRunManager.reset_data()

func _on_unstuck_button_pressed() -> void:  # Fixed method name with underscores
	# Create a flag or signal to indicate respawn is needed
	if GameManager.has_method("set_respawn_needed"):
		GameManager.set_respawn_needed(true)
	queue_free()
	GameManager.game_menu_open = false  # Reset the menu state flag
