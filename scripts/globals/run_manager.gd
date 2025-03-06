extends Node

signal run_started
signal run_ended(stats: Dictionary)
signal run_metrics_updated
signal run_status_check(can_complete: bool, reason: String)

# Run state
var is_run_active: bool = false
var run_start_time: int = 0
var current_sewer_level: int = 0

# Tracked metrics
var run_stats: Dictionary = {
	"time_elapsed": 0,       # In seconds
	"kills": {
		"total": 0,
		"by_enemy_type": {},
	},
	"damage_dealt": 0,
	"damage_taken": 0,
	"coins_collected": 0,
	"highest_level_reached": 0,
	"deaths": 0,
	"potions_used": 0,
	"boss_kills": 0
}

# Historical best stats
var historical_best_stats: Dictionary = {
	"best_score": 0,
	"best_time": 999999,     # Starting with high value
	"most_kills": 0,
	"most_damage_dealt": 0,
	"least_damage_taken": 999999,  # Starting with high value
	"most_coins_collected": 0,
	"highest_healing_done": 0,
	"fastest_completion": 999999,  # In seconds, starting with high value
	"highest_reward_tier": "",
	"best_run_date": 0,      # Unix timestamp
	"runs_completed": 0,
	"completion_rate": 0.0   # Percentage
}

# Temporary storage for completion dialogue
var temp_final_score: int = 0
var temp_rewards_tier: String = ""
var temp_rewards_coins: int = 0 
var temp_rewards_exp: int = 0

# Scoring weights (used for calculating final run score)
const SCORE_WEIGHTS = {
	"time_modifier": 0.8,     # Lower time is better (score multiplier decreases over time)
	"kills": 10,              # Points per kill
	"boss_kills": 100,        # Points per boss kill
	"damage_dealt": 0.5,      # Points per damage dealt
	"damage_taken": -0.8,     # Negative points per damage taken
	"highest_level": 100,     # Points per sewer level reached (1-4)
	"deaths": -50,            # Negative points per death
	"healing_done": 1
}

# Reward thresholds - used to determine rewards based on final score
const REWARD_THRESHOLDS = {
	"bronze": 250,
	"silver": 500,
	"gold": 750,
	"platinum": 1000
}

# Save data path
const SAVE_DATA_PATH = "user://game_data/run_data.tres"
const HISTORICAL_DATA_PATH = "user://game_data/historical_run_data.tres"

# Total runs attempted/completed for statistics
var total_runs_attempted: int = 0
var total_runs_completed: int = 0

func _ready() -> void:
	load_run_data()
	load_historical_data()
	update_formatted_stats()
	
	# Connect to required signals
	if StatisticsManager:
		StatisticsManager.stat_updated.connect(_on_stat_updated)
		
	# Connect to dialogue manager for quest/run triggers
	GameDialogueManager.start_sewer_run.connect(start_run)
	GameDialogueManager.complete_sewer_run.connect(complete_run)

func _process(delta: float) -> void:
	if is_run_active:
		run_stats.time_elapsed = (Time.get_ticks_msec() - run_start_time) / 1000
		run_metrics_updated.emit()

# ===== Run Control Functions =====

func start_run() -> void:
	if is_run_active:
		run_status_check.emit(false, "A sewer run is already in progress.")
		return
		
	is_run_active = true
	run_start_time = Time.get_ticks_msec()
	temp_final_score = 0
	temp_rewards_tier = ""
	temp_rewards_coins = 0
	temp_rewards_exp = 0
	# Reset run stats
	run_stats = {
		"time_elapsed": 0,
		"kills": {
			"total": 0,
			"by_enemy_type": {},
		},
		"damage_dealt": 0,
		"damage_taken": 0,
		"healing_done": 0,
		"coins_collected": 0,
		"highest_level_reached": 1,  # Start at sewer level 1
		"deaths": 0,
		"potions_used": 0,
		"boss_kills": 0
	}
	
	current_sewer_level = 1
	total_runs_attempted += 1
	run_started.emit()
	run_metrics_updated.emit()
	save_run_data()
	
	print("Sewer run started!")
	run_status_check.emit(true, "Sewer run started! Make your way to floor 4!")

