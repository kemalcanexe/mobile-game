class_name ItemArt
## Nesnelerin Faz 5 görselleri: yumuşak hatlı oyuncak stili. (+) nesneler
## parlak mavi/sarı ve yuvarlak, (−) nesneler mor/kırmızı; engeller mekâna göre
## değişir (Kütüphanede kitap yığını, Yemekhanede "Kaygan zemin" tabelası …).
## Tanımadığı nesnede boş sözlük döner; ItemFactory eski görsele düşer.

const CREAM := Color("#FFF8E6")
const BLUE := Color("#2E6BFF")
const YELLOW := Color("#FFD23F")
const RED := Color("#E5484D")
const PURPLE := Color("#8B3DFF")
const INK := Color("#1E2A3A")

## Koşu sahnesi ayarlar: engellerin görünümü mekâna göre seçilir.
static var location := ""


static func build(art: String, lane_w: float, extra: Dictionary) -> Dictionary:
	var n := Node3D.new()
	var r := {"node": n, "size": Vector3(1.2, 3.2, 1.0), "center": Vector3(0, 1.6, 0), "spin": false}
	match art:
		# ------------------------------------------------ toplanabilirler
		"flashcard":
			var card := _float(n)
			_add(card, ShapeLib.rounded_box(Vector3(0.95, 0.62, 0.07), 0.09), LocKit.mat(CREAM, 0.5, 0.12))
			_add(card, LocKit.unit_box(), LocKit.mat(RED, 0.5), Vector3(0, 0.19, 0), Vector3(0.82, 0.03, 0.08))
			for k in 3:
				_add(card, LocKit.unit_box(), LocKit.mat(Color("#7FA6F5"), 0.6), Vector3(0, 0.07 - k * 0.12, 0), Vector3(0.74, 0.022, 0.078))
			_ring(n, BLUE)
			r["spin"] = true
		"note":
			var nb := _float(n)
			_add(nb, ShapeLib.rounded_box(Vector3(0.72, 0.92, 0.13), 0.07), LocKit.mat(BLUE, 0.35, 0.12))
			_add(nb, ShapeLib.rounded_box(Vector3(0.66, 0.86, 0.1), 0.05), LocKit.mat(CREAM, 0.6), Vector3(0.03, 0, 0))
			_add(nb, ShapeLib.rounded_box(Vector3(0.4, 0.2, 0.14), 0.04), LocKit.mat(Color.WHITE, 0.5), Vector3(0.05, 0.18, 0))
			for k in 6:
				var ring := TorusMesh.new()
				ring.inner_radius = 0.035
				ring.outer_radius = 0.055
				_add(nb, ring, LocKit.mat(Color("#D7DDEA"), 0.2, 0.0, 0.8), Vector3(-0.36, 0.34 - k * 0.135, 0), Vector3.ONE, Vector3(0, 0, PI / 2))
			_ring(n, BLUE)
			r["spin"] = true
		"formula", "physics", "code":
			var col: Color = {"formula": BLUE, "physics": Color("#FF6A2B"), "code": Color("#12A36B")}[art]
			var sym: String = {"formula": "∫dx", "physics": "F=ma", "code": "{ }"}[art]
			var f := _float(n)
			_add(f, ShapeLib.rounded_box(Vector3(1.0, 0.9, 0.1), 0.14), LocKit.mat(col, 0.35, 0.35))
			_add(f, ShapeLib.rounded_box(Vector3(0.86, 0.76, 0.12), 0.1), LocKit.mat(Color.WHITE, 0.4, 0.15))
			for side in [1.0, -1.0]:
				var l := Models.label(sym, 62 if sym.length() > 3 else 76, col, Color.WHITE)
				l.font = UiKit.heavy()
				l.double_sided = false
				l.position = Vector3(0, 0, side * 0.07)
				l.rotation.y = 0.0 if side > 0 else PI
				f.add_child(l)
			_ring(n, col)
			r["spin"] = true
		"book":
			var b := _float(n, 1.05)
			var cover: Color = [Color("#C0392B"), Color("#2E6BFF"), Color("#16A085"), Color("#8E44AD")][randi() % 4]
			_add(b, ShapeLib.rounded_box(Vector3(0.36, 1.05, 0.8), 0.06), LocKit.mat(cover, 0.45, 0.15))
			_add(b, LocKit.unit_box(), LocKit.mat(CREAM, 0.7), Vector3(0.03, 0, 0), Vector3(0.32, 0.95, 0.74))
			_add(b, ShapeLib.star(0.1, 0.045, 0.03), LocKit.mat(YELLOW, 0.3, 0.8), Vector3(-0.19, 0.2, 0), Vector3.ONE, Vector3(0, -PI / 2, 0))
			for k in 2:
				_add(b, LocKit.unit_box(), LocKit.mat(YELLOW, 0.3, 0.4), Vector3(-0.185, -0.25 + k * 0.1, 0), Vector3(0.02, 0.03, 0.7))
			_ring(n, YELLOW)
			r["spin"] = true
		"bonus":
			var s := _float(n)
			_add(s, ShapeLib.star(0.5, 0.22, 0.18), LocKit.mat(YELLOW, 0.25, 0.9))
			for side in [1.0, -1.0]:
				var q := Models.label("?", 90, BLUE, Color.WHITE)
				q.font = UiKit.heavy()
				q.double_sided = false
				q.position = Vector3(0, -0.02, side * 0.17)
				q.rotation.y = 0.0 if side > 0 else PI
				s.add_child(q)
			_ring(n, YELLOW)
			r["spin"] = true
		# ------------------------------------------------ güçlendiriciler
		"highlighter":
			var h := _float(n)
			h.rotation.z = 0.5
			_add(h, ShapeLib.rounded_box(Vector3(0.3, 0.72, 0.26), 0.1), LocKit.mat(YELLOW, 0.35, 0.5))
			_add(h, ShapeLib.rounded_box(Vector3(0.33, 0.3, 0.29), 0.1), LocKit.mat(Color("#F2A900"), 0.3, 0.2), Vector3(0, 0.46, 0))
			_add(h, LocKit.unit_box(), LocKit.mat(Color("#FFE97A"), 0.3, 0.8), Vector3(0, -0.44, 0), Vector3(0.2, 0.16, 0.12))
			_ring(n, YELLOW)
			r["spin"] = true
		"coffee":
			var cup := _float(n, 0.95)
			var body := CylinderMesh.new()
			body.top_radius = 0.26
			body.bottom_radius = 0.19
			body.height = 0.62
			_add(cup, body, LocKit.mat(Color.WHITE, 0.5))
			var sleeve := CylinderMesh.new()
			sleeve.top_radius = 0.255
			sleeve.bottom_radius = 0.215
			sleeve.height = 0.22
			_add(cup, sleeve, LocKit.mat(Color("#A0673F"), 0.8))
			var lid := CylinderMesh.new()
			lid.top_radius = 0.25
			lid.bottom_radius = 0.28
			lid.height = 0.08
			_add(cup, lid, LocKit.mat(Color("#3B2A20"), 0.5), Vector3(0, 0.34, 0))
			for k in 3:
				var puff := SphereMesh.new()
				puff.radius = 0.08 + k * 0.02
				puff.height = puff.radius * 2.0
				_add(cup, puff, LocKit.glass(Color.WHITE, 0.45, true), Vector3(sin(k * 1.7) * 0.06, 0.5 + k * 0.17, 0))
			_ring(n, Color("#C98B4B"))
			r["spin"] = true
		"cartridge":
			var ct := _float(n)
			ct.rotation.z = 0.35
			var tube := CapsuleMesh.new()
			tube.radius = 0.17
			tube.height = 0.8
			_add(ct, tube, LocKit.glass(Color("#E6F0FF"), 0.35))
			var ink := CapsuleMesh.new()
			ink.radius = 0.12
			ink.height = 0.55
			_add(ct, ink, LocKit.mat(BLUE, 0.3, 0.9), Vector3(0, -0.05, 0))
			var cap := CylinderMesh.new()
			cap.top_radius = 0.14
			cap.bottom_radius = 0.18
			cap.height = 0.16
			_add(ct, cap, LocKit.mat(Color("#D7DDEA"), 0.2, 0.0, 0.8), Vector3(0, 0.4, 0))
			_ring(n, BLUE)
			r["spin"] = true
		"libraryCard", "stackOverflow":
			var so := art == "stackOverflow"
			var colc := Color("#F48024") if so else Color("#0FA3C7")
			var lc := _float(n)
			_add(lc, ShapeLib.rounded_box(Vector3(1.0, 0.64, 0.07), 0.08), LocKit.mat(colc, 0.35, 0.3))
			_add(lc, ShapeLib.rounded_box(Vector3(0.28, 0.34, 0.08), 0.04), LocKit.mat(Color.WHITE, 0.5), Vector3(-0.28, 0.02, 0))
			for k in 4:
				var wbar := 0.42 - k * 0.07 if so else 0.4
				_add(lc, LocKit.unit_box(), LocKit.mat(Color.WHITE, 0.5), Vector3(0.18, 0.17 - k * 0.1, 0), Vector3(wbar, 0.045, 0.08))
			_ring(n, colc)
			r["spin"] = true
		"syllabus":
			var sy := _float(n)
			_add(sy, ShapeLib.rounded_box(Vector3(0.78, 1.0, 0.05), 0.05), LocKit.mat(Color.WHITE, 0.6, 0.15))
			_add(sy, LocKit.unit_box(), LocKit.mat(Color("#12A36B"), 0.5), Vector3(0, 0.38, 0), Vector3(0.7, 0.14, 0.06))
			for k in 5:
				_add(sy, LocKit.unit_box(), LocKit.mat(Color("#9FB3D9"), 0.6), Vector3(-0.04 * (k % 2), 0.16 - k * 0.12, 0), Vector3(0.58, 0.03, 0.06))
			_ring(n, Color("#12A36B"))
			r["spin"] = true
		"studyGroup":
			var mg := _float(n)
			for s in [-1.0, 1.0]:
				_add(mg, ShapeLib.rounded_box(Vector3(0.2, 0.62, 0.22), 0.08), LocKit.mat(RED, 0.35, 0.3), Vector3(s * 0.26, 0.05, 0))
				_add(mg, ShapeLib.rounded_box(Vector3(0.21, 0.16, 0.23), 0.05), LocKit.mat(Color("#E6EAF2"), 0.2, 0.0, 0.8), Vector3(s * 0.26, 0.42, 0))
			_add(mg, ShapeLib.rounded_box(Vector3(0.72, 0.22, 0.22), 0.1), LocKit.mat(RED, 0.35, 0.3), Vector3(0, -0.25, 0))
			var heads := [BLUE, Color("#2BC48A"), YELLOW]
			for k in 3:
				var hs := SphereMesh.new()
				hs.radius = 0.1
				hs.height = 0.2
				_add(mg, hs, LocKit.mat(heads[k], 0.4, 0.3), Vector3((k - 1) * 0.26, 0.72, 0))
			_ring(n, RED)
			r["spin"] = true
		# ------------------------------------------------ dikkat dağıtıcılar
		"phone":
			var ph := _float(n, 1.2)
			_add(ph, ShapeLib.rounded_box(Vector3(0.58, 1.0, 0.1), 0.1), LocKit.mat(Color("#1C1F27"), 0.3))
			_add(ph, ShapeLib.rounded_box(Vector3(0.5, 0.88, 0.11), 0.07), LocKit.mat(Color("#FF6F91"), 0.3, 1.1))
			var bub := _node(ph, Vector3(0.36, 0.5, 0.1))
			_add(bub, ShapeLib.rounded_box(Vector3(0.5, 0.24, 0.08), 0.1), LocKit.mat(Color.WHITE, 0.4, 0.3))
			var dot := SphereMesh.new()
			dot.radius = 0.06
			dot.height = 0.12
			_add(bub, dot, LocKit.mat(RED, 0.3, 0.8), Vector3(-0.15, 0, 0.05))
			_ring(n, RED)
		"console":
			var gp := _float(n, 1.15)
			_add(gp, ShapeLib.rounded_box(Vector3(0.95, 0.42, 0.26), 0.18), LocKit.mat(PURPLE, 0.35, 0.2))
			for s in [-1.0, 1.0]:
				var grip := SphereMesh.new()
				grip.radius = 0.2
				grip.height = 0.4
				_add(gp, grip, LocKit.mat(PURPLE.darkened(0.2), 0.4), Vector3(s * 0.4, -0.14, 0))
			for k in 4:
				var btn := SphereMesh.new()
				btn.radius = 0.045
				btn.height = 0.09
				var bc: Color = [RED, YELLOW, Color("#2BC48A"), BLUE][k]
				_add(gp, btn, LocKit.mat(bc, 0.3, 0.5), Vector3(0.25 + (k % 2) * 0.1 - 0.05, 0.02 + (k / 2) * 0.1 - 0.05, 0.13))
			_add(gp, LocKit.unit_box(), LocKit.mat(INK, 0.5), Vector3(-0.25, 0.02, 0.13), Vector3(0.2, 0.06, 0.03))
			_add(gp, LocKit.unit_box(), LocKit.mat(INK, 0.5), Vector3(-0.25, 0.02, 0.13), Vector3(0.06, 0.2, 0.03))
			_ring(n, PURPLE)
		"friend", "friendSkip":
			var text := "Kantin?" if art == "friend" else "Derse girmeyelim!"
			var st := Models.make("students", ["character-male-b", "character-female-c", "character-male-d"][randi() % 3], 1.0)
			n.add_child(st)
			st.rotation.y = 0.0
			var ap := st.find_child("AnimationPlayer", true, false) as AnimationPlayer
			if ap and ap.has_animation("emote-yes"):
				ap.get_animation("emote-yes").loop_mode = Animation.LOOP_LINEAR
				ap.play("emote-yes")
			var bubble := _node(n, Vector3(0, 2.35, 0))
			var bw := 1.6 if text.length() < 10 else 2.8
			var bb := ShapeLib.mesh_node(ShapeLib.rounded_box(Vector3(bw, 0.55, 0.08), 0.22), LocKit.mat(Color.WHITE, 0.4, 0.3))
			bubble.add_child(bb)
			var t := Models.label(text, 54, PURPLE, Color(0, 0, 0, 0))
			t.font = UiKit.heavy()
			t.position = Vector3(0, 0, 0.06)
			bubble.add_child(t)
		"pillow":
			var pl := _float(n, 0.9)
			_add(pl, ShapeLib.rounded_box(Vector3(1.1, 0.55, 0.45), 0.24), LocKit.mat(Color("#E4DBFF"), 0.9))
			_add(pl, LocKit.unit_box(), LocKit.mat(Color("#C9B8FF"), 0.9), Vector3.ZERO, Vector3(1.0, 0.04, 0.47))
			var z := Models.label("Zzz", 70, PURPLE, Color.WHITE)
			z.font = UiKit.heavy()
			z.position = Vector3(0.3, 0.65, 0)
			z.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			pl.add_child(z)
			_ring(n, PURPLE)
		"tv":
			var tv := _float(n, 1.25)
			_add(tv, ShapeLib.rounded_box(Vector3(1.3, 0.85, 0.16), 0.1), LocKit.mat(Color("#1B1E27"), 0.3))
			_add(tv, ShapeLib.rounded_box(Vector3(1.16, 0.72, 0.17), 0.07), LocKit.mat(Color("#A774FF"), 0.3, 1.2))
			_add(tv, LocKit.unit_box(), LocKit.mat(Color("#1B1E27"), 0.4), Vector3(0, -0.6, 0), Vector3(0.1, 0.4, 0.1))
			_add(tv, ShapeLib.rounded_box(Vector3(0.6, 0.06, 0.3), 0.03), LocKit.mat(Color("#1B1E27"), 0.4), Vector3(0, -0.8, 0))
			var nx := Models.label("Sonraki bölüm\n5 sn içinde", 30, Color.WHITE, Color(0.2, 0.05, 0.4))
			nx.position = Vector3(0, 0, 0.1)
			nx.double_sided = false
			tv.add_child(nx)
			_ring(n, PURPLE)
		"party":
			var pa := _float(n, 1.0)
			_add(pa, ShapeLib.rounded_box(Vector3(0.95, 0.62, 0.08), 0.06), LocKit.mat(Color("#FF5FA2"), 0.4, 0.2))
			var flap := PrismMesh.new()
			flap.size = Vector3(0.95, 0.36, 0.09)
			_add(pa, flap, LocKit.mat(Color("#FF8DC0"), 0.5), Vector3(0, 0.12, 0.01), Vector3.ONE, Vector3(0, 0, PI))
			var bcols := [YELLOW, Color("#2BC48A"), BLUE]
			for k in 3:
				var bl := SphereMesh.new()
				bl.radius = 0.2
				bl.height = 0.48
				_add(pa, bl, LocKit.mat(bcols[k], 0.25, 0.3), Vector3((k - 1) * 0.38, 0.95 + (k % 2) * 0.15, -0.05))
				_add(pa, LocKit.unit_box(), LocKit.mat(Color.WHITE, 0.5), Vector3((k - 1) * 0.38, 0.55 + (k % 2) * 0.07, -0.05), Vector3(0.012, 0.5, 0.012))
			_ring(n, PURPLE)
		# ------------------------------------------------ engeller (mekâna göre)
		"spill", "staples":
			return _ground(art == "staples", n, r, lane_w)
		"plane", "paperBall":
			return _air(art == "paperBall", n, r, lane_w)
		"encyclopedia":
			return _wall(n, r, lane_w)
		_:
			return {}
	return r


