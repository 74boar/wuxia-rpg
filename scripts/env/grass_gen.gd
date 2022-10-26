extends MultiMeshInstance

export var point_mesh : Mesh

var mdt
var verts = []
var points = []
var norms = []
var cross = []

#generation
export var scale_min := 0.8
export var scale_max := 1.2

func _ready():
	generate_grass()
#	var mm = multimesh
#	var num_instances = multimesh.instance_count
#	var proxy = get_node("grass_card_proxy")
#	var p1 = proxy.get_node("P1")
#	var p2 = proxy.get_node("P2")
#
#
#	#iterate over all grass instances
#	for i in num_instances:
#		var i_xform : Transform = multimesh.get_instance_transform(i)
#		var pos = i_xform.origin + global_transform.origin
#		var atlas_code = get_atlas_code()
#
#		#set proxy transform to instance transform
#		proxy.transform = i_xform
#		var p1_pos = p1.global_transform.origin
#		var p2_pos = p2.global_transform.origin
#
#		#set instance custom data
#		multimesh.set_instance_custom_data(i,Color(
#			p1_pos.x,
#			p1_pos.y,
#			p1_pos.z,
#			atlas_code
#		))
#
#		#test lerping b/w card endpoints
#		multimesh.set_instance_color(i,Color(
#			p2_pos.x,
#			p2_pos.y,
#			p2_pos.z,
#			1.0
#		))
	
	#set viewport texture
	var env_viewport : Viewport = get_node("/root/Game/env_ViewportContainer/Viewport")
	var t : Texture = env_viewport.get_texture()
	#t.flags = Texture.FLAG_VIDEO_SURFACE 
	t.flags = Texture.FLAG_FILTER  
	print(t.flags)
	material_override.set_shader_param("texture_viewport", t)


func generate_grass():
	mdt = MeshDataTool.new()
	mdt.create_from_surface(point_mesh, 0)
	
	#set number of instances to draw
	multimesh.instance_count = mdt.get_face_count()
	
	var proxy = get_node("grass_card_proxy")
	var p1 = proxy.get_node("P1")
	var p2 = proxy.get_node("P2")
	var p3 = proxy.get_node("P3")
	var p4 = proxy.get_node("P4")
	
	#for each vertex...
	for i in multimesh.instance_count:
		var face_normal : Vector3 = mdt.get_face_normal(i)
		var a : int = mdt.get_face_vertex(i, 0)
		var b : int = mdt.get_face_vertex(i, 1)
		var c : int = mdt.get_face_vertex(i, 2)
		var ap : Vector3 = mdt.get_vertex(a)
		var bp : Vector3 = mdt.get_vertex(b)
		var cp : Vector3 = mdt.get_vertex(c)
		var center : Vector3 = lerp(lerp(ap, bp, 0.5), cp, 0.5)
		var atlas_code : float = get_atlas_code()
		
		#randomize scale
		var x_scale = Utils._rng.randf_range(scale_min, scale_max)
		var y_scale = Utils._rng.randf_range(scale_min, scale_max)
		var scale_vec = Vector3(x_scale, y_scale, 1)
		proxy.scale = scale_vec
		
		#set proxy transform to instance transform
		#calculate flat
		if face_normal != Vector3.UP:
			proxy.look_at_from_position(center, center + face_normal, Vector3.UP)
		var p1_pos = p1.global_transform.origin
		var p2_pos = p2.global_transform.origin
		var p3_pos = p3.global_transform.origin
		var p4_pos = p4.global_transform.origin
		var t = lerp(p3_pos, p4_pos, 0.5)
		
		
		#recalculate "standing up"
		proxy.look_at_from_position(center, t, Vector3.UP)
		proxy.rotate_y(Utils._rng.randi_range(0, 180))
		p1_pos = p1.global_transform.origin
		p2_pos = p2.global_transform.origin
		
		#debug
		points.append(center)
		norms.append(center + face_normal)
		#cross.append(t)
		
		var norm = face_normal# + center
		
		#set instance custom data
		multimesh.set_instance_custom_data(i,Color(
			Utils._rng.randi_range(0, 1),
			p1_pos.y,
			p1_pos.z,
			atlas_code
		))
		
		#test lerping b/w card endpoints
		multimesh.set_instance_color(i,Color(
			norm.x,
			norm.y,
			norm.z,
			Utils._rng.randf_range(0.0, 0.6)
		))
		
		multimesh.set_instance_transform(i,proxy.transform)


