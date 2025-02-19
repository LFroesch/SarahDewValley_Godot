# DamageBar.gd
extends Node2D

@onready var progress_bar = $ProgressBar
@onready var player: Player

func _ready() -> void:
	await get_tree().process_frame
	player = get_parent() as Player
	if player:
		setup_bar()

func setup_bar() -> void:
	progress_bar.max_value = player.max_health
	progress_bar.value = player.current_health

func _process(_delta: float) -> void:
	if player:
		progress_bar.value = player.current_health
		position = Vector2(-10, 2)

func show_bar() -> void:
	show()

func hide_bar() -> void:
	hide()
