extends PanelContainer
@onready var title_label = $MarginContainer/VBoxContainer/TitleLabel
@onready var grid_container = $MarginContainer/VBoxContainer/ScrollContainer/GridContainer
var main_inventory_items = ["egg", "milk", "corn", "tomato", "coin"]

var tooltip_panel = null
var tooltip_text_label = null

func _ready() -> void:
	visible = false
	title_label.text = "ITEMS:"
	title_label.add_theme_font_size_override("font_size", 18)
	InventoryManager.inventory_changed.connect(update_spillover_display)
	_create_permanent_tooltip()
	update_spillover_display()

func _create_permanent_tooltip() -> void:
	# Create a canvas layer for tooltips
	var font = preload("res://assets/ui/fonts/pixelFont-7-8x14-sproutLands.ttf")
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100  # Above everything else
	get_tree().root.add_child(canvas_layer)
	
	# Create the actual label that will show the text
	tooltip_text_label = Label.new()
	tooltip_text_label.add_theme_font_override("font", font)
	tooltip_text_label.add_theme_font_size_override("font_size", 18)
	tooltip_text_label.modulate = Color(1, 0.9, 0.7)  # Slight gold/cream color for text
	
	# Create a panel to hold the label
	tooltip_panel = PanelContainer.new()
	
	# Create an MMORPG-style panel using StyleBoxFlat
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.15, 0.2, 0.95)  # Dark blue-gray background
	
	# No rounded corners for blocky look
	style.corner_radius_top_left = 0
	style.corner_radius_top_right = 0
	style.corner_radius_bottom_left = 0
	style.corner_radius_bottom_right = 0
	
	# Add a border
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.4, 0.4, 0.5, 1.0)  # Light gray-blue border
	
	# Add a subtle shadow
	style.shadow_color = Color(0, 0, 0, 0.4)
	style.shadow_size = 4
	style.shadow_offset = Vector2(2, 2)
	
	tooltip_panel.add_theme_stylebox_override("panel", style)
	
	# Add padding via margin container
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	tooltip_panel.add_child(margin)
	
	# Add the label to the margin container
	margin.add_child(tooltip_text_label)
	
	# Add the panel to the canvas layer and hide it
	canvas_layer.add_child(tooltip_panel)
	tooltip_panel.visible = false

func update_spillover_display() -> void:
	var spillover_items = {}
	for item_name in InventoryManager.inventory:
		if not item_name in main_inventory_items:
			spillover_items[item_name] = InventoryManager.inventory[item_name]
	
	for child in grid_container.get_children():
		child.queue_free()
	
	for item_name in spillover_items.keys():
		var item_container = create_item_display(item_name, spillover_items[item_name])
		grid_container.add_child(item_container)

func create_item_display(item_name: String, quantity: int) -> Control:
	var container = VBoxContainer.new()
	
	var item_scene = load("res://scenes/items/" + item_name + ".tscn")
	if item_scene:
		var item_instance = item_scene.instantiate()
		if item_instance is Sprite2D:
			var texture_rect = TextureRect.new()
			texture_rect.texture = item_instance.texture
			texture_rect.custom_minimum_size = Vector2(32, 32)
			texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			texture_rect.mouse_filter = Control.MOUSE_FILTER_STOP
			texture_rect.gui_input.connect(func(event): _on_item_clicked(event, item_name))
			texture_rect.mouse_entered.connect(func(): _show_simple_tooltip(texture_rect, item_name))
			texture_rect.mouse_exited.connect(func(): _hide_simple_tooltip())
			
			container.add_child(texture_rect)
	
	var label = Label.new()
	label.text = str(quantity)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 18)
	
	container.add_child(label)
	return container

func _on_item_clicked(event: InputEvent, item_name: String) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if InventoryManager.food_healing_values.has(item_name):
			InventoryManager.consume_food(item_name)
		#other items?

func _show_simple_tooltip(control: Control, item_name: String) -> void:
	if tooltip_text_label:
		tooltip_text_label.text = _get_item_tooltip_text(item_name)
	else:
		return

	tooltip_panel.visible = true
	await get_tree().process_frame
	var global_pos = control.global_position
	var size = tooltip_panel.size
	tooltip_panel.global_position = Vector2(
		global_pos.x - (size.x - control.size.x) / 2,
		global_pos.y - size.y - 5
	)

func _hide_simple_tooltip() -> void:
	if tooltip_panel:
		tooltip_panel.visible = false

func _get_item_tooltip_text(item_name: String) -> String:
	var tooltip_text = item_name.capitalize()

	if InventoryManager.item_descriptions.has(item_name):
		var description = InventoryManager.item_descriptions[item_name]
		tooltip_text += "\n- " + str(description)

	if InventoryManager.food_healing_values.has(item_name):
		var healing = InventoryManager.food_healing_values[item_name]
		tooltip_text += "\n- Heals " + str(healing) + " HP"
		tooltip_text += "\n  Click to consume"
	
	if InventoryManager.coin_values.has(item_name):
		var value = InventoryManager.coin_values[item_name]
		tooltip_text += "\n- Value: " + str(value)
	
	return tooltip_text

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("show_spillover"):
		visible = !visible
		if visible:
			update_spillover_display()
		else:
			_hide_simple_tooltip()
