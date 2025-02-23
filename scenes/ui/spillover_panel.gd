# SpilloverPanel.gd
extends PanelContainer

@onready var grid_container = $MarginContainer/VBoxContainer/GridContainer
var main_inventory_items = ["log", "egg", "milk", "stone", "corn", "tomato", "coin"]

func _ready() -> void:
	visible = false
	InventoryManager.inventory_changed.connect(update_spillover_display)
	update_spillover_display()

func update_spillover_display() -> void:
	# Get all items that aren't in main inventory
	var spillover_items = {}
	for item_name in InventoryManager.inventory:
		if not item_name in main_inventory_items:
			spillover_items[item_name] = InventoryManager.inventory[item_name]
	
	# Clear existing items
	for child in grid_container.get_children():
		child.queue_free()
	
	# Display all spillover items
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
			
			# Make texture clickable
			texture_rect.mouse_filter = Control.MOUSE_FILTER_STOP
			
			# Connect click event
			texture_rect.gui_input.connect(func(event): _on_item_clicked(event, item_name))
			
			container.add_child(texture_rect)
	
	var label = Label.new()
	label.text = str(quantity)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var font = load("res://assets/ui/fonts/zx_palm_variation.tres")
	label.add_theme_font_override("font", font)
	
	container.add_child(label)
	return container

# Add this function to handle clicks
func _on_item_clicked(event: InputEvent, item_name: String) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# If it's a food item
		if InventoryManager.food_healing_values.has(item_name):
			InventoryManager.consume_food(item_name)
		# You could add other item type handling here
