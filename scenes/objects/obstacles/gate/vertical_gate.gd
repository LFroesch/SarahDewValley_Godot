#HorizontalGate.gd
extends Node2D

@export var required_key = "skeleton_key"
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var unlock_check_area: Area2D = $UnlockCheckArea

var is_open = false

func _ready():
	animated_sprite.play("closed")

func has_required_key(player):
	if required_key in InventoryManager.inventory and InventoryManager.inventory[required_key] > 0:
		return true
	return false

# Function to open the gate
func open_gate(player):
	animated_sprite.play("open")
	if collision_shape:
		collision_shape.set_deferred("disabled", true)
	is_open = true

func _on_unlock_check_area_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not is_open:
		if has_required_key(body):
			open_gate(body)
