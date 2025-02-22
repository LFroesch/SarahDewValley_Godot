extends Node2D

@onready var progress_bar = $ProgressBar
@onready var enemy_sprite: CharacterBody2D = $".."

func _ready() -> void:
	await get_tree().process_frame
	if enemy_sprite:
		setup_bar()

func setup_bar() -> void:
	progress_bar.max_value = enemy_sprite.health
	progress_bar.value = enemy_sprite.health

func _process(_delta: float) -> void:
	if enemy_sprite:
		progress_bar.value = enemy_sprite.health
		position = Vector2(-10, 2)

func show_bar() -> void:
	show()

func hide_bar() -> void:
	hide()
