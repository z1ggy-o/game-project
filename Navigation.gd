extends Navigation

signal send_path

const SPEED = 4

var begin = Vector3()
var end = Vector3() 
var m = SpatialMaterial.new()

var path = []
var draw_path = true

func _process(delta):

	if path.size() > 1:
		var to_walk = delta * SPEED
		var to_watch = Vector3(0, 1, 0)
		while to_walk > 0 and path.size() >= 2:
			var pfrom = path[path.size() - 1]
			var pto = path[path.size() - 2]
			to_watch = (pto - pfrom).normalized()
			var d = pfrom.distance_to(pto)
			print("distance", d)
			print("walk: ", to_walk)
			if d <= to_walk:
				path.remove(path.size() - 1)
				to_walk -= d
			else:
				path[path.size() - 1] = pfrom.linear_interpolate(pto, to_walk/d)
				to_walk = 0
		
		var atpos = path[path.size() - 1]
		var atdir = to_watch
		atdir.y = 0
		
		var t = Transform()
		t.origin = atpos
		t = t.looking_at(atpos + atdir, Vector3(0, 1, 0))
		get_node("Position").set_transform(t)
		
		if path.size() < 2:
			path = []
			set_process(false)
	else:
		set_process(false)
		
func _update_path():
	var p = get_simple_path(begin, end, true)
	path = Array(p)
	path.invert()
	set_process(true)
	
	if draw_path:
		var im = get_node("draw")
		im.set_material_override(m)
		im.clear()
		im.begin(Mesh.PRIMITIVE_POINTS, null)
		im.add_vertex(begin)
		im.add_vertex(end)
		im.end()
		im.begin(Mesh.PRIMITIVE_LINE_STRIP, null)
		for x in p:
			im.add_vertex(x)
		im.end()
"""
func _input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		var from = owner.get_node("Camera/Camera").project_ray_origin(event.position)
		var to = from + owner.get_node("Camera/Camera").project_ray_normal(event.position)*100
		var p = get_closest_point_to_segment(from, to, true)
		print(from, to)
		
		begin = get_closest_point(get_node("Position").get_translation())
		end = p
		print(get_node("Position").get_translation())
		print(begin, end)

		_update_path()
		"""
		
func _ready():
	set_process_input(true)

	m.flags_unshaded = true
	m.flags_use_point_size = true
	m.albedo_color = Color(1.0, 1.0, 1.0, 1.0)
	
func get_Navigation_path(begin, end):
	var end_point = get_closest_point(end)
	var begin_point = get_closest_point(begin)
	
	var p = get_simple_path(begin, end, true)
	var paths = []
	paths = Array(p)
	paths.invert()
	
	return paths

func _on_Enemy_navigate_path(begin, end):
	get_Navigation_path(begin, end)
	pass # Replace with function body.
