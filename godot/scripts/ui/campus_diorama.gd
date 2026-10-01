class_name CampusDiorama
extends Node3D
## Ana menüdeki kampüs maketi: ada şeklinde bir kaide üzerinde beş sınav
## mekânının binaları, ortada meydan ve çeşme, yollar, ağaçlar, fenerler.
## Her binanın üstünde mekân adı ve orada yapılan sınav yazar.

const ISLAND_R := 10.0

## Binaların yerleşimi: mekân → (konum, dönüş, sınav anahtarı)
const SPOTS := {
	"library": [Vector3(-5.2, 0, -3.6), 0.6],
	"gym": [Vector3(5.4, 0, -3.4), -0.6],
	"cafeteria": [Vector3(-5.6, 0, 3.8), 2.4],
	"lab": [Vector3(5.6, 0, 3.6), -2.4],
}

var tuki: TukiModel
## Bina etiketleri (arka taraftakiler kamera döndükçe söner).
var _labels_by_spot: Array[Label3D] = []


func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 2026
	_island()
	var b := LocKit.BoxBatch.new(0.7)
	_paths(b)
	_plaza(b)
	_library(b, SPOTS["library"][0], SPOTS["library"][1])
	_gym(b, SPOTS["gym"][0], SPOTS["gym"][1])
	_cafeteria(b, SPOTS["cafeteria"][0], SPOTS["cafeteria"][1])
	_lab(b, SPOTS["lab"][0], SPOTS["lab"][1])
	b.flush(self)
	_trees(rng)
	_labels()
	tuki = TukiModel.new()
	tuki.scale = Vector3.ONE * 0.62
	tuki.position = Vector3(0, 0.62, 1.9)
	add_child(tuki)
	tuki.emote("wave")


func _island() -> void:
	var top := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = ISLAND_R
	cm.bottom_radius = ISLAND_R
	cm.height = 0.4
	cm.radial_segments = 64
	top.mesh = cm
	top.position.y = 0.2
	top.material_override = LocKit.shader("grass", {"grass_a": "#3F8F35", "grass_b": "#6CB548", "stripe": 1.5})
	add_child(top)
	var soil := MeshInstance3D.new()
	var sm := CylinderMesh.new()
	sm.top_radius = ISLAND_R
	sm.bottom_radius = ISLAND_R * 0.82
	sm.height = 2.2
	sm.radial_segments = 64
	soil.mesh = sm
	soil.position.y = -1.1
	soil.material_override = LocKit.mat(Color("#8A5A3C"), 0.95)
	add_child(soil)
	var rim := MeshInstance3D.new()
	var tm := TorusMesh.new()
	tm.inner_radius = ISLAND_R - 0.15
	tm.outer_radius = ISLAND_R + 0.12
	tm.rings = 64
	rim.mesh = tm
	rim.scale = Vector3(1, 0.5, 1)
	rim.position.y = 0.36
	rim.material_override = LocKit.mat(Color("#CFC6B6"), 0.8)
	add_child(rim)


func _paths(b: LocKit.BoxBatch) -> void:
	var stone := Color("#D8C6A6")
	for k in SPOTS:
		var p: Vector3 = SPOTS[k][0]
		var d := p.length()
		var ang := atan2(p.x, p.z)
		b.add(Vector3(1.1, 0.06, d - 1.5), Vector3(p.x * 0.5, 0.42, p.z * 0.5), stone, Vector3(0, ang, 0))
	var plaza := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 2.8
	cm.bottom_radius = 2.8
	cm.height = 0.08
	cm.radial_segments = 48
	plaza.mesh = cm
	plaza.position.y = 0.43
	plaza.material_override = LocKit.shader("paving", {"stone_a": "#D9C8A8", "stone_b": "#C0AC8A", "joint": "#7D6E5C", "stone": Vector2(0.45, 0.3)})
	add_child(plaza)


