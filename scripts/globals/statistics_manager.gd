extends Node

signal experience_gained(amount: int)
signal level_up(new_level: int)
signal stat_updated(stat_name: String, new_value: int)
signal talent_point_added(amount: int)
signal talent_spent(talent_name: String, level: int)
signal talents_reset()

var save_data_path: String = "user://game_data/statistics_data.tres"

var level_display_names: Dictionary = {
	"Level1": "Starter Islands",
	"Level2": "How tf did u get here",
	"brady_city": "Brady Town",
	"brady_city_mayor_house" : "Brady Town Mayor House",
	"the_sewers": "The Sewers",
	"the_sewers_floor_1": "Sewers Floor 1",
	"the_sewers_floor_2": "Sewers Floor 2",
	"the_sewers_floor_3": "Sewers Floor 3",
	"the_sewers_floor_4": "Sewers Floor 4",
	"the_sewers_floor_5": "Sewers Floor 5"
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
	},
	"talents": {
		"available_points": 0,
		"total_points_earned": 0,
		"health": 0,
		"speed": 0,
		"fireball": 0,
		"fire_nova": 0,
		"heal": 0,
		"melee": 0
	}
}

var xp_to_next_level: Dictionary = {
	1: 100,
	2: 200,
	3: 300,
	4: 400,
	5: 500,
	6: 600,
	7: 700,
	8: 800,
	9: 900,
	10: 1000,
	11: 1100,
	12: 1200,
	13: 1300,
	14: 1400,
	15: 1500,
	16: 1600,
	17: 1700,
	18: 1800,
	19: 1900,
	20: 2000,
	21: 2100,
	22: 2200,
	23: 2300,
	24: 2400,
	25: 2500,
	26: 2600,
	27: 2700,
	28: 2800,
	29: 2900,
	30: 3000,
	31: 3100,
	32: 3200,
	33: 3300,
	34: 3400,
	35: 3500,
	36: 3600,
	37: 3700,
	38: 3800,
	39: 3900,
	40: 4000,
	41: 4100,
	42: 4200,
	43: 4300,
	44: 4400,
	45: 4500,
	46: 4600,
	47: 4700,
	48: 4800,
	49: 4900,
	50: 5000
	
}

func _ready() -> void:
	load_statistics()
	initialize_talent_data()

func get_level_name(level_id: String) -> String:
	return level_display_names.get(level_id, level_id)

func record_kill(enemy_type: String) -> void:
	stats.kills.total += 1
	if not stats.kills.by_enemy_type.has(enemy_type):
		stats.kills.by_enemy_type[enemy_type] = 0
	stats.kills.by_enemy_type[enemy_type] += 1
	stat_updated.emit("kills", stats.kills.total)
	if QuestManager:
		QuestManager.record_quest_kill(enemy_type)
	save_statistics()

func buy_experience() -> void:
	if InventoryManager.inventory.has("coin") and InventoryManager.inventory["coin"] >= 100:
		add_experience(1000)
		for i in range(100):
			InventoryManager.remove_collectible("coin")

func add_experience(amount: int) -> void:
	stats.experience.current += amount
	stats.experience.total_gained += amount
	experience_gained.emit(amount)
	HitSplatManager.spawn_xp_number(amount)
	
	# Check for level ups
	while true:
		var current_level = stats.experience.level
		var xp_needed = xp_to_next_level.get(current_level, 999999)
		
		if stats.experience.current >= xp_needed:
			# Level up
			stats.experience.current -= xp_needed
			stats.experience.level += 1
			level_up.emit(stats.experience.level)
			experience_gained.emit(0)
			# Award a talent point on level up
			add_talent_points(1)
		else:
			# No more level ups to process
			break
	
	save_statistics()

func level_up_character() -> void:
	stats.experience.level += 1
	stats.experience.current -= xp_to_next_level[stats.experience.level - 1]
	level_up.emit(stats.experience.level)
	add_talent_points(1)

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
		},
		"talents": {
			"available_points": 0,
			"total_points_earned": 0,
			"health": 0,
			"speed": 0,
			"fireball": 0,
			"fire_nova": 0,
			"heal": 0,
			"melee": 0
		}
	}
	save_statistics()
	talents_reset.emit()
	
func update_ui_after_reset() -> void:
	# Find all stats panels and update them
	var stats_panels = get_tree().get_nodes_in_group("stats_panels")
	for panel in stats_panels:
		if panel.has_method("update_stats"):
			panel.update_stats()

# ------ Talent System Functions ------

# Add talent points (e.g., on level up)
func add_talent_points(amount: int) -> void:
	if not stats.has("talents"):
		initialize_talent_data()
	
	stats.talents.available_points += amount
	stats.talents.total_points_earned += amount
	save_statistics()
	talent_point_added.emit(amount)

# Initialize talent data structure if it doesn't exist
func initialize_talent_data() -> void:
	if not stats.has("talents"):
		stats.talents = {
			"available_points": 0,
			"total_points_earned": 0,
			"health": 0,
			"speed": 0,
			"fireball": 0,
			"fire_nova": 0,
			"heal": 0,
			"melee": 0
		}
		save_statistics()

# Get available talent points
func get_available_talent_points() -> int:
	if not stats.has("talents"):
		initialize_talent_data()
	return stats.talents.available_points

# Get the level of a specific talent
func get_talent_level(talent_name: String) -> int:
	if not stats.has("talents"):
		initialize_talent_data()
	if not stats.talents.has(talent_name):
		return 0
	return stats.talents[talent_name]

# Update talent level (when spending points)
func update_talent(talent_name: String, level: int) -> void:
	if not stats.has("talents"):
		initialize_talent_data()
	
	var old_level = stats.talents.get(talent_name, 0)
	stats.talents[talent_name] = level
	
	# Deduct a talent point
	if level > old_level:
		stats.talents.available_points -= 1
	
	save_statistics()
	talent_spent.emit(talent_name, level)

# Reset all talents
func reset_talents() -> void:
	if not stats.has("talents"):
		initialize_talent_data()
		
	# Calculate total spent points
	var spent_points = 0
	for key in stats.talents.keys():
		if key != "available_points" and key != "total_points_earned":
			spent_points += stats.talents[key]
			stats.talents[key] = 0
	
	# Return spent points to available pool
	stats.talents.available_points += spent_points
	
	save_statistics()
	talents_reset.emit()
