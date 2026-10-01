class_name Models
## Kenney modellerinin önbelleği ve ölçekli örnekleme.

static var _cache := {}


static func scene(kit: String, name: String) -> PackedScene:
	var key := kit + "/" + name
	if not _cache.has(key):
		var path := "res://assets/models/%s/%s.glb" % [kit, name]
		if not ResourceLoader.exists(path):
			path = "res://assets/models/%s/%s.gltf" % [kit, name]  # KayKit paketleri
		_cache[key] = load(path)
	return _cache[key]


## Modeli kitin metre ölçeğiyle örnekler; [param extra] ek çarpan.
static func make(kit: String, name: String, extra := 1.0) -> Node3D:
	var n: Node3D = scene(kit, name).instantiate()
	var s: float = float(Game.content.world_cfg["modelScale"][kit]) * extra
	n.scale = Vector3.ONE * s
	return n


## Gölge düşürmeyi kapatır (uzak ve küçük dekorlar için performans).
static func no_shadow(n: Node) -> void:
	if n is GeometryInstance3D:
		n.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for c in n.get_children():
		no_shadow(c)


static func mat(color: Color, rough := 0.85, emissive := 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = rough
	if emissive > 0.0:
		m.emission_enabled = true
		m.emission = color
		m.emission_energy_multiplier = emissive
	return m


static func box(size: Vector3, color: Color, pos := Vector3.ZERO) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	mi.mesh = bm
	mi.material_override = mat(color)
	mi.position = pos
	return mi


static func label(text: String, size: int, color: Color, outline := Color(0, 0, 0, 0.6)) -> Label3D:
	var l := Label3D.new()
	l.text = text
	l.font = UiKit.font()
	l.font_size = size
	l.outline_size = maxi(4, size / 8)
	l.modulate = color
	l.outline_modulate = outline
	l.pixel_size = 0.01
	return l
