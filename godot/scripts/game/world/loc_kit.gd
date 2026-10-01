class_name LocKit
## Mekân inşa araçları. Bir parçadaki kutular BoxBatch ile tek MultiMesh
## çizimine toplanır (telefonda çizim çağrısı az kalır); malzemeler önbelleklenir.

static var _mats := {}
static var _shaders := {}
static var _box_mesh: BoxMesh
static var _cyl_mesh: CylinderMesh


static func mat(c: Color, rough := 0.7, emit := 0.0, metal := 0.0) -> StandardMaterial3D:
	var key := "%s|%.2f|%.2f|%.2f" % [c.to_html(), rough, emit, metal]
	if not _mats.has(key):
		var m := StandardMaterial3D.new()
		m.albedo_color = c
		m.roughness = rough
		m.metallic = metal
		if emit > 0.0:
			m.emission_enabled = true
			m.emission = c
			m.emission_energy_multiplier = emit
		_mats[key] = m
	return _mats[key]


## Yarı saydam cam / ışık hüzmesi.
static func glass(c: Color, alpha: float, unshaded := false) -> StandardMaterial3D:
	var key := "glass|%s|%.2f|%s" % [c.to_html(), alpha, unshaded]
	if not _mats.has(key):
		var m := StandardMaterial3D.new()
		m.albedo_color = Color(c, alpha)
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		m.roughness = 0.1
		m.cull_mode = BaseMaterial3D.CULL_DISABLED
		if unshaded:
			m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_mats[key] = m
	return _mats[key]


## Dünya uzayı desenli zemin shader'ı (res://assets/shaders/<ad>.gdshader).
static func shader(name: String, params: Dictionary = {}) -> ShaderMaterial:
	var key := name + JSON.stringify(params)
	if not _shaders.has(key):
		var sm := ShaderMaterial.new()
		sm.shader = load("res://assets/shaders/%s.gdshader" % name)
		for k in params:
			var v = params[k]
			sm.set_shader_parameter(k, Color(v) if v is String else v)
		_shaders[key] = sm
	return _shaders[key]


static func unit_box() -> BoxMesh:
	if _box_mesh == null:
		_box_mesh = BoxMesh.new()
		_box_mesh.size = Vector3.ONE
	return _box_mesh


static func unit_cyl() -> CylinderMesh:
	if _cyl_mesh == null:
		_cyl_mesh = CylinderMesh.new()
		_cyl_mesh.top_radius = 0.5
		_cyl_mesh.bottom_radius = 0.5
		_cyl_mesh.height = 1.0
		_cyl_mesh.radial_segments = 16
	return _cyl_mesh


static func box(parent: Node3D, size: Vector3, pos: Vector3, m: Material, shadow := true) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = unit_box()
	mi.scale = size
	mi.material_override = m
	mi.position = pos
	if not shadow:
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mi)
	return mi


static func plane(parent: Node3D, size: Vector2, pos: Vector3, m: Material) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = size
	mi.mesh = pm
	mi.material_override = m
	mi.position = pos
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mi)
	return mi


static func label(parent: Node3D, text: String, size: int, color: Color, outline: Color, pos: Vector3, rot_y := 0.0) -> Label3D:
	var l := Label3D.new()
	l.text = text
	l.font = UiKit.font()
	l.font_size = size
	l.pixel_size = 0.01
	l.modulate = color
	l.outline_size = maxi(4, size / 9)
	l.outline_modulate = outline
	l.position = pos
	l.rotation.y = rot_y
	parent.add_child(l)
	return l


static func omni(parent: Node3D, pos: Vector3, c: Color, energy: float, rng_m: float) -> OmniLight3D:
	var l := OmniLight3D.new()
	l.light_color = c
	l.light_energy = energy
	l.omni_range = rng_m
	l.position = pos
	parent.add_child(l)
	return l


static func model(parent: Node3D, kit: String, name: String, pos: Vector3, rot_y := 0.0, s := 1.0, shadow := true) -> Node3D:
	var n := Models.make(kit, name, s)
	if not shadow:
		Models.no_shadow(n)
	n.position = pos
	n.rotation.y = rot_y
	parent.add_child(n)
	return n


## Kutuları tek MultiMesh'e toplar. add() ile ekle, flush() ile sahneye koy.
class BoxBatch:
	var items: Array = []
	var rough := 0.7
	var mesh: Mesh
	## Verilirse örnek renkleri yerine bu malzeme kullanılır (parlak pencere, cam).
	var material: Material

	func _init(p_rough := 0.7, p_mesh: Mesh = null, p_material: Material = null) -> void:
		rough = p_rough
		mesh = p_mesh if p_mesh else LocKit.unit_box()
		material = p_material

	func add(size: Vector3, pos: Vector3, c := Color.WHITE, rot := Vector3.ZERO) -> void:
		# ölçek yerel eksenlerde, sonra döndür
		var b := Basis.from_euler(rot) * Basis.from_scale(size) if rot != Vector3.ZERO else Basis.from_scale(size)
		items.append([Transform3D(b, pos), c])

	func add_xform(t: Transform3D, c: Color) -> void:
		items.append([t, c])

	func flush(parent: Node3D, shadow := true) -> MultiMeshInstance3D:
		if items.is_empty():
			return null
		var mm := MultiMesh.new()
		mm.transform_format = MultiMesh.TRANSFORM_3D
		mm.use_colors = true
		mm.mesh = mesh
		mm.instance_count = items.size()
		for i in items.size():
			mm.set_instance_transform(i, items[i][0])
			mm.set_instance_color(i, items[i][1])
		var mmi := MultiMeshInstance3D.new()
		mmi.multimesh = mm
		mmi.material_override = material if material else LocKit.vertex_color_mat(rough)
		if not shadow:
			mmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		parent.add_child(mmi)
		items.clear()
		return mmi


static func vertex_color_mat(rough: float) -> StandardMaterial3D:
	var key := "vc|%.2f" % rough
	if not _mats.has(key):
		var m := StandardMaterial3D.new()
		m.vertex_color_use_as_albedo = true
		m.roughness = rough
		_mats[key] = m
	return _mats[key]
