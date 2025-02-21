extends Node

var main_scene_path: String = "res://scenes/main_scene.tscn"
var main_scene_root_path: String = "/root/MainScene"
var main_scene_level_root_path: String = "/root/MainScene/GameRoot/LevelRoot"

var current_level: String = ""
var previous_level: String = ""

var level_scenes : Dictionary = {
	"Level1" : "res://scenes/levels/level_1.tscn",
	"Level2" : "res://scenes/levels/level_2.tscn"
}

func load_main_scene_container() -> void:
	if get_tree().root.has_node(main_scene_root_path):
		return
	var node: Node = load(main_scene_path).instantiate()
	if node != null:
		get_tree().root.add_child(node)
		
func load_level(level: String) -> void:
	current_level = level
	var scene_path: String = level_scenes.get(level)
	if scene_path == null:
		return
	var level_scene: Node = load(scene_path).instantiate()
	var level_root: Node = get_node(main_scene_level_root_path)
	if level_root != null:
		var nodes = level_root.get_children()
		if nodes != null:
			for node: Node in nodes:
				node.queue_free()
		await get_tree().process_frame
		level_root.add_child(level_scene)

# Save current level state to config file
func save_level_state() -> void:
	var config = ConfigFile.new()
	config.set_value("game", "current_level", current_level)
	config.save("user://game_data/game_state.cfg")

# Load level state from config file
func load_level_state() -> String:
	var config = ConfigFile.new()
	var err = config.load("user://game_data/game_state.cfg")
	if err == OK:
		return config.get_value("game", "current_level", "Level1")
	return "Level1"  # Default to Level1 if no save exists
