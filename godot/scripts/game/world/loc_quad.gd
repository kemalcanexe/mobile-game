class_name LocQuad
extends Location
## Quiz 1: Kampüs Meydanı. Taş döşeli yol, çimenler, çitler ve fenerler,
## ağaçlar, iki yanda fakülte binaları (tuğla/taş cephe, sütunlu giriş),
## dersin renginde bayraklar, ara sıra çeşme ve çimende öğrenciler.

const FACADES := [Color("#B5543C"), Color("#E7D7B8"), Color("#C97B4A"), Color("#DCC9A6"), Color("#9E4A38")]
const TRIM := Color("#F4EFE4")


func build_chunk(c: Node3D, i: int, rng: RandomNumberGenerator) -> void:
	var half := chunk_len / 2.0
	LocKit.plane(c, Vector2(half_road * 2.0, chunk_len), Vector3(0, 0.0, 0), LocKit.shader("paving", {
		"stone_a": "#C9B697", "stone_b": "#AE9878", "joint": "#6F6252"}))
	for sx in [-1.0, 1.0]:
		LocKit.plane(c, Vector2(40.0, chunk_len), Vector3(sx * (half_road + 20.4), -0.01, 0),
			LocKit.shader("grass", {"grass_a": "#3F8F35", "grass_b": "#6CB548"}))
	var solid := LocKit.BoxBatch.new(0.8)
	var hedge := LocKit.BoxBatch.new(0.95)
	var windows := LocKit.BoxBatch.new(0.15, null, LocKit.mat(Color("#BFDFF5"), 0.15, 0.25))
	for sx in [-1.0, 1.0]:
		var edge: float = sx * half_road
		# tuğla şerit, bordür ve çit
		solid.add(Vector3(0.5, 0.02, chunk_len), Vector3(edge - sx * 0.3, 0.012, 0), Color("#A64B36"))
		solid.add(Vector3(0.4, 0.18, chunk_len), Vector3(edge + sx * 0.2, 0.09, 0), Color("#CFC6B6"))
		var z := half - 0.2
		while z > -half:
			var gap := (int(floor((z + i * chunk_len) / 7.5)) % 4) == 0
			if gap:
				# çitin açıklığında çiçek tarhı
				for f in 6:
					var fc: Color = [Color("#FF5D73"), Color("#FFD23F"), Color("#FFFFFF"), Color("#B06BFF")][rng.randi() % 4]
					hedge.add(Vector3(0.22, 0.22, 0.22), Vector3(edge + sx * rng.randf_range(0.6, 1.4), 0.25, z - rng.randf_range(0.2, 2.2)), fc)
				hedge.add(Vector3(1.0, 0.16, 2.3), Vector3(edge + sx * 1.0, 0.08, z - 1.15), Color("#5A3B28"))
			else:
				hedge.add(Vector3(0.9, 0.85, 2.1), Vector3(edge + sx * 1.0, 0.43, z - 1.05),
					Color("#3F7D34").lerp(Color("#4F9440"), rng.randf()))
				hedge.add(Vector3(0.7, 0.2, 1.9), Vector3(edge + sx * 1.0, 0.95, z - 1.05), Color("#5CA44A"))
			z -= 2.5
		# fenerler
		for k in 2:
			LocKit.model(c, "fantasy", "lantern", Vector3(edge + sx * 0.3, 0.15, half - 3.75 - k * 15.0), 0.0, 1.0, false)
		# ağaçlar ve öğrenciler
		for k in rng.randi_range(2, 4):
			var tname := "tree-high" if rng.randf() < 0.5 else "tree"
			var t := LocKit.model(c, "mini_forest", tname, Vector3(sx * rng.randf_range(half_road + 3.0, half_road + 9.0), 0,
				rng.randf_range(-half, half)), rng.randf() * TAU, rng.randf_range(0.85, 1.2))
		if rng.randf() < 0.6:
			var p := Vector3(sx * rng.randf_range(half_road + 2.5, half_road + 7.0), 0, rng.randf_range(-half + 2, half - 2))
			student(c, p, rng.randf() * TAU, rng, "idle" if rng.randf() < 0.6 else "sit")
			if rng.randf() < 0.5:
				student(c, p + Vector3(rng.randf_range(-0.9, 0.9), 0, rng.randf_range(0.8, 1.2)), rng.randf() * TAU, rng, "emote-yes")
		# fakülte binası
		_faculty(solid, windows, c, sx * (half_road + 13.0), rng.randf_range(-3, 3), sx, rng)
		# bayrak direkleri (dersin rengi)
		if i % 2 == 0:
			var fx: float = sx * (half_road + 2.6)
			solid.add(Vector3(0.12, 7.5, 0.12), Vector3(fx, 3.75, -half * 0.3), Color("#D9DCE3"))
			var flag := LocKit.box(c, Vector3(0.05, 1.1, 1.7), Vector3(fx, 6.8, -half * 0.3 - 0.9), LocKit.mat(accent, 0.6, 0.1))
			flag.rotation.x = 0.06
	# ara sıra çeşme
	if i % 3 == 2:
		var side := -1.0 if i % 2 else 1.0
		LocKit.model(c, "fantasy", "fountain-round-detail", Vector3(side * (half_road + 5.5), 0, 0), 0.0, 1.5)
	solid.flush(c)
	hedge.flush(c, false)
	windows.flush(c, false)
	if i >= 0 and i % sign_every() == 1:
		arch(c, rng.randf_range(-6, 6), Color("#EDE6D6"), sign_text)


