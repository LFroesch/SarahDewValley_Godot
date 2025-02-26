extends Node

signal quest_started(quest_id: String)
signal quest_updated(quest_id: String, progress: float)
signal quest_objectives_completed(quest_id: String)
signal quest_completed(quest_id: String)

var current_quest: String = ""
var completed_quests: Array = []
var active_quests: Dictionary = {}
var ready_for_turnin_quests: Array = []
var save_data_path: String = "user://game_data/quest_data.tres"

var quest_kill_counts: Dictionary = {}
var quest_completion_counts: Dictionary = {}

var quests: Dictionary = {
	"banesword": {
		"title": "The Giant Skeleton",
		"description": "Defeat Banesword the giant skeleton south of town.",
		"objectives": {
			"kill_enemy": {
				"enemy_type": "skeleton_chief",
				"count": 1,
				"current": 0
			}
		},
		"rewards": {
			"experience": 200,
			"gold": 50
		},
		"requires_turnin": true,
		"repeatable": true
	},
	"goblin_encroachment": {
		"title": "Goblin Encroachment",
		"description": "Defeat 20 goblins in the world or the sewers.",
		"objectives": {
			"kill_enemy": {
				"enemy_type": "goblin_barbarian",
				"count": 20,
				"current": 0
			}
		},
		"rewards": {
			"experience": 200,
			"gold": 50
		},
		"requires_turnin": true,
		"repeatable": true
	},
	"skeleton_encroachment": {
		"title": "Skeleton Encroachment",
		"description": "Defeat 20 skeletons in the world or the sewers.",
		"objectives": {
			"kill_enemy": {
				"enemy_type": "skeleton_warrior",
				"count": 20,
				"current": 0
			}
		},
		"rewards": {
			"experience": 200,
			"gold": 50
		},
		"requires_turnin": true,
		"repeatable": true
	},
	"talk_to_steve": {
		"title": "Talk to Steve",
		"description": "Go to Brady Town and talk to Steve.",
		"objectives": {
			"talk_to": {
				"target": "steve"
			}
		},
		"rewards": {
			"experience": 100,
			"gold": 10
		},
		"requires_turnin": true,
		"repeatable": false
	}
	# Add more quests as needed
}

func _ready() -> void:
	StatisticsManager.stat_updated.connect(on_stat_updated)
	load_quest_data()

func start_quest(quest_id: String) -> void:
	if not quests.has(quest_id):
		printerr("Attempted to start nonexistent quest: ", quest_id)
		return
	
	if completed_quests.has(quest_id):
		var quest = quests[quest_id]
		
		if not quest.has("repeatable") or not quest.repeatable:
			print("Quest already completed and not repeatable: ", quest_id)
			return
	
	if ready_for_turnin_quests.has(quest_id):
		print("Quest ready for turnin: ", quest_id)
		return
	
	if completed_quests.has(quest_id):
		completed_quests.erase(quest_id)
	
	current_quest = quest_id
	active_quests[quest_id] = quests[quest_id].duplicate(true)
	
	quest_kill_counts[quest_id] = {}
	
	for objective_key in active_quests[quest_id].objectives:
		var objective = active_quests[quest_id].objectives[objective_key]
		if objective_key == "kill_enemy":
			var enemy_type = objective.enemy_type
			quest_kill_counts[quest_id][enemy_type] = 0
			objective.current = 0
	
	print("Started quest: ", quests[quest_id].title)
	quest_started.emit(quest_id)
	save_quest_data()

func on_stat_updated(stat_name: String, new_value: int) -> void:
	if stat_name == "kills":
		pass

func record_quest_kill(enemy_type: String) -> void:
	for quest_id in active_quests:
		var quest = active_quests[quest_id]
		for objective_key in quest.objectives:
			var objective = quest.objectives[objective_key]
			if objective_key == "kill_enemy" and objective.enemy_type == enemy_type:
				if not quest_kill_counts.has(quest_id):
					quest_kill_counts[quest_id] = {}
				if not quest_kill_counts[quest_id].has(enemy_type):
					quest_kill_counts[quest_id][enemy_type] = 0
				
				quest_kill_counts[quest_id][enemy_type] += 1
				objective.current = quest_kill_counts[quest_id][enemy_type]
				
				print("Quest kill recorded: %s for quest %s, count: %d/%d" % 
					  [enemy_type, quest_id, objective.current, objective.count])
				
				var progress = float(objective.current) / float(objective.count)
				quest_updated.emit(quest_id, progress)
				
				check_quest_objectives(quest_id)
	
	save_quest_data()

func check_quest_objectives(quest_id: String) -> void:
	if not active_quests.has(quest_id):
		return
		
	var quest = active_quests[quest_id]
	var all_complete = true
	
	for objective_key in quest.objectives:
		var objective = quest.objectives[objective_key]
		if objective.current < objective.count:
			all_complete = false
			break
	
	if all_complete:
		mark_quest_ready_for_turnin(quest_id)

func mark_quest_ready_for_turnin(quest_id: String) -> void:
	if not active_quests.has(quest_id):
		return
		
	var quest = active_quests[quest_id]
	
	if not quest.has("requires_turnin") or not quest.requires_turnin:
		complete_quest(quest_id)
		return
	
	if not ready_for_turnin_quests.has(quest_id):
		ready_for_turnin_quests.append(quest_id)
		print("Quest objectives completed: ", quest.title)
		quest_objectives_completed.emit(quest_id)
		save_quest_data()

