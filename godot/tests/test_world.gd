extends TestCase
## Faz 5 dünyası: her sınavın mekânı var, her mekân parçası hatasız kurulur,
## engeller mekâna göre değişse de çarpışma boyutları oynanışla tutarlı kalır.

const LOCS := ["quad", "library", "cafeteria", "lab", "gym"]


func content() -> Content:
	return Content.load_all()


func test_her_sinavin_mekani_ve_ayari_var() -> void:
	var c := content()
	for a in ["quiz1", "midterm", "quiz2", "project", "final"]:
		var loc := c.location_for(a)
		check(loc in LOCS, "%s → %s" % [a, loc])
		var p := c.location_preset(loc)
		for key in ["sign", "skyTop", "ambient", "sunEnergy", "fogDensity", "far", "trail"]:
			check(p.has(key), "%s ayarında %s var" % [loc, key])
	eq(c.location_for("final"), "gym", "finaller spor salonunda")
	eq(c.location_for("midterm"), "library", "vize kütüphanede")


func test_her_mekan_parcasi_kurulur() -> void:
	var c := content()
	for loc_id in LOCS:
		var campus := Campus.new()
		campus.setup(loc_id, c.location_preset(loc_id), {"accent": "#2E6BFF", "sign": "TEST"}, c.world_cfg)
		campus.update_for(0.0)
		var chunks := campus.get_children().filter(func(n: Node) -> bool: return n.name.begins_with("Chunk"))
		check(chunks.size() >= int(c.world_cfg["world"]["chunksAhead"]), "%s parça sayısı %d" % [loc_id, chunks.size()])
		for ch in chunks:
			check(ch.get_child_count() > 3, "%s/%s içerik var" % [loc_id, ch.name])
		# ileri gidince arkadakiler silinir, öndekiler eklenir
		campus.update_for(-200.0)
		var alive := campus.get_children().filter(func(n: Node) -> bool: return n.name.begins_with("Chunk") and not n.is_queued_for_deletion())
		check(alive.all(func(n: Node) -> bool: return n.name != "Chunk0"), "%s eski parça silindi" % loc_id)
		campus.free()


func test_engeller_mekana_gore_ayni_boyutta() -> void:
	var lane_w := 2.6
	for art in ["spill", "staples", "plane", "paperBall", "encyclopedia"]:
		var first: Vector3
		for loc_id in LOCS:
			ItemArt.location = loc_id
			var r := ItemArt.build(art, lane_w, {})
			check(not r.is_empty(), "%s/%s görsel var" % [loc_id, art])
			if r.is_empty():
				continue
			var n: Node3D = r["node"]
			check(n.get_child_count() > 0, "%s/%s boş değil" % [loc_id, art])
			if loc_id == LOCS[0]:
				first = r["size"]
			else:
				eq(r["size"], first, "%s/%s çarpışma kutusu mekândan bağımsız" % [loc_id, art])
			n.free()
	ItemArt.location = ""


func test_tuki_modeli_pozlari_var() -> void:
	var m := TukiModel.new()
	Engine.get_main_loop().root.add_child(m)
	for pose in ["run", "air", "slide", "stumble", "idle", "victory", "sad", "wave"]:
		check(m.has_pose(pose), "Tüki pozu: %s" % pose)
	m.free()