func end_run(completed: bool = true) -> void:
	if not is_run_active:
		return
		
	is_run_active = false
	
	# Calculate final score
	var final_score = calculate_run_score()
	run_stats["final_score"] = final_score
	run_stats["completed"] = completed
	
	# Determine rewards
	var rewards = determine_rewards(final_score)
	run_stats["rewards"] = rewards
	
	if completed:
		total_runs_completed += 1
		update_historical_bests()
	
	run_ended.emit(run_stats)
	save_run_data()
	save_historical_data()
	
	print("Sewer run ended! Final score: ", final_score)
	print("Rewards: ", rewards)

# Reset an active run and start fresh
func reset_run() -> void:
	if is_run_active:
		# End the current run without completing it
		end_run(false)
	
	# Start a new run
	start_run()
	
# Function to check run status - useful for UI or when player returns after dying
func check_run_status() -> Dictionary:
	var status = {
		"is_active": is_run_active,
		"current_level": current_sewer_level,
		"time_elapsed": run_stats.time_elapsed if is_run_active else 0,
		"can_complete": false,
		"reason": ""
	}
	
	if is_run_active:
		if run_stats.highest_level_reached >= 4:
			status.can_complete = true
		else:
			status.reason = "You need to reach sewer level 4 first!"
	else:
		status.reason = "No active run. Talk to Sewer Steve to start a new run."
	
	return status

# ===== Event Tracking Functions =====

func _on_stat_updated(stat_name: String, new_value: int) -> void:
	if not is_run_active:
		return
		
	if stat_name == "kills":
		run_stats.kills.total = new_value - run_stats.kills.total
		run_metrics_updated.emit()
		save_run_data()

func record_kill(enemy_type: String) -> void:
	if not is_run_active:
		return
		
	# Check if player is in sewer levels
	var current_scene = SceneManager.current_level
	if not _is_in_sewer_levels(current_scene):
		return
		
	run_stats.kills.total += 1
	
	if not run_stats.kills.by_enemy_type.has(enemy_type):
		run_stats.kills.by_enemy_type[enemy_type] = 0
	run_stats.kills.by_enemy_type[enemy_type] += 1
	
	# Check if this is a boss kill
	if enemy_type.ends_with("chief") or enemy_type.ends_with("boss"):
		run_stats.boss_kills += 1
	
	run_metrics_updated.emit()
	save_run_data()

func record_damage_dealt(amount: int) -> void:
	if not is_run_active:
		return
		
	# Check if player is in sewer levels
	var current_scene = SceneManager.current_level
	if not _is_in_sewer_levels(current_scene):
		return
		
	run_stats.damage_dealt += amount
	run_metrics_updated.emit()
	save_run_data()

func record_damage_taken(amount: int) -> void:
	if not is_run_active:
		return
		
	# Check if player is in sewer levels
	var current_scene = SceneManager.current_level
	if not _is_in_sewer_levels(current_scene):
		return
		
	run_stats.damage_taken += amount
	run_metrics_updated.emit()
	save_run_data()

func record_coins_collected(amount: int) -> void:
	if not is_run_active:
		return
		
	# Check if player is in sewer levels
	var current_scene = SceneManager.current_level
	if not _is_in_sewer_levels(current_scene):
		return
		
	run_stats.coins_collected += amount
	run_metrics_updated.emit()
	save_run_data()

func record_death() -> void:
	if not is_run_active:
		return
		
	# Check if player is in sewer levels
	var current_scene = SceneManager.current_level
	if not _is_in_sewer_levels(current_scene):
		return
		
	run_stats.deaths += 1
	run_metrics_updated.emit()
	save_run_data()

func record_healing_taken(amount: int) -> void:
	if not is_run_active:
		return
		
	# Check if player is in sewer levels
	var current_scene = SceneManager.current_level
	if not _is_in_sewer_levels(current_scene):
		return
		
	run_stats.healing_done += amount
	run_metrics_updated.emit()
	save_run_data()

func update_sewer_level(level: int) -> void:
	if not is_run_active:
		return
	
	current_sewer_level = level
	
	if level > run_stats.highest_level_reached:
		run_stats.highest_level_reached = level
		
	# If we reached level 4 (final level), check for auto-completion
	if level >= 4:
		# Don't end the run automatically - let the player trigger it
		# when they're ready to complete the run
		pass
		
	run_metrics_updated.emit()
	save_run_data()

