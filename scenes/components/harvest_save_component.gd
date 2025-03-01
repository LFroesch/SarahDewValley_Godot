class_name HarvestSaveComponent
extends SaveDataComponent

@export var collectible_name: String = ""

func _ready() -> void:
	add_to_group("save_data_component")
	
	# Get the collectible name from the parent if available
	var collectible_component = get_parent().get_node_or_null("CollectibleComponent")
	if collectible_component and collectible_name.is_empty():
		collectible_name = collectible_component.collectible_name
	
	# Create the proper resource if not yet set
	if save_data_resource == null:
		save_data_resource = _create_save_data_resource()

func _create_save_data_resource() -> Resource:
	# Create a scene data resource (or use your CropSceneDataResource if needed)
	var resource = SceneDataResource.new()
	return resource
