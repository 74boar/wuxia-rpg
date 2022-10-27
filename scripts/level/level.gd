extends Spatial

export var test_radius = 1.0
var colliding = false
var focus_entity #the entity around which the cutout effect occurs
var head_offset = Vector3(0, -3, 0)  #TODO: remove head offset

const CUTOUT_MATS = [
	preload("res://resources/materials/Cutout.material")
]
const TEST_DIRECTIONS = [
	Vector3(0, 0, 0), #center
	Vector3(0, 0, 1), #forward
	Vector3(0, 0, -1), #backward
	Vector3(1, 0, 0), #right
	Vector3(-1, 0, 0), #left
]

#Debug, should be set by player
func _ready():
	focus_entity = Utils._level_camera_move


func _process(delta):
	if !focus_entity:
		return
	
	#raycast to camera
	var result = cast_to_camera()
	if result && result["collider"]: #TODO: apply collision mask so only cutout objects can trigger this
		colliding = true #true until 
		apply_cutout()
	elif colliding: #case we are no longer colliding with something
		colliding = false
		remove_cutout()


func apply_cutout():
	#for each cutout material
	for m in CUTOUT_MATS:
		var screen_pos : Vector2 = Utils._level_camera.unproject_position(focus_entity.global_transform.origin + head_offset) #TODO: remove head offset
		m.set_shader_param("cutout_screen_pos", screen_pos)


func remove_cutout():
	#for each cutout material
	for m in CUTOUT_MATS:
		var out_of_bounds = Vector2(-1000.0, -1000.0)
		m.set_shader_param("cutout_screen_pos", out_of_bounds)


func cast_to_camera() -> Dictionary:
	var origin_pos = focus_entity.global_transform.origin
	var camera_pos = Utils._level_camera.global_transform.origin
	var result : Dictionary
	
	for dir in TEST_DIRECTIONS:
		result = Utils.raycast(origin_pos + (dir * test_radius), camera_pos) #TODO apply offset to camera as well?
		if result and result["collider"]:
			return result #return first collision
	return result