## Meydan: saat kulesi ve çeşme.
func _plaza(b: LocKit.BoxBatch) -> void:
	LocKit.model(self, "fantasy", "fountain-round-detail", Vector3(0, 0.45, -0.6), 0.0, 0.7)
	var tz := -2.6
	b.add(Vector3(1.0, 4.4, 1.0), Vector3(0, 2.6, tz), Color("#E7D7B8"))
	b.add(Vector3(1.2, 0.25, 1.2), Vector3(0, 4.85, tz), Color("#F4EFE4"))
	b.add(Vector3(0.8, 0.8, 0.02), Vector3(0, 4.1, tz + 0.51), Color("#FFFFFF"))
	b.add(Vector3(0.04, 0.3, 0.03), Vector3(0, 4.18, tz + 0.53), Color("#1E2A3A"))
	b.add(Vector3(0.22, 0.04, 0.03), Vector3(0.08, 4.1, tz + 0.53), Color("#1E2A3A"))
	var roof := MeshInstance3D.new()
	var pm := PrismMesh.new()
	pm.size = Vector3(1.3, 1.0, 1.3)
	roof.mesh = pm
	roof.position = Vector3(0, 5.5, tz)
	roof.material_override = LocKit.mat(Color("#7A3B2E"), 0.7)
	add_child(roof)


func _xf(base: Vector3, rot: float, local: Vector3) -> Vector3:
	return base + local.rotated(Vector3.UP, rot)


## Kütüphane: sütunlu klasik bina ve kubbe.
func _library(b: LocKit.BoxBatch, p: Vector3, r: float) -> void:
	b.add(Vector3(4.2, 2.4, 3.0), _xf(p, r, Vector3(0, 1.6, 0)), Color("#E7D7B8"), Vector3(0, r, 0))
	b.add(Vector3(4.5, 0.3, 3.3), _xf(p, r, Vector3(0, 2.95, 0)), Color("#F4EFE4"), Vector3(0, r, 0))
	for k in 5:
		b.add(Vector3(0.32, 2.0, 0.32), _xf(p, r, Vector3(-1.6 + k * 0.8, 1.4, 1.7)), Color("#F4EFE4"), Vector3(0, r, 0))
	b.add(Vector3(4.0, 0.25, 0.8), _xf(p, r, Vector3(0, 2.5, 1.6)), Color("#F4EFE4"), Vector3(0, r, 0))
	var dome := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 1.1
	sm.height = 1.1
	sm.is_hemisphere = true
	dome.mesh = sm
	dome.position = _xf(p, r, Vector3(0, 3.1, -0.2))
	dome.material_override = LocKit.mat(Color("#3E8E8A"), 0.4)
	add_child(dome)


## Spor salonu: kemerli çatılı büyük hol.
func _gym(b: LocKit.BoxBatch, p: Vector3, r: float) -> void:
	b.add(Vector3(4.4, 1.8, 3.2), _xf(p, r, Vector3(0, 1.3, 0)), Color("#DCE3EA"), Vector3(0, r, 0))
	b.add(Vector3(4.5, 0.4, 0.1), _xf(p, r, Vector3(0, 1.2, 1.62)), Color("#2E6BFF"), Vector3(0, r, 0))
	var roof := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 1.65
	cm.bottom_radius = 1.65
	cm.height = 4.5
	roof.mesh = cm
	roof.scale = Vector3(1, 1, 0.55)
	roof.rotation = Vector3(0, r, PI / 2.0)
	roof.position = _xf(p, r, Vector3(0, 2.2, 0))
	roof.material_override = LocKit.mat(Color("#1F4FA8"), 0.45)
	add_child(roof)


## Yemekhane: çizgili tenteli alçak bina, önünde masalar.
func _cafeteria(b: LocKit.BoxBatch, p: Vector3, r: float) -> void:
	b.add(Vector3(3.8, 1.8, 2.8), _xf(p, r, Vector3(0, 1.3, 0)), Color("#F2B8A0"), Vector3(0, r, 0))
	b.add(Vector3(4.0, 0.2, 3.0), _xf(p, r, Vector3(0, 2.3, 0)), Color("#F4EFE4"), Vector3(0, r, 0))
	for k in 6:
		b.add(Vector3(0.66, 0.08, 0.9), _xf(p, r, Vector3(-1.65 + k * 0.66, 1.9, 1.75)),
			Color("#E5484D") if k % 2 == 0 else Color.WHITE, Vector3(-0.4, r, 0))
	for k in 2:
		b.add(Vector3(0.7, 0.08, 0.7), _xf(p, r, Vector3(-0.8 + k * 1.6, 0.75, 2.8)), Color("#FFFFFF"), Vector3(0, r, 0))
		b.add(Vector3(0.08, 0.35, 0.08), _xf(p, r, Vector3(-0.8 + k * 1.6, 0.58, 2.8)), Color("#555555"), Vector3(0, r, 0))


