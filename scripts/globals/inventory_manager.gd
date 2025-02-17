extends Node

var inventory: Dictionary = Dictionary()
var save_data_path: String = "user://game_data/inventory_data.tres"

signal inventory_changed

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
	print("Inventory save result: ", result)

func load_inventory() -> void:
	if not FileAccess.file_exists(save_data_path):
		return
		
	var save_resource = ResourceLoader.load(save_data_path)
	if save_resource and save_resource.has_meta("inventory_data"):
		inventory = save_resource.get_meta("inventory_data")
		inventory_changed.emit()  # Update any UI listening for changes
