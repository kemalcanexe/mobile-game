class_name RunScene
extends Node3D
## Tek bir sınav (level): kampüste 3D koşu.
##
## Level verisi 2D piksel biriminde; [code]upp[/code] (units per pixel) ile metreye
## çevrilir. Tüki -z yönünde koşar; kamera arkasından takip eder.

signal finished(outcome: Dictionary)
signal hud_update
signal popup(text: String, color: Color)
signal effect_event(kind: String)

enum State { READY, RUNNING, FINISHED }

var course_id := "calc101"
var assessment := "quiz1"
## Testler için: hazır spawn planı ({total, events}) ve seviye tanımı.
var plan_override := {}
var level_override := {}
## Testlerde false: gerçek kayıt dosyasına yazılmaz, HUD kurulmaz.
var record_progress := true
var with_hud := true

var content: Content
var cfg: Dictionary
var game_cfg: Dictionary
var level: Dictionary
var theme: Dictionary
var plan: Dictionary
var curve: SpeedCurve
var upp := 0.05
var lane_w := 2.6

var state := State.READY
var tuki: Tuki
var camera: Camera3D
var campus: Campus
var trail: InkTrail
var ink: InkState
var score := LevelScore.new()
var effects := EffectState.new()
var swipe := SwipeDetector.new()
var rng := RandomNumberGenerator.new()
var outcome := {}

## Kat edilen mesafe (piksel birimi, level verisiyle aynı).
var distance := 0.0
var _next_event := 0
var _objects: Array[LaneObject] = []
var _buffer := ""
var _buffer_age := 0.0
var _shake := 0.0
var _final_stretch_shown := false
var _cam_x := 0.0
var _end_timer := -1.0
var _last_drag_velocity := Vector2.ZERO
## 0 = tanıtım kamerası (Tüki'nin önünde), 1 = koşu kamerası (arkasında).
var _intro_blend := 0.0


func _ready() -> void:
	content = Game.content
	cfg = content.world_cfg
	game_cfg = content.game_cfg
	if Game.params.has("course"):
		course_id = Game.params["course"]
		assessment = Game.params["assessment"]
	var course := content.course(course_id)
	level = level_override if not level_override.is_empty() else course["levels"][assessment]
	if Game.params.has("duration"):
		# geliştirme/ekran görüntüsü için kısa level
		level = level.duplicate(true)
		level["durationSeconds"] = float(Game.params["duration"])
	theme = cfg["themes"].get(course_id, cfg["themes"]["calc101"])
	upp = float(cfg["unitsPerPixel"])
	lane_w = float(cfg["laneWidth"])
	curve = SpeedCurve.from_dict(level["speed"])
	plan = plan_override if not plan_override.is_empty() else LevelGenerator.generate(level, course["patterns"], game_cfg)
	rng.seed = int(level["seed"])
	ink = InkState.new(float(game_cfg["ink"]["max"]), float(game_cfg["ink"]["lowThreshold"]))
	swipe.min_distance = float(cfg["input"]["minSwipeDistance"])
	swipe.min_fling = float(cfg["input"]["minFlingVelocity"])
	_build_environment()
	campus = Campus.new()
	campus.setup(theme, cfg)
	add_child(campus)
	_build_ground()
	tuki = Tuki.new()
	tuki.configure(cfg)
	add_child(tuki)
	tuki.position = Vector3(0, 0.02, 0)
	tuki.hitbox.area_entered.connect(_on_area)
	trail = InkTrail.new()
	trail.color = Color(theme["accent"]) if theme.get("lamps", false) else Color("#1F3A93")
	add_child(trail)
	camera = Camera3D.new()
	camera.fov = float(cfg["camera"]["fov"])
	camera.far = 260.0
	add_child(camera)
	_place_camera(1.0)
	_build_finish_gate()
	campus.update_for(0.0)
	if with_hud:
		add_child(RunHud.new(self))


