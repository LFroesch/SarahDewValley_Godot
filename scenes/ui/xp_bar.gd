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

func _ready():
	# Connect to statistics manager signals
	StatisticsManager.experience_gained.connect(_on_experience_gained)
	StatisticsManager.level_up.connect(_on_level_up)
	
	# Initialize values from StatisticsManager
	if StatisticsManager:
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
		
func _process(_delta):
	if StatisticsManager:
		var new_xp = StatisticsManager.get_current_xp()
		var new_max_xp = StatisticsManager.get_xp_for_next_level()
		var new_level = StatisticsManager.get_current_level()
		
		# Only update if values have changed
		if new_xp != current_xp || new_max_xp != max_xp || new_level != current_level:
			current_xp = new_xp
			max_xp = new_max_xp
			current_level = new_level
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
	var tween = create_tween()
	tween.tween_property(progress_bar, "value", current_xp, 0.5).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)

func _on_level_up(new_level: int):
	current_level = new_level
	
	# Create a level-up flash effect
	var tween = create_tween()
	tween.tween_property(level_label, "modulate", Color(1.5, 1.5, 1.5), 0.2)
	tween.tween_property(level_label, "modulate", Color(1, 1, 1), 0.3)
	
	# Update the display
	update_xp_display()
