extends Node

var allow_save_game: bool

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("save_game"):
		save_game()

func save_game() -> void:
	if not allow_save_game:
		return
		
	DayAndNightCycleManager.save_time_state()
	InventoryManager.save_inventory()
	ToolManager.save_tools()
	SceneManager.save_level_state()
	
	var save_level_data_component: SaveLevelDataComponent = get_tree().get_first_node_in_group("save_level_data_component")
	if save_level_data_component != null:
		save_level_data_component.save_game()
		
func load_game() -> void:
	await get_tree().process_frame 
	
	DayAndNightCycleManager.load_time_state()
	InventoryManager.load_inventory()
	ToolManager.load_tools() 
	var save_level_data_component: SaveLevelDataComponent = get_tree().get_first_node_in_group("save_level_data_component")
	
	if save_level_data_component != null:
		save_level_data_component.load_game()