# ---------------------------------------------------------------- yardımcılar

## Yerden yükselen, dönebilen tutucu (toplanabilirler 1,1 m'de süzülür).
static func _float(parent: Node3D, y := 1.1) -> Node3D:
	return _node(parent, Vector3(0, y, 0))


static func _node(parent: Node3D, pos: Vector3) -> Node3D:
	var n := Node3D.new()
	n.position = pos
	parent.add_child(n)
	return n


static func _add(parent: Node3D, mesh: Mesh, m: Material, pos := Vector3.ZERO, scl := Vector3.ONE, rot := Vector3.ZERO) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = m
	mi.position = pos
	mi.scale = scl
	mi.rotation = rot
	parent.add_child(mi)
	return mi


## Nesnenin altında yerde parlayan halka: uzaktan bile seçilir.
static func _ring(parent: Node3D, c: Color) -> void:
	var tm := TorusMesh.new()
	tm.inner_radius = 0.42
	tm.outer_radius = 0.55
	var mi := _add(parent, tm, LocKit.glass(c.lightened(0.2), 0.4, true), Vector3(0, 0.03, 0), Vector3(1, 0.05, 1))
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


## Yer engeli: ~1 m, zıplanır.
static func _ground(alt: bool, n: Node3D, r: Dictionary, lane_w: float) -> Dictionary:
	var w := lane_w * 0.8
	r["size"] = Vector3(w, 1.0, 0.7)
	r["center"] = Vector3(0, 0.5, 0)
	var b := LocKit.BoxBatch.new(0.55)
	match location:
		"library":
			# kitap yığını
			var cols := [Color("#8E2F3C"), Color("#2F4E8E"), Color("#2E7D5B"), Color("#D9A441"), Color("#6B3F8E")]
			for k in 5:
				var bw := w * (0.9 - k * 0.08)
				var y := 0.1 + k * 0.2
				b.add(Vector3(bw, 0.18, 0.62), Vector3(randf_range(-0.08, 0.08), y, 0), cols[(k + int(alt)) % 5], Vector3(0, randf_range(-0.15, 0.15), 0))
				b.add(Vector3(bw - 0.04, 0.14, 0.56), Vector3(randf_range(-0.08, 0.08) + 0.03, y, 0.01), Color("#F3EAD3"))
		"cafeteria":
			if alt:
				# tepsi yığını
				for k in 7:
					b.add(Vector3(w * 0.7, 0.07, 0.55), Vector3(0, 0.1 + k * 0.12, 0), Color("#E5484D") if k % 2 else Color("#F2F2F2"), Vector3(0, randf_range(-0.1, 0.1), 0))
			else:
				# "Kaygan zemin" A tabelası + su birikintisi
				for s in [-1.0, 1.0]:
					b.add(Vector3(w * 0.8, 1.0, 0.05), Vector3(0, 0.48, s * 0.17), YELLOW, Vector3(-s * 0.33, 0, 0))
				b.add(Vector3(w, 0.01, 0.9), Vector3(0, 0.005, 0), Color("#9ED8FF"))
				var t := Models.label("KAYGAN ZEMİN", 44, INK, Color(0, 0, 0, 0))
				t.font = UiKit.heavy()
				t.position = Vector3(0, 0.5, 0.21)
				t.rotation.x = -0.33
				t.double_sided = false
				n.add_child(t)
		"lab":
			if alt:
				# gaz tüpleri
				for k in 3:
					var cyl := MeshInstance3D.new()
					cyl.mesh = LocKit.unit_cyl()
					cyl.scale = Vector3(0.36, 0.95, 0.36)
					cyl.position = Vector3((k - 1) * 0.6, 0.48, 0)
					cyl.material_override = LocKit.mat([Color("#2BC48A"), Color("#E5484D"), Color("#4FC3FF")][k], 0.3)
					n.add_child(cyl)
					b.add(Vector3(0.2, 0.12, 0.2), Vector3((k - 1) * 0.6, 1.0, 0), Color("#C9D1D9"))
			else:
				# tehlikeli madde sandığı (sarı-siyah şeritli)
				b.add(Vector3(w * 0.85, 0.9, 0.62), Vector3(0, 0.45, 0), Color("#3A3F47"))
				for k in 6:
					b.add(Vector3(0.18, 0.95, 0.02), Vector3(-w * 0.35 + k * w * 0.14, 0.45, 0.32), YELLOW, Vector3(0, 0, 0.5))
				var t2 := Models.label("!", 90, RED, Color.WHITE)
				t2.font = UiKit.heavy()
				t2.position = Vector3(0, 0.5, 0.34)
				n.add_child(t2)
		"gym":
			if alt:
				# atletizm engelleri
				for s in [-1.0, 1.0]:
					b.add(Vector3(0.06, 0.9, 0.06), Vector3(s * w * 0.45, 0.45, 0), Color("#D9DCE3"))
					b.add(Vector3(0.06, 0.04, 0.5), Vector3(s * w * 0.45, 0.02, 0), Color("#D9DCE3"))
				for k in 4:
					b.add(Vector3(w * 0.9 / 4.0, 0.18, 0.05), Vector3(-w * 0.34 + k * w * 0.225, 0.86, 0), RED if k % 2 else Color.WHITE)
			else:
				# spor bankı
				b.add(Vector3(w * 0.95, 0.12, 0.45), Vector3(0, 0.62, 0), Color("#B9803F"))
				for s in [-1.0, 1.0]:
					b.add(Vector3(0.1, 0.6, 0.4), Vector3(s * w * 0.4, 0.3, 0), Color("#8B95A7"))
		"quad":
			if alt:
				# park bankı
				b.add(Vector3(w * 0.95, 0.1, 0.5), Vector3(0, 0.5, 0), Color("#8A5A34"))
				b.add(Vector3(w * 0.95, 0.35, 0.08), Vector3(0, 0.8, -0.22), Color("#8A5A34"))
				for s in [-1.0, 1.0]:
					b.add(Vector3(0.1, 0.5, 0.5), Vector3(s * w * 0.42, 0.25, 0), Color("#3A3F47"))
			else:
				# taş saksı ve çiçekler
				b.add(Vector3(w * 0.9, 0.7, 0.62), Vector3(0, 0.35, 0), Color("#CFC6B6"))
				b.add(Vector3(w * 0.8, 0.08, 0.52), Vector3(0, 0.72, 0), Color("#5A3B28"))
				for k in 9:
					var fc: Color = [Color("#FF5D73"), YELLOW, Color("#B06BFF"), Color.WHITE][k % 4]
					b.add(Vector3(0.2, 0.2, 0.2), Vector3(-w * 0.35 + k * w * 0.088, 0.88, randf_range(-0.15, 0.15)), fc)
					b.add(Vector3(0.05, 0.15, 0.05), Vector3(-w * 0.35 + k * w * 0.088, 0.78, 0), Color("#3F8F35"))
		_:
			# kırmızı-beyaz çizgili bariyer (varsayılan)
			for s in [-1.0, 1.0]:
				b.add(Vector3(0.12, 0.9, 0.5), Vector3(s * w * 0.42, 0.45, 0), Color("#8A93A6"))
			b.add(Vector3(w, 0.42, 0.14), Vector3(0, 0.66, 0), Color.WHITE)
			for k in 5:
				b.add(Vector3(0.2, 0.55, 0.16), Vector3(-w / 2.0 + (k + 0.5) * w / 5.0, 0.66, 0), RED, Vector3(0, 0, 0.6))
	b.flush(n)
	return r


