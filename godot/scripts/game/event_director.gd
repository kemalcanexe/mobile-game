class_name EventDirector
extends Node3D
## Plandaki özel olayları (specials) koşu sırasında işletir: Yoklama, Pop Quiz,
## Grup Ödevi, Ofis Saati, Soru Kapıları, tema bölgeleri, All-nighter ve boss.
## Olay kuralları data/config/events.json'dan gelir.

var run: RunScene
var cfg: Dictionary
var specials: Array = []
var boss: ProfKirmizi

var _next := 0
var _active: Array = []
## Grup ödevi: tembel arkadaşın kalan süresi ve modeli.
var group_left := 0.0
var _group_friend: Node3D
var office_left := 0.0
var night := false
var _gates_done := {}
var _zone_nodes: Array = []


func setup(p_run: RunScene, p_specials: Array) -> void:
	run = p_run
	cfg = run.content.events_cfg
	specials = p_specials
	# boss, ilk saldırı nesnesi doğmadan sahnede olmalı
	for sp in specials:
		if sp["type"] == "boss" and boss == null:
			boss = ProfKirmizi.new()
			boss.setup(run, cfg["boss"])
			run.add_child(boss)


## Toplanan puanın oyuncuya kalan payı (grup ödevinde yarısı arkadaşa).
func share_factor() -> float:
	return 1.0 - float(cfg["groupProject"]["share"]) if group_left > 0.0 else 1.0


func tick(delta: float) -> void:
	var ahead := float(run.cfg["world"]["spawnAhead"]) / run.upp
	# görselleri erkenden kur, olayı mesafesi gelince başlat
	while _next < specials.size() and float(specials[_next]["d"]) - run.distance <= ahead:
		var sp: Dictionary = specials[_next].duplicate()
		_next += 1
		sp["started"] = false
		_prepare(sp)
		_active.append(sp)
	for sp in _active.duplicate():
		if not sp["started"] and run.distance >= float(sp["d"]):
			sp["started"] = true
			_start(sp)
		if sp["started"] and _update(sp, delta):
			_active.erase(sp)
	_update_group(delta)
	if office_left > 0.0:
		office_left -= delta
	if boss:
		boss.tick(delta)


func active_types() -> Array:
	return _active.filter(func(sp) -> bool: return sp["started"]).map(func(sp) -> String: return sp["type"])


# ------------------------------------------------------------ hazırlık

func _prepare(sp: Dictionary) -> void:
	match sp["type"]:
		"rollCall":
			sp["held"] = 0.0
			sp["node"] = _rollcall_visual(sp)
		"questionGate":
			sp["node"] = _question_board(sp)
		"zone":
			sp["node"] = _zone_visual(sp)


func _start(sp: Dictionary) -> void:
	match sp["type"]:
		"rollCall":
			Sound.play("rollcall")
			run.banner.emit("YOKLAMA!", UiKit.GREEN)
			if run.effects.skip_class:
				# "Derse girmeyelim" sonrası: yoklama otomatik kaçar
				run.effects.skip_class = false
				_rollcall_result(sp, false)
		"popQuiz":
			Sound.play("boss_warn")
			run.banner.emit("POP QUIZ!", UiKit.YELLOW)
		"groupProject":
			group_left = float(cfg["groupProject"]["seconds"])
			_attach_friend()
			Sound.play("group_on")
			run.banner.emit("GRUP ÖDEVİ", UiKit.PURPLE)
			run.popup.emit("Puanının yarısı arkadaşa!", UiKit.PURPLE)
		"questionGate":
			run.question.emit(sp["q"])
			Sound.play("page")
		"zone":
			run.tuki.set_zone(sp["zone"])
			Sound.play("zone")
			run.banner.emit("YERÇEKİMİ TERS!" if sp["zone"] == "gravity" else "SÜRTÜNMESİZ BUZ!",
				UiKit.PURPLE if sp["zone"] == "gravity" else Color("#7FD8FF"))
		"allNighter":
			_start_night()
		"bossPhase":
			if boss:
				boss.phase_shout()


