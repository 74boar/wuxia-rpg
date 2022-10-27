extends Node

var _level_camera #the main camera in the level
var _level_camera_move #the kinematic body that moves the camera
var _rng = RandomNumberGenerator.new()

func _ready():
	_rng.randomize()


func mouse_to_world_coords(RAY_LENGTH : int = 10000):
	var from = _level_camera.project_ray_origin(get_viewport().get_mouse_position())
	var to = from + _level_camera.project_ray_normal(get_viewport().get_mouse_position()) * RAY_LENGTH
	var space_state = _level_camera.get_world().get_direct_space_state()
	return space_state.intersect_ray(from, to)


func raycast(from : Vector3, to : Vector3, mask : int = 0x7fffffff): #mask layer x = pow(2, x-1), mask layer x and y = pow(2, x-1) + pow(2, y-1)
	var space_state = _level_camera.get_world().direct_space_state
	return space_state.intersect_ray(from, to, [], mask)
