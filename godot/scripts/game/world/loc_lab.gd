class_name LocLab
extends Location
## Proje/Lab: Fen Laboratuvarı. Açık gri fayans, yol kenarında sarı-siyah
## güvenlik şeridi, iki yanda deney tezgâhları (şişeler, parlayan sıvılar),
## çeker ocaklar, periyodik tablo panosu, tavanda borular, soğuk ışık.

const LIQUIDS := [Color("#3DFF9A"), Color("#4FC3FF"), Color("#FF5FD2"), Color("#FFD23F")]
const WALL := Color("#E8EEF2")


func build_chunk(c: Node3D, i: int, rng: RandomNumberGenerator) -> void:
	var half := chunk_len / 2.0
	var room := half_road + 7.5
	LocKit.plane(c, Vector2(room * 2.0, chunk_len), Vector3.ZERO, LocKit.shader("tiles", {
		"color_a": "#C9D3DA", "color_b": "#AEBBC4", "tile": 1.2, "checker": 0.35, "grout": "#8C9AA4", "gloss": 0.18}))
	var solid := LocKit.BoxBatch.new(0.45)
	var paint := LocKit.BoxBatch.new(0.6)
	var glass := LocKit.BoxBatch.new(0.1, LocKit.unit_cyl(), LocKit.glass(Color("#DDF4FF"), 0.28))
	var liquid := {}
	for col in LIQUIDS:
		liquid[col] = LocKit.BoxBatch.new(0.2, LocKit.unit_cyl(), LocKit.mat(col, 0.2, 2.2))
	var lamps := LocKit.BoxBatch.new(0.2, null, LocKit.mat(Color("#E9F8FF"), 0.2, 2.6))
	for sx in [-1.0, 1.0]:
		var edge: float = sx * half_road
		# güvenlik şeridi
		var z := half
		while z > -half:
			paint.add(Vector3(0.3, 0.012, 0.5), Vector3(edge + sx * 0.25, 0.006, z - 0.25), Color("#FFC400"))
			paint.add(Vector3(0.3, 0.012, 0.5), Vector3(edge + sx * 0.25, 0.006, z - 0.75), Color("#1A1A1A"))
			z -= 1.0
		# deney tezgâhları
		var bx: float = sx * (half_road + 2.0)
		var bz := half - 2.0
		var k := 0
		while bz > -half + 1.0:
			var gk := i * 6 + k
			if gk % 5 == 3:
				_fume_hood(solid, glass, liquid, Vector3(sx * (room - 1.4), 0, bz), sx, rng)
			solid.add(Vector3(1.3, 0.95, 3.4), Vector3(bx, 0.475, bz), Color("#F4F7F9"))
			solid.add(Vector3(1.45, 0.08, 3.6), Vector3(bx, 0.99, bz), Color("#1F2A33"))
			for d in 3:
				solid.add(Vector3(0.02, 0.7, 0.9), Vector3(bx - sx * 0.66, 0.5, bz - 1.1 + d * 1.1), Color("#D5DDE3"))
			# şişeler ve tüpler
			for n in rng.randi_range(3, 6):
				var p := Vector3(bx + rng.randf_range(-0.45, 0.45), 1.03, bz + rng.randf_range(-1.5, 1.5))
				var hgt := rng.randf_range(0.25, 0.6)
				var r := rng.randf_range(0.07, 0.16)
				glass.add(Vector3(r * 2.0, hgt, r * 2.0), p + Vector3(0, hgt / 2.0, 0), Color.WHITE)
				var lc: Color = LIQUIDS[rng.randi() % LIQUIDS.size()]
				var fill := hgt * rng.randf_range(0.3, 0.7)
				liquid[lc].add(Vector3(r * 1.7, fill, r * 1.7), p + Vector3(0, fill / 2.0 + 0.01, 0), lc)
			bz -= 4.4
			k += 1
		# duvar: beyaz panel + mavi şerit, periyodik tablo
		var wx: float = sx * room
		solid.add(Vector3(0.3, 7.0, chunk_len), Vector3(wx, 3.5, 0), WALL)
		paint.add(Vector3(0.34, 0.3, chunk_len), Vector3(wx - sx * 0.02, 1.4, 0), Color("#2A7FBA"))
		if i % 2 == 0:
			_periodic(paint, Vector3(wx - sx * 0.18, 3.6, rng.randf_range(-6, 6)), sx)
		# tavanda borular
		for py in [6.2, 6.6]:
			solid.add(Vector3(0.22, 0.22, chunk_len), Vector3(sx * (half_road + 3.5 + py - 6.2), py, 0), Color("#9AA7B1"), Vector3.ZERO)
	# floresan ışıklar
	var lz := half - 3.0
	var li := 0
	while lz > -half:
		for lx in [-lane_w, lane_w]:
			lamps.add(Vector3(0.35, 0.08, 2.6), Vector3(lx, 6.8, lz))
		if li % 2 == 0:
			LocKit.omni(c, Vector3(0, 5.5, lz), Color("#DDF3FF"), 1.4, 12.0)
		lz -= 6.0
		li += 1
	solid.flush(c)
	paint.flush(c, false)
	glass.flush(c, false)
	for lc in liquid:
		liquid[lc].flush(c, false)
	lamps.flush(c, false)
	if i >= 0 and i % sign_every() == 1:
		arch(c, rng.randf_range(-5, 5), Color("#DCE4EA"), sign_text)


func _fume_hood(solid: LocKit.BoxBatch, glass: LocKit.BoxBatch, liquid: Dictionary, pos: Vector3, sx: float, rng: RandomNumberGenerator) -> void:
	solid.add(Vector3(1.6, 0.95, 2.6), pos + Vector3(0, 0.475, 0), Color("#F4F7F9"))
	solid.add(Vector3(1.6, 1.4, 2.6), pos + Vector3(sx * 0.1, 2.6, 0), Color("#DCE3E8"))
	solid.add(Vector3(0.1, 1.2, 2.6), pos + Vector3(sx * 0.75, 1.55, 0), Color("#DCE3E8"))
	glass.add(Vector3(0.05, 1.1, 2.3), pos + Vector3(-sx * 0.8, 1.55, 0), Color.WHITE)
	var lc: Color = LIQUIDS[rng.randi() % LIQUIDS.size()]
	liquid[lc].add(Vector3(0.3, 0.3, 0.3), pos + Vector3(0, 1.1, 0), lc)


## Renkli karelerden periyodik tablo panosu.
func _periodic(paint: LocKit.BoxBatch, pos: Vector3, sx: float) -> void:
	var groups := [Color("#FF8A80"), Color("#FFD180"), Color("#FFFF8D"), Color("#CCFF90"), Color("#80D8FF"), Color("#B388FF")]
	paint.add(Vector3(0.05, 2.2, 4.2), pos, Color("#FFFFFF"))
	for r in 7:
		for col in 18:
			if r == 0 and col > 0 and col < 17:
				continue
			if (r == 1 or r == 2) and col > 1 and col < 12:
				continue
			var cc: Color = groups[min(col / 3, 5)]
			paint.add(Vector3(0.03, 0.24, 0.2), pos + Vector3(-sx * 0.03, 0.9 - r * 0.28, -1.9 + col * 0.225), cc)
