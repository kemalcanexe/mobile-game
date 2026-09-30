class_name Campus
extends Node3D
## Sonsuz kampüs yolu: parçalar (chunk) önde üretilir, arkada silinir.
## Her parça: 3 şeritli taş yol, bordür, çimen, lambalar, ağaçlar, banklar,
## iki yanda fakülte binaları. İçerik parça indeksine göre seed'li.

var theme: Dictionary
var cfg: Dictionary
var chunk_len := 28.0
var lane_w := 2.6
var _chunks := {}  # index -> Node3D
var _path_mat: StandardMaterial3D
var _grass_mat: StandardMaterial3D
var _curb_mat: StandardMaterial3D
var _line_mat: StandardMaterial3D
var _side_mat: StandardMaterial3D

const BUILDINGS := ["building-a", "building-b", "building-c", "building-d", "building-f", "building-g",
	"building-h", "building-i", "building-l", "building-m", "building-n", "building-j", "building-k"]


func setup(p_theme: Dictionary, p_cfg: Dictionary) -> void:
	theme = p_theme
	cfg = p_cfg
	chunk_len = float(cfg["world"]["chunkLength"])
	lane_w = float(cfg["laneWidth"])
	_path_mat = Models.mat(Color(theme["path"]), 0.95)
	_grass_mat = Models.mat(Color(theme["ground"]), 1.0)
	_curb_mat = Models.mat(Color(0.93, 0.93, 0.9), 0.8)
	_side_mat = Models.mat(Color(theme["path"]).darkened(0.12), 0.95)
	_line_mat = Models.mat(Color(theme["accent"]).lightened(0.35), 0.6)
	# Uzak zemin: parçaların ötesinde de çimen görünsün
	var far := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(400, 400)
	far.mesh = pm
	far.material_override = _grass_mat
	far.position = Vector3(0, -0.02, 0)
	far.name = "FarGround"
	add_child(far)


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
	var far: Node3D = get_node("FarGround")
	far.position.z = player_z - 120.0


func _build_chunk(i: int) -> Node3D:
	var c := Node3D.new()
	c.name = "Chunk%d" % i
	var z0 := -i * chunk_len
	c.position = Vector3(0, 0, z0 - chunk_len / 2.0)
	add_child(c)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(i * 7919 + 17)
	var road_w := lane_w * 3.0 + 1.4
	var side_w := float(cfg["world"]["sidewalkWidth"])
	_plane(c, Vector3(0, 0.0, 0), Vector2(road_w, chunk_len), _path_mat)
	# şerit çizgileri (kesik)
	for lx in [-lane_w / 2.0, lane_w / 2.0]:
		for k in 4:
			var dash := MeshInstance3D.new()
			var bm := BoxMesh.new()
			bm.size = Vector3(0.12, 0.02, 3.0)
			dash.mesh = bm
			dash.material_override = _line_mat
			dash.position = Vector3(lx, 0.01, -chunk_len / 2.0 + 3.5 + k * 7.0)
			dash.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			c.add_child(dash)
	for s in [-1.0, 1.0]:
		var edge: float = s * road_w / 2.0
		var curb := Models.box(Vector3(0.35, 0.22, chunk_len), Color.WHITE, Vector3(edge + s * 0.17, 0.11, 0))
		curb.material_override = _curb_mat
		c.add_child(curb)
		_plane(c, Vector3(edge + s * (0.35 + side_w / 2.0), 0.2, 0), Vector2(side_w, chunk_len), _side_mat)
		_plane(c, Vector3(edge + s * (0.35 + side_w + 12.0), 0.01, 0), Vector2(24.0, chunk_len), _grass_mat)
		_decorate_side(c, s, edge + s * 0.35, side_w, rng)
	# ara sıra karşıdan karşıya geçiş çizgileri ve kampüs tabelası
	if i > 0 and i % 6 == 0:
		_crosswalk(c, road_w)
	if i >= 0 and i % 4 == 1:
		_campus_sign(c, road_w, rng)
	return c


func _plane(parent: Node3D, pos: Vector3, size: Vector2, m: Material) -> void:
	var mi := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = size
	mi.mesh = pm
	mi.material_override = m
	mi.position = pos
	parent.add_child(mi)


