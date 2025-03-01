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
	#(Tutorial) First Kill Quest Skeleton Chief
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
			"experience": 500,
			"gold": 50
		},
		"requires_turnin": true,
		"repeatable": true
	}, #Goblin Chief Kill Quest
	"ruknash_the_terrible": {
		"title": "Ruknash the Terrible",
		"description": "Defeat Ruknash the Terrible, north east of town.",
		"objectives": {
			"kill_enemy": {
				"enemy_type": "goblin_chief",
				"count": 1,
				"current": 0
			}
		},
		"rewards": {
			"experience": 500,
			"gold": 50
		},
		"requires_turnin": true,
		"repeatable": true
	}, #Goblin Kill Quest
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
			"experience": 500,
			"gold": 50
		},
		"requires_turnin": true,
		"repeatable": true
	}, #Skeleton Kill Quest
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
			"experience": 500,
			"gold": 50
		},
		"requires_turnin": true,
		"repeatable": true
	}, #(Tutorial) Talk to Steve
	"my_friend_in_town": {
		"title": "My Friend In Town",
		"description": "Go to Brady Town and talk to my friend by the fountain.",
		"objectives": {
			"talk_to": {
				"target": "steve"
			}
		},
		"rewards": {
			"experience": 200,
			"gold": 10
		},
		"turnin_npc": "steve",
		"requires_turnin": true,
		"repeatable": false
	}, #(Tutorial) Talk to Farmer Dave
	"farmer_dave": {
		"title": "Farmer Dave",
		"description": "Go southeast and find Farmer Dave.",
		"objectives": {
			"talk_to": {
				"target": "farmer_dave"
			}
		},
		"rewards": {
			"experience": 200,
			"gold": 10
		},
		"turnin_npc": "farmer_dave",
		"requires_turnin": true,
		"repeatable": false
	}, #(Tutorial) Talk to Larry
	"talk_to_larry": {
		"title": "Talk to Larry",
		"description": "Go to the middle island and find Larry, he's southeast from spawn.",
		"objectives": {
			"talk_to": {
				"target": "larry"
			}
		},
		"rewards": {
			"experience": 200,
			"gold": 10
		},
		"turnin_npc": "larry",
		"requires_turnin": true,
		"repeatable": false
	}, #First Sewer Quest
	"talk_to_sam_level_5": {
		"title": "Talk to Sewer Sam",
		"description": "Find your way to level 5 in the sewers and talk to Sewer Sam.",
		"objectives": {
			"talk_to": {
				"target": "sam"
			}
		},
		"rewards": {
			"experience": 1000,
			"gold": 100
		},
		"turnin_npc": "sam",
		"requires_turnin": true,
		"repeatable": true
	}, #HarvestCorn
		"harvest_corn": {
		"title": "Corn Harvest",
		"description": "Plant and Harvest 10 corn.",
		"objectives": {
			"collect_item": {
				"item_type": "corn",
				"count": 10,
				"current": 0
			}
		},
		"rewards": {
			"experience": 300,
			"gold": 50,
			"items": [
				{"item_id": "healing_potion", "count": 2}
			]
		},
		"requires_turnin": true,
		"repeatable": true
	}, #HarvestTomato
		"harvest_tomato": {
		"title": "Tomato Harvest",
		"description": "Plant and Harvest 10 tomato.",
		"objectives": {
			"collect_item": {
				"item_type": "tomato",
				"count": 10,
				"current": 0
			}
		},
		"rewards": {
			"experience": 300,
			"gold": 50,
			"items": [
				{"item_id": "healing_potion", "count": 2}
			]
		},
		"requires_turnin": true,
		"repeatable": true
	}
	# Add more quests as needed
}

func _ready() -> void:
	StatisticsManager.stat_updated.connect(on_stat_updated)
	load_quest_data()

