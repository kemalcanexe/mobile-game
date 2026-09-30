class_name ItemFactory
## Nesnelerin 3D görselleri. (+) nesneler yuvarlak hatlı ve parlak mavi/sarı,
## (−) nesneler köşeli ve kırmızı/mor: uzaktan bile ayırt edilir.

const BLUE := Color("#2E6BFF")
const YELLOW := Color("#FFD23F")
const RED := Color("#FF4D4D")
const PURPLE := Color("#8B3DFF")
const PAPER := Color("#FFFDF5")
const GREEN := Color("#12A36B")
const INK_DARK := Color("#1E2A3A")


## Görsel düğüm + çarpışma kutusu boyutu ve konumu.
static func build(item: Dictionary, lane_w: float, extra: Dictionary = {}) -> Dictionary:
	var art: String = item["art"]
	var n := Node3D.new()
	var size := Vector3(1.2, 3.2, 1.0)  # toplanabilirler: zıplarken de toplanır
	var center := Vector3(0, 1.6, 0)
	var spin := false
	match art:
		"flashcard":
			n.add_child(_card(Vector3(0.9, 0.6, 0.06), PAPER, BLUE, "Aa", 56))
			spin = true
		"note":
			n.add_child(_card(Vector3(0.7, 0.9, 0.06), PAPER, BLUE, "NOT", 44))
			spin = true
		"formula":
			n.add_child(_card(Vector3(0.9, 0.9, 0.08), Color("#DDE7FF"), BLUE, "∫dx", 64))
			spin = true
		"physics":
			n.add_child(_card(Vector3(1.0, 0.8, 0.08), Color("#FFE7D6"), Color("#FF6A2B"), "F=ma", 50))
			spin = true
		"code":
			n.add_child(_card(Vector3(1.0, 0.8, 0.08), Color("#D8F5E3"), Color("#12A36B"), "{ }", 70))
			spin = true
		"book":
			var b := Models.make("furniture", "books", 1.3)
			b.position = Vector3(-0.35, 0.55, 0.3)
			n.add_child(b)
			n.add_child(_glow(BLUE, 0.9))
			spin = true
		"bonus":
			var s := _sphere(0.45, YELLOW, 0.6)
			s.position.y = 1.0
			n.add_child(s)
			var q := Models.label("?", 110, BLUE, Color.WHITE)
			q.position = Vector3(0, 1.0, 0.46)
			q.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			n.add_child(q)
			spin = true
		"highlighter":
			var body := _cyl(0.16, 0.8, YELLOW, 0.5)
			body.rotation_degrees = Vector3(0, 0, 35)
			body.position.y = 1.0
			n.add_child(body)
			var cap := _cyl(0.17, 0.28, Color("#F2A900"), 0.2)
			cap.rotation_degrees = Vector3(0, 0, 35)
			cap.position = Vector3(-0.28, 1.4, 0)
			n.add_child(cap)
			n.add_child(_glow(YELLOW, 1.0))
			spin = true
		"coffee":
			var cup := Models.make("food", "cup-coffee", 1.2)
			cup.position = Vector3(0, 0.55, 0)
			n.add_child(cup)
			n.add_child(_glow(Color("#C98B4B"), 0.9))
			spin = true
		"cartridge":
			var cart := MeshInstance3D.new()
			var cm := CapsuleMesh.new()
			cm.radius = 0.18
			cm.height = 0.8
			cart.mesh = cm
			cart.material_override = Models.mat(BLUE, 0.3, 0.4)
			cart.position.y = 1.0
			cart.rotation_degrees.z = 20
			n.add_child(cart)
			n.add_child(_glow(BLUE, 0.9))
			spin = true
		"libraryCard":
			n.add_child(_card(Vector3(1.05, 0.68, 0.06), Color("#DDF6FF"), Color("#0FA3C7"), "KÜTÜPHANE", 26))
			n.add_child(_glow(Color("#3CD3F5"), 1.05))
			spin = true
		"stackOverflow":
			var so := _card(Vector3(1.0, 0.8, 0.08), Color("#FFF1E3"), Color("#F48024"), "S/O", 64)
			n.add_child(so)
			for k in 3:
				var bar := Models.box(Vector3(0.5 - k * 0.1, 0.07, 0.1), Color("#F48024"), Vector3(0, 1.62 + k * 0.1, 0))
				n.add_child(bar)
			n.add_child(_glow(Color("#F48024"), 1.05))
			spin = true
		"syllabus":
			var sheet := Models.box(Vector3(0.75, 1.0, 0.04), PAPER, Vector3(0, 1.05, 0))
			sheet.material_override = Models.mat(PAPER, 0.6, 0.2)
			n.add_child(sheet)
			for k in 5:
				n.add_child(Models.box(Vector3(0.5, 0.035, 0.05), Color("#9FB3D9"), Vector3(0, 0.8 + k * 0.1, 0)))
			var st := Models.label("SYLLABUS", 30, GREEN, Color.WHITE)
			st.position = Vector3(0, 1.4, 0.03)
			n.add_child(st)
			n.add_child(_glow(GREEN, 1.05))
			spin = true
		"studyGroup":
			# mıknatıs: U biçimi + üç küçük "arkadaş" başı
			var red := Color("#E23B3B")
			for sx in [-0.28, 0.28]:
				n.add_child(Models.box(Vector3(0.18, 0.6, 0.18), red, Vector3(sx, 1.15, 0)))
				n.add_child(Models.box(Vector3(0.19, 0.16, 0.19), Color("#D9DDE5"), Vector3(sx, 1.52, 0)))
			n.add_child(Models.box(Vector3(0.74, 0.18, 0.18), red, Vector3(0, 0.8, 0)))
			var heads := [Color("#2E6BFF"), Color("#2BC48A"), Color("#FFD23F")]
			for k in 3:
				var hd := _sphere(0.13, heads[k], 0.4)
				hd.position = Vector3((k - 1) * 0.32, 1.95, 0)
				n.add_child(hd)
			n.add_child(_glow(Color("#E23B3B"), 1.2))
			spin = true
		"friendSkip":
			_person(n, Color("#FF8A3D"), "Derse girmeyelim!", Color("#C95A10"))
		"pillow":
			var pil := MeshInstance3D.new()
			var pm := SphereMesh.new()
			pm.radius = 0.55
			pm.height = 1.1
			pil.mesh = pm
			pil.scale = Vector3(1.3, 0.55, 0.9)
			pil.material_override = Models.mat(Color("#EDE7FF"), 0.9)
			pil.position.y = 1.0
			n.add_child(pil)
			var z := Models.label("Zzz", 70, PURPLE, Color.WHITE)
			z.position = Vector3(0.2, 1.75, 0)
			z.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			n.add_child(z)
		"tv":
			var tv := Models.box(Vector3(1.25, 0.85, 0.2), Color("#1B1E27"), Vector3(0, 1.3, 0))
			n.add_child(tv)
			var screen := Models.box(Vector3(1.1, 0.7, 0.02), PURPLE, Vector3(0, 1.3, 0.11))
			screen.material_override = Models.mat(Color("#A774FF"), 0.3, 1.1)
			n.add_child(screen)
			n.add_child(Models.box(Vector3(0.1, 0.5, 0.1), Color("#1B1E27"), Vector3(0, 0.7, 0)))
			n.add_child(Models.box(Vector3(0.6, 0.06, 0.35), Color("#1B1E27"), Vector3(0, 0.45, 0)))
			var nxt := Models.label("Sonraki bölüm\n5 sn içinde", 30, Color.WHITE, PURPLE.darkened(0.5))
			nxt.position = Vector3(0, 1.3, 0.125)
			nxt.double_sided = false
			n.add_child(nxt)
		"party":
			var env := Models.box(Vector3(1.0, 0.65, 0.08), Color("#FF5FA2"), Vector3(0, 1.2, 0))
			env.rotation_degrees.z = 12
			n.add_child(env)
			var flap := MeshInstance3D.new()
			var pr := PrismMesh.new()
			pr.size = Vector3(1.0, 0.4, 0.09)
			flap.mesh = pr
			flap.material_override = Models.mat(Color("#FF8DC0"))
			flap.position = Vector3(0, 1.0, 0.01)
			flap.rotation_degrees = Vector3(0, 0, 192)
			n.add_child(flap)
			var pl := Models.label("PARTİ!", 56, Color.WHITE, Color("#B01E63"))
			pl.position = Vector3(0, 1.95, 0)
			pl.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			n.add_child(pl)
			for k in 8:
				var c := Models.box(Vector3(0.1, 0.1, 0.02), [YELLOW, BLUE, GREEN, RED][k % 4], Vector3(randf_range(-0.7, 0.7), randf_range(1.4, 2.4), randf_range(-0.2, 0.2)))
				c.rotation = Vector3(randf(), randf(), randf()) * TAU
				n.add_child(c)
		"bottle":
			# karikatür şişe: gözlüklü, gülümseyen
			var green := Color("#2F9E5B")
			var body := _cyl(0.3, 0.9, green, 0.15)
			body.position.y = 0.95
			n.add_child(body)
			var neck := _cyl(0.12, 0.45, green, 0.15)
			neck.position.y = 1.62
			n.add_child(neck)
			n.add_child(Models.box(Vector3(0.42, 0.3, 0.02), Color("#FFF1C1"), Vector3(0, 0.95, 0.3)))
			for sx in [-0.13, 0.13]:
				var lens := MeshInstance3D.new()
				var tm := TorusMesh.new()
				tm.inner_radius = 0.07
				tm.outer_radius = 0.1
				lens.mesh = tm
				lens.material_override = Models.mat(INK_DARK)
				lens.rotation_degrees.x = 90
				lens.position = Vector3(sx, 1.28, 0.31)
				n.add_child(lens)
			var sm := Models.label("‿", 60, INK_DARK, Color(0, 0, 0, 0))
			sm.position = Vector3(0, 1.14, 0.32)
			n.add_child(sm)
		"answerGate", "divisionGate", "officeDoor":
			# içinden geçilen kapı: iki direk, üst kiriş, yarı saydam perde
			var col := BLUE
			var text: String = str(extra.get("text", ""))
			if art == "divisionGate":
				col = GREEN
				text = "İŞ BÖLÜMÜ"
			elif art == "officeDoor":
				col = Color("#C98B2B")
				text = "OFİS SAATİ"
			var gw := lane_w * 0.9
			for sx in [-1.0, 1.0]:
				n.add_child(Models.box(Vector3(0.22, 3.6, 0.22), col.darkened(0.25), Vector3(sx * gw / 2.0, 1.8, 0)))
			var beam := Models.box(Vector3(gw + 0.22, 0.9, 0.3), col, Vector3(0, 3.35, 0))
			beam.material_override = Models.mat(col, 0.5, 0.35)
			n.add_child(beam)
			var curtain := Models.box(Vector3(gw, 2.9, 0.04), col, Vector3(0, 1.45, 0))
			var cmat := Models.mat(col.lightened(0.3), 0.3, 0.8)
			cmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			cmat.albedo_color = Color(col.lightened(0.3), 0.28)
			curtain.material_override = cmat
			curtain.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			n.add_child(curtain)
			var lbl := Models.label(text, 76 if text.length() <= 8 else 54, Color.WHITE, col.darkened(0.55))
			lbl.position = Vector3(0, 3.35, 0.17)
			n.add_child(lbl)
			if art == "officeDoor":
				var glow := Models.box(Vector3(gw * 0.8, 2.6, 0.02), UiKit.GOLD, Vector3(0, 1.4, -0.05))
				glow.material_override = Models.mat(Color("#FFE08A"), 0.2, 2.0)
				n.add_child(glow)
			size = Vector3(gw, 3.6, 0.5)
			center = Vector3(0, 1.8, 0)
		"ramp":
			# türev rampası: sarı eğik düzlem, üstünde f'(x) yazısı
			var ramp := MeshInstance3D.new()
			var pm := PrismMesh.new()
			pm.left_to_right = 1.0
			pm.size = Vector3(3.0, 1.0, lane_w * 0.85)
			ramp.mesh = pm
			ramp.material_override = Models.mat(YELLOW, 0.5, 0.25)
			ramp.rotation_degrees.y = 90
			ramp.position.y = 0.5
			n.add_child(ramp)
			var fl := Models.label("f′(x) ↗", 64, INK_DARK, Color.WHITE)
			fl.position = Vector3(0, 1.4, 0)
			fl.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			n.add_child(fl)
			size = Vector3(lane_w * 0.8, 1.2, 1.0)
			center = Vector3(0, 0.6, 1.2)
		"bug":
			# CS böceği: yeşil gövde, bacaklar, antenler (zıplanır)
			var bug := Node3D.new()
			bug.name = "Bug"
			var shell := _sphere(0.42, Color("#2BC48A"), 0.5)
			shell.scale = Vector3(1.2, 0.6, 1.4)
			shell.position.y = 0.4
			bug.add_child(shell)
			var bh := _sphere(0.22, Color("#1C9467"), 0.3)
			bh.position = Vector3(0, 0.45, 0.55)
			bug.add_child(bh)
			for sx in [-1.0, 1.0]:
				for k in 3:
					var leg := Models.box(Vector3(0.45, 0.05, 0.05), INK_DARK, Vector3(sx * 0.55, 0.2, -0.3 + k * 0.3))
					leg.rotation_degrees.z = sx * -25
					bug.add_child(leg)
				var ant := Models.box(Vector3(0.04, 0.4, 0.04), INK_DARK, Vector3(sx * 0.12, 0.75, 0.7))
				ant.rotation_degrees.x = 35
				bug.add_child(ant)
				var eye := _sphere(0.06, RED, 1.0)
				eye.position = Vector3(sx * 0.1, 0.52, 0.74)
				bug.add_child(eye)
			var bl := Models.label("BUG", 44, Color.WHITE, Color("#1C9467"))
			bl.position = Vector3(0, 1.2, 0)
			bl.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			bug.add_child(bl)
			n.add_child(bug)
			size = Vector3(lane_w * 0.6, 0.9, 1.0)
			center = Vector3(0, 0.45, 0)
		"bossX":
			# Prof. Kırmızı'nın ✗'i: şeridi kapatır
			for rz in [45.0, -45.0]:
				var bar := Models.box(Vector3(lane_w * 0.95, 0.42, 0.4), Color("#E0262B"), Vector3(0, 1.3, 0))
				bar.material_override = Models.mat(Color("#E0262B"), 0.35, 0.9)
				bar.rotation_degrees.z = rz
				n.add_child(bar)
			size = Vector3(lane_w * 0.85, 2.6, 0.8)
			center = Vector3(0, 1.3, 0)
		"bossLine":
			# "Bu sınavda çıkmaz dediğim konu": kırmızı çizgi bariyer
			var line := Models.box(Vector3(lane_w, 2.4, 0.12), Color("#E0262B"), Vector3(0, 1.3, 0))
			var lm := Models.mat(Color("#FF3B3B"), 0.2, 1.6)
			lm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			lm.albedo_color = Color("#FF3B3B", 0.55)
			line.material_override = lm
			line.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			n.add_child(line)
			n.add_child(Models.box(Vector3(lane_w, 0.12, 0.2), Color("#9E1418"), Vector3(0, 2.55, 0)))
			var no := Models.label("ÇIKMAZ", 70, Color.WHITE, Color("#9E1418"))
			no.position = Vector3(0, 1.3, 0.08)
			n.add_child(no)
			size = Vector3(lane_w * 0.9, 2.6, 0.5)
			center = Vector3(0, 1.3, 0)
		"phone":
			var ph := Models.box(Vector3(0.55, 1.0, 0.1), Color("#22252E"), Vector3(0, 1.1, 0))
			n.add_child(ph)
			var scr := Models.box(Vector3(0.46, 0.85, 0.02), Color("#FF6B6B"), Vector3(0, 1.1, -0.06))
			scr.material_override = Models.mat(Color("#FF8080"), 0.3, 0.9)
			n.add_child(scr)
			var badge := _sphere(0.13, RED, 0.8)
			badge.position = Vector3(0.28, 1.6, -0.05)
			n.add_child(badge)
			var bell := Models.label("!", 70, Color.WHITE, RED)
			bell.position = Vector3(0, 1.1, -0.08)
			bell.rotation_degrees.y = 180
			n.add_child(bell)
			size = Vector3(1.2, 3.2, 1.0)
		"console":
			var pad := Models.box(Vector3(1.0, 0.4, 0.5), PURPLE, Vector3(0, 1.1, 0))
			pad.material_override = Models.mat(PURPLE, 0.4, 0.2)
			n.add_child(pad)
			for sx in [-0.55, 0.55]:
				var grip := Models.box(Vector3(0.35, 0.5, 0.45), PURPLE.darkened(0.2), Vector3(sx, 0.95, 0))
				n.add_child(grip)
			for p in [Vector3(0.25, 1.32, -0.12), Vector3(0.4, 1.32, 0.02)]:
				var btn := _sphere(0.07, RED, 0.5)
				btn.position = p
				n.add_child(btn)
		"friend":
			_person(n, PURPLE, "Kantin?", PURPLE)
		"spill":
			# yer engeli: kırmızı-beyaz çizgili bariyer (zıplanır)
			var bw := lane_w * 0.82
			for sx in [-1.0, 1.0]:
				n.add_child(Models.box(Vector3(0.12, 0.9, 0.5), Color("#8A93A6"), Vector3(sx * bw * 0.42, 0.45, 0)))
			var plank := Models.box(Vector3(bw, 0.42, 0.14), Color.WHITE, Vector3(0, 0.66, 0))
			plank.material_override = Models.mat(Color.WHITE, 0.5, 0.1)
			n.add_child(plank)
			var stripes := 5
			for k in stripes:
				var st := Models.box(Vector3(0.2, 0.55, 0.02), RED, Vector3(-bw / 2.0 + (k + 0.5) * bw / stripes, 0.66, 0.08))
				st.material_override = Models.mat(RED, 0.5, 0.3)
				st.rotation_degrees.z = 35
				n.add_child(st)
				var st2 := st.duplicate()
				st2.position.z = -0.08
				n.add_child(st2)
			var lamp := _sphere(0.1, Color("#FFB020"), 1.5)
			lamp.position = Vector3(bw * 0.42, 0.98, 0)
			n.add_child(lamp)
			size = Vector3(lane_w * 0.8, 1.0, 0.7)
			center = Vector3(0, 0.5, 0)
		"staples":
			# yer engeli: koni sırası
			for k in 3:
				var cone := Models.make("roads", "construction-cone", 1.1)
				cone.position = Vector3((k - 1) * 0.75, 0, 0)
				n.add_child(cone)
			size = Vector3(lane_w * 0.8, 1.0, 0.7)
			center = Vector3(0, 0.5, 0)
		"plane", "paperBall":
			# hava engeli: iki direk arasında afiş (altından kayılır)
			var text := "SINAV HAFTASI" if art == "plane" else "SESSİZ OL!"
			var col := RED if art == "plane" else PURPLE
			for sx in [-1.0, 1.0]:
				n.add_child(Models.box(Vector3(0.14, 2.6, 0.14), Color(0.85, 0.85, 0.88), Vector3(sx * lane_w * 0.45, 1.3, 0)))
			var banner := Models.box(Vector3(lane_w * 0.95, 1.0, 0.12), col, Vector3(0, 1.75, 0))
			banner.material_override = Models.mat(col, 0.6, 0.15)
			n.add_child(banner)
			var lbl := Models.label(text, 60, Color.WHITE, col.darkened(0.5))
			lbl.position = Vector3(0, 1.75, 0.08)
			n.add_child(lbl)
			var lbl2 := lbl.duplicate()
			lbl2.position = Vector3(0, 1.75, -0.08)
			lbl2.rotation_degrees.y = 180
			n.add_child(lbl2)
			size = Vector3(lane_w * 0.9, 1.1, 0.4)
			center = Vector3(0, 1.75, 0)
		"encyclopedia":
			# duvar: dev ansiklopedi yığını (şeridi tamamen kapatır)
			var colors := [Color("#C0392B"), Color("#2E6BFF"), Color("#F39C12"), Color("#16A085")]
			for k in 4:
				var bk := Models.box(Vector3(lane_w * 0.85 - k * 0.08, 0.65, 1.6), colors[k], Vector3(randf_range(-0.08, 0.08), 0.33 + k * 0.66, 0))
				bk.rotation.y = randf_range(-0.08, 0.08)
				n.add_child(bk)
				# sayfalar yanlarda görünür; kameraya renkli sırt bakar
				var page := Models.box(Vector3(lane_w * 0.85 - k * 0.08 + 0.04, 0.5, 1.3), PAPER, bk.position + Vector3(0, 0, -0.12))
				page.rotation.y = bk.rotation.y
				n.add_child(page)
			for k in 4:
				var vol := Models.label(["A–E", "F–K", "L–R", "S–Z"][k], 56, Color("#FFE9A8"), Color(0, 0, 0, 0.5))
				vol.position = Vector3(0, 0.33 + k * 0.66, 0.81)
				n.add_child(vol)
			var az := Models.label("ANSİKLOPEDİ", 40, Color.WHITE, Color(0, 0, 0, 0.7))
			az.position = Vector3(0, 2.75, 0.4)
			az.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			n.add_child(az)
			size = Vector3(lane_w * 0.85, 2.7, 1.6)
			center = Vector3(0, 1.35, 0)
		_:
			n.add_child(Models.box(Vector3(0.6, 0.6, 0.6), Color.MAGENTA, Vector3(0, 1, 0)))
	return {"node": n, "size": size, "center": center, "spin": spin}


