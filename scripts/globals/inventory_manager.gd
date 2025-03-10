#inventory_manager.gd
extends Node

var inventory: Dictionary = Dictionary()
var save_data_path: String = "user://game_data/inventory_data.tres"

signal inventory_changed

# items / values

var item_descriptions = {
	"log" : "a big wooden log",
	"stone" : "a decent sized rock"
}

var coin_values = {
	"log" : 3,
	"stone" : 5,
	"healing_potion" : 25,
}

var food_healing_values = {
	"egg": 15,
	"milk": 20,
	"corn": 10,
	"tomato": 10,
	"healing_potion": 50
	}

signal health_recovered(amount: int)

func consume_food(food_name: String) -> bool:
		
	if not inventory.has(food_name) or inventory[food_name] <= 0:
		return false

	if not food_healing_values.has(food_name):
		return false

	remove_collectible(food_name)

	var heal_amount = food_healing_values[food_name]
	health_recovered.emit(heal_amount)

	return true

func add_collectible(collectible_name: String) -> void:
	inventory.get_or_add(collectible_name)
	QuestManager.record_item_collection(collectible_name, 1)
	if inventory[collectible_name] == null:
		inventory[collectible_name] = 1
	else:
		inventory[collectible_name] += 1
	inventory_changed.emit()
	
func save_inventory() -> void:
	var save_resource = Resource.new()
	save_resource.set_meta("inventory_data", inventory)
	var result = ResourceSaver.save(save_resource, save_data_path)

func reset_inventory() -> void:
	var main_inventory_items = ["egg", "milk", "corn", "tomato", "coin"]
	var items_to_remove = []
	for collectible_name in inventory:
		if collectible_name in main_inventory_items:
			inventory[collectible_name] = 0
		else:
			items_to_remove.append(collectible_name)
	
	for item in items_to_remove:
		inventory.erase(item)
	
	inventory_changed.emit()
	save_inventory()

func load_inventory() -> void:
	if not FileAccess.file_exists(save_data_path):
		return
		
	var save_resource = ResourceLoader.load(save_data_path)
	if save_resource and save_resource.has_meta("inventory_data"):
		inventory = save_resource.get_meta("inventory_data")
		inventory_changed.emit()

func remove_collectible(collectible_name: String) -> void:
	var main_inventory_items = ["egg", "milk", "corn", "tomato", "coin"]
	
	# Only proceed if the item exists in inventory
	if collectible_name in inventory:
		if inventory[collectible_name] > 0:
			inventory[collectible_name] -= 1
			# If it's not a main item and count reaches 0, remove it completely
			if inventory[collectible_name] == 0 and not (collectible_name in main_inventory_items):
				inventory.erase(collectible_name)
	
	inventory_changed.emit()
