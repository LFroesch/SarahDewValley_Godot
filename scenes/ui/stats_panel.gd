extends PanelContainer
@onready var current_quest_label: Label = $MarginContainer/VBoxContainer/CurrentQuestLabel
@onready var current_location_label: Label = $MarginContainer/VBoxContainer/CurrentLocationLabel
@onready var level_label: Label = $MarginContainer/VBoxContainer/LevelLabel
@onready var xp_label: Label = $MarginContainer/VBoxContainer/XPLabel
@onready var kills_container: VBoxContainer = $MarginContainer/VBoxContainer/KillsContainer
var kill_labels: Dictionary = {}

func _ready() -> void:
	hide()
	update_stats()
	StatisticsManager.stat_updated.connect(_on_stat_updated)
	StatisticsManager.experience_gained.connect(_on_experience_gained)
	StatisticsManager.level_up.connect(_on_level_up)
	QuestManager.quest_started.connect(_on_quest_changed)
	QuestManager.quest_updated.connect(_on_quest_progress)
	QuestManager.quest_objectives_completed.connect(_on_quest_changed)
	QuestManager.quest_completed.connect(_on_quest_changed)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("show_stats_pane"):
		visible = !visible
		if visible:
			update_stats()

func update_stats() -> void:
	var current_location = SceneManager.current_level
	var location_name = StatisticsManager.get_level_name(current_location)
	var current_level = StatisticsManager.get_current_level()
	var current_xp = StatisticsManager.get_current_xp()
	var next_level_xp = StatisticsManager.get_xp_for_next_level()
	current_location_label.text = "Location: %s" % location_name
	level_label.text = "Level: %d" % current_level
	xp_label.text = "XP: %d / %d" % [current_xp, next_level_xp]
	update_quest_display()
	update_kill_stats()

func update_quest_display() -> void:
	var quest_id = QuestManager.current_quest
	
	if quest_id.is_empty():
		# Check if there are any active quests
		if not QuestManager.active_quests.is_empty():
			# Get the first active quest
			quest_id = QuestManager.active_quests.keys()[0]
		# Check for ready-for-turnin quests
		elif not QuestManager.ready_for_turnin_quests.is_empty():
			quest_id = QuestManager.ready_for_turnin_quests[0]
	
	if QuestManager.is_quest_ready_for_turnin(quest_id):
		var quest = QuestManager.quests[quest_id]
		current_quest_label.text = "Quest: %s (Return to Quest Giver)" % quest.title
	elif QuestManager.is_quest_active(quest_id):
		var quest = QuestManager.active_quests[quest_id]
		var progress = QuestManager.get_quest_progress(quest_id)
		var progress_percent = int(progress * 100)
		
		current_quest_label.text = "Quest: %s (%d%%)" % [quest.title, progress_percent]
	elif not QuestManager.completed_quests.is_empty():
		# Show the last completed quest
		var last_quest_id = QuestManager.completed_quests[-1]
		if QuestManager.quests.has(last_quest_id):
			current_quest_label.text = "Quest: %s (Completed)" % QuestManager.quests[last_quest_id].title
	else:
		current_quest_label.text = "Quest: None"

func update_kill_stats() -> void:
	for label in kill_labels.values():
		label.queue_free()
	kill_labels.clear()
	var enemy_kills = StatisticsManager.stats.kills.by_enemy_type
	for enemy_type in enemy_kills.keys():
		var kill_count = enemy_kills[enemy_type]
		var label = Label.new()
		label.text = "%s Kills: %d" % [enemy_type.capitalize(), kill_count]

		kills_container.add_child(label)
		kill_labels[enemy_type] = label

func _on_stat_updated(stat_name: String, new_value: int) -> void:
	if visible:
		update_stats()

func _on_experience_gained(_amount: int) -> void:
	if visible:
		update_stats()

func _on_level_up(_new_level: int) -> void:
	if visible:
		update_stats()

func _on_quest_changed(_quest_id: String) -> void:
	if visible:
		update_quest_display()

func _on_quest_progress(_quest_id: String, _progress: float) -> void:
	if visible:
		update_quest_display()