func _build_environment() -> void:
	var we := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var sm := ProceduralSkyMaterial.new()
	sm.sky_top_color = Color(theme["skyTop"])
	sm.sky_horizon_color = Color(theme["skyHorizon"])
	sm.ground_horizon_color = Color(theme["skyHorizon"])
	sm.ground_bottom_color = Color(theme["ground"]).darkened(0.3)
	sm.sun_angle_max = 20.0
	sky.sky_material = sm
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(theme["skyHorizon"]).lerp(Color("#FFF6EA"), 0.75)
	env.ambient_light_energy = float(theme["ambient"])
	env.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	env.fog_enabled = true
	env.fog_light_color = Color(theme["fog"])
	env.fog_density = 0.0022
	env.fog_sky_affect = 0.0
	env.glow_enabled = false
	we.environment = env
	add_child(we)
	var sun := DirectionalLight3D.new()
	sun.light_color = Color(theme["sunColor"])
	sun.light_energy = float(theme["sunEnergy"])
	sun.rotation_degrees = Vector3(float(theme["sunPitch"]), 35, 0)
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 70.0
	sun.shadow_bias = 0.05
	add_child(sun)


func _build_ground() -> void:
	var ground := StaticBody3D.new()
	ground.collision_layer = 1
	var cs := CollisionShape3D.new()
	cs.shape = WorldBoundaryShape3D.new()
	ground.add_child(cs)
	add_child(ground)


func _build_finish_gate() -> void:
	var z := -float(plan["total"]) * upp
	var gate := Node3D.new()
	gate.name = "FinishGate"
	gate.position = Vector3(0, 0, z)
	var accent := Color(theme["accent"])
	for s in [-1.0, 1.0]:
		var pillar := Models.box(Vector3(0.9, 8.0, 0.9), UiKit.YELLOW, Vector3(s * (lane_w * 1.5 + 1.2), 4.0, 0))
		pillar.material_override = Models.mat(UiKit.YELLOW, 0.5, 0.2)
		gate.add_child(pillar)
	var banner := Models.box(Vector3(lane_w * 3 + 3.4, 1.8, 0.4), accent, Vector3(0, 7.2, 0))
	banner.material_override = Models.mat(accent, 0.5, 0.25)
	gate.add_child(banner)
	var txt := Models.label("SAYFA SONU!", 150, Color.WHITE, accent.darkened(0.5))
	txt.position = Vector3(0, 7.2, 0.22)
	gate.add_child(txt)
	# yerde dama deseni bitiş çizgisi
	for k in 12:
		for r in 2:
			if (k + r) % 2 == 0:
				var sq := Models.box(Vector3(lane_w * 3.4 / 12.0, 0.03, 0.6), UiKit.INK, Vector3(-lane_w * 1.7 + (k + 0.5) * lane_w * 3.4 / 12.0, 0.015, (r - 0.5) * 0.6))
				gate.add_child(sq)
	add_child(gate)


# --------------------------------------------------------------- durum

func start() -> void:
	if state != State.READY:
		return
	state = State.RUNNING
	create_tween().tween_property(self, "_intro_blend", 1.0, 0.8).set_trans(Tween.TRANS_SINE)


func progress() -> float:
	return clampf(distance / float(plan["total"]), 0.0, 1.0)


func speed_mps() -> float:
	return float(game_cfg["scroll"]["baseSpeed"]) * upp * curve.multiplier_at(progress()) * effects.time_scale()


func _physics_process(delta: float) -> void:
	if state == State.RUNNING:
		effects.update(delta)
		tuki.forward_speed = speed_mps()
		_update_buffer(delta)
	elif state == State.FINISHED:
		tuki.forward_speed = maxf(0.0, tuki.forward_speed - 30.0 * delta)
	else:
		tuki.forward_speed = 0.0


func _process(delta: float) -> void:
	distance = maxf(0.0, -tuki.position.z) / upp
	campus.update_for(tuki.position.z)
	if state == State.RUNNING:
		_spawn()
		trail.add_point(tuki.global_position, tuki.is_airborne())
		if not _final_stretch_shown and progress() >= float(game_cfg["scroll"]["finalStretchProgress"]):
			_final_stretch_shown = true
			effect_event.emit("finalStretch")
		if ink.is_empty() or distance >= float(plan["total"]):
			_finish()
		hud_update.emit()
	elif state == State.FINISHED and _end_timer > 0.0:
		_end_timer -= delta
		if _end_timer <= 0.0:
			finished.emit(outcome)
	trail.redraw(ink.is_low())
	_despawn()
	_place_camera(delta)