func get_atlas_code() -> float:
	var x_range = [0, 1, 2]
	var y_range = [0]
	
	var x : float = Utils._rng.randi_range(0, x_range.size()-1)
	var y : float = Utils._rng.randi_range(0, y_range.size()-1)
	var code : float = x + (y / 10.0)
	return code


#func _ready():
#	yield(owner, "ready")
#	mdt = MeshDataTool.new()
#	mdt.create_from_surface(get_parent().mesh, 0)
#
#	get_valid_verts()
#	addGrass()


#DEBUG
#func _process(delta):
#	for i in points.size():
#		var p = points[i]
#		var n = norms[i]
#		var c = cross[i]
#		#DebugDraw.draw_cube(p, 0.2)
#		DebugDraw.draw_line_3d(p, n, Color.red)
#		DebugDraw.draw_line_3d(p, c, Color.green)


##Grass displacement
#func _process(delta):
#	var collider = get_tree().get_nodes_in_group("Grass_Colliders")[0]
#	self.material_override.set_shader_param("character_position", collider.global_transform.origin)
#	#print(collider.global_transform.origin)


#SOURCE: https://godotengine.org/qa/72233/how-to-distribute-meshes-within-triangle-face-bounds
func get_valid_verts():
	for i in mdt.get_face_count():
		
		var face_normal : Vector3 = mdt.get_face_normal(i)
#		if face_normal.z < -0.5: #do not add faces facing away from the camera
#			continue
		
		# Get the index in the vertex array.
		var a = mdt.get_face_vertex(i, 0)
		var b = mdt.get_face_vertex(i, 1)
		var c = mdt.get_face_vertex(i, 2)
		# Get vertex position using vertex index.
		var ap = mdt.get_vertex(a)
		var bp = mdt.get_vertex(b)
		var cp = mdt.get_vertex(c)
		#if mdt.get_vertex_color(a).r > 0.1: #USE FOR SPLAT MAP
		#verts.append({"verts":[ap,bp,cp],"vertcol":mdt.get_vertex_color(a)})
		verts.append({"verts":[ap,bp,cp],"facenorm":face_normal})


#returns a random point inside a triangle formed by vertices
func get_random_point_inside(vertices) -> Vector3:
	var a = Utils._rng.randf_range(0.0,1.0)
	var b = Utils._rng.randf_range(0.0,1.0)
	if  a > b:
		var t = b
		b = a
		a = t
	return vertices[0] * a + vertices[1] * (b - a) + vertices[2] * (1.0 - b)

func addGrass():
	for i in multimesh.instance_count:
		var xform = Transform()
		verts.shuffle()
		
		
		var randpos = get_random_point_inside(verts[0].verts)
		
		#Blue noise randomization (more even distribution)
		#get the candidate points
#		var candidates = PoolVector3Array()
#		var steps = 5
#		for j in steps:
#			candidates.append(global_transform.xform(get_random_point_inside(verts[0].verts)))
#		randpos = candidates[0] 
#		if points.size() > 0:
#			#choose point that is furthest from its closest point
#			var d = 0
#			for c in candidates:
#				var d_t = get_distance_from_closest_point(points, c)
#				if d_t  > d:
#					d = d_t
#					randpos = c

		var pos = randpos
		points.append(pos)
		
		#var face_normal = Vector3(verts[0].facenorm.r,verts[0].facenorm.g,verts[0].facenorm.b)
		var face_normal : Vector3 = verts[0].facenorm
		if face_normal.y < 0.5:
			continue
		
		var v_offset : float = Utils._rng.randi_range(-1, 1) * 1.0
		var time_offset = rand_range(0.0, 0.99)
		v_offset+=time_offset #store time in the decimal component
		
		multimesh.set_instance_custom_data(i,Color(
			pos.x,
			pos.y,
			pos.z,
			v_offset
		))
		
		xform.origin = pos# - global_transform.origin
		
		#xform = xform.scaled(Vector3(1.0, -1.0, 1.0))
		multimesh.set_instance_transform(i,xform)


func get_distance_from_closest_point(points : PoolVector3Array, c : Vector3):
	var d = 10000000
	var closest_point = points[0]
	for p in points:
		var d_t = p.distance_to(c)
		if d_t < d:
			d = d_t
			closest_point = p
	return d
