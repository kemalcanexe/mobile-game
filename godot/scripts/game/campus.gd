class_name Campus
extends Node3D
## Sonsuz kampüs yolu: mekânın parçaları (chunk) önde üretilir, arkada silinir.
## Parçanın içeriğini Location alt sınıfı kurar (Meydan, Kütüphane, Yemekhane,
## Laboratuvar, Spor Salonu); içerik parça indeksine göre seed'li.

var location: Location
var cfg: Dictionary
var preset: Dictionary
var chunk_len := 30.0
var _chunks := {}  # index -> Node3D
var _far: MeshInstance3D
var _dust: CPUParticles3D


## loc_id: "quad" | "library" | "cafeteria" | "lab" | "gym"; course_theme: dersin rengi ve tabelası.
func setup(loc_id: String, p_preset: Dictionary, course_theme: Dictionary, p_cfg: Dictionary) -> void:
	cfg = p_cfg
	preset = p_preset
	chunk_len = float(cfg["world"]["chunkLength"])
	location = Location.create(loc_id)
	location.setup(loc_id, preset, cfg, Color(course_theme.get("accent", "#2E6BFF")), str(course_theme.get("sign", preset["sign"])))
	# uzak zemin: parçaların ötesi boş görünmesin
	_far = MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(400, 400)
	_far.mesh = pm
	_far.material_override = LocKit.mat(Color(preset["far"]), 1.0)
	_far.position = Vector3(0, -0.03, 0)
	_far.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_far)
	if loc_id == "library" or loc_id == "lab":
		_dust = _make_dust(Color("#FFE9C0") if loc_id == "library" else Color("#CFF6FF"))
		add_child(_dust)


## Oyuncunun z'sine göre parçaları güncel tutar (z eksi yönde ilerler).
func update_for(player_z: float) -> void:
	var cur := int(floor(-player_z / chunk_len))
	var ahead := int(cfg["world"]["chunksAhead"])
	for i in range(cur - 1, cur + ahead + 1):
		if i >= -1 and not _chunks.has(i):
			_chunks[i] = _build_chunk(i)
	for i in _chunks.keys():
		if i < cur - 1:
			_chunks[i].queue_free()
			_chunks.erase(i)
	_far.position.z = player_z - 120.0
	if _dust:
		_dust.position = Vector3(0, 3.0, player_z - 14.0)


func _build_chunk(i: int) -> Node3D:
	var c := Node3D.new()
	c.name = "Chunk%d" % i
	c.position = Vector3(0, 0, -i * chunk_len - chunk_len / 2.0)
	add_child(c)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(i * 7919 + 17)
	location.build_chunk(c, i, rng)
	return c


## Işıkta süzülen toz zerreleri (kütüphane, laboratuvar).
func _make_dust(col: Color) -> CPUParticles3D:
	var p := CPUParticles3D.new()
	p.amount = 90
	p.lifetime = 8.0
	p.preprocess = 8.0
	p.local_coords = false
	p.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	p.emission_box_extents = Vector3(7, 3, 18)
	p.gravity = Vector3(0, 0.02, 0)
	p.initial_velocity_min = 0.02
	p.initial_velocity_max = 0.1
	var qm := QuadMesh.new()
	qm.size = Vector2(0.09, 0.09)
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	m.albedo_texture = Fx._glow_texture()
	m.albedo_color = Color(col, 0.7)
	qm.material = m
	p.mesh = qm
	return p