## Laboratuvar: cam cepheli modern bina ve yeşil sıvı tankı.
func _lab(b: LocKit.BoxBatch, p: Vector3, r: float) -> void:
	b.add(Vector3(3.6, 3.0, 2.8), _xf(p, r, Vector3(0, 1.9, 0)), Color("#D6ECF3"), Vector3(0, r, 0))
	b.add(Vector3(3.7, 0.25, 2.9), _xf(p, r, Vector3(0, 3.5, 0)), Color("#2A7FBA"), Vector3(0, r, 0))
	b.add(Vector3(3.7, 0.18, 2.9), _xf(p, r, Vector3(0, 0.55, 0)), Color("#2A7FBA"), Vector3(0, r, 0))
	for side in [1.0, -1.0]:
		for k in 4:
			for j in 2:
				var w := LocKit.box(self, Vector3(0.6, 0.9, 0.05), _xf(p, r, Vector3(-1.2 + k * 0.8, 1.3 + j * 1.2, side * 1.42)),
					LocKit.mat(Color("#7FD1FF"), 0.1, 0.5))
				w.rotation.y = r
	for k in 3:
		var w2 := LocKit.box(self, Vector3(0.05, 0.9, 0.6), _xf(p, r, Vector3(1.82, 1.3 + (k % 2) * 1.2, -0.8 + k * 0.8)),
			LocKit.mat(Color("#7FD1FF"), 0.1, 0.5))
		w2.rotation.y = r
	var tank := MeshInstance3D.new()
	tank.mesh = LocKit.unit_cyl()
	tank.scale = Vector3(0.8, 1.6, 0.8)
	tank.position = _xf(p, r, Vector3(2.2, 1.2, -0.6))
	tank.material_override = LocKit.mat(Color("#3DFF9A"), 0.2, 1.2)
	add_child(tank)


func _trees(rng: RandomNumberGenerator) -> void:
	var k := 0
	while k < 22:
		var a := rng.randf() * TAU
		var d := rng.randf_range(6.5, ISLAND_R - 0.8)
		var p := Vector3(sin(a) * d, 0.4, cos(a) * d)
		var near := false
		for s in SPOTS:
			if (SPOTS[s][0] as Vector3).distance_to(p) < 3.2:
				near = true
		if near:
			continue
		LocKit.model(self, "mini_forest", "tree-high" if rng.randf() < 0.5 else "tree", p, rng.randf() * TAU, rng.randf_range(0.35, 0.5))
		k += 1
	for a in range(0, 360, 45):
		var p := Vector3(sin(deg_to_rad(a)) * 3.2, 0.4, cos(deg_to_rad(a)) * 3.2)
		LocKit.model(self, "fantasy", "lantern", p, 0.0, 0.5)


func _labels() -> void:
	var exams := {"quad": "quiz1", "library": "midterm", "gym": "final", "cafeteria": "quiz2", "lab": "project"}
	var tints := {"quad": "#2E9E5B", "library": "#8E2F3C", "gym": "#1F4FA8", "cafeteria": "#D2553D", "lab": "#1F8A8A"}
	for k in exams:
		var preset := Game.content.location_preset(k)
		var p: Vector3 = Vector3(0, 7.4, -2.6) if k == "quad" else SPOTS[k][0] + Vector3(0, 5.2, 0)
		var l := LocKit.label(self, "%s\n%s" % [preset.get("short", preset["name"]), Assessment.display_name(exams[k])], 54,
			Color.WHITE, Color(tints[k]), p)
		l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		l.font = UiKit.heavy()
		l.outline_size = 22
		l.no_depth_test = true  # binaların arkasında kalsa da okunur
		l.render_priority = 2
		if k != "quad":
			_labels_by_spot.append(l)


## Kameraya bakan yarıdaki etiketler görünür, arkadakiler söner: başlıkla çakışmaz.
func _process(_delta: float) -> void:
	var cam := get_viewport().get_camera_3d()
	if cam == null:
		return
	var to_cam := Vector2(cam.global_position.x, cam.global_position.z).normalized()
	for l in _labels_by_spot:
		var d := Vector2(l.position.x, l.position.z).normalized()
		var a := smoothstep(-0.15, 0.35, d.dot(to_cam))
		l.modulate.a = a
		l.outline_modulate.a = a
		l.visible = a > 0.01