## Kötü arkadaş: gövde, baş, saç ve konuşma balonu.
static func _person(n: Node3D, shirt: Color, speech: String, speech_color: Color) -> void:
	var torso := MeshInstance3D.new()
	var tc := CapsuleMesh.new()
	tc.radius = 0.32
	tc.height = 1.2
	torso.mesh = tc
	torso.material_override = Models.mat(shirt, 0.6)
	torso.position.y = 0.95
	n.add_child(torso)
	var head := _sphere(0.28, Color("#F2C7A5"), 0.0)
	head.position.y = 1.85
	n.add_child(head)
	var hair := _sphere(0.3, Color("#3B2A20"), 0.0)
	hair.position = Vector3(0, 1.98, 0.05)
	hair.scale = Vector3(1, 0.6, 1)
	n.add_child(hair)
	var bubble := Models.label(speech, 56 if speech.length() > 10 else 64, speech_color, Color.WHITE)
	bubble.position = Vector3(0, 2.7, 0)
	bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	n.add_child(bubble)


static func _card(size: Vector3, face: Color, ink: Color, text: String, font: int) -> Node3D:
	var root := Node3D.new()
	root.position.y = 1.05
	var card := Models.box(size, face)
	card.material_override = Models.mat(face, 0.5, 0.15)
	root.add_child(card)
	var rim := Models.box(size + Vector3(0.08, 0.08, -0.03), ink)
	rim.material_override = Models.mat(ink, 0.4, 0.6)
	root.add_child(rim)
	for side in [1.0, -1.0]:
		var l := Models.label(text, font, ink, Color.WHITE)
		l.position = Vector3(0, 0, side * (size.z / 2.0 + 0.005))
		if side < 0:
			l.rotation_degrees.y = 180
		root.add_child(l)
	return root


static func _glow(c: Color, y: float) -> MeshInstance3D:
	var g := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 0.55
	sm.height = 1.1
	g.mesh = sm
	var m := StandardMaterial3D.new()
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.albedo_color = Color(c, 0.18)
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	g.material_override = m
	g.position.y = y
	g.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return g


static func _sphere(r: float, c: Color, emissive: float) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = r
	sm.height = r * 2.0
	mi.mesh = sm
	mi.material_override = Models.mat(c, 0.35, emissive)
	return mi


static func _cyl(r: float, h: float, c: Color, emissive: float) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = r
	cm.bottom_radius = r
	cm.height = h
	mi.mesh = cm
	mi.material_override = Models.mat(c, 0.35, emissive)
	return mi
