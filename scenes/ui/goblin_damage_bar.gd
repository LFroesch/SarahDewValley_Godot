# GoblinHealthBar.gd
extends Node2D

@onready var progress_bar = $ProgressBar
@onready var goblin: CharacterBody2D = $".."

func _ready() -> void:
	await get_tree().process_frame
	if goblin:
		setup_bar()

func setup_bar() -> void:
	progress_bar.max_value = goblin.health  # Use the goblin's health value
	progress_bar.value = goblin.health

func _process(_delta: float) -> void:
	if goblin:
		progress_bar.value = goblin.health
		position = Vector2(-10, 2)  # Adjust position to be above the goblin

func show_bar() -> void:
	show()

func hide_bar() -> void:
	hide()