func complete_quest(quest_id: String) -> void:
	if not (active_quests.has(quest_id) or ready_for_turnin_quests.has(quest_id)):
		return
	
	var quest = active_quests.get(quest_id, quests.get(quest_id))
	
	if not quest_completion_counts.has(quest_id):
		quest_completion_counts[quest_id] = 0
	quest_completion_counts[quest_id] += 1
	
	# Track completion time for cooldown calculation
	if quest.has("repeatable") and quest.repeatable:
		# Example: Store current game day/time when completed
		# quest_last_completion[quest_id] = DayAndNightCycleManager.get_current_day()
		pass
	
	if quest.rewards.has("experience"):
		var xp_reward = quest.rewards.experience
		StatisticsManager.add_experience(xp_reward)
	
	if quest.rewards.has("gold"):
		var gold_amount = quest.rewards.gold
		for i in gold_amount:
			InventoryManager.add_collectible("coin")
	
	active_quests.erase(quest_id)
	if ready_for_turnin_quests.has(quest_id):
		ready_for_turnin_quests.erase(quest_id)
	
	quest_kill_counts.erase(quest_id)
	completed_quests.append(quest_id)
	active_quests.erase(quest_id)
	
	if ready_for_turnin_quests.has(quest_id):
		ready_for_turnin_quests.erase(quest_id)

	if not completed_quests.has(quest_id):
		completed_quests.append(quest_id)

	if current_quest == quest_id:
		current_quest = ""

	quest_kill_counts.erase(quest_id)
	
	print("Completed quest: ", quest.title)
	quest_completed.emit(quest_id)
	save_quest_data()

	var quest_panels = get_tree().get_nodes_in_group("quest_panels")
	for panel in quest_panels:
		if panel.visible and panel.has_method("update_quest_display"):
			panel.update_quest_display()

func is_quest_active(quest_id: String) -> bool:
	return active_quests.has(quest_id)

func is_quest_ready_for_turnin(quest_id: String) -> bool:
	return ready_for_turnin_quests.has(quest_id)

func is_quest_completed(quest_id: String) -> bool:
	return completed_quests.has(quest_id)

func can_repeat_quest(quest_id: String) -> bool:
	if not quests.has(quest_id):
		return false
	
	var quest = quests[quest_id]
	
	if not quest.has("repeatable") or not quest.repeatable:
		return false

	if active_quests.has(quest_id) or ready_for_turnin_quests.has(quest_id):
		return false

	if quest.has("repeat_cooldown") and quest.repeat_cooldown > 0:
		# Implement cooldown check here with your game's time system
		pass
	
	return true

func get_quest_progress(quest_id: String) -> float:
	if is_quest_ready_for_turnin(quest_id):
		return 1.0
		
	if not active_quests.has(quest_id):
		return 0.0
		
	var quest = active_quests[quest_id]
	var total_objectives = quest.objectives.size()
	var completed_objectives = 0
	
	for objective_key in quest.objectives:
		var objective = quest.objectives[objective_key]
		var progress = float(objective.current) / float(objective.count)
		completed_objectives += progress
	
	return completed_objectives / total_objectives

func save_quest_data() -> void:
	var save_resource = Resource.new()
	var save_data = {
		"current_quest": current_quest,
		"completed_quests": completed_quests,
		"active_quests": active_quests,
		"ready_for_turnin_quests": ready_for_turnin_quests,
		"quest_kill_counts": quest_kill_counts,
		"quest_completion_counts": quest_completion_counts
	}
	
	save_resource.set_meta("quest_data", save_data)
	
	# Ensure directory exists
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("game_data"):
		dir.make_dir("game_data")
	
	var result = ResourceSaver.save(save_resource, save_data_path)
	if result != OK:
		printerr("Failed to save quest data. Error code: ", result)

func load_quest_data() -> void:
	if not FileAccess.file_exists(save_data_path):
		print("No quest save data found. Starting freshsh.")
		return
	
	var save_resource = ResourceLoader.load(save_data_path)
	if save_resource and save_resource.has_meta("quest_data"):
		var data = save_resource.get_meta("quest_data")
		
		if data.has("current_quest"):
			current_quest = data.current_quest
		
		if data.has("completed_quests"):
			completed_quests = data.completed_quests
		
		if data.has("active_quests"):
			active_quests = data.active_quests
			
		if data.has("ready_for_turnin_quests"):
			ready_for_turnin_quests = data.ready_for_turnin_quests
			
		if data.has("quest_kill_counts"):
			quest_kill_counts = data.quest_kill_counts
		
		if data.has("quest_completion_counts"):
			quest_completion_counts = data.quest_completion_counts
			
		print("Quest data loaded successfully")
	else:
		printerr("Failed to load quest data: Invalid or corrupted save file")

func reset_quests() -> void:
	current_quest = ""
	completed_quests = []
	active_quests = {}
	ready_for_turnin_quests = []
	quest_kill_counts = {}
	quest_completion_counts = {}
	
	print("All quest data has been reset")
	
	# Delete the save file if it exists
	if FileAccess.file_exists(save_data_path):
		var dir = DirAccess.open("user://")
		var err = dir.remove(save_data_path)
		if err != OK:
			printerr("Failed to delete quest save file. Error: ", err)
		else:
			print("Quest save file deleted successfully")