func start_quest(quest_id: String) -> void:
	if not quests.has(quest_id):
		return
	
	if completed_quests.has(quest_id):
		var quest = quests[quest_id]
		
		if not quest.has("repeatable") or not quest.repeatable:
			return
	
	if ready_for_turnin_quests.has(quest_id):
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
				
				var progress = float(objective.current) / float(objective.count)
				quest_updated.emit(quest_id, progress)
				
				check_quest_objectives(quest_id)
	
	save_quest_data()
	
func record_item_collection(item_type: String, quantity: int = 1) -> void:
	for quest_id in active_quests:
		var quest = active_quests[quest_id]
		for objective_key in quest.objectives:
			var objective = quest.objectives[objective_key]
			if objective_key == "collect_item" and objective.item_type == item_type:
				objective.current += quantity
				print("Item collected: %s for quest %s, count: %d/%d" % 
					  [item_type, quest_id, objective.current, objective.count])
				var progress = float(objective.current) / float(objective.count)
				quest_updated.emit(quest_id, progress)
				check_quest_objectives(quest_id)
	
	save_quest_data()

func record_npc_interaction(npc_id: String) -> void:
	for quest_id in active_quests:
		var quest = active_quests[quest_id]
		for objective_key in quest.objectives:
			var objective = quest.objectives[objective_key]
			if objective_key == "talk_to" and objective.target == npc_id:
				print("Talked to NPC: %s for quest %s" % [npc_id, quest_id])
				quest_updated.emit(quest_id, 1.0)
				mark_quest_ready_for_turnin(quest_id)
	
	save_quest_data()

func check_quest_objectives(quest_id: String) -> void:
	if not active_quests.has(quest_id):
		return
	var quest = active_quests[quest_id]
	var all_complete = true
	for objective_key in quest.objectives:
		var objective = quest.objectives[objective_key]
		if objective_key == "kill_enemy" and objective.current < objective.count:
			all_complete = false
			break
		elif objective_key == "collect_item" and objective.current < objective.count:
			all_complete = false
			break
		elif objective_key == "talk_to":
			pass
	
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
		quest_objectives_completed.emit(quest_id)
		save_quest_data()

func complete_quest(quest_id: String) -> void:
	if not (active_quests.has(quest_id) or ready_for_turnin_quests.has(quest_id)):
		return
	
	var quest = active_quests.get(quest_id, quests.get(quest_id))
	
	for objective_key in quest.objectives:
		var objective = quest.objectives[objective_key]
		if objective_key == "collect_item":
			var item_type = objective.item_type
			var count_to_remove = objective.count
			
			for i in count_to_remove:
				InventoryManager.remove_collectible(item_type)
	
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
			
	if quest.rewards.has("items"):
		for item_data in quest.rewards.items:
			for i in item_data.count:
				InventoryManager.add_collectible(item_data.item_id)
				
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
	# You can still keep this method for other parts of your code
	# that might need a simple progress percentage
	
	if is_quest_ready_for_turnin(quest_id):
		return 1.0
		
	if not active_quests.has(quest_id):
		return 0.0
		
	var quest = active_quests[quest_id]
	var total_objectives = 0
	var completed_objective_points = 0.0
	
	for objective_key in quest.objectives:
		var objective = quest.objectives[objective_key]
		total_objectives += 1
		
		if objective_key == "talk_to":
			# Talk quests are binary - either complete or not
			completed_objective_points += 0  # Not complete by default
			
		elif objective.has("current") and objective.has("count"):
			var progress = float(objective.current) / float(objective.count)
			completed_objective_points += progress
		
	if total_objectives > 0:
		return completed_objective_points / total_objectives
	return 0.0

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
	
	# Delete the save file if it exists
	if FileAccess.file_exists(save_data_path):
		var dir = DirAccess.open("user://")
		var err = dir.remove(save_data_path)
		if err != OK:
			printerr("Failed to delete quest save file. Error: ", err)
		else:
			print("Quest save file deleted successfully")
