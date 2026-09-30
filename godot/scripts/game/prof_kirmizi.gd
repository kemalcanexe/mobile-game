class_name ProfKirmizi
extends Node3D
## Final boss: Kırmızı Kalemli Profesör (GAME_PROPOSAL §11). Yenilmez; yolun
## önünde süzülür, telgraflı saldırılarını plandaki "telegraph" nesneleriyle
## yapar: önce şerit kırmızı kesik çizgiyle işaretlenir, sonra ✗ düşer.

const RED := Color("#E0262B")
const RED_DARK := Color("#9E1418")

var run: RunScene
var cfg: Dictionary
var model: Node3D
var _brow_l: Node3D
var _brow_r: Node3D
var _mouth: Label3D
var _bubble: Label3D
var _t := 0.0
var _aim_x := 0.0
var _pending: Array = []
var _reacting := false


func setup(p_run: RunScene, p_cfg: Dictionary) -> void:
	run = p_run
	cfg = p_cfg


func _ready() -> void:
	model = Node3D.new()
	model.scale = Vector3.ONE * float(cfg.get("scale", 1.0))
	add_child(model)
	_build_pen()
	_build_costume(run.course_id)
	_bubble = Models.label("", 110, Color.WHITE, RED_DARK)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.position = Vector3(0, 5.6 * float(cfg.get("scale", 1.0)), 0)
	add_child(_bubble)
	position = run.tuki.position + Vector3(0, float(cfg["height"]), -float(cfg["distanceAhead"]))


func _build_pen() -> void:
	# dev kırmızı kalem: gövde, kapak, sivri uç (aşağıda), gözlük, kaşlar
	var body := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.9
	cm.bottom_radius = 0.9
	cm.height = 3.6
	body.mesh = cm
	body.material_override = Models.mat(RED, 0.4, 0.15)
	body.position.y = 1.8
	model.add_child(body)
	var cap := MeshInstance3D.new()
	var capm := CylinderMesh.new()
	capm.top_radius = 0.95
	capm.bottom_radius = 0.95
	capm.height = 1.2
	cap.mesh = capm
	cap.material_override = Models.mat(RED_DARK, 0.35)
	cap.position.y = 4.1
	model.add_child(cap)
	var tip := MeshInstance3D.new()
	var tm := CylinderMesh.new()
	tm.top_radius = 0.9
	tm.bottom_radius = 0.05
	tm.height = 1.1
	tip.mesh = tm
	tip.material_override = Models.mat(Color("#F4D9B0"), 0.6)
	tip.position.y = -0.55
	model.add_child(tip)
	var ink := MeshInstance3D.new()
	var im := SphereMesh.new()
	im.radius = 0.12
	im.height = 0.24
	ink.mesh = im
	ink.material_override = Models.mat(RED, 0.3, 0.8)
	ink.position.y = -1.1
	model.add_child(ink)
	# yüz kameraya (+z) bakar
	for sx in [-0.38, 0.38]:
		var eye := MeshInstance3D.new()
		var es := SphereMesh.new()
		es.radius = 0.24
		es.height = 0.48
		eye.mesh = es
		eye.material_override = Models.mat(Color.WHITE, 0.3)
		eye.position = Vector3(sx, 2.9, 0.78)
		model.add_child(eye)
		var pupil := MeshInstance3D.new()
		var ps := SphereMesh.new()
		ps.radius = 0.1
		ps.height = 0.2
		pupil.mesh = ps
		pupil.material_override = Models.mat(Color("#1E2A3A"))
		pupil.position = Vector3(sx, 2.88, 1.0)
		model.add_child(pupil)
		var lens := MeshInstance3D.new()
		var lm := TorusMesh.new()
		lm.inner_radius = 0.26
		lm.outer_radius = 0.33
		lens.mesh = lm
		lens.material_override = Models.mat(Color("#1E2A3A"), 0.3)
		lens.rotation_degrees.x = 90
		lens.position = Vector3(sx, 2.9, 0.95)
		model.add_child(lens)
		var brow := Models.box(Vector3(0.45, 0.1, 0.1), Color("#1E2A3A"), Vector3(sx, 3.35, 0.9))
		model.add_child(brow)
		if sx < 0:
			_brow_l = brow
		else:
			_brow_r = brow
	model.add_child(Models.box(Vector3(0.2, 0.06, 0.06), Color("#1E2A3A"), Vector3(0, 2.92, 0.98)))
	_mouth = Models.label("︶", 120, Color("#1E2A3A"), Color(0, 0, 0, 0))
	_mouth.position = Vector3(0, 2.35, 0.92)
	model.add_child(_mouth)


