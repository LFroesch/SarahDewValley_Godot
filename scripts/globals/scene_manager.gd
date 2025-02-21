extends Node

var main_scene_path: String = "res://scenes/main_scene.tscn"
var main_scene_root_path: String = "/root/MainScene"
var main_scene_level_root_path: String = "/root/MainScene/GameRoot/LevelRoot"

var current_level: String = ""
var previous_level: String = ""
var last_position: Vector2 = Vector2.ZERO

var level_scenes : Dictionary = {
	"Level1" : "res://scenes/levels/level_1.tscn",
	"Level2" : "res://scenes/levels/level_2.tscn", #Dummy Level atm
	"city_test" : "res://scenes/levels/city_test.tscn" #Test for City Level
}

var level_transitions : Dictionary = {
	"Level1": {
		"to_city": {
			"target_level": "city_test",
			"entry_point": Vector2(840, 650)  # Where to spawn in city_test
		}
	},
	"city_test": {
		"to_main": {
			"target_level": "Level1",
			"entry_point": Vector2(760, 650)  # Where to spawn back in Level1
		}
	}
}

func load_main_scene_container() -> void:
	if get_tree().root.has_node(main_scene_root_path):
		return
	var node: Node = load(main_scene_path).instantiate()
	if node != null:
		get_tree().root.add_child(node)
		
func load_level(level: String, spawn_position: Vector2 = Vector2.ZERO) -> void:
	previous_level = current_level
	current_level = level
	last_position = spawn_position
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
		await get_tree().process_frame
		var player = get_tree().get_first_node_in_group("player")
		if player and spawn_position != Vector2.ZERO:
			player.global_position = spawn_position

# Save current level state to config file
func save_level_state() -> void:
	var config = ConfigFile.new()
	var player = get_tree().get_first_node_in_group("player")
	var position = Vector2.ZERO
	if player:
		position = player.global_position
	config.set_value("game", "current_level", current_level)
	config.set_value("game", "player_position", {
		"x": position.x,
		"y": position.y
	})
	config.save("user://game_data/game_state.cfg")
	
# Load level state from config file
func load_level_state() -> Dictionary:
	var config = ConfigFile.new()
	var err = config.load("user://game_data/game_state.cfg")
	if err == OK:
		var pos_dict = config.get_value("game", "player_position", {"x": 0, "y": 0})
		return {
			"level": config.get_value("game", "current_level", "Level1"),
			"position": Vector2(pos_dict.x, pos_dict.y)
		}
	return {
		"level": "Level1",
		"position": Vector2.ZERO
	}