## Prosedürel fakülte binası: cephe, pencere ızgarası, silme, sütunlu giriş, alınlık.
func _faculty(b: LocKit.BoxBatch, win: LocKit.BoxBatch, c: Node3D, x: float, z: float, sx: float, rng: RandomNumberGenerator) -> void:
	var col: Color = FACADES[rng.randi() % FACADES.size()]
	var floors := rng.randi_range(2, 4)
	var fh := 3.4
	var h := floors * fh + 0.8
	var w := rng.randf_range(20.0, 26.0)
	var d := 10.0
	var front := x - sx * d / 2.0  # yola bakan yüz
	b.add(Vector3(d, h, w), Vector3(x, h / 2.0, z), col)
	b.add(Vector3(d + 0.6, 0.5, w + 0.6), Vector3(x, h + 0.25, z), TRIM)          # üst silme
	b.add(Vector3(d + 0.3, 0.6, w + 0.3), Vector3(x, 0.3, z), col.darkened(0.25))  # kaide
	for f in floors:
		b.add(Vector3(0.25, 0.18, w), Vector3(front - sx * 0.05, 0.8 + f * fh, z), TRIM)
		var wz := -w / 2.0 + 1.6
		while wz < w / 2.0 - 1.4:
			var y := 0.8 + f * fh + 1.55
			win.add(Vector3(0.1, 1.9, 1.1), Vector3(front - sx * 0.06, y, z + wz))
			b.add(Vector3(0.16, 2.1, 0.12), Vector3(front - sx * 0.08, y, z + wz - 0.6), TRIM)
			b.add(Vector3(0.16, 2.1, 0.12), Vector3(front - sx * 0.08, y, z + wz + 0.6), TRIM)
			b.add(Vector3(0.22, 0.14, 1.34), Vector3(front - sx * 0.1, y - 1.02, z + wz), TRIM)
			wz += 2.4
	# sütunlu giriş ve alınlık
	var ez := z + rng.randf_range(-3, 3)
	for k in 4:
		b.add(Vector3(0.7, 5.2, 0.7), Vector3(front - sx * 1.6, 2.6, ez - 3.0 + k * 2.0), TRIM)
	b.add(Vector3(2.4, 0.5, 8.0), Vector3(front - sx * 1.2, 5.45, ez), TRIM)
	b.add(Vector3(2.8, 0.35, 8.4), Vector3(front - sx * 1.2, 0.18, ez), Color("#CFC6B6"))
	var ped := MeshInstance3D.new()
	var pm := PrismMesh.new()
	pm.size = Vector3(8.4, 1.8, 2.4)
	ped.mesh = pm
	ped.material_override = LocKit.mat(TRIM, 0.8)
	ped.position = Vector3(front - sx * 1.2, 6.6, ez)
	ped.rotation.y = PI / 2.0
	c.add_child(ped)
	# çatı
	var roof := MeshInstance3D.new()
	var rm := PrismMesh.new()
	rm.size = Vector3(d + 0.8, 2.6, w + 0.8)
	roof.mesh = rm
	roof.material_override = LocKit.mat(Color("#5B4B63") if rng.randf() < 0.5 else Color("#7A3B2E"), 0.7)
	roof.position = Vector3(x, h + 1.8, z)
	c.add_child(roof)
