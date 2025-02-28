extends Sprite2D

func _ready() -> void:
	pass
	
func _on_despawn() -> void:
	queue_free()