# ===== Scoring and Rewards =====

func calculate_run_score() -> int:
	var score = 0
	
	# Time factor (score decreases as time increases)
	var time_factor = max(0.5, SCORE_WEIGHTS.time_modifier - (run_stats.time_elapsed / 600))  # Decrease multiplier after 10 minutes
	
	# Calculate base score
	score += run_stats.kills.total * SCORE_WEIGHTS.kills
	score += run_stats.boss_kills * SCORE_WEIGHTS.boss_kills
	score += run_stats.damage_dealt * SCORE_WEIGHTS.damage_dealt
	score += run_stats.damage_taken * SCORE_WEIGHTS.damage_taken
	score += run_stats.highest_level_reached * SCORE_WEIGHTS.highest_level
	score += run_stats.deaths * SCORE_WEIGHTS.deaths
	score += run_stats.healing_done * SCORE_WEIGHTS.healing_done
	
	# Apply time factor
	score = int(score * time_factor)
	
	var time_in_minutes = run_stats.time_elapsed / 60.0
	
	if time_in_minutes <= 2.0:
		# Completed in 2 minutes or less
		score += 500
		print("Time bonus: +500 (under 2 minutes)")
	elif time_in_minutes <= 3.0:
		# Completed in 3 minutes or less
		score += 300
		print("Time bonus: +300 (under 3 minutes)")
	elif time_in_minutes >= 5.0:
		# Took 5 minutes or longer - no bonus
		print("Time bonus: +0 (over 5 minutes)")
	else:
		# Between 3 and 5 minutes - scaled bonus
		var scaled_bonus = int(300 * (1.0 - ((time_in_minutes - 3.0) / 2.0)))
		score += scaled_bonus
		print("Time bonus: +", scaled_bonus, " (scaled between 3-5 minutes)")
	
	# Ensure minimum score is 0
	return max(0, score)

func determine_rewards(score: int) -> Dictionary:
	var rewards = {
		"coins": 0,
		"experience": 0,
		"items": []
	}
	
	# Base rewards
	rewards.coins = int(score * 0.1)
	rewards.experience = int(score * 0.5)
	
	# Tier-based rewards
	if score >= REWARD_THRESHOLDS.platinum:
		rewards.coins += 200
		rewards.experience += 500
		rewards.items.append("healing_potion")
		rewards.items.append("healing_potion")
		rewards.tier = "platinum"
	elif score >= REWARD_THRESHOLDS.gold:
		rewards.coins += 150
		rewards.experience += 300
		rewards.items.append("healing_potion")
		rewards.tier = "gold"
	elif score >= REWARD_THRESHOLDS.silver:
		rewards.coins += 100
		rewards.experience += 200
		rewards.tier = "silver"
	elif score >= REWARD_THRESHOLDS.bronze:
		rewards.coins += 50
		rewards.experience += 100
		rewards.tier = "bronze"
	else:
		rewards.tier = "none"
		
	return rewards

func apply_rewards(rewards: Dictionary) -> void:
	# Add coins
	for i in rewards.coins:
		InventoryManager.add_collectible("coin")
		
	# Add experience
	if rewards.experience > 0:
		StatisticsManager.add_experience(rewards.experience)
		
	# Add items
	for item in rewards.items:
		InventoryManager.add_collectible(item)

# ===== Historical Best Functions =====

