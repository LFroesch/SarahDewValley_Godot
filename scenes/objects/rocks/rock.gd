extends Sprite2D

@onready var hurt_component: HurtComponent = $HurtComponent
@onready var damage_component: Node2D = $DamageComponent

var stone_scene = preload("res://scenes/objects/stone.tscn")

func _ready() -> void:
	hurt_component.hurt.connect(on_hurt)
	damage_component.max_damaged_reached.connect(on_max_damage_reached)
	
func on_hurt(hit_damage: int) -> void:
	damage_component.apply_damage(hit_damage)
	material.set_shader_parameter("shake_intensity", 1.5)
	await get_tree().create_timer(0.5).timeout
	material.set_shader_parameter("shake_intensity", 0.0)
	

func on_max_damage_reached() -> void:
	print("max damaged reached")
	call_deferred("add_stone_scene")
	queue_free()
	
func add_stone_scene() -> void:
	var stone_instance1 = stone_scene.instantiate() as Node2D
	stone_instance1.global_position = global_position
	get_parent().add_child(stone_instance1)
	
