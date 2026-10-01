class_name LocLibrary
extends Location
## Vize: Merkez Kütüphane. Ahşap zemin, ortada halı yol, iki yanda dolu
## kitaplıklar ve okuma nişleri, arkada ahşap panel duvar ve kemerli pencereler.

const SPINES := [Color("#8E2F3C"), Color("#2F4E8E"), Color("#2E7D5B"), Color("#D9A441"), Color("#6B3F8E"),
	Color("#C8553D"), Color("#1F6F78"), Color("#E8D8B8"), Color("#3B3B58"), Color("#A63D40")]
const WOOD := Color("#4A2B1C")
const WOOD_DARK := Color("#2E1A10")
const UNIT := 3.0  # kitaplık/niş aralığı (m)


func build_chunk(c: Node3D, i: int, rng: RandomNumberGenerator) -> void:
	var half := chunk_len / 2.0
	var floor_w := (half_road + 6.0) * 2.0
	LocKit.plane(c, Vector2(floor_w, chunk_len), Vector3.ZERO, LocKit.shader("wood", {
		"base_a": "#9E6440", "base_b": "#83502F", "plank_w": 0.42, "plank_l": 2.4}))
	var solid := LocKit.BoxBatch.new(0.65)
	var books := LocKit.BoxBatch.new(0.8)
	var glow := LocKit.BoxBatch.new(0.2, null, LocKit.mat(Color("#CFE9FF"), 0.2, 1.4))
	var beams := LocKit.BoxBatch.new(1.0, null, LocKit.glass(Color(1.0, 0.9, 0.7), 0.06, true))
	# halı yol: bordo, altın kenar
	solid.add(Vector3(lane_w * 0.86, 0.025, chunk_len), Vector3(0, 0.012, 0), Color("#7E2433"))
	for sx in [-1.0, 1.0]:
		solid.add(Vector3(0.1, 0.03, chunk_len), Vector3(sx * lane_w * 0.36, 0.016, 0), Color("#E3B04B"))
	var xs := half_road + 0.9
	var k := 0
	var z := half - UNIT / 2.0
	while z > -half:
		var gk := i * 10 + k  # dünya genelinde birim sırası (nişler parçalar arasında düzenli)
		for sx in [-1.0, 1.0]:
			if gk % 4 == 2:
				_reading_nook(c, Vector3(sx * (xs + 0.7), 0, z), sx, gk % 8 == 2)
			else:
				_bookcase(solid, books, Vector3(sx * (xs + 0.4), 0, z), sx, rng)
			# arka duvar: ahşap panel + sıva + kemerli pencere
			var wx: float = sx * (xs + 2.4)
			solid.add(Vector3(0.3, 2.2, UNIT), Vector3(wx, 1.1, z), Color("#5A3522"))
			solid.add(Vector3(0.34, 0.12, UNIT), Vector3(wx - sx * 0.02, 2.25, z), WOOD_DARK)
			solid.add(Vector3(0.3, 6.0, UNIT), Vector3(wx, 5.2, z), Color("#D8C3A0"))
			solid.add(Vector3(0.6, 8.2, 0.5), Vector3(wx - sx * 0.1, 4.1, z + UNIT / 2.0), WOOD)
			if gk % 2 == 0:
				glow.add(Vector3(0.08, 3.0, 1.3), Vector3(wx - sx * 0.17, 4.9, z))
				solid.add(Vector3(0.1, 3.1, 0.08), Vector3(wx - sx * 0.2, 4.9, z), Color("#3A2416"))
				solid.add(Vector3(0.1, 0.08, 1.4), Vector3(wx - sx * 0.2, 5.1, z), Color("#3A2416"))
				beams.add(Vector3(0.05, 7.0, 1.2), Vector3(wx - sx * 2.5, 2.9, z), Color.WHITE, Vector3(0, 0, sx * 0.66))
		z -= UNIT
		k += 1
	solid.flush(c)
	books.flush(c, false)
	glow.flush(c, false)
	beams.flush(c, false)
	# tavandan sarkan sıcak ışıklar
	for lz in [-half * 0.5, half * 0.5]:
		LocKit.omni(c, Vector3(0, 4.4, lz), Color("#FFB45E"), 1.5, 9.0)
	if i >= 0 and i % sign_every() == 1:
		arch(c, rng.randf_range(-4, 4), WOOD, sign_text)


## Dolu kitaplık: koyu ahşap çerçeve + rastgele renk, boy ve eğimde kitap sırtları.
func _bookcase(solid: LocKit.BoxBatch, books: LocKit.BoxBatch, pos: Vector3, sx: float, rng: RandomNumberGenerator) -> void:
	var w := UNIT - 0.25
	var h := 3.8
	var d := 0.55
	var shelves := 5
	# kitaplık yola bakar: yerel x → dünya z, derinlik → dünya x
	var face := -sx
	for s in [-1.0, 1.0]:
		solid.add(Vector3(d, h, 0.12), pos + Vector3(0, h / 2.0, s * w / 2.0), WOOD)
	solid.add(Vector3(0.06, h, w), pos + Vector3(-face * (d / 2.0 - 0.03), h / 2.0, 0), WOOD_DARK)
	var sh := h / shelves
	for j in shelves + 1:
		solid.add(Vector3(d + 0.04, 0.09, w + 0.1), pos + Vector3(0, j * sh, 0), WOOD)
	solid.add(Vector3(d + 0.12, 0.16, w + 0.3), pos + Vector3(face * 0.02, h + 0.08, 0), WOOD)
	for j in shelves:
		var zz := -w / 2.0 + 0.1
		while zz < w / 2.0 - 0.12:
			var bw := rng.randf_range(0.06, 0.13)
			var bh := sh * rng.randf_range(0.6, 0.86)
			var lean := rng.randf_range(0.15, 0.35) if rng.randf() < 0.06 else 0.0
			var col: Color = SPINES[rng.randi() % SPINES.size()]
			col = col.lerp(Color.WHITE, rng.randf_range(0.0, 0.15)).darkened(rng.randf_range(0.0, 0.2))
			books.add(Vector3(d * 0.78, bh, bw), pos + Vector3(face * 0.02, j * sh + 0.045 + bh / 2.0, zz + bw / 2.0),
				col, Vector3(lean, 0, 0))
			zz += bw + (0.2 if rng.randf() < 0.05 else 0.004)


func _reading_nook(c: Node3D, pos: Vector3, sx: float, light: bool) -> void:
	LocKit.model(c, "kk_furniture", "table_medium", pos)
	LocKit.model(c, "kk_furniture", "lamp_table", pos + Vector3(0, 0.85, -0.35), 0.0, 0.8, false)
	LocKit.model(c, "kk_furniture", "book_set", pos + Vector3(-sx * 0.3, 0.85, 0.4), 0.4, 1.0, false)
	LocKit.model(c, "kk_furniture", "chair_A_wood", pos + Vector3(0, 0, 1.2), PI, 1.0, false)
	if light:
		LocKit.omni(c, pos + Vector3(0, 1.8, -0.35), Color("#FFBE6E"), 2.4, 5.5)
