extends PanelContainer
@onready var current_quest_label: Label = $MarginContainer/VBoxContainer/QuestTitleLabel
@onready var quest_container: VBoxContainer = $MarginContainer/VBoxContainer/ScrollContainer/QuestContainer
var quest_labels: Dictionary = {}

func _ready() -> void:
	hide()
	update_quest_display()
	QuestManager.quest_started.connect(_on_quest_changed)
	QuestManager.quest_updated.connect(_on_quest_progress)
	QuestManager.quest_objectives_completed.connect(_on_quest_changed)
	QuestManager.quest_completed.connect(_on_quest_changed)
	
	# Add to quest_panels group for auto-updating
	add_to_group("quest_panels")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("show_questpanel"):
		visible = !visible
		if visible:
			update_quest_display()

func update_quest_display() -> void:
	# Clear all existing labels from container first
	for child in quest_container.get_children():
		child.queue_free()
	
	# Also clear the dictionary
	quest_labels.clear()
	
	current_quest_label.text = "QUESTS:"
	current_quest_label.add_theme_font_size_override("font_size", 18)
	var processed_quest_ids = []
	var quest_info = []
	
	# Process quests ready for turn-in first
	for quest_id in QuestManager.ready_for_turnin_quests:
		if QuestManager.quests.has(quest_id) and not processed_quest_ids.has(quest_id):
			quest_info.append({
				"id": quest_id,
				"title": QuestManager.quests[quest_id].title,
				"status": "Ready to Hand In"
			})
			processed_quest_ids.append(quest_id)
	
	# Then process active quests
	for quest_id in QuestManager.active_quests.keys():
		if not processed_quest_ids.has(quest_id):
			var quest = QuestManager.active_quests[quest_id]
			var status_text = ""
			
			# Handle different objective types
			for objective_key in quest.objectives:
				var objective = quest.objectives[objective_key]
				
				if objective_key == "kill_enemy":
					var current = objective.current
					var total = objective.count
					status_text = "%d / %d" % [current, total]
					
				elif objective_key == "collect_item":
					var current = objective.current
					var total = objective.count
					status_text = "%d / %d" % [current, total]
					
				elif objective_key == "talk_to":
					status_text = "0 / 1"  # Talk quests are 0/1 until completed
			
			quest_info.append({
				"id": quest_id,
				"title": quest.title,
				"status": status_text
			})
			processed_quest_ids.append(quest_id)
	
	if quest_info.is_empty():
		var empty_label = Label.new()
		empty_label.text = "No Active Quests"
		empty_label.add_theme_font_size_override("font_size", 18)
		quest_container.add_child(empty_label)
		return
	
	for i in range(quest_info.size()):
		var quest = quest_info[i]
		var label = Label.new()
		label.text = "- %s\n     (%s)" % [quest.title, quest.status]
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.add_theme_font_size_override("font_size", 18)
		
		quest_container.add_child(label)
		quest_labels[quest.id] = label

# Fixed method names
func _on_quest_changed(_quest_id: String) -> void:
	if visible:
		update_quest_display()

func _on_quest_progress(_quest_id: String, _progress: float) -> void:
	if visible:
		update_quest_display()
