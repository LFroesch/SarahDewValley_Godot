extends Sprite2D

@onready var despawn_timer = $DespawnTimer

func _ready() -> void:
	if despawn_timer:
		despawn_timer.timeout.connect(_on_despawn)
		despawn_timer.start(randf_range(240.0, 300.0))

func _on_despawn() -> void:
	queue_free()
