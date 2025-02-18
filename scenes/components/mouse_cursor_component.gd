extends Node

@export var cursor_component_texture: Texture2D

func _ready() -> void:
	var image = cursor_component_texture.get_image()
	image.resize(image.get_width() * 1.5, image.get_height() * 1.5)
	var scaled_texture = ImageTexture.create_from_image(image)
	Input.set_custom_mouse_cursor(scaled_texture, Input.CURSOR_ARROW)
