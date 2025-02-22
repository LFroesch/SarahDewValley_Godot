extends CanvasLayer

@onready var save_game_button: Button = $MarginContainer/VBoxContainer/SaveGameButton
@onready var confirmation_dialog: ConfirmationDialog = $ConfirmationDialog

func _ready() -> void:
	save_game_button.disabled = !SaveGameManager.allow_save_game
	save_game_button.focus_mode = SaveGameManager.allow_save_game if Control.FOCUS_ALL else Control.FOCUS_NONE
	
	confirmation_dialog.dialog_text = "Are you sure you want to delete your save file? You will restart the game. This action cannot be undone."
	confirmation_dialog.get_ok_button().text = "Delete"
	confirmation_dialog.get_cancel_button().text = "Cancel"
	
func _on_start_game_button_pressed() -> void:
	GameManager.start_game()
	queue_free()

func _on_save_game_button_pressed() -> void:
	SaveGameManager.save_game()

func _on_exit_game_button_pressed() -> void:
	GameManager.exit_game()

func _on_update_game_button_pressed() -> void:
	OS.shell_open("https://lfroesch.itch.io/sdv")

func _on_delete_save_button_pressed() -> void:
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
