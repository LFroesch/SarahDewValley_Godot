# save_crop_data_component.gd
class_name SaveCropDataComponent
extends SaveDataComponent

func _create_save_data_resource() -> Resource:
	return CropSceneDataResource.new()
