#tool_manager.gd
extends Node

var selected_tool: DataTypes.Tools = DataTypes.Tools.None
var enabled_tools: Array[DataTypes.Tools] = [] 

signal tool_selected(tool: DataTypes.Tools)
signal enable_tool(tool : DataTypes.Tools)

const save_data_path = "user://game_data/tools.tres"

func select_tool(tool: DataTypes.Tools) -> void:
	tool_selected.emit(tool)
	selected_tool = tool
	
func enable_tool_button(tool : DataTypes.Tools) -> void:
	if not enabled_tools.has(tool):
		enabled_tools.append(tool)
	enable_tool.emit(tool)

func save_tools() -> void:
	var save_data = ToolSaveData.new()
	save_data.enabled_tools = enabled_tools
	var result = ResourceSaver.save(save_data, save_data_path)
	print("Tools save result: ", result)

func load_tools() -> void:
	if not FileAccess.file_exists(save_data_path):
		return
	var save_data = ResourceLoader.load(save_data_path)
	if save_data:
		enabled_tools = save_data.enabled_tools
		for tool in enabled_tools:
			enable_tool.emit(tool)
			
func has_farming_tools() -> bool:
	return enabled_tools.has(DataTypes.Tools.TillGround) and enabled_tools.has(DataTypes.Tools.WaterCrops)
