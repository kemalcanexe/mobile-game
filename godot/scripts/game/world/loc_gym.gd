class_name LocGym
extends Location
## Final: Spor Salonu (finaller gerçekten burada yapılır). Parke saha ve
## çizgiler, kenarlarda sınav sıraları, renkli tribünler ve seyirciler,
## asılı flamalar ve tavan ışıkları; ara sıra skorbord.

const TEAM := [Color("#1F4FA8"), Color("#FFD23F"), Color("#E63946"), Color("#FFFFFF")]


func sign_every() -> int:
	return 3


func build_chunk(c: Node3D, i: int, rng: RandomNumberGenerator) -> void:
	var half := chunk_len / 2.0
	var court := half_road + 2.2
	LocKit.plane(c, Vector2(court * 2.0 + 16.0, chunk_len), Vector3.ZERO, LocKit.shader("wood", {
		"base_a": "#E2B47A", "base_b": "#D29E62", "plank_w": 0.18, "plank_l": 3.2, "seam_dark": 0.7, "gloss": 0.3}))
	var solid := LocKit.BoxBatch.new(0.6)
	var paint := LocKit.BoxBatch.new(0.4)
	var people := LocKit.BoxBatch.new(0.85)
	var lamps := LocKit.BoxBatch.new(0.2, null, LocKit.mat(Color.WHITE, 0.2, 3.0))
	# saha çizgileri
	for sx in [-1.0, 1.0]:
		paint.add(Vector3(0.1, 0.012, chunk_len), Vector3(sx * (court - 0.3), 0.006, 0), Color.WHITE)
	if i % 2 == 0:
		paint.add(Vector3(court * 2.0 - 0.6, 0.012, 0.1), Vector3(0, 0.006, 0), Color.WHITE)
		var ring := MeshInstance3D.new()
		var tm := TorusMesh.new()
		tm.inner_radius = 2.2
		tm.outer_radius = 2.32
		ring.mesh = tm
		ring.scale = Vector3(1, 0.02, 1)
		ring.material_override = LocKit.mat(Color.WHITE, 0.4)
		ring.position = Vector3(0, 0.006, 0)
		c.add_child(ring)
	else:
		paint.add(Vector3(4.8, 0.011, 7.0), Vector3(0, 0.004, 0), accent.darkened(0.2))
	# sınav sıraları (masa + kâğıt), saha kenarında
	var z := half - 1.0
	while z > -half:
		for sx in [-1.0, 1.0]:
			for col in 2:
				var x: float = sx * (court + 0.9 + col * 1.5)
				solid.add(Vector3(0.9, 0.06, 0.6), Vector3(x, 0.78, z), Color("#C9A77A"))
				solid.add(Vector3(0.06, 0.75, 0.06), Vector3(x - 0.38, 0.38, z - 0.24), Color("#6B7280"))
				solid.add(Vector3(0.06, 0.75, 0.06), Vector3(x + 0.38, 0.38, z + 0.24), Color("#6B7280"))
				paint.add(Vector3(0.36, 0.01, 0.48), Vector3(x, 0.815, z), Color("#FAFAF5"), Vector3(0, rng.randf_range(-0.2, 0.2), 0))
		z -= 1.8
	# tribünler: basamaklar, koltuklar, seyirciler
	for sx in [-1.0, 1.0]:
		for r in 7:
			var x: float = sx * (court + 4.2 + r * 1.0)
			var y := 0.5 + r * 0.6
			solid.add(Vector3(1.0, y, chunk_len), Vector3(x, y / 2.0, 0), Color("#2C3550"))
			var zz := half - 0.45
			while zz > -half:
				var team_c: Color = TEAM[0] if (int(floor(zz / 6.0)) + r) % 3 else TEAM[1]
				solid.add(Vector3(0.7, 0.18, 0.7), Vector3(x, y + 0.09, zz), team_c)
				if rng.randf() < 0.55:
					var col: Color = TEAM[rng.randi() % TEAM.size()].lerp(Color(rng.randf(), rng.randf(), rng.randf()), 0.25)
					var hgt := rng.randf_range(0.7, 0.95)
					people.add(Vector3(0.42, hgt, 0.36), Vector3(x, y + 0.18 + hgt / 2.0, zz), col)
					people.add(Vector3(0.3, 0.3, 0.3), Vector3(x, y + 0.36 + hgt, zz),
						Color("#F1C6A3").darkened(rng.randf_range(0.0, 0.5)))
				zz -= 0.9
		# üstte flamalar ve duvar
		var wx: float = sx * (court + 12.0)
		solid.add(Vector3(0.4, 12.0, chunk_len), Vector3(wx, 6.0, 0), Color("#232B45"))
		var bz := half - 3.0
		var k := 0
		while bz > -half:
			var bc: Color = accent if k % 3 == 0 else TEAM[k % 3]
			solid.add(Vector3(0.05, 1.8, 1.0), Vector3(wx - sx * 0.3, 7.0, bz), bc)
			bz -= 6.0
			k += 1
	# tavan ışıkları
	var lz := half - 3.0
	var li := 0
	while lz > -half:
		lamps.add(Vector3(1.4, 0.15, 0.6), Vector3(0, 11.0, lz))
		if li % 2 == 0:
			LocKit.omni(c, Vector3(0, 8.0, lz), Color("#F2F6FF"), 1.6, 16.0)
		lz -= 6.0
		li += 1
	solid.flush(c)
	paint.flush(c, false)
	people.flush(c, false)
	lamps.flush(c, false)
	if i >= 0 and i % sign_every() == 1:
		_scoreboard(c, rng.randf_range(-6, 6))


func _scoreboard(c: Node3D, z: float) -> void:
	var b := LocKit.BoxBatch.new(0.4)
	b.add(Vector3(7.0, 2.4, 0.4), Vector3(0, 9.4, z), Color("#111522"))
	b.add(Vector3(7.3, 0.14, 0.5), Vector3(0, 10.66, z), accent)
	b.add(Vector3(0.08, 1.4, 0.08), Vector3(-2.5, 11.3, z), Color("#9AA3B5"))
	b.add(Vector3(0.08, 1.4, 0.08), Vector3(2.5, 11.3, z), Color("#9AA3B5"))
	b.flush(c)
	LocKit.label(c, "FİNAL · %s" % sign_text, 90, Color("#FFD23F"), Color(0, 0, 0, 0), Vector3(0, 9.75, z + 0.22))
	LocKit.label(c, "SÜRE İŞLİYOR", 70, Color("#FF5A5A"), Color(0, 0, 0, 0), Vector3(0, 8.9, z + 0.22))
