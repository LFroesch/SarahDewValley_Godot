extends PanelContainer
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
	current_location_label.add_theme_font_size_override("font_size", 18)
	level_label.add_theme_font_size_override("font_size", 18)
	xp_label.add_theme_font_size_override("font_size", 18)
	update_kill_stats()


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
		label.add_theme_font_size_override("font_size", 18)
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
