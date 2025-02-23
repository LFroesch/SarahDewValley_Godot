extends Node

var inventory: Dictionary = Dictionary()
var save_data_path: String = "user://game_data/inventory_data.tres"

signal inventory_changed

var food_healing_values = {
	"egg": 15,
	"milk": 20,
	"corn": 10,
	"tomato": 10
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
	for collectible_name in inventory:
		inventory[collectible_name] = 0
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
	inventory.get_or_add(collectible_name)
	if inventory[collectible_name] == null:
		inventory[collectible_name] = 0
	else:
		if inventory[collectible_name] > 0:
			inventory[collectible_name] -= 1
	inventory_changed.emit()
