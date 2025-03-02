extends Node2D
class_name DamageNumber

enum Type {DAMAGE_TO_PLAYER, DAMAGE_TO_ENEMY, HEALING, EXP}

var amount: int = 0
var type: Type = Type.DAMAGE_TO_ENEMY
var label: Label
var tween: Tween

func _ready():
	label = Label.new()
	add_child(label)
	label.custom_minimum_size = Vector2(20, 20)
	label.add_theme_font_size_override("font_size", 18)
	var font = preload("res://assets/ui/fonts/pixelFont-7-8x14-sproutLands.ttf")
	label.add_theme_font_override("font", font)
	z_index = 100
	match type:
		Type.DAMAGE_TO_PLAYER:
			label.add_theme_color_override("font_color", Color(1, 0.2, 0.2)) # Red
		Type.DAMAGE_TO_ENEMY:
			label.add_theme_color_override("font_color", Color(245.0/255.0, 142.0/255.0, 7.0/255.0)) # Orange
		Type.HEALING:
			label.add_theme_color_override("font_color", Color(0.2, 1, 0.2)) # Green
		Type.EXP:
			label.add_theme_color_override("font_color", Color(118.8/255.0, 38.0/255.0, 255.0/255.0)) #PURPLE
	if type == Type.HEALING:
		label.text = "+" + str(amount)
	else:
		label.text = str(amount)

	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	label.position = Vector2(-25, -15)

	animate_fade_out()

func animate_fade_out():
	tween = create_tween()
	tween.tween_interval(1.0) # Wait before starting fade
	tween.tween_property(self, "modulate:a", 0.0, 0.3) # Fade out
	tween.tween_callback(queue_free)

static func create(pos: Vector2, amount: int, type: Type) -> DamageNumber:
	var instance = DamageNumber.new()
	var offset_x = randf_range(-40, 40)
	var offset_y = randf_range(-25, 25)
	instance.position = pos + Vector2(offset_x, offset_y)
	instance.amount = amount
	instance.type = type
	return instance
