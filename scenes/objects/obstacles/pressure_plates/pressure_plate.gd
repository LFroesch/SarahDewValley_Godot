extends Node2D

# Export array of NodePaths to allow setting target gates in the inspector
@export var target_gates: Array[NodePath] = []
@export var stay_pressed: bool = true # Whether the plate stays pressed or pops back up when player leaves

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var player_detection_area: Area2D = $PlayerDetectionArea

var is_pressed: bool = false
var player_inside: bool = false

func _ready():
	# Connect the detection area signals
	player_detection_area.body_entered.connect(_on_player_detection_area_body_entered)
	player_detection_area.body_exited.connect(_on_player_detection_area_body_exited)
	
	# Start with the idle animation
	animated_sprite.play("idle")

func _on_player_detection_area_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not is_pressed:
		player_inside = true
		press_plate()

func _on_player_detection_area_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_inside = false

func press_plate() -> void:
	is_pressed = true
	animated_sprite.play("pressed")
	for gate_path in target_gates:
		var gate = get_node_or_null(gate_path)
		if gate:
			gate.open_gate(null)
