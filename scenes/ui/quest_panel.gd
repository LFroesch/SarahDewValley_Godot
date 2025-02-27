extends PanelContainer

@onready var current_quest_label: Label = $MarginContainer/VBoxContainer/CurrentQuestLabel
var quest_labels: Dictionary = {}

func _ready() -> void:
	hide()
	update_quest_display()
	QuestManager.quest_started.connect(_on_quest_changed)
	QuestManager.quest_updated.connect(_on_quest_progress)
	QuestManager.quest_objectives_completed.connect(_on_quest_changed)
	QuestManager.quest_completed.connect(_on_quest_changed)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("show_questpanel"):
		visible = !visible
		if visible:
			update_quest_display()

func update_quest_display() -> void:
	for label in quest_labels.values():
		if is_instance_valid(label):
			label.queue_free()
	quest_labels.clear()
	
	current_quest_label.text = "QUESTS:"
	current_quest_label.add_theme_font_size_override("font_size", 18)
	var processed_quest_ids = []
	var quest_info = []
	
	for quest_id in QuestManager.ready_for_turnin_quests:
		if QuestManager.quests.has(quest_id) and not processed_quest_ids.has(quest_id):
			quest_info.append({
				"id": quest_id,
				"title": QuestManager.quests[quest_id].title,
				"status": "Return to Quest Giver"
			})
			processed_quest_ids.append(quest_id)

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
	
	if quest_info.is_empty():
		current_quest_label.text += "\nNo Active Quests"
		return
	
	for i in range(quest_info.size()):
		var quest = quest_info[i]
		var label = Label.new()
		label.text = "• %s\n     (%s)" % [quest.title, quest.status]
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.add_theme_font_size_override("font_size", 18)
		
		current_quest_label.get_parent().add_child(label)
		current_quest_label.get_parent().move_child(label, current_quest_label.get_index() + 1 + i)
		quest_labels[quest.id] = label

func _on_quest_changed(_quest_id: String) -> void:
	if visible:
		update_quest_display()

func _on_quest_progress(_quest_id: String, _progress: float) -> void:
	if visible:
		update_quest_display()
