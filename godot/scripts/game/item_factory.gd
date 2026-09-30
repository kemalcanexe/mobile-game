class_name ItemFactory
## Nesnelerin 3D görselleri. (+) nesneler yuvarlak hatlı ve parlak mavi/sarı,
## (−) nesneler köşeli ve kırmızı/mor: uzaktan bile ayırt edilir.

const BLUE := Color("#2E6BFF")
const YELLOW := Color("#FFD23F")
const RED := Color("#FF4D4D")
const PURPLE := Color("#8B3DFF")
const PAPER := Color("#FFFDF5")


## Görsel düğüm + çarpışma kutusu boyutu ve konumu.
static func build(item: Dictionary, lane_w: float) -> Dictionary:
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
			var torso := MeshInstance3D.new()
			var tc := CapsuleMesh.new()
			tc.radius = 0.32
			tc.height = 1.2
			torso.mesh = tc
			torso.material_override = Models.mat(PURPLE, 0.6)
			torso.position.y = 0.95
			n.add_child(torso)
			var head := _sphere(0.28, Color("#F2C7A5"), 0.0)
			head.position.y = 1.85
			n.add_child(head)
			var hair := _sphere(0.3, Color("#3B2A20"), 0.0)
			hair.position = Vector3(0, 1.98, 0.05)
			hair.scale = Vector3(1, 0.6, 1)
			n.add_child(hair)
			var bubble := Models.label("Kantin?", 64, PURPLE, Color.WHITE)
			bubble.position = Vector3(0, 2.7, 0)
			bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			n.add_child(bubble)
		"spill":
			# yer engeli: bariyer (zıplanır)
			var bar := Models.make("roads", "construction-barrier", 1.25)
			bar.rotation_degrees.y = 90
			n.add_child(bar)
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
