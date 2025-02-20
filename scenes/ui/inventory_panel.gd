extends PanelContainer

@onready var log_label: Label = $MarginContainer/VBoxContainer/Logs/LogLabel
@onready var stone_label: Label = $MarginContainer/VBoxContainer/Stone/StoneLabel
@onready var tomato_label: Label = $MarginContainer/VBoxContainer/Tomato/TomatoLabel
@onready var egg_label: Label = $MarginContainer/VBoxContainer/Egg/EggLabel
@onready var milk_label: Label = $MarginContainer/VBoxContainer/Milk/MilkLabel
@onready var corn_label: Label = $MarginContainer/VBoxContainer/Corn/CornLabel
@onready var coin_label: Label = $MarginContainer/VBoxContainer/Coins/CoinLabel

@onready var egg_texture = $MarginContainer/VBoxContainer/Egg/TextureRect
@onready var milk_texture = $MarginContainer/VBoxContainer/Milk/TextureRect
@onready var corn_texture = $MarginContainer/VBoxContainer/Corn/TextureRect
@onready var tomato_texture = $MarginContainer/VBoxContainer/Tomato/TextureRect

func _ready() -> void:
	InventoryManager.inventory_changed.connect(on_inventory_changed)
	
	# Make textures clickable
	egg_texture.mouse_filter = Control.MOUSE_FILTER_STOP
	milk_texture.mouse_filter = Control.MOUSE_FILTER_STOP
	corn_texture.mouse_filter = Control.MOUSE_FILTER_STOP
	tomato_texture.mouse_filter = Control.MOUSE_FILTER_STOP

	# Connect gui input signals
	egg_texture.gui_input.connect(func(event): _on_food_input(event, "egg"))
	milk_texture.gui_input.connect(func(event): _on_food_input(event, "milk"))
	corn_texture.gui_input.connect(func(event): _on_food_input(event, "corn"))
	tomato_texture.gui_input.connect(func(event): _on_food_input(event, "tomato"))

func _on_food_input(event: InputEvent, food_name: String) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		InventoryManager.consume_food(food_name)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("egg"):
		print("eating egg")
		InventoryManager.consume_food("egg")
	elif event.is_action_pressed("milk"):
		InventoryManager.consume_food("milk")
		print("eating milk")
		
func on_inventory_changed() -> void:
	var inventory: Dictionary = InventoryManager.inventory
	
	if inventory.has("log"):
		log_label.text = str(inventory["log"])
		
	if inventory.has("egg"):
		egg_label.text = str(inventory["egg"])
	
	if inventory.has("milk"):
		milk_label.text = str(inventory["milk"])
		
	if inventory.has("stone"):
		stone_label.text = str(inventory["stone"])
		
	if inventory.has("corn"):
		corn_label.text = str(inventory["corn"])
		
	if inventory.has("tomato"):
		tomato_label.text = str(inventory["tomato"])
	
	if inventory.has("coin"):
		coin_label.text = str(inventory["coin"])
		
