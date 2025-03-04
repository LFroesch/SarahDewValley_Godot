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
				"description": QuestManager.quests[quest_id].description,
				"status": "Ready to Hand In",
				"rewards": QuestManager.quests[quest_id].rewards
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
				"description": quest.description,
				"status": status_text,
				"rewards": quest.rewards
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
		var quest_box = VBoxContainer.new()
		quest_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		# Create title and status label
		var title_label = Label.new()
		title_label.text = "- %s (%s)" % [quest.title, quest.status]
		title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		title_label.add_theme_font_size_override("font_size", 18)
		quest_box.add_child(title_label)
		
		# Create description label
		var desc_label = Label.new()
		desc_label.text = "%s" % quest.description
		desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		desc_label.add_theme_font_size_override("font_size", 12)
		desc_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8, 0.9)) # Slightly faded text for description
		quest_box.add_child(desc_label)
		
		# Add rewards section
		var rewards = quest.rewards
		var rewards_label = Label.new()
		rewards_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		rewards_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		rewards_label.add_theme_font_size_override("font_size", 12)
		
		var rewards_text = "Rewards: "
		var rewards_parts = []
		
		if rewards.has("experience"):
			rewards_parts.append("%d XP" % rewards.experience)
		
		if rewards.has("gold"):
			rewards_parts.append("%d Coins" % rewards.gold)
		
		if rewards.has("items"):
			var items_text = []
			for item in rewards.items:
				var item_name = item.item_id.capitalize()
				items_text.append("%dx %s" % [item.count, item_name])
			if items_text.size() > 0:
				rewards_parts.append(" + ".join(items_text))
		rewards_label.text = rewards_text + " + ".join(rewards_parts)
		rewards_label.add_theme_color_override("font_color", Color(0.9, 0.7, 0.2, 1.0))
		quest_box.add_child(rewards_label)
		
		# Add a small margin between quests
		if i < quest_info.size() - 1:
			var spacer = Control.new()
			spacer.custom_minimum_size = Vector2(0, 10)
			quest_box.add_child(spacer)
		
		quest_container.add_child(quest_box)
		quest_labels[quest.id] = title_label

func _on_quest_changed(_quest_id: String) -> void:
	if visible:
		update_quest_display()

func _on_quest_progress(_quest_id: String, _progress: float) -> void:
	if visible:
		update_quest_display()