func update_historical_bests() -> void:
	# Update runs completed stats
	historical_best_stats.runs_completed = total_runs_completed
	if total_runs_attempted > 0:
		historical_best_stats.completion_rate = float(total_runs_completed) / float(total_runs_attempted) * 100.0
	
	# Only update if this was a completed run
	if not run_stats.get("completed", false):
		return
		
	var current_score = run_stats.get("final_score", 0)
	var current_time = run_stats.get("time_elapsed", 0)
	
	# Check each metric and update if it's a new best
	if current_score > historical_best_stats.best_score:
		historical_best_stats.best_score = current_score
		historical_best_stats.best_run_date = Time.get_unix_time_from_system()
	
	if current_time < historical_best_stats.fastest_completion and run_stats.get("completed", false):
		historical_best_stats.fastest_completion = current_time
	
	if run_stats.kills.total > historical_best_stats.most_kills:
		historical_best_stats.most_kills = run_stats.kills.total
	
	if run_stats.damage_dealt > historical_best_stats.most_damage_dealt:
		historical_best_stats.most_damage_dealt = run_stats.damage_dealt
	
	if run_stats.damage_taken < historical_best_stats.least_damage_taken or historical_best_stats.least_damage_taken == 999999:
		historical_best_stats.least_damage_taken = run_stats.damage_taken
	
	if run_stats.coins_collected > historical_best_stats.most_coins_collected:
		historical_best_stats.most_coins_collected = run_stats.coins_collected
	
	if run_stats.get("healing_done", 0) > historical_best_stats.highest_healing_done:
		historical_best_stats.highest_healing_done = run_stats.healing_done
	
	# Update reward tier if better than previous best
	var current_tier = run_stats.get("rewards", {}).get("tier", "")
	var tier_ranks = {"platinum": 4, "gold": 3, "silver": 2, "bronze": 1, "none": 0, "": 0}
	
	if tier_ranks.get(current_tier, 0) > tier_ranks.get(historical_best_stats.highest_reward_tier, 0):
		historical_best_stats.highest_reward_tier = current_tier
		
	# Update formatted values for dialogue
	update_formatted_stats()

# Public formatted properties for direct access in dialogue
var formatted_best_time: String = "0:00"
var formatted_least_damage: String = "N/A"
var formatted_highest_tier: String = "None"
var formatted_completion_rate: String = "0.0%"

# Update the formatted properties for dialogue access
func update_formatted_stats() -> void:
	# Format time as minutes:seconds
	var best_time_mins = int(historical_best_stats.fastest_completion / 60)
	var best_time_secs = int(historical_best_stats.fastest_completion) % 60
	formatted_best_time = "%d:%02d" % [best_time_mins, best_time_secs]
	
	# Format damage taken safely
	if historical_best_stats.least_damage_taken < 999999:
		formatted_least_damage = str(historical_best_stats.least_damage_taken)
	else:
		formatted_least_damage = "N/A"
	
	# Format reward tier safely
	if historical_best_stats.highest_reward_tier != "":
		formatted_highest_tier = historical_best_stats.highest_reward_tier.capitalize()
	else:
		formatted_highest_tier = "None"
	
	# Format completion rate
	formatted_completion_rate = "%.1f%%" % historical_best_stats.completion_rate

# ===== Save/Load Functions =====

func save_run_data() -> void:
	var save_resource = Resource.new()
	var save_data = {
		"is_run_active": is_run_active,
		"run_start_time": run_start_time,
		"current_sewer_level": current_sewer_level,
		"run_stats": run_stats,
		"total_runs_attempted": total_runs_attempted,
		"total_runs_completed": total_runs_completed
	}
	
	save_resource.set_meta("run_data", save_data)
	
	# Ensure directory exists
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("game_data"):
		dir.make_dir("game_data")
	
	var result = ResourceSaver.save(save_resource, SAVE_DATA_PATH)
	if result != OK:
		printerr("Failed to save run data. Error code: ", result)

func load_run_data() -> void:
	if not FileAccess.file_exists(SAVE_DATA_PATH):
		return
	
	var save_resource = ResourceLoader.load(SAVE_DATA_PATH)
	if save_resource and save_resource.has_meta("run_data"):
		var data = save_resource.get_meta("run_data")
		
		if data.has("is_run_active"):
			is_run_active = data.is_run_active
		
		if data.has("run_start_time"):
			run_start_time = data.run_start_time
			
		if data.has("current_sewer_level"):
			current_sewer_level = data.current_sewer_level
			
		if data.has("run_stats"):
			run_stats = data.run_stats
			
		if data.has("total_runs_attempted"):
			total_runs_attempted = data.total_runs_attempted
			
		if data.has("total_runs_completed"):
			total_runs_completed = data.total_runs_completed
			
		print("Run data loaded successfully")
		
		if is_run_active:
			run_metrics_updated.emit()
	else:
		printerr("Failed to load run data: Invalid or corrupted save file")

func save_historical_data() -> void:
	var save_resource = Resource.new()
	save_resource.set_meta("historical_data", historical_best_stats)
	
	# Ensure directory exists
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("game_data"):
		dir.make_dir("game_data")
	
	var result = ResourceSaver.save(save_resource, HISTORICAL_DATA_PATH)
	if result != OK:
		printerr("Failed to save historical data. Error code: ", result)

