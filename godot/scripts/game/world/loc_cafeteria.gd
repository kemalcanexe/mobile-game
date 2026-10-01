class_name LocCafeteria
extends Location
## Quiz 2: Yemekhane. Damalı fayans, iki yanda uzun masalar ve tepsiler,
## arkada self servis tezgâhı ve menü panosu, büyük gün ışığı pencereleri,
## sarkan lambalar; masalarda öğrenciler.

const WALL_TILE := Color("#F3F1EA")
const WALL_TOP := Color("#F2B8A0")


func build_chunk(c: Node3D, i: int, rng: RandomNumberGenerator) -> void:
	var half := chunk_len / 2.0
	var hall := half_road + 9.0
	LocKit.plane(c, Vector2(hall * 2.0, chunk_len), Vector3.ZERO, LocKit.shader("tiles", {
		"color_a": "#F4EEE2", "color_b": "#C0392B", "tile": 0.9, "checker": 1.0, "grout": "#B9B1A3", "gloss": 0.22}))
	var solid := LocKit.BoxBatch.new(0.5)
	var glow := LocKit.BoxBatch.new(0.2, null, LocKit.mat(Color("#FFF6DC"), 0.2, 1.6))
	var sun := LocKit.BoxBatch.new(0.2, null, LocKit.mat(Color("#DDF1FF"), 0.2, 1.2))
	for sx in [-1.0, 1.0]:
		# uzun masalar + sandalyeler + tepsiler
		var z := half - 4.0
		var k := 0
		while z > -half:
			var tx: float = sx * (half_road + 2.3)
			LocKit.model(c, "kk_restaurant", "kitchentable_A_large_decorated" if (i + k) % 3 == 0 else "table_round_A_decorated",
				Vector3(tx, 0, z), 0.0, 0.85)
			LocKit.model(c, "kk_restaurant", "chair_A" if k % 2 else "chair_B", Vector3(tx + sx * 1.3, 0, z), -sx * PI / 2.0, 1.0, false)
			if rng.randf() < 0.4:
				student(c, Vector3(tx - sx * 1.35, 0, z + rng.randf_range(-0.8, 0.8)), sx * PI / 2.0, rng, "sit")
			z -= 8.0
			k += 1
		# self servis tezgâhı (arka duvar önünde): paslanmaz gövde, ahşap üst,
		# yemek küvetleri ve hapşırık camı; tek batch (KayKit tezgâhlarına göre çok ucuz)
		var cx: float = sx * (hall - 3.0)
		solid.add(Vector3(1.2, 0.95, chunk_len), Vector3(cx, 0.475, 0), Color("#C9CED6"))
		solid.add(Vector3(1.3, 0.08, chunk_len), Vector3(cx, 0.99, 0), Color("#B07A4A"))
		solid.add(Vector3(0.06, 0.9, chunk_len), Vector3(cx - sx * 0.63, 0.45, 0), Color("#E2E6EC"))
		var pz := half - 0.8
		while pz > -half:
			var food: Color = [Color("#E8A33D"), Color("#8DB255"), Color("#C0452B"), Color("#F3E6C4")][rng.randi() % 4]
			solid.add(Vector3(0.7, 0.05, 0.55), Vector3(cx, 1.04, pz), Color("#E9EDF2"))
			solid.add(Vector3(0.6, 0.03, 0.45), Vector3(cx, 1.07, pz), food)
			pz -= 0.9
		solid.add(Vector3(0.05, 0.05, chunk_len), Vector3(cx - sx * 0.55, 1.6, 0), Color("#9AA3B5"))
		sun.add(Vector3(0.03, 0.55, chunk_len), Vector3(cx - sx * 0.55, 1.3, 0))
		for fz in [-half * 0.5, half * 0.3]:
			LocKit.model(c, "kk_restaurant", ["crate_carrots", "crate_tomatoes", "crate_buns"][rng.randi() % 3],
				Vector3(cx + sx * 0.15, 1.03, fz), rng.randf() * TAU, 0.6)
		# duvar: fayans alt, boyalı üst, pencereler
		var wx: float = sx * hall
		solid.add(Vector3(0.3, 1.8, chunk_len), Vector3(wx, 0.9, 0), WALL_TILE)
		solid.add(Vector3(0.34, 0.1, chunk_len), Vector3(wx - sx * 0.02, 1.85, 0), Color("#2E86AB"))
		solid.add(Vector3(0.3, 6.2, chunk_len), Vector3(wx, 4.9, 0), WALL_TOP)
		var wz := half - 2.5
		while wz > -half:
			sun.add(Vector3(0.08, 3.2, 2.6), Vector3(wx - sx * 0.17, 4.7, wz))
			solid.add(Vector3(0.12, 0.12, 2.8), Vector3(wx - sx * 0.2, 3.05, wz), Color.WHITE)
			solid.add(Vector3(0.12, 0.12, 2.8), Vector3(wx - sx * 0.2, 6.35, wz), Color.WHITE)
			solid.add(Vector3(0.12, 3.4, 0.12), Vector3(wx - sx * 0.2, 4.7, wz), Color.WHITE)
			wz -= 5.0
	# sarkan lambalar
	var lz := half - 2.5
	while lz > -half:
		for lx in [-lane_w, lane_w]:
			glow.add(Vector3(0.9, 0.25, 0.9), Vector3(lx, 5.4, lz))
			solid.add(Vector3(0.03, 2.0, 0.03), Vector3(lx, 6.5, lz), Color("#333333"))
		lz -= 5.0
	LocKit.omni(c, Vector3(0, 5.0, -half * 0.5), Color("#FFF2D8"), 1.2, 11.0)
	solid.flush(c)
	glow.flush(c, false)
	sun.flush(c, false)
	# menü panosu
	if i >= 0 and i % sign_every() == 1:
		arch(c, rng.randf_range(-5, 5), Color("#2E86AB"), sign_text)
	if i % 2 == 0:
		var mz := rng.randf_range(-8, 8)
		var side := 1.0 if i % 4 == 0 else -1.0
		var board := LocKit.box(c, Vector3(0.15, 2.2, 3.6), Vector3(side * (hall - 0.3), 3.3, mz), LocKit.mat(Color("#20332B"), 0.8))
		var rot := -side * PI / 2.0
		LocKit.label(c, "GÜNÜN MENÜSÜ", 60, Color("#FFD23F"), Color(0, 0, 0, 0), Vector3(side * (hall - 0.4), 4.0, mz), rot)
		LocKit.label(c, "Mercimek · Pilav\nKuru fasulye · Ayran", 44, Color.WHITE, Color(0, 0, 0, 0),
			Vector3(side * (hall - 0.4), 3.1, mz), rot)