## Hava engeli: 1,2 m'nin üstünde, altından kayılır.
static func _air(alt: bool, n: Node3D, r: Dictionary, lane_w: float) -> Dictionary:
	var w := lane_w * 0.95
	r["size"] = Vector3(lane_w * 0.9, 1.1, 0.4)
	r["center"] = Vector3(0, 1.75, 0)
	var b := LocKit.BoxBatch.new(0.55)
	var text := ""
	var band := RED
	var fg := Color.WHITE
	match location:
		"library":
			text = "SESSİZ OL!" if not alt else "KİTAP İADE"
			band = Color("#5A3522")
			fg = Color("#FFD98A")
			for s in [-1.0, 1.0]:
				b.add(Vector3(0.04, 2.6, 0.04), Vector3(s * w * 0.35, 3.6, 0), Color("#A08060"))
		"cafeteria":
			text = "SIRA BURADA" if not alt else "TEPSİNİ AL"
			band = Color("#2E86AB")
			for s in [-1.0, 1.0]:
				b.add(Vector3(0.04, 2.6, 0.04), Vector3(s * w * 0.35, 3.6, 0), Color("#555555"))
		"lab":
			text = "DİKKAT: BORU" if not alt else "GÖZLÜK TAK!"
			band = YELLOW
			fg = INK
			var pipe := MeshInstance3D.new()
			pipe.mesh = LocKit.unit_cyl()
			pipe.scale = Vector3(0.3, w, 0.3)
			pipe.rotation.z = PI / 2.0
			pipe.position = Vector3(0, 2.35, 0)
			pipe.material_override = LocKit.mat(Color("#9AA7B1"), 0.3, 0.0, 0.6)
			n.add_child(pipe)
		"gym":
			# voleybol filesi
			for s in [-1.0, 1.0]:
				b.add(Vector3(0.1, 2.6, 0.1), Vector3(s * w * 0.5, 1.3, 0), Color("#D9DCE3"))
			b.add(Vector3(w, 0.12, 0.05), Vector3(0, 2.25, 0), Color.WHITE)
			for k in 12:
				b.add(Vector3(0.02, 0.95, 0.02), Vector3(-w / 2.0 + (k + 0.5) * w / 12.0, 1.75, 0), Color(0.95, 0.95, 0.95))
			for k in 5:
				b.add(Vector3(w, 0.02, 0.02), Vector3(0, 1.3 + k * 0.2, 0), Color(0.95, 0.95, 0.95))
			b.flush(n)
			return r
		_:
			text = "HOŞ GELDİN!" if not alt else "KULÜP TANITIMI"
			band = Color("#2E6BFF")
			for s in [-1.0, 1.0]:
				b.add(Vector3(0.14, 2.6, 0.14), Vector3(s * w * 0.48, 1.3, 0), Color("#D9DCE3"))
				b.add(Vector3(0.22, 0.12, 0.22), Vector3(s * w * 0.48, 2.62, 0), Color("#D9DCE3"))
	b.add(Vector3(w * 0.92, 0.95, 0.12), Vector3(0, 1.75, 0), band)
	b.add(Vector3(w * 0.96, 0.08, 0.14), Vector3(0, 2.24, 0), band.darkened(0.3))
	b.add(Vector3(w * 0.96, 0.08, 0.14), Vector3(0, 1.26, 0), band.darkened(0.3))
	b.flush(n)
	for side in [1.0, -1.0]:
		var l := Models.label(text, 50 if text.length() < 11 else 42, fg, band.darkened(0.5))
		l.font = UiKit.heavy()
		l.double_sided = false
		l.position = Vector3(0, 1.75, side * 0.08)
		l.rotation.y = 0.0 if side > 0 else PI
		n.add_child(l)
	return r


