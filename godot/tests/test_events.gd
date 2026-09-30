extends TestCase
## Özel olaylar, tema bölgeleri ve boss: sahne gerçek fizikle çalıştırılır.

var scene: RunScene


func tree() -> SceneTree:
	return Engine.get_main_loop()


func make(events: Array, specials: Array = [], total := 4000.0, course := "calc101") -> RunScene:
	var s := RunScene.new()
	s.course_id = course
	s.level_override = {"id": "test", "assessment": "quiz1", "durationSeconds": 10,
		"speed": {"start": 1.0, "end": 1.0, "curve": "linear"}, "seed": 42,
		"gapRows": {"min": 1, "max": 1}, "pool": []}
	s.plan_override = {"total": total, "events": events, "specials": specials}
	s.record_progress = false
	s.with_hud = false
	tree().root.add_child(s)
	scene = s
	return s


func cleanup() -> void:
	if is_instance_valid(scene):
		scene.queue_free()


func frames(n: int) -> void:
	for i in n:
		await tree().physics_frame


func run_until(d: float) -> void:
	var guard := 0
	while scene.distance < d and scene.state == RunScene.State.RUNNING and guard < 3000:
		await tree().physics_frame
		guard += 1


func test_yoklama_seritte_kalinca_puan() -> void:
	var s := make([], [{"type": "rollCall", "d": 400.0, "length": 1000.0, "lane": 2}])
	await frames(2)
	s.start()
	s.handle_swipe("right")
	await run_until(1100)
	eq(s.score.event_points, 10.0, "Burada! +10")
	eq(s.score.event_penalty, 0.0)


func test_yoklama_kacirilinca_devamsizlik() -> void:
	var s := make([], [{"type": "rollCall", "d": 400.0, "length": 400.0, "lane": 0}])
	await frames(2)
	s.start()
	await run_until(900)
	eq(s.score.event_penalty, 5.0, "Devamsızlık −5")


func test_derse_girmeyelim_yoklamayi_kacirtir() -> void:
	var s := make([], [{"type": "rollCall", "d": 400.0, "length": 1000.0, "lane": 1}])
	s.effects.skip_class = true
	await frames(2)
	s.start()
	await run_until(1500)
	eq(s.score.event_points, 0.0, "Tüki şeritte olsa da kaçırdı")
	eq(s.score.event_penalty, 5.0)
	check(not s.effects.skip_class, "bayrak tüketildi")


func test_soru_kapisi_dogru_ve_yanlis() -> void:
	var ev := []
	for lane in 3:
		ev.append({"d": 700.0, "lane": lane, "code": "qg", "gate": 0, "text": str(lane), "correct": lane == 1})
		ev.append({"d": 1500.0, "lane": lane, "code": "qg", "gate": 1, "text": str(lane), "correct": lane == 2})
	var sp := [{"type": "questionGate", "d": 500.0, "gateD": 700.0, "id": 0, "q": "?", "correct": 1},
		{"type": "questionGate", "d": 1300.0, "gateD": 1500.0, "id": 1, "q": "?", "correct": 2}]
	var s := make(ev, sp)
	await frames(2)
	s.start()
	await run_until(800)
	eq(s.score.event_points, 20.0, "doğru şerit +20")
	await run_until(1600)
	eq(s.score.event_penalty, 10.0, "yanlış şerit −10")
	eq(s.score.hit_count, 0, "kapı engel sayılmaz")


func test_grup_odevi_yariya_boler_is_bolumu_ayirir() -> void:
	var s := make([{"d": 600.0, "lane": 1, "code": "nt"}, {"d": 900.0, "lane": 1, "code": "gd"},
		{"d": 1200.0, "lane": 1, "code": "nt"}], [{"type": "groupProject", "d": 400.0}])
	await frames(2)
	s.start()
	await run_until(700)
	eq(s.score.collected_points, 5.0, "yarısı arkadaşa")
	check(s.director.group_left > 0.0)
	await run_until(1300)
	eq(s.director.group_left, 0.0, "kapıdan geçince ayrıldı")
	eq(s.score.collected_points, 15.0, "sonra tam puan")