## true dönerse olay biter.
func _update(sp: Dictionary, delta: float) -> bool:
	match sp["type"]:
		"rollCall":
			if sp.get("done", false):
				return true
			var end := float(sp["d"]) + float(sp["length"])
			if run.tuki.target_lane == int(sp["lane"]) and run.tuki.lane == int(sp["lane"]):
				sp["held"] = float(sp["held"]) + delta
			if float(sp["held"]) >= float(cfg["rollCall"]["holdSeconds"]):
				_rollcall_result(sp, true)
				return true
			if run.distance > end:
				_rollcall_result(sp, false)
				return true
			return false
		"popQuiz":
			return run.distance > float(sp["d"]) + float(sp["length"])
		"questionGate":
			if _gates_done.has(int(sp["id"])) or run.distance > float(sp["gateD"]) + 200.0:
				run.question.emit("")
				return true
			return false
		"zone":
			if run.distance > float(sp["d"]) + float(sp["length"]):
				run.tuki.set_zone("")
				return true
			return false
	return true


# ------------------------------------------------------------ yoklama

func _rollcall_visual(sp: Dictionary) -> Node3D:
	var root := Node3D.new()
	var lane_x := (int(sp["lane"]) - 1) * run.lane_w
	var z0 := -float(sp["d"]) * run.upp
	var length := float(sp["length"]) * run.upp
	var strip := Models.box(Vector3(run.lane_w * 0.9, 0.02, length), UiKit.GREEN, Vector3(lane_x, 0.03, z0 - length / 2.0))
	var m := Models.mat(UiKit.GREEN, 0.5, 0.9)
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.albedo_color = Color(UiKit.GREEN, 0.45)
	strip.material_override = m
	strip.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(strip)
	# kürsüde profesör silüeti + "Burada!" tabelası
	var prof := Node3D.new()
	# kürsü yolun kenarında, yeşil şeritle aynı tarafta
	var side := -1.0 if int(sp["lane"]) == 0 else 1.0
	prof.position = Vector3(side * (run.lane_w * 1.5 + 1.6), 0, z0 - 2.0)
	var desk := Models.box(Vector3(1.4, 1.1, 0.7), Color("#6B4A2B"), Vector3(0, 0.55, 0))
	prof.add_child(desk)
	var body := Models.box(Vector3(0.7, 1.3, 0.4), Color("#2A2F3D"), Vector3(0, 1.75, -0.2))
	prof.add_child(body)
	var head := MeshInstance3D.new()
	var hs := SphereMesh.new()
	hs.radius = 0.3
	hs.height = 0.6
	head.mesh = hs
	head.material_override = Models.mat(Color("#2A2F3D"))
	head.position = Vector3(0, 2.7, -0.2)
	prof.add_child(head)
	var sign := Models.label("Burada!", 90, Color.WHITE, UiKit.GREEN_DARK)
	sign.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sign.position = Vector3(0, 3.6, 0)
	prof.add_child(sign)
	root.add_child(prof)
	sp["sign"] = sign
	run.add_child(root)
	return root


func _rollcall_result(sp: Dictionary, ok: bool) -> void:
	sp["done"] = true
	var c: Dictionary = cfg["rollCall"]
	if ok:
		run.event_points(float(c["points"]), "Burada! +%d" % int(c["points"]))
		Sound.play("rollcall_ok")
		Fx.burst(run, run.tuki.global_position + Vector3(0, 1.4, 0), UiKit.GREEN, 24, 6.0, 0.12)
	else:
		run.event_points(-float(c["penalty"]), "Devamsızlık −%d" % int(c["penalty"]), UiKit.RED)
		Sound.play("gate_wrong")
		run.banner.emit("DEVAMSIZLIK", UiKit.RED)
	if sp.has("node") and is_instance_valid(sp["node"]):
		var n: Node3D = sp["node"]
		n.create_tween().tween_interval(1.0)
		get_tree().create_timer(1.5, false).timeout.connect(n.queue_free)


# --------------------------------------------------------- grup ödevi

func _attach_friend() -> void:
	if _group_friend:
		return
	_group_friend = Node3D.new()
	var built := ItemFactory.build({"art": "friend"}, run.lane_w)
	var fn: Node3D = built["node"]
	# konuşma balonunu değiştir
	for c in fn.get_children():
		if c is Label3D:
			c.text = "Ben de yazdım!"
	_group_friend.add_child(fn)
	_group_friend.scale = Vector3.ONE * 0.8
	run.add_child(_group_friend)


func _update_group(delta: float) -> void:
	if group_left <= 0.0:
		return
	group_left -= delta
	if _group_friend:
		var target := run.tuki.position + Vector3(0.9, 0, 1.6)
		_group_friend.position = _group_friend.position.lerp(target, 1.0 - exp(-10.0 * delta)) \
			if _group_friend.position != Vector3.ZERO else target
		_group_friend.position.y = absf(sin(Time.get_ticks_msec() * 0.012)) * 0.25
	if group_left <= 0.0:
		_detach_friend("Grup ödevi bitti")