## Duvar: şeridi tamamen kapatır (~2,7 m).
static func _wall(n: Node3D, r: Dictionary, lane_w: float) -> Dictionary:
	var w := lane_w * 0.85
	r["size"] = Vector3(w, 2.7, 1.2)
	r["center"] = Vector3(0, 1.35, 0)
	var b := LocKit.BoxBatch.new(0.55)
	match location:
		"library":
			# kitap arabası dolu raf
			var wood := Color("#4A2B1C")
			b.add(Vector3(w, 2.6, 1.0), Vector3(0, 1.3, -0.1), wood)
			for j in 4:
				var y := 0.35 + j * 0.62
				var x := -w / 2.0 + 0.12
				while x < w / 2.0 - 0.12:
					var bw := randf_range(0.07, 0.13)
					var cols := [Color("#8E2F3C"), Color("#2F4E8E"), Color("#2E7D5B"), Color("#D9A441"), Color("#6B3F8E")]
					b.add(Vector3(bw, 0.5, 0.5), Vector3(x + bw / 2.0, y + 0.25, 0.3), cols[randi() % 5])
					x += bw + 0.005
				b.add(Vector3(w, 0.06, 0.7), Vector3(0, y - 0.03, 0.25), wood.darkened(0.2))
		"cafeteria":
			# içecek otomatı
			var body := ShapeLib.mesh_node(ShapeLib.rounded_box(Vector3(w, 2.6, 1.0), 0.12), LocKit.mat(RED, 0.35), Vector3(0, 1.3, 0), Vector3(0, 0, 0))
			n.add_child(body)
			var glass_front := ShapeLib.mesh_node(ShapeLib.rounded_box(Vector3(w * 0.62, 1.7, 0.1), 0.06), LocKit.mat(Color("#DDF4FF"), 0.1, 0.9), Vector3(-w * 0.12, 1.55, 0.5))
			n.add_child(glass_front)
			for j in 4:
				for k in 4:
					b.add(Vector3(0.16, 0.26, 0.1), Vector3(-w * 0.12 - 0.36 + k * 0.24, 0.9 + j * 0.4, 0.52),
						[YELLOW, BLUE, Color("#2BC48A"), Color("#FF8A3D")][(j + k) % 4])
			b.add(Vector3(0.3, 0.8, 0.08), Vector3(w * 0.33, 1.6, 0.52), Color("#20242E"))
		"lab":
			# cam kapaklı dolap
			b.add(Vector3(w, 2.6, 1.0), Vector3(0, 1.3, 0), Color("#E8EEF2"))
			b.add(Vector3(w * 0.9, 0.08, 0.1), Vector3(0, 1.3, 0.52), Color("#2A7FBA"))
			var gl := LocKit.box(n, Vector3(w * 0.84, 1.0, 0.04), Vector3(0, 1.95, 0.52), LocKit.glass(Color("#BFE8FF"), 0.35))
			gl.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			for k in 5:
				var lc: Color = [Color("#3DFF9A"), Color("#4FC3FF"), Color("#FF5FD2")][k % 3]
				b.add(Vector3(0.14, 0.34, 0.14), Vector3(-w * 0.35 + k * w * 0.17, 1.72, 0.3), lc)
			var sign := Models.label("KİMYASAL", 44, INK, Color(0, 0, 0, 0))
			sign.font = UiKit.heavy()
			sign.position = Vector3(0, 0.8, 0.51)
			n.add_child(sign)
		"gym":
			# üst üste minderler
			var cols2 := [Color("#1F4FA8"), Color("#E63946"), Color("#1F4FA8"), Color("#FFD23F"), Color("#1F4FA8")]
			for k in 5:
				b.add(Vector3(w * (0.98 - (k % 2) * 0.04), 0.5, 1.1), Vector3(randf_range(-0.05, 0.05), 0.27 + k * 0.52, 0), cols2[k], Vector3(0, randf_range(-0.06, 0.06), 0))
		_:
			# duyuru panosu
			b.add(Vector3(w, 2.2, 0.3), Vector3(0, 1.5, 0), Color("#6B4A2B"))
			b.add(Vector3(w * 0.88, 1.9, 0.32), Vector3(0, 1.52, 0.02), Color("#C8955C"))
			for k in 8:
				var pc: Color = [Color.WHITE, YELLOW, Color("#9ED8FF"), Color("#FFB3C1")][k % 4]
				b.add(Vector3(0.42, 0.52, 0.02), Vector3(-w * 0.3 + (k % 4) * w * 0.2, 1.1 + (k / 4) * 0.75, 0.2), pc, Vector3(0, 0, randf_range(-0.15, 0.15)))
			b.add(Vector3(0.14, 0.5, 0.14), Vector3(-w * 0.4, 0.25, 0), Color("#4A3322"))
			b.add(Vector3(0.14, 0.5, 0.14), Vector3(w * 0.4, 0.25, 0), Color("#4A3322"))
	b.flush(n)
	return r
