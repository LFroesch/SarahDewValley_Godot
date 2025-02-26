extends PanelContainer
@onready var current_quest_label: Label = $MarginContainer/VBoxContainer/CurrentQuestLabel
@onready var current_location_label: Label = $MarginContainer/VBoxContainer/CurrentLocationLabel
@onready var level_label: Label = $MarginContainer/VBoxContainer/LevelLabel
@onready var xp_label: Label = $MarginContainer/VBoxContainer/XPLabel
@onready var kills_container: VBoxContainer = $MarginContainer/VBoxContainer/KillsContainer
var kill_labels: Dictionary = {}
var quest_labels: Dictionary = {}

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
	# Clear any existing quest labels
	for label in quest_labels.values():
		if is_instance_valid(label):
			label.queue_free()
	quest_labels.clear()
	
	# Set the main quest label title
	current_quest_label.text = "QUESTS:"
	
	# Track different quest categories and keep track of quest IDs we've already processed
	var processed_quest_ids = []
	var quest_info = []
	
	# First priority: quests ready for turnin
	for quest_id in QuestManager.ready_for_turnin_quests:
		if QuestManager.quests.has(quest_id) and not processed_quest_ids.has(quest_id):
			quest_info.append({
				"id": quest_id,
				"title": QuestManager.quests[quest_id].title,
				"status": "Return to Quest Giver"
			})
			processed_quest_ids.append(quest_id)
	
	# Second priority: active quests
	for quest_id in QuestManager.active_quests.keys():
		if not processed_quest_ids.has(quest_id):
			var quest = QuestManager.active_quests[quest_id]
			var progress = QuestManager.get_quest_progress(quest_id)
			var progress_percent = int(progress * 100)
			
			quest_info.append({
				"id": quest_id,
				"title": quest.title,
				"status": "%d%%" % progress_percent
			})
			processed_quest_ids.append(quest_id)
	
	# If no quests at all, show a message
	if quest_info.is_empty():
		current_quest_label.text += "\nNo Active Quests"
		return
	
	# Add a label for each quest
	for i in range(quest_info.size()):
		var quest = quest_info[i]
		var label = Label.new()
		label.text = "• %s (%s)" % [quest.title, quest.status]
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		# Add the label as a child to the current_quest_label's parent
		current_quest_label.get_parent().add_child(label)
		
		# Insert it right after the current_quest_label in the hierarchy
		current_quest_label.get_parent().move_child(label, current_quest_label.get_index() + 1 + i)
		
		# Store the label for later cleanup
		quest_labels[quest.id] = label

func update_kill_stats() -> void:
	for label in kill_labels.values():
		label.queue_free()
	kill_labels.clear()
	var enemy_kills = StatisticsManager.stats.kills.by_enemy_type
	for enemy_type in enemy_kills.keys():
		var kill_count = enemy_kills[enemy_type]
		var label = Label.new()
		label.text = "%s Kills: %d" % [enemy_type.capitalize(), kill_count]
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
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
