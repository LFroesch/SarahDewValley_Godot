extends PanelContainer

@onready var label: Label = $MarginContainer/Label
var tween: Tween

func _ready():
	modulate.a = 0
	visible = false
	StatisticsManager.level_up.connect(_on_level_up)

func _on_level_up(new_level: int):
	label.text = "LEVEL UP! Now Level " + str(new_level)
	visible = true
	if tween and tween.is_valid():
		tween.kill()
	tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "modulate:a", 1.0, 0.5)
	tween.tween_interval(2.5)
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func(): visible = false)