func _place_camera(delta: float) -> void:
	var c: Dictionary = cfg["camera"]
	var k := 1.0 - exp(-float(c["followSharpness"]) * delta)
	_cam_x = lerpf(_cam_x, tuki.position.x * 0.75, k)
	var base := Vector3(_cam_x, float(c["height"]) + tuki.position.y * 0.35, tuki.position.z + float(c["distance"]))
	var shake := Vector3.ZERO
	if _shake > 0.0:
		_shake -= delta
		var a := float(c["shakeAmount"]) * (_shake / float(c["shakeTime"]))
		shake = Vector3(randf_range(-a, a), randf_range(-a, a), 0)
	var look := Vector3(_cam_x * 0.8, 1.4 + tuki.position.y * 0.25, tuki.position.z - float(c["lookAhead"]))
	if _intro_blend < 1.0:
		# tanıtım: önden, hafif yandan, Tüki ekranın üst yarısında
		var intro_pos := tuki.position + Vector3(1.5, 1.7, -6.2)
		var intro_look := tuki.position + Vector3(0.3, -1.1, 0)
		var b := _intro_blend
		base = intro_pos.lerp(base, b)
		look = intro_look.lerp(look, b)
	camera.position = base + shake
	camera.look_at(look)
	var boost := clampf((curve.multiplier_at(progress()) - 1.0) / 0.75, 0.0, 1.0) if state == State.RUNNING else 0.0
	camera.fov = lerpf(camera.fov, float(c["fov"]) + float(c["fovSpeedBoost"]) * boost, k)


# --------------------------------------------------------------- spawn

func _spawn() -> void:
	var ahead := float(cfg["world"]["spawnAhead"]) / upp
	var events: Array = plan["events"]
	while _next_event < events.size() and float(events[_next_event]["d"]) - distance <= ahead:
		var e: Dictionary = events[_next_event]
		_next_event += 1
		var code: String = e["code"]
		var item: Dictionary = content.items[code]
		var obj := LaneObject.new()
		obj.setup(code, item, int(e["lane"]), lane_w)
		add_child(obj)
		obj.position = Vector3((int(e["lane"]) - 1) * lane_w, 0, -float(e["d"]) * upp)
		if item["kind"] == "collectible":
			score.register_spawn(float(item["points"]))
		_objects.append(obj)


func _despawn() -> void:
	var behind := tuki.position.z + float(cfg["world"]["despawnBehind"])
	for i in range(_objects.size() - 1, -1, -1):
		var o := _objects[i]
		if not is_instance_valid(o) or o.is_queued_for_deletion():
			_objects.remove_at(i)
		elif o.position.z > behind:
			o.queue_free()
			_objects.remove_at(i)


# ---------------------------------------------------------------- girdi

func _unhandled_input(event: InputEvent) -> void:
	if state != State.RUNNING:
		return
	if event is InputEventScreenTouch:
		if event.pressed:
			swipe.start()
			_last_drag_velocity = Vector2.ZERO
		else:
			_swipe(swipe.end(_last_drag_velocity))
	elif event is InputEventScreenDrag:
		_last_drag_velocity = event.velocity
		_swipe(swipe.update(event.relative))
	elif event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_LEFT, KEY_A:
				_swipe(SwipeDetector.LEFT)
			KEY_RIGHT, KEY_D:
				_swipe(SwipeDetector.RIGHT)
			KEY_UP, KEY_W, KEY_SPACE:
				_swipe(SwipeDetector.UP)
			KEY_DOWN, KEY_S:
				_swipe(SwipeDetector.DOWN)


func _swipe(dir: String) -> void:
	if dir != "":
		handle_swipe(dir)


## Swipe'ı (debuff'ları hesaba katarak) Tüki'ye iletir.
func handle_swipe(dir: String) -> void:
	if state != State.RUNNING:
		return
	if effects.reversed():
		if dir == SwipeDetector.LEFT:
			dir = SwipeDetector.RIGHT
		elif dir == SwipeDetector.RIGHT:
			dir = SwipeDetector.LEFT
	# yeni komut bekleyen eskisini geçersiz kılar
	if _execute(dir):
		_buffer = ""
	else:
		_buffer = dir
		_buffer_age = 0.0


func _execute(dir: String) -> bool:
	match dir:
		SwipeDetector.LEFT:
			return tuki.change_lane(-1)
		SwipeDetector.RIGHT:
			return tuki.change_lane(1)
		SwipeDetector.UP:
			return tuki.try_jump()
		SwipeDetector.DOWN:
			return tuki.slide_or_fast_fall()
	return true