func _decorate_side(c: Node3D, s: float, x0: float, side_w: float, rng: RandomNumberGenerator) -> void:
	var half := chunk_len / 2.0
	# lambalar: her parçada iki tane, yola bakar
	for k in 2:
		var lamp := Models.make("roads", "light-curved")
		lamp.position = Vector3(x0 + s * 0.5, 0.2, -half + 4.0 + k * 14.0)
		lamp.rotation.y = PI / 2.0 if s < 0 else -PI / 2.0
		c.add_child(lamp)
		if theme.get("lamps", false):
			var ol := OmniLight3D.new()
			ol.light_color = Color(theme["accent"]).lightened(0.4)
			ol.light_energy = 2.2
			ol.omni_range = 9.0
			ol.position = Vector3(x0 + s * 1.6, 5.8, lamp.position.z)
			c.add_child(ol)
	# bank ve çöp kutusu
	if rng.randf() < 0.7:
		var bench := Models.make("furniture", "bench")
		bench.position = Vector3(x0 + s * (side_w - 0.6), 0.2, -half + rng.randf_range(6, 12))
		bench.rotation.y = -PI / 2.0 if s < 0 else PI / 2.0
		c.add_child(bench)
		var bin := Models.make("furniture", "trashcan", 0.55)
		bin.position = bench.position + Vector3(0, 0, 2.2)
		c.add_child(bin)
	# çimende ağaçlar, çalılar, çiçekler
	var trees: Array = theme["trees"]
	for k in rng.randi_range(3, 5):
		var t := Models.make("nature", trees[rng.randi() % trees.size()], rng.randf_range(0.85, 1.25))
		t.position = Vector3(x0 + s * rng.randf_range(side_w + 1.8, side_w + 9.0), 0, -half + rng.randf_range(0, chunk_len))
		t.rotation.y = rng.randf() * TAU
		c.add_child(t)
	for k in rng.randi_range(2, 5):
		var names := ["plant_bush", "plant_bushLarge", "flower_redA", "flower_yellowA", "grass_large"]
		var b := Models.make("nature", names[rng.randi() % names.size()], rng.randf_range(0.9, 1.6))
		b.position = Vector3(x0 + s * rng.randf_range(side_w + 0.5, side_w + 7.0), 0, -half + rng.randf_range(0, chunk_len))
		Models.no_shadow(b)
		c.add_child(b)
	# fakülte binaları
	var setback := float(cfg["world"]["buildingSetback"])
	var z := -half
	while z < half:
		var bname: String = BUILDINGS[rng.randi() % BUILDINGS.size()]
		var b := Models.make("commercial", bname, rng.randf_range(0.95, 1.2))
		b.position = Vector3(s * (setback + rng.randf_range(2.0, 5.0)), 0, z + 6.0)
		b.rotation.y = PI / 2.0 if s < 0 else -PI / 2.0
		c.add_child(b)
		z += rng.randf_range(11.0, 15.0)


func _crosswalk(c: Node3D, road_w: float) -> void:
	for k in 8:
		var stripe := Models.box(Vector3(road_w * 0.9 / 8.0 * 0.6, 0.02, 2.2), Color(0.97, 0.97, 0.95),
				Vector3(-road_w * 0.45 + (k + 0.5) * road_w * 0.9 / 8.0, 0.012, 0))
		stripe.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		c.add_child(stripe)


## Yolun üstünden geçen bölüm tabelası (kapı kemeri).
func _campus_sign(c: Node3D, road_w: float, rng: RandomNumberGenerator) -> void:
	var accent := Color(theme["accent"])
	var h := 10.5
	var gate := Node3D.new()
	gate.position = Vector3(0, 0, rng.randf_range(-6, 6))
	for s in [-1.0, 1.0]:
		gate.add_child(Models.box(Vector3(0.6, h, 0.6), Color(0.95, 0.94, 0.9), Vector3(s * (road_w / 2.0 + 0.8), h / 2.0, 0)))
	var beam := Models.box(Vector3(road_w + 2.4, 1.4, 0.5), accent, Vector3(0, h - 0.4, 0))
	gate.add_child(beam)
	var txt := Models.label(theme["sign"], 120, Color.WHITE, accent.darkened(0.5))
	txt.position = Vector3(0, h - 0.4, 0.27)
	gate.add_child(txt)
	c.add_child(gate)
