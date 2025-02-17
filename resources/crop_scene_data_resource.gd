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
	super._load_data(window)
	
	if node_path != null:
		var existing_node = window.get_node_or_null(node_path)
		if existing_node:
			var growth_component = existing_node.get_node_or_null("GrowthCycleComponent")
			if growth_component:
				growth_component.current_growth_state = current_growth_state
				growth_component.is_watered = is_watered
				growth_component.starting_day = starting_day
