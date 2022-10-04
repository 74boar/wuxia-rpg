extends Camera

func _ready():
	Utils._level_camera = self


func _process(delta):
	update_cameras()


func update_cameras():
	#update transform of all cameras in the scene/tree
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME, "copy_cams", "set_global_transform", global_transform)
