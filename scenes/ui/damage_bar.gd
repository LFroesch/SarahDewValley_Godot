extends Node2D

@onready var progress_bar = $ProgressBar
@onready var player: Player

func _ready() -> void:
	await get_tree().process_frame
	player = get_parent() as Player
	if player:
		player.health_changed.connect(_on_player_health_changed)
		setup_bar()
		update_bar_visibility()

func setup_bar() -> void:
	progress_bar.max_value = player.max_health
	progress_bar.value = player.current_health

func _process(delta: float) -> void:
	if player:
		progress_bar.value = player.current_health
		position = Vector2(-10, 2)
		update_bar_visibility()

func update_bar_visibility() -> void:
	if player.current_health < player.max_health:
		show()
	else:
		hide()

func show_bar() -> void:
	show()

func hide_bar() -> void:
	hide()

func _on_player_health_changed(current: float, maximum: float) -> void:
	progress_bar.max_value = maximum
	progress_bar.value = current
