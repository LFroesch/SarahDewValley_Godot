extends CanvasLayer

@onready var spillover_panel: PanelContainer = $SpilloverPanel


func _ready() -> void:
	# Make sure spillover starts hidden
	spillover_panel.hide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_spillover"):
		spillover_panel.visible = !spillover_panel.visible
