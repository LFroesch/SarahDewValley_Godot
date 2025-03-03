extends Node

# Predefined drop tables for different enemy types
const DROP_TABLES = {
	"common_enemy": [
		{"item": "res://scenes/objects/egg.tscn", "weight": 40, "min_count": 1, "max_count": 2},
		{"item": "res://scenes/objects/coin.tscn", "weight": 100, "min_count": 1, "max_count": 2},
		{"item": "res://scenes/objects/coin.tscn", "weight": 10, "min_count": 3, "max_count": 5},
		{"item": "res://scenes/objects/milk.tscn", "weight": 20, "count": 1}
	],
	"boss_enemy": [
		{"item": "res://scenes/objects/egg.tscn", "weight": 70, "min_count": 3, "max_count": 5},
		{"item": "res://scenes/objects/coin.tscn", "weight": 100, "min_count": 5, "max_count": 10},
		{"item": "res://scenes/objects/coin.tscn", "weight": 20, "min_count": 15, "max_count": 20},
		{"item": "res://scenes/objects/coin.tscn", "weight": 50, "min_count": 10, "max_count": 20},
		{"item": "res://scenes/objects/milk.tscn", "weight": 30, "min_count": 2, "max_count": 3}
	]
	#"quest_enemy": [
		#{"item": Father's Special Sword weight: 10 count 1
		#{"item": The Magic Pot weight: 10 count 1
		#{"item": Beans tm weight: 10 count 1
		#{"item": idfk weight: 10 count 1
	#]
}
const DEFAULT_MIN_DISTANCE = 7.0
const DEFAULT_SCATTER_RADIUS = {
	"common_enemy": 20.0,
	"boss_enemy": 50.0
}
const DEFAULT_DROP_CHANCE = {
	"common_enemy": 80,
	"boss_enemy": 100
}

# Function to handle drops when an enemy dies
func drop(position: Vector2, table_name: String = "common_enemy", custom_table: Array = [], parent_node = null) -> void:
	# Check if we should use a custom table or a predefined one
	var drop_table = custom_table if custom_table.size() > 0 else DROP_TABLES.get(table_name, DROP_TABLES["common_enemy"])
	
	# Get configuration values based on enemy type
	var scatter_radius = DEFAULT_SCATTER_RADIUS.get(table_name, 20.0)
	var drop_chance = DEFAULT_DROP_CHANCE.get(table_name, 80)
	
	# Random check if drops should happen at all (useful for common enemies)
	var drop_roll = randi_range(1, 100)
	if drop_roll > drop_chance:
		return
	
	# Select the drops
	var drops = select_drops(drop_table)
	
	# Scatter the drops
	var used_positions = []
	for loot_resource_path in drops:
		var loot = load(loot_resource_path).instantiate()
		var offset = get_random_position(used_positions, DEFAULT_MIN_DISTANCE, scatter_radius)
		used_positions.append(offset)
		loot.global_position = position + offset
		
		# Add the loot to the scene
		if parent_node:
			parent_node.call_deferred("add_child", loot)
		else:
			# If no parent is specified, add to current scene root
			get_tree().current_scene.call_deferred("add_child", loot)

# Helper function to select which items to drop
func select_drops(drop_table: Array) -> Array:
	var drops = []
	for drop in drop_table:
		var loot_roll = randi_range(1, 100)
		if loot_roll <= drop.get("weight", 0):
			var count = 1
			if "min_count" in drop and "max_count" in drop:
				count = randi_range(drop.min_count, drop.max_count)
			elif "count" in drop:
				count = drop.count
			
			for i in count:
				drops.append(drop.item)
	return drops

# Helper function to get a random position with minimum distance from other items
func get_random_position(existing_positions: Array, min_distance: float, scatter_radius: float) -> Vector2:
	var max_attempts = 10
	var attempt = 0
	
	while attempt < max_attempts:
		var angle = randf() * PI * 2
		var distance = randf() * scatter_radius
		var offset = Vector2(
			cos(angle) * distance,
			sin(angle) * distance
		)
		
		var is_valid = true
		for pos in existing_positions:
			if pos.distance_to(offset) < min_distance:
				is_valid = false
				break
		
		if is_valid:
			return offset
			
		attempt += 1
	
	# Fallback if we couldn't find a valid position
	var angle = randf() * PI * 2
	var distance = randf() * scatter_radius
	return Vector2(cos(angle) * distance, sin(angle) * distance)

# Convenience method for use in enemy scenes
func drop_for_enemy(enemy_type: String, position: Vector2, parent_node = null) -> void:
	match enemy_type:
		"goblin_barbarian":
			drop(position, "common_enemy", [], parent_node)
		"goblin_chief":
			drop(position, "boss_enemy", [], parent_node)
		"skeleton_warrior":
			drop(position, "common_enemy", [], parent_node)
		"skeleton_chief":
			drop(position, "boss_enemy", [], parent_node)
		_:
			drop(position, "common_enemy", [], parent_node)

# Advanced method for fully custom drops
func custom_drop(position: Vector2, custom_table: Array, scatter_radius: float = 20.0, 
				min_distance: float = DEFAULT_MIN_DISTANCE, parent_node = null) -> void:
	# This method allows for completely custom drop behavior
	var drops = select_drops(custom_table)
	var used_positions = []
	
	for loot_resource_path in drops:
		var loot = load(loot_resource_path).instantiate()
		var offset = get_random_position(used_positions, min_distance, scatter_radius)
		used_positions.append(offset)
		loot.global_position = position + offset
		
		if parent_node:
			parent_node.call_deferred("add_child", loot)
		else:
			get_tree().current_scene.call_deferred("add_child", loot)
