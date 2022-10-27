extends KinematicBody

onready var _pitch_tween = find_node("Pitch_Tween")
onready var _pivot_tween = find_node("Pivot_Tween")
onready var _zoom_tween = find_node("Zoom_Tween")
onready var _pitch = find_node("Cam_Pitch")
onready var _pivot = find_node("Cam_Pivot")
onready var _stick = find_node("Cam_Stick")
onready var _cam = find_node("LevelCamera")

var velocity = Vector3()
var friction = 0.05
var move_speed = 18
var snap_speed = 30
var zoom_speed = 5
var rotate_speed = 1.125

var default_pitch = -60
var topdown_pitch = -90
var is_topdown = false
var pitch_time = 0.2
var pivot_time = 0.5
var zoom_time = 0.15


var min_zoom = 0
var max_zoom = 25

var follow_target = null setget set_follow_target
var follow_target_tag_distance = 4

func _ready():
	Utils._level_camera_move = self
	
	#disable physics interpolation
	#set_physics_interpolation_mode(Node.PHYSICS_INTERPOLATION_MODE_OFF)


func get_input() -> Vector3:
	var input_dir = Vector3()
	# Cam rotation
	if Input.is_action_pressed("rotate_left") and !_pivot_tween.is_active():
		set_cam_rotate(_pivot.rotation_degrees.y + rotate_speed)
	if Input.is_action_pressed("rotate_right") and !_pivot_tween.is_active():
		set_cam_rotate(_pivot.rotation_degrees.y - rotate_speed)
	#Cam Zoom
	if Input.is_action_just_released("zoom_in"):
		var current_zoom = _stick.transform.origin.z
		var zoom_target = clamp(current_zoom + (zoom_speed * -1), min_zoom, max_zoom)
		set_zoom(zoom_target)
	if Input.is_action_just_released("zoom_out"):
		var current_zoom = _stick.transform.origin.z
		var zoom_target = clamp(current_zoom + zoom_speed, min_zoom, max_zoom)
		set_zoom(zoom_target)
	
	#Cam Movement
	if Input.is_action_pressed("move_forward"):
		input_dir += -_pivot.global_transform.basis.z
	if Input.is_action_pressed("move_back"):
		input_dir += _pivot.global_transform.basis.z
	if Input.is_action_pressed("move_left"):
		input_dir += -_pivot.global_transform.basis.x
	if Input.is_action_pressed("move_right"):
		input_dir += _pivot.global_transform.basis.x
	if Input.is_action_just_pressed("toggle_topdown_view"):
		var target_pitch = topdown_pitch
		if is_topdown:
			target_pitch = default_pitch
			is_topdown = false
		else:
			is_topdown = true
		_pitch_tween.interpolate_property(_pitch, "rotation_degrees:x", _pitch.rotation_degrees.x, target_pitch, pitch_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		_pitch_tween.start()
	
	return input_dir.normalized()


func set_zoom(zoom_target):
	#_stick.transform.origin.z = zoom_target
	_zoom_tween.interpolate_property(_stick, "transform:origin:z", _stick.transform.origin.z, zoom_target, zoom_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	_zoom_tween.start()


func set_cam_rotate(rotate_target):
	_pivot.rotation_degrees.y = rotate_target


func set_follow_target(target):
	follow_target = target


func clear_follow_target():
	follow_target = null


func _process(_delta):
	#update nodes that move with this node
	#copy_move()
	
	#adjust obstacle projection camera UV offset
#	var proj_cam = $"%Projection_Camera"
#	#var proj_cam = Utils._level_camera
#	var uv_origin = proj_cam.unproject_position(Vector3.ZERO)
#	var uv_offset = proj_cam.unproject_position(global_transform.origin)
#	$"%Env_UI".material.set_shader_param("offset", uv_origin - uv_offset)
	
	#input
	var desired_velocity = get_input() * move_speed * (_stick.transform.origin.z / (max_zoom * 1.0))
	
	#Case: we are following something
	if follow_target:
		var from = global_transform.origin
		var to = follow_target.get_global_transform_interpolated().origin
		var d = from.distance_to(to)
		var step = 0.025
		global_transform.origin = lerp(from, to, step)
		
		desired_velocity = Vector3.ZERO
		velocity = (to-from).normalized() * snap_speed #this will be used when follow_target = null to get a fade-out on snap
		return
	
	#input, accelerate
	if desired_velocity.length() > 0:
		velocity = desired_velocity
	else:
		#No input, de-accelerate
		velocity = velocity.linear_interpolate(Vector3.ZERO, friction)
	
	#move
	velocity = move_and_slide(velocity, Vector3.UP)
	
	#update call cameras to match level camera
	_cam.update_cameras()



func copy_move():
	#update transform of all cameras in the scene/tree
	for n in get_tree().get_nodes_in_group("copy_move"):
		var to_pos = global_transform.origin
		to_pos.y = 10
		n.global_transform.origin = to_pos
		#n.reset_physics_interpolation()
