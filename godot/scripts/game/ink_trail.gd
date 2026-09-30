class_name InkTrail
extends MeshInstance3D
## Tüki'nin arkasında yere çizilen mürekkep şeridi. Havadayken kesilir
## ("kalem kaldır"); mürekkep azalınca silikleşir.

var max_points := 90
var spacing := 0.35
var width := 0.14
var color := Color("#1F3A93")
var _pts: Array[Vector3] = []
var _gaps: Array[bool] = []
var _mesh := ImmediateMesh.new()
var _mat := StandardMaterial3D.new()


func _ready() -> void:
	mesh = _mesh
	_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_mat.vertex_color_use_as_albedo = true
	_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	material_override = _mat
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	top_level = true
	global_transform = Transform3D.IDENTITY


func add_point(p: Vector3, airborne: bool) -> void:
	if not _pts.is_empty() and _pts[-1].distance_to(p) < spacing:
		return
	_pts.append(Vector3(p.x, 0.025, p.z))
	_gaps.append(airborne)
	if _pts.size() > max_points:
		_pts.pop_front()
		_gaps.pop_front()


func redraw(low_ink: bool) -> void:
	_mesh.clear_surfaces()
	if _pts.size() < 2:
		return
	var n := _pts.size()
	var drawn: Array[int] = []
	for i in range(1, n):
		if _gaps[i] or _gaps[i - 1]:
			continue
		if low_ink and i % 3 == 0:
			continue  # mürekkep azsa kesik kesik
		drawn.append(i)
	# uzun uçuşta (rampa, ay yerçekimi) çizilecek parça kalmayabilir
	if drawn.is_empty():
		return
	_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in drawn:
		var a := _pts[i - 1]
		var b := _pts[i]
		var side := Vector3(width / 2.0, 0, 0)
		var alpha := float(i) / n
		var c := Color(color, alpha * (0.45 if low_ink else 0.95))
		for v in [a - side, a + side, b + side, a - side, b + side, b - side]:
			_mesh.surface_set_color(c)
			_mesh.surface_add_vertex(v)
	_mesh.surface_end()
