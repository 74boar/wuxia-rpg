extends Node

var _level_camera #the main camera in the level
var _level_camera_move #the kinematic body that moves the camera
var _rng = RandomNumberGenerator.new()

func _ready():
	_rng.randomize()