func _update_buffer(delta: float) -> void:
	if _buffer == "":
		return
	if _execute(_buffer):
		_buffer = ""
		return
	_buffer_age += delta
	if _buffer_age > float(cfg["input"]["bufferSeconds"]):
		_buffer = ""


func buffered() -> String:
	return _buffer


# ------------------------------------------------------------ çarpışma

func _on_area(area: Area3D) -> void:
	if area is LaneObject:
		contact(area)


func contact(obj: LaneObject) -> void:
	if obj.resolved or state != State.RUNNING:
		return
	match obj.kind():
		"collectible", "bonus", "powerUp":
			_collect(obj)
		_:
			_hit(obj)


func _collect(obj: LaneObject) -> void:
	var item := obj.item
	var pos := obj.global_position + Vector3(0, 1.4, 0)
	match item["kind"]:
		"collectible":
			var mult := effects.score_multiplier()
			score.collect(float(item["points"]), mult)
			popup.emit("+%d" % roundi(float(item["points"]) * mult), UiKit.BLUE)
			Fx.burst(self, pos, UiKit.YELLOW, 14, 5.0, 0.09)
			Input.vibrate_handheld(15)
		"bonus":
			score.add_extra_credit(float(item["extraCredit"]))
			popup.emit("+%d ekstra kredi" % roundi(float(item["extraCredit"])), UiKit.GOLD)
			Fx.burst(self, pos, UiKit.GOLD, 26, 7.0, 0.12)
		"powerUp":
			var e: Dictionary = item["effect"]
			match e["type"]:
				"scoreMultiplier":
					effects.multiplier = float(e["value"])
					effects.multiplier_left = float(e["duration"])
					popup.emit("Fosforlu x2!", UiKit.GOLD)
				"slowMotion":
					effects.slow_fraction = float(e["value"])
					effects.slow_left = float(e["duration"])
					popup.emit("Odak modu", Color("#8B5A2B"))
				"ink":
					ink.apply(float(e["value"]))
					popup.emit("+%d mürekkep" % roundi(float(e["value"])), UiKit.BLUE)
			effect_event.emit(e["type"])
			Fx.burst(self, pos, UiKit.BLUE, 22, 6.0, 0.1)
	obj.pop()


func _hit(obj: LaneObject) -> void:
	var item := obj.item
	score.penalize(float(item.get("points", 0)))
	ink.apply(float(item.get("ink", 0)))
	_shake = float(cfg["camera"]["shakeTime"])
	tuki.stumble()
	Input.vibrate_handheld(45)
	popup.emit("%d" % roundi(float(item.get("points", 0))), UiKit.RED)
	Fx.burst(self, obj.global_position + Vector3(0, 0.8, 0), Color(0.55, 0.45, 0.35), 16, 4.0, 0.14)
	var e: Dictionary = item.get("effect", {})
	match e.get("type", ""):
		"notification":
			effects.notification_left = float(e["duration"])
			effect_event.emit("notification")
		"reverseControls":
			effects.reverse_left = float(e["duration"])
			effect_event.emit("reverseControls")
		"pullLane":
			var ln := tuki.target_lane
			var dir := 1 if ln == 0 else (-1 if ln == 2 else (1 if rng.randi() % 2 == 0 else -1))
			tuki.force_lane(ln + dir)
			effect_event.emit("pullLane")
	# fizik: nesne savrulur
	# ileri ve yola dışarı doğru savrulur (kameraya gelmez)
	var side := -1.0 if obj.lane == 0 else (1.0 if obj.lane == 2 else (1.0 if rng.randi() % 2 == 0 else -1.0))
	var push := Vector3(side * rng.randf_range(5, 8), 5.0, -speed_mps() * 1.25)
	obj.knock(push)


# ------------------------------------------------------------- bitiş

func _finish() -> void:
	state = State.FINISHED
	var depleted := ink.is_empty()
	var result := score.finish(content.grading, ink.current, depleted)
	outcome = {"score": result, "ink": ink.current, "collected": score.collected_count,
		"hits": score.hit_count, "bonus": score.bonus_count, "distance": distance, "depleted": depleted}
	if record_progress:
		outcome["completion"] = Game.progress.record_level(course_id, assessment, float(result["score"]))
	if depleted:
		tuki.stumble()
		tuki.forward_speed = speed_mps() * 0.5
	else:
		Fx.confetti(self, Vector3(0, 6, tuki.position.z - 6))
	_end_timer = 1.2
