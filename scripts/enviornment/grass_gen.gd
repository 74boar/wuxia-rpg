extends MultiMeshInstance

export var bounds_mesh : Mesh

var mdt
var verts = []
var points = []

#func _ready():
#	yield(owner, "ready")
#	mdt = MeshDataTool.new()
#	mdt.create_from_surface(get_parent().mesh, 0)
#
#	get_valid_verts()
#	addGrass()


#func _process(delta):
#	for p in points:
#		DebugDraw.draw_cube(global_transform.xform(p), 0.2)


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
