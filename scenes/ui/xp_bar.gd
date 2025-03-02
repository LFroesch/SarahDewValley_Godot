extends Control
# XP Bar styling
@export var background_color: Color = Color("#8b7156")
@export var border_color: Color = Color("#664c33")
@export var empty_bar_color: Color = Color("#463423")
@export var fill_bar_color: Color = Color("#7fa64a")
@export var tick_color: Color = Color("#332519")
@export var level_indicator_color: Color = Color("#7c6241")
@export var level_text_color: Color = Color("#ffffff")
# XP values
@export var current_xp: int = 0
@export var max_xp: int = 100
@export var current_level: int = 1
@export var tick_count: int = 4
# References
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var level_label: Label = $LevelLabel
@onready var background: Panel = $Background
@onready var ticks_container: Control = $ProgressBar/Ticks
@onready var level_panel: Panel = $LevelPanel
# Add a flag to track level up state
var just_leveled_up: bool = false

func _ready():
	# Connect to statistics manager signals
	if StatisticsManager:
		StatisticsManager.experience_gained.connect(_on_experience_gained)
		StatisticsManager.level_up.connect(_on_level_up)
		
		# Initialize values from StatisticsManager
		current_xp = StatisticsManager.get_current_xp()
		max_xp = StatisticsManager.get_xp_for_next_level()
		current_level = StatisticsManager.get_current_level()
	
	# Set up styling
	apply_styling()
	
	# Initialize the XP bar
	update_xp_display()
	adjust_tick_positions()

func adjust_tick_positions():
	var bar_width = progress_bar.size.x
	var ticks = ticks_container.get_children()
	
	for i in range(ticks.size()):
		var tick = ticks[i]
		var position_percent = float(i + 1) / (ticks.size() + 1)
		tick.position.x = bar_width * position_percent - tick.size.x / 2

# Every frame check, specifically handling the level up transition
func _process(_delta):
	if just_leveled_up:
		# If we just leveled up, force the progress bar to 0
		progress_bar.value = 0
		progress_bar.max_value = StatisticsManager.get_xp_for_next_level()
		level_label.text = str(StatisticsManager.get_current_level())
		just_leveled_up = false
	elif StatisticsManager:
		var stored_level = current_level
		var actual_level = StatisticsManager.get_current_level()
		
		# If we detect a level mismatch, force an update
		if stored_level != actual_level:
			current_level = actual_level
			current_xp = StatisticsManager.get_current_xp()
			max_xp = StatisticsManager.get_xp_for_next_level()
			update_xp_display()

func apply_styling():
	# Apply colors to the background panel
	var bg_style = background.get("theme_override_styles/panel")
	if bg_style:
		bg_style.bg_color = background_color
		bg_style.border_color = border_color
	
	# Apply colors to the progress bar
	var empty_style = progress_bar.get("theme_override_styles/background")
	var fill_style = progress_bar.get("theme_override_styles/fill")
	
	if empty_style:
		empty_style.bg_color = empty_bar_color
	
	if fill_style:
		fill_style.bg_color = fill_bar_color
	
	# Apply colors to ticks
	for i in range(tick_count):
		var tick = ticks_container.get_node("Tick" + str(i+1))
		if tick:
			tick.color = tick_color
	
	# Apply colors to level panel
	var level_style = level_panel.get("theme_override_styles/panel")
	if level_style:
		level_style.bg_color = level_indicator_color
	
	# Apply text color to level label
	level_label.add_theme_color_override("font_color", level_text_color)
	level_label.add_theme_font_size_override("font_size", 18)

func update_xp_display():
	progress_bar.max_value = max_xp
	progress_bar.value = current_xp
	level_label.text = str(current_level)

func _on_experience_gained(_amount: int):
	if not just_leveled_up:
		current_xp = StatisticsManager.get_current_xp()
		var tween = create_tween()
		tween.tween_property(progress_bar, "value", current_xp, 0.5).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)

func _on_level_up(new_level: int):
	print("LEVEL UP HANDLER: Level " + str(new_level))
	print("Current XP: " + str(StatisticsManager.get_current_xp()))
	print("Max XP: " + str(StatisticsManager.get_xp_for_next_level()))
	
	# Cancel any existing tweens on the progress bar
	var existing_tweens = get_tree().get_nodes_in_group("tweening")
	for tween in existing_tweens:
		if tween.is_valid() and tween.has_method("kill"):
			tween.kill()
	
	# Force update with latest values
	progress_bar.max_value = StatisticsManager.get_xp_for_next_level()
	# Explicitly set to zero first, then to the actual value
	progress_bar.value = 0
	await get_tree().process_frame
	progress_bar.value = StatisticsManager.get_current_xp()
	level_label.text = str(new_level)
	
	# Force redraw
	progress_bar.queue_redraw()
	
	# Flash effect for level only
	var tween = create_tween()
	tween.tween_property(level_label, "modulate", Color(1.5, 1.5, 1.5), 0.2)
	tween.tween_property(level_label, "modulate", Color(1, 1, 1), 0.3)