func _detach_friend(text: String) -> void:
	group_left = 0.0
	Sound.play("group_off")
	run.popup.emit(text, UiKit.PURPLE)
	if _group_friend:
		var f := _group_friend
		_group_friend = null
		var tw := f.create_tween()
		tw.tween_property(f, "position", f.position + Vector3(6, 0, 4), 0.6)
		tw.tween_callback(f.queue_free)


# ----------------------------------------------------------- kapılar

func on_gate(obj: LaneObject) -> void:
	if obj.resolved:
		return
	obj.resolved = true
	match obj.item["art"]:
		"divisionGate":
			obj.pop()
			if group_left > 0.0:
				_detach_friend("İş bölümü! Arkadaş gitti")
				run.banner.emit("İŞ BÖLÜMÜ", UiKit.GREEN)
		"officeDoor":
			obj.pop()
			_start_office()
		"answerGate":
			var id := int(obj.extra.get("gate", -1))
			if _gates_done.has(id):
				return
			_gates_done[id] = true
			var c: Dictionary = cfg["questionGate"]
			if obj.extra.get("correct", false):
				run.event_points(float(c["correct"]), "Doğru! +%d" % int(c["correct"]))
				Sound.play("gate_ok")
				Fx.burst(run, obj.global_position + Vector3(0, 2.0, 0), UiKit.GREEN, 30, 7.0, 0.12)
			else:
				run.event_points(-float(c["wrong"]), "✗ −%d" % int(c["wrong"]), UiKit.RED)
				Sound.play("gate_wrong")
				Sound.vibrate("hit")
				run.banner.emit("✗", UiKit.RED)
			run.question.emit("")
			# aynı soru kapısının diğer şıkları kaybolur
			for o in run.objects():
				if is_instance_valid(o) and o.item.get("art") == "answerGate" and int(o.extra.get("gate", -2)) == id:
					o.resolved = true
					o.pop()


func _start_office() -> void:
	var c: Dictionary = cfg["officeHours"]
	office_left = float(c["seconds"])
	Sound.play("office")
	run.banner.emit("OFİS SAATİ", UiKit.GOLD)
	# önündeki engeller kaybolur, Tüki'nin şeridine bonus notlar dizilir
	var row := float(run.game_cfg["scroll"]["rowSpacing"])
	var clear_to := run.distance + int(c["clearRows"]) * row
	for o in run.objects():
		if is_instance_valid(o) and not o.resolved and o.is_hazard():
			var d := -o.position.z / run.upp
			if d > run.distance and d < clear_to:
				o.resolved = true
				Fx.burst(run, o.global_position + Vector3(0, 1.0, 0), Color(1, 0.95, 0.7), 10, 3.0, 0.1)
				o.queue_free()
	var speed := run.speed_mps() / run.upp
	var rows := ceili(float(c["seconds"]) * speed / row)
	for r in rows:
		run.spawn_item(c["item"], run.tuki.target_lane, run.distance + (r + 2) * row)


# ------------------------------------------------------- soru kapısı

func _question_board(sp: Dictionary) -> Node3D:
	var root := Node3D.new()
	var z := -float(sp["gateD"]) * run.upp - 0.6
	var w := run.lane_w * 3.4
	for sx in [-1.0, 1.0]:
		root.add_child(Models.box(Vector3(0.35, 7.2, 0.35), Color("#DDE3EE"), Vector3(sx * w / 2.0, 3.6, z)))
	var board := Models.box(Vector3(w, 1.6, 0.25), Color("#1E2A3A"), Vector3(0, 6.3, z))
	board.material_override = Models.mat(Color("#1E2A3A"), 0.6)
	root.add_child(board)
	var q := Models.label(sp["q"], 110, Color.WHITE, Color(0, 0, 0, 0))
	q.position = Vector3(0, 6.3, z + 0.14)
	root.add_child(q)
	run.add_child(root)
	return root


# ------------------------------------------------------------- bölgeler

