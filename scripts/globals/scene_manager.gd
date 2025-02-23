extends Node

var main_scene_path: String = "res://scenes/main_scene.tscn"
var main_scene_root_path: String = "/root/MainScene"
var main_scene_level_root_path: String = "/root/MainScene/GameRoot/LevelRoot"

var current_level: String = ""
var previous_level: String = ""
var last_position: Vector2 = Vector2.ZERO

var level_scenes : Dictionary = {
	"Level1" : "res://scenes/levels/level_1.tscn",
	"Level2" : "res://scenes/levels/level_2.tscn",
	"brady_city" : "res://scenes/levels/brady_city.tscn",
	"the_sewers" : "res://scenes/levels/the_sewers.tscn",
	"the_sewers_floor_1" : "res://scenes/levels/sewers_floor_1.tscn"
}

var level_transitions : Dictionary = {
	"Level1": {
		"to_brady_city": {
			"target_level": "brady_city",
			"entry_point": Vector2(840, 652)
		},
		"to_center_island": {
			"target_level": "Level1",
			"entry_point": Vector2(650, 500)
		},
		"to_starter_island": {
			"target_level": "Level1",
			"entry_point": Vector2(375, 250)
		}
	},
	"brady_city": {
		"to_starter_zone": {
			"target_level": "Level1",
			"entry_point": Vector2(760, 652)
		},
		"to_sewers": {
			"target_level": "the_sewers",
			"entry_point": Vector2(940, 875)
		}
	},
	"the_sewers": {
		"to_city": {
			"target_level": "brady_city",
			"entry_point": Vector2(1000, 750)
		},
		"to_floor_1": {
			"target_level": "the_sewers_floor_1",
			"entry_point": Vector2(865, 740)
		},
	},
	"the_sewers_floor_1": {
		"to_sewers": {
			"target_level": "the_sewers",
			"entry_point": Vector2(940, 875)
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
	
func load_level_state() -> Dictionary:
	var config = ConfigFile.new()
	var err = config.load("user://game_data/game_state.cfg")
	
	if err != OK:
		current_level = "Level1"
		last_position = Vector2.ZERO
		return {
			"level": "Level1",
			"position": Vector2(250, 250)
		}
	var pos_dict = config.get_value("game", "player_position", {"x": 0, "y": 0})
	var saved_level = config.get_value("game", "current_level", "Level1")
	
	if not level_scenes.has(saved_level):
		saved_level = "Level1"
		pos_dict = {"x": 700, "y": 600}
		
	return {
		"level": saved_level,
		"position": Vector2(pos_dict.x, pos_dict.y)
	}
