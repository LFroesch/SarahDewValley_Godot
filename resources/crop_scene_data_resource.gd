# crop_scene_data_resource.gd
class_name CropSceneDataResource
extends SceneDataResource

@export var current_growth_state: int
@export var is_watered: bool
@export var starting_day: int

func _save_data(node: Node2D) -> void:
	super._save_data(node)
	
	var growth_component = node.get_node_or_null("GrowthCycleComponent")
	if growth_component:
		current_growth_state = growth_component.current_growth_state
		is_watered = growth_component.is_watered
		starting_day = growth_component.starting_day
	
func _load_data(window: Window) -> void:
	# Check if this crop is in harvesting state (assuming 5 is Harvesting from your DataTypes)
	if current_growth_state == 5: # DataTypes.GrowthStates.Harvesting
		# Get the parent node
		var parent_node = window.get_node_or_null(parent_node_path)
		if parent_node == null:
			push_error("Parent node not found for harvesting crop: " + node_name)
			return
			
		# Determine the harvest scene path based on the crop type
		var harvest_scene_path = ""
		if "corn" in scene_file_path.to_lower():
			harvest_scene_path = "res://scenes/objects/plants/corn_harvest.tscn"
		elif "tomato" in scene_file_path.to_lower():
			harvest_scene_path = "res://scenes/objects/plants/tomato_harvest.tscn"
		# Add other crops as needed
			
		if not harvest_scene_path.is_empty():
			# Create the harvest item
			var harvest_scene = load(harvest_scene_path)
			if harvest_scene:
				var harvest_instance = harvest_scene.instantiate()
				harvest_instance.global_position = global_position
				parent_node.add_child(harvest_instance)
				print("Created harvest item at: ", global_position)
		
		# Skip normal loading for harvesting crops
		return
	
	# Original loading code for non-harvesting crops
	await super._load_data(window)
	
	if node_path != null:
		await window.get_tree().process_frame
		
		var existing_node = window.get_node_or_null(node_path)
		if existing_node:
			var growth_component = existing_node.get_node_or_null("GrowthCycleComponent")
			if growth_component:
				growth_component.current_growth_state = current_growth_state
				growth_component.is_watered = is_watered
				growth_component.starting_day = starting_day