func load_historical_data() -> void:
	if not FileAccess.file_exists(HISTORICAL_DATA_PATH):
		return
	
	var save_resource = ResourceLoader.load(HISTORICAL_DATA_PATH)
	if save_resource and save_resource.has_meta("historical_data"):
		historical_best_stats = save_resource.get_meta("historical_data")
		update_formatted_stats()
		print("Historical data loaded successfully")
	else:
		printerr("Failed to load historical data: Invalid or corrupted save file")

# Function to detect player's current sewer level
func update_current_level(level_name: String) -> void:
	if not is_run_active:
		return
	
	# Update the current sewer level based on the level name
	match level_name:
		"the_sewers_floor_1":
			update_sewer_level(1)
		"the_sewers_floor_2":
			update_sewer_level(2)
		"the_sewers_floor_3":
			update_sewer_level(3)
		"the_sewers_floor_4":
			update_sewer_level(4)
		"the_sewers_floor_5":
			update_sewer_level(5)

# Helper function to check if player is in sewer levels
func _is_in_sewer_levels(level_name: String) -> bool:
	return level_name == "the_sewers_floor_1" or \
		   level_name == "the_sewers_floor_2" or \
		   level_name == "the_sewers_floor_3" or \
		   level_name == "the_sewers_floor_4" or \
		   level_name == "the_sewers_floor_5" or \
		   level_name == "the_sewers"

# Function to check if run can be completed - useful for dialogue options
func can_complete_run() -> Dictionary:
	var result = {
		"can_complete": false,
		"reason": ""
	}
	
	if not is_run_active:
		result.reason = "No active sewer run."
		return result
		
	if run_stats.highest_level_reached < 4:
		result.reason = "You need to reach sewer level 4 first!"
		return result
	
	result.can_complete = true
	return result

# Function to award run rewards to the player - called by dialogue handler
func complete_run() -> void:
	var status = can_complete_run()
	
	if not status.can_complete:
		run_status_check.emit(false, status.reason)
		return
		
	# End the run and apply rewards
	end_run(true)
	apply_rewards(run_stats.rewards)
	run_status_check.emit(true, "Run completed successfully!")

# Add this function to prepare completion data
func prepare_completion_data() -> void:
	temp_final_score = 0
	temp_rewards_tier = ""
	temp_rewards_coins = 0
	temp_rewards_exp = 0
	temp_final_score = calculate_run_score()
	var rewards = determine_rewards(temp_final_score)
	temp_rewards_tier = rewards.tier
	temp_rewards_coins = rewards.coins
	temp_rewards_exp = rewards.experience
	print("Prepared completion data: score=", temp_final_score, " tier=", temp_rewards_tier)
	print("Run stats for scoring:")
	print("- Kills: ", run_stats.kills.total)
	print("- Boss kills: ", run_stats.boss_kills)
	print("- Damage dealt: ", run_stats.damage_dealt)
	print("- Damage taken: ", run_stats.damage_taken)
	print("- Healing done: ", run_stats.healing_done)
	print("- Highest level: ", run_stats.highest_level_reached)
	print("- Deaths: ", run_stats.deaths)
	print("- Time elapsed: ", run_stats.time_elapsed)


func reset_data() -> void:
	# Reset the run state
	is_run_active = false
	run_start_time = 0
	current_sewer_level = 0
	
	# Reset temporary variables
	temp_final_score = 0
	temp_rewards_tier = ""
	temp_rewards_coins = 0
	temp_rewards_exp = 0
	
	# Reset run stats
	run_stats = {
		"time_elapsed": 0,
		"kills": {
			"total": 0,
			"by_enemy_type": {},
		},
		"damage_dealt": 0,
		"damage_taken": 0,
		"healing_done": 0,
		"coins_collected": 0,
		"highest_level_reached": 0,
		"deaths": 0,
		"potions_used": 0,
		"boss_kills": 0
	}
	
	# Reset total runs counters
	total_runs_attempted = 0
	total_runs_completed = 0
	
	# Also reset the completion rate in historical stats
	historical_best_stats.completion_rate = 0.0
	historical_best_stats.runs_completed = 0
	
	# Save the reset data
	save_run_data()
	save_historical_data()
	print("DungeonRunManager data reset")