func _build_costume(course: String) -> void:
	match course:
		"phys101":
			# laboratuvar önlüğü
			var coat := MeshInstance3D.new()
			var cm := CylinderMesh.new()
			cm.top_radius = 0.95
			cm.bottom_radius = 1.25
			cm.height = 2.2
			coat.mesh = cm
			coat.material_override = Models.mat(Color("#F4F6FA"), 0.8)
			coat.position.y = 1.0
			model.add_child(coat)
			var pocket := Models.box(Vector3(0.4, 0.3, 0.05), Color("#DDE3EE"), Vector3(0.45, 1.5, 1.08))
			model.add_child(pocket)
		"cs101":
			# kulaklık
			var band := MeshInstance3D.new()
			var tm := TorusMesh.new()
			tm.inner_radius = 0.95
			tm.outer_radius = 1.08
			band.mesh = tm
			band.material_override = Models.mat(Color("#20242E"), 0.4)
			band.rotation_degrees.z = 90
			band.position.y = 4.1
			model.add_child(band)
			for sx in [-1.0, 1.0]:
				var cup := Models.box(Vector3(0.3, 0.6, 0.6), Color("#2BC48A"), Vector3(sx * 1.05, 3.2, 0))
				cup.material_override = Models.mat(Color("#2BC48A"), 0.3, 0.8)
				model.add_child(cup)
		_:
			# mezuniyet kepi
			var board := Models.box(Vector3(2.4, 0.12, 2.4), Color("#1E2A3A"), Vector3(0, 4.85, 0))
			board.rotation_degrees.y = 45
			model.add_child(board)
			var tassel := Models.box(Vector3(0.06, 0.8, 0.06), UiKit.YELLOW, Vector3(1.1, 4.45, 0.6))
			model.add_child(tassel)


func tick(delta: float) -> void:
	_t += delta
	var tuki := run.tuki
	var target := Vector3(_aim_x, float(cfg["height"]) + sin(_t * 1.6) * 0.35, tuki.position.z - float(cfg["distanceAhead"]))
	position = position.lerp(target, 1.0 - exp(-3.0 * delta))
	position.z = target.z
	model.rotation.z = sin(_t * 1.1) * 0.08 + (position.x - _aim_x) * -0.05
	_aim_x = lerpf(_aim_x, 0.0, delta * 0.5)
	_update_attacks()


## Plandan gelen saldırı nesnesi: görünmez başlar, telgraftan sonra düşer.
func on_spawned(obj: LaneObject) -> void:
	if not obj.item.get("telegraph", false):
		return
	obj.visual.visible = false
	_pending.append({"obj": obj, "state": 0})


func _update_attacks() -> void:
	var speed := maxf(run.speed_mps(), 1.0)
	for a in _pending.duplicate():
		# nesne (ofis saati vb. ile) silinmiş olabilir: tipli atamadan önce bak
		if not is_instance_valid(a["obj"]) or a["obj"].resolved:
			_pending.erase(a)
			continue
		var obj: LaneObject = a["obj"]
		var t := (run.tuki.position.z - obj.position.z) / speed
		if a["state"] == 0 and t <= float(cfg["telegraphSeconds"]):
			a["state"] = 1
			_telegraph(obj)
		elif a["state"] == 1 and t <= float(cfg["landSeconds"]):
			a["state"] = 2
			_throw(obj)
			_pending.erase(a)