func _zone_visual(sp: Dictionary) -> Node3D:
	var root := Node3D.new()
	var z0 := -float(sp["d"]) * run.upp
	var length := float(sp["length"]) * run.upp
	var w := run.lane_w * 3.2
	var gravity: bool = sp["zone"] == "gravity"
	var col := Color("#8B3DFF") if gravity else Color("#9EE7FF")
	var floor_m := StandardMaterial3D.new()
	floor_m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	floor_m.albedo_color = Color(col, 0.22 if gravity else 0.55)
	floor_m.roughness = 0.05
	floor_m.metallic = 0.4 if not gravity else 0.0
	floor_m.emission_enabled = gravity
	floor_m.emission = col
	floor_m.emission_energy_multiplier = 0.4
	var floor := Models.box(Vector3(w, 0.02, length), col, Vector3(0, 0.025, z0 - length / 2.0))
	floor.material_override = floor_m
	floor.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(floor)
	var step := 7.0
	var k := 0.0
	while k < length:
		if gravity:
			# mor kemerler ve havada süzülen küpler
			var arch_m := Models.mat(col, 0.4, 1.3)
			root.add_child(_arch(w, z0 - k, arch_m))
			for i in 2:
				var cube := Models.box(Vector3.ONE * 0.4, col, Vector3(randf_range(-w / 2, w / 2), randf_range(2.5, 5.0), z0 - k - randf() * step))
				cube.material_override = Models.mat(col.lightened(0.3), 0.4, 1.0)
				cube.rotation = Vector3(randf(), randf(), randf()) * TAU
				root.add_child(cube)
		else:
			# buz kristalleri kenarlarda
			for sx in [-1.0, 1.0]:
				var crystal := MeshInstance3D.new()
				var pm := PrismMesh.new()
				pm.size = Vector3(0.6, randf_range(1.0, 2.2), 0.6)
				crystal.mesh = pm
				crystal.material_override = Models.mat(Color("#CFF3FF"), 0.05, 0.6)
				crystal.position = Vector3(sx * (w / 2.0 + 0.6), pm.size.y / 2.0, z0 - k - randf() * step)
				root.add_child(crystal)
		k += step
	var sign := Models.label("YERÇEKİMİ TERS: ↑↓ yer değiştirir" if gravity else "BUZ: şeritler kaygan", 70, Color.WHITE, col.darkened(0.5))
	sign.position = Vector3(0, 4.6, z0 + 0.5)
	root.add_child(sign)
	run.add_child(root)
	return root


func _arch(w: float, z: float, m: Material) -> Node3D:
	var a := Node3D.new()
	for sx in [-1.0, 1.0]:
		# kiriş kameranın üstünde kalsın (yakından geçerken görüşü kesmesin)
		var post := Models.box(Vector3(0.25, 7.2, 0.25), Color.WHITE, Vector3(sx * w / 2.0, 3.6, z))
		post.material_override = m
		a.add_child(post)
	var top := Models.box(Vector3(w + 0.25, 0.25, 0.25), Color.WHITE, Vector3(0, 7.2, z))
	top.material_override = m
	a.add_child(top)
	return a


# ---------------------------------------------------------- all-nighter

func _start_night() -> void:
	if night:
		return
	night = true
	var c: Dictionary = cfg["allNighter"]
	var t := float(c["fade"])
	run.banner.emit("ALL-NIGHTER", Color("#9DB4FF"))
	Sound.set_night(true)
	var tw := create_tween().set_parallel(true)
	tw.tween_property(run.sun, "light_energy", float(c["sunEnergy"]), t)
	tw.tween_property(run.env, "ambient_light_energy", float(c["ambient"]), t)
	tw.tween_property(run.env, "fog_light_color", Color(c["fog"]), t)
	tw.tween_property(run.sky_mat, "sky_top_color", Color(c["sky"]), t)
	tw.tween_property(run.sky_mat, "sky_horizon_color", Color(c["fog"]), t)
	tw.tween_property(run.sky_mat, "ground_horizon_color", Color(c["fog"]), t)
	tw.tween_property(run.tuki.lantern, "light_energy", float(c["lanternEnergy"]), t)
	run.tuki.lantern.omni_range = float(c["lanternRange"])
	# zaten sahnede olan kahveler de ışık saçsın
	for o in run.objects():
		if is_instance_valid(o):
			on_spawned(o)


## Yeni doğan nesne: gece ise kahveler sıcak ışık yayar.
func on_spawned(obj: LaneObject) -> void:
	if night and obj.item.get("art") == "coffee" and obj.get_node_or_null("CoffeeLight") == null:
		var l := OmniLight3D.new()
		l.name = "CoffeeLight"
		l.light_color = Color("#FFB35C")
		l.light_energy = float(cfg["allNighter"]["coffeeLight"])
		l.omni_range = 8.0
		l.position.y = 1.4
		obj.add_child(l)
	if boss:
		boss.on_spawned(obj)