func test_ofis_saati_engelleri_temizler() -> void:
	var s := make([{"d": 600.0, "lane": 1, "code": "oh"}, {"d": 900.0, "lane": 1, "code": "ow"},
		{"d": 1100.0, "lane": 1, "code": "og"}], [{"type": "officeHours", "d": 600.0, "lane": 1}])
	await frames(2)
	s.start()
	await run_until(1300)
	eq(s.score.hit_count, 0, "koridorda engel yok")
	check(s.score.collected_points > 0.0, "bonus notlar toplandı")
	eq(s.score.max_points, 0.0, "bonus notlar maksimuma eklenmez")


func test_turev_rampasi_firlatir_ve_x2() -> void:
	var s := make([{"d": 600.0, "lane": 1, "code": "dr"}, {"d": 760.0, "lane": 1, "code": "og"}])
	await frames(2)
	s.start()
	await run_until(620)
	await frames(4)
	check(s.tuki.is_airborne(), "rampadan havalandı")
	check(s.effects.score_multiplier() > 1.0, "x2")
	await run_until(900)
	eq(s.score.hit_count, 0, "rampa ile bariyerin üstünden geçti")


func test_yercekimi_bolgesi_kontrolleri_cevirir() -> void:
	var s := make([], [{"type": "zone", "zone": "gravity", "d": 400.0, "length": 800.0}])
	await frames(2)
	s.start()
	await run_until(500)
	eq(s.tuki.zone, "gravity")
	s.handle_swipe("down")
	await frames(4)
	check(s.tuki.is_airborne(), "aşağı = zıpla")
	await frames(90)
	s.handle_swipe("up")
	check(s.tuki.sliding, "yukarı = kay")
	await run_until(1300)
	eq(s.tuki.zone, "", "bölge bitti")


func test_buz_serit_degisimi_yavas() -> void:
	var s := make([], [{"type": "zone", "zone": "ice", "d": 300.0, "length": 2000.0}])
	await frames(2)
	s.start()
	await run_until(400)
	s.handle_swipe("left")
	await frames(10)
	check(s.tuki.lane != 0, "buzda hemen varmaz")
	await frames(30)
	eq(s.tuki.lane, 0, "sonunda varır")


func test_bug_serit_degistirir() -> void:
	var s := make([{"d": 2000.0, "lane": 0, "code": "bg"}])
	await frames(2)
	s.start()
	await run_until(600)
	var bug: LaneObject = null
	for o in s.objects():
		if is_instance_valid(o) and o.code == "bg":
			bug = o
	check(bug != null, "bug doğdu")
	await frames(100)
	if bug:
		eq(bug.lane, 1, "kenardan içeri sıçradı")


func test_boss_telgraf_sonra_x_duser() -> void:
	var s := make([{"d": 1500.0, "lane": 1, "code": "bx"}], [{"type": "boss", "d": 0.0}], 4000.0, "phys101")
	await frames(2)
	s.start()
	await run_until(100)
	check(s.director.boss != null, "boss sahnede")
	var x: LaneObject = null
	await run_until(300)
	for o in s.objects():
		if is_instance_valid(o) and o.code == "bx":
			x = o
	check(x != null and not x.visual.visible, "önce görünmez")
	await run_until(1500 - 15 * 1.5 / 0.05)
	await frames(3)
	check(x.get_node_or_null("Telegraph") != null, "şerit işaretlendi")
	await run_until(1500 - 15 * 0.8 / 0.05)
	await frames(3)
	check(x.visual.visible, "✗ düştü")
	await run_until(1600)
	eq(s.score.hit_count, 1, "✗ şeridi kapatır")