func _telegraph(obj: LaneObject) -> void:
	_aim_x = obj.position.x
	Sound.play("boss_warn")
	# şeritte Tüki'ye doğru kırmızı kesik çizgi
	var dashes := Node3D.new()
	dashes.name = "Telegraph"
	var m := Models.mat(RED, 0.4, 2.0)
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	for k in 8:
		var dash := Models.box(Vector3(0.5, 0.03, 1.1), RED, Vector3(0, 0.05, 1.2 + k * 2.0))
		dash.material_override = m
		dash.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		dashes.add_child(dash)
	obj.add_child(dashes)
	var tw := obj.create_tween().set_loops(6)
	tw.tween_property(m, "albedo_color:a", 0.25, 0.12)
	tw.tween_property(m, "albedo_color:a", 1.0, 0.12)


func _throw(obj: LaneObject) -> void:
	Sound.play("boss_throw")
	var v := obj.visual
	v.visible = true
	var land := v.global_position
	v.global_position = global_position + Vector3(0, -1.0, 0)
	v.scale = Vector3.ONE * 0.4
	var tw := v.create_tween().set_parallel(true)
	tw.tween_property(v, "global_position", land, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_property(v, "scale", Vector3.ONE, 0.3)
	tw.chain().tween_callback(func() -> void:
		if not is_instance_valid(obj):
			return
		Sound.play("boss_impact")
		Sound.vibrate("boss")
		run.shake()
		Fx.burst(run, land + Vector3(0, 0.3, 0), RED, 18, 5.0, 0.14)
		var tg := obj.get_node_or_null("Telegraph")
		if tg:
			tg.queue_free())


## %33 ve %66: "Ek soru!" ve hız bir kademe artar (SpeedCurve.steps).
func phase_shout() -> void:
	Sound.play("boss_shout")
	run.banner.emit("EK SORU!", RED)
	_say("Ek soru!", 1.6)
	var tw := model.create_tween()
	var base := Vector3.ONE * float(cfg.get("scale", 1.0))
	tw.tween_property(model, "scale", base * 1.25, 0.12)
	tw.tween_property(model, "scale", base, 0.25).set_trans(Tween.TRANS_BACK)


func _say(text: String, seconds: float) -> void:
	_bubble.text = text
	get_tree().create_timer(seconds, false).timeout.connect(func() -> void:
		if _bubble.text == text:
			_bubble.text = "")


## Sayfa sonu: nota göre baş sallama, kaş kaldırma ya da yüz avuçlama.
func react(score: float) -> String:
	if _reacting:
		return ""
	_reacting = true
	var r: Dictionary = cfg["reactions"]
	var kind := "facepalm"
	if score >= float(r["nod"]):
		kind = "nod"
	elif score >= float(r["eyebrow"]):
		kind = "eyebrow"
	var tw := model.create_tween()
	match kind:
		"nod":
			_mouth.text = "‿"
			_say("Aferin.", 2.5)
			for i in 3:
				tw.tween_property(model, "rotation:x", 0.35, 0.18)
				tw.tween_property(model, "rotation:x", -0.05, 0.18)
		"eyebrow":
			_mouth.text = "—"
			_say("Hmm…", 2.5)
			tw.tween_property(_brow_l, "position:y", 3.6, 0.2)
			tw.parallel().tween_property(_brow_l, "rotation:z", 0.3, 0.2)
		_:
			_mouth.text = "︵"
			_say("Görüşelim.", 2.5)
			tw.tween_property(model, "rotation:x", 0.6, 0.35)
			tw.parallel().tween_property(_brow_l, "rotation:z", -0.4, 0.2)
			tw.parallel().tween_property(_brow_r, "rotation:z", 0.4, 0.2)
	return kind
