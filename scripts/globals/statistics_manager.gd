extends Node

signal experience_gained(amount: int)
signal level_up(new_level: int)
signal stat_updated(stat_name: String, new_value: int)

var level_display_names: Dictionary = {
	"Level1": "Starter Islands",
	"Level2": "How tf did u get here",
	"brady_city": "Brady Town",
	"the_sewers": "The Sewers",
	"the_sewers_floor_1": "Sewers Floor 1"
}

var stats: Dictionary = {
	"kills": {
		"total": 0,
		"by_enemy_type": {}
	},
	"experience": {
		"current": 0,
		"total_gained": 0,
		"level": 1
	}
}

var save_data_path: String = "user://game_data/statistics_data.tres"
var xp_to_next_level: Dictionary = {
	1: 100,
	2: 250,
	3: 450,
	4: 700,
	5: 1000,
}

func _ready() -> void:
	load_statistics()

func get_level_name(level_id: String) -> String:
	return level_display_names.get(level_id, level_id)

func record_kill(enemy_type: String) -> void:
	stats.kills.total += 1
	if not stats.kills.by_enemy_type.has(enemy_type):
		stats.kills.by_enemy_type[enemy_type] = 0
	stats.kills.by_enemy_type[enemy_type] += 1
	stat_updated.emit("kills", stats.kills.total)
	save_statistics()

func add_experience(amount: int) -> void:
	stats.experience.current += amount
	stats.experience.total_gained += amount
	experience_gained.emit(amount)
	var current_level = stats.experience.level
	if xp_to_next_level.has(current_level):
		while stats.experience.current >= xp_to_next_level[current_level]:
			level_up_character()
	
	save_statistics()

func level_up_character() -> void:
	stats.experience.level += 1
	stats.experience.current -= xp_to_next_level[stats.experience.level - 1]
	level_up.emit(stats.experience.level)

func get_kill_count(enemy_type: String = "") -> int:
	if enemy_type.is_empty():
		return stats.kills.total
	return stats.kills.by_enemy_type.get(enemy_type, 0)

func get_current_level() -> int:
	return stats.experience.level

func get_current_xp() -> int:
	return stats.experience.current

func get_xp_for_next_level() -> int:
	return xp_to_next_level.get(stats.experience.level, 999999)

func save_statistics() -> void:
	var save_resource = Resource.new()
	save_resource.set_meta("statistics_data", stats)
	var result = ResourceSaver.save(save_resource, save_data_path)

func load_statistics() -> void:
	if not FileAccess.file_exists(save_data_path):
		return
		
	var save_resource = ResourceLoader.load(save_data_path)
	if save_resource and save_resource.has_meta("statistics_data"):
		stats = save_resource.get_meta("statistics_data")
		stat_updated.emit("kills", stats.kills.total)

func reset_statistics() -> void:
	stats = {
		"kills": {
			"total": 0,
			"by_enemy_type": {}
		},
		"experience": {
			"current": 0,
			"total_gained": 0,
			"level": 1
		}
	}
	save_statistics()
