extends TestCase
## 3D koşu mekanikleri: sahne gerçek fizikle (Jolt) çalıştırılır.

var scene: RunScene


func tree() -> SceneTree:
	return Engine.get_main_loop()


func make(events: Array, total := 3000.0) -> RunScene:
	var s := RunScene.new()
	s.level_override = {"id": "test", "assessment": "quiz1", "durationSeconds": 10,
		"speed": {"start": 1.0, "end": 1.0, "curve": "linear"}, "seed": 42,
		"gapRows": {"min": 1, "max": 1}, "pool": []}
	s.plan_override = {"total": total, "events": events}
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


func run_until(d: float, px_away := 0.0) -> void:
	var guard := 0
	while scene.distance < d - px_away and scene.state == RunScene.State.RUNNING and guard < 2000:
		await tree().physics_frame
		guard += 1


func test_serit_degisimi() -> void:
	var s := make([])
	await frames(2)
	s.handle_swipe("left")
	await frames(5)
	eq(s.tuki.target_lane, 1, "başlamadan girdi alınmaz")
	s.start()
	s.handle_swipe("right")
	await frames(20)
	eq(s.tuki.lane, 2)
	near(s.tuki.position.x, 2.6, 0.01)
	s.handle_swipe("right")
	await frames(10)
	eq(s.tuki.lane, 2, "kenardan çıkılmaz")
	s.handle_swipe("left")
	s.handle_swipe("left")
	await frames(20)
	eq(s.tuki.lane, 0, "çift swipe iki şerit")
	check(s.distance > 100, "koşuyor")


func test_ziplayinca_bariyer_asilir() -> void:
	var s := make([{"d": 700.0, "lane": 1, "code": "og"}])
	await frames(2)
	s.start()
	await run_until(700, 110)
	check(s.tuki.try_jump(), "yerde zıplar")
	await frames(40)
	eq(s.score.hit_count, 0, "zıplayınca çarpmaz")
	eq(s.ink.current, 100.0)


func test_ziplamadan_bariyere_carpilir() -> void:
	var s := make([{"d": 700.0, "lane": 1, "code": "og"}])
	await frames(2)
	s.start()
	await run_until(820)
	eq(s.score.hit_count, 1)
	eq(s.score.penalty_points, 5.0)
	eq(s.ink.current, 90.0)


func test_kayinca_afisin_altindan_gecilir() -> void:
	var s := make([{"d": 700.0, "lane": 1, "code": "oa"}, {"d": 1500.0, "lane": 1, "code": "oa"}])
	await frames(2)
	s.start()
	await run_until(700, 60)
	s.handle_swipe("down")
	check(s.tuki.sliding)
	await frames(30)
	eq(s.score.hit_count, 0, "kayınca çarpmaz")
	await run_until(1500, 100)
	s.handle_swipe("up")
	await frames(30)
	eq(s.score.hit_count, 1, "zıplarken afişe çarpar")


func test_havada_asagi_hizli_indirir_ve_buffer() -> void:
	var s := make([])
	await frames(2)
	s.start()
	await frames(5)
	s.handle_swipe("up")
	await frames(6)
	check(s.tuki.is_airborne(), "havada")
	s.handle_swipe("up")
	eq(s.buffered(), "up", "havada zıpla bekletilir")
	s.handle_swipe("down")
	await frames(8)
	check(not s.tuki.is_airborne(), "fast-fall ile indi")
	check(s.tuki.sliding, "inip kayar")


func test_duvar_her_durumda_carpar() -> void:
	var s := make([{"d": 700.0, "lane": 1, "code": "ow"}])
	await frames(2)
	s.start()
	await run_until(700, 110)
	s.tuki.try_jump()
	await frames(40)
	eq(s.score.hit_count, 1)


func test_toplama_fosforlu_ve_kartus() -> void:
	var s := make([{"d": 600.0, "lane": 1, "code": "ph"}, {"d": 800.0, "lane": 1, "code": "hl"},
		{"d": 1000.0, "lane": 1, "code": "nt"}, {"d": 1200.0, "lane": 1, "code": "ik"},
		{"d": 1200.0, "lane": 0, "code": "bk"}])
	await frames(2)
	s.start()
	await run_until(700)
	eq(s.ink.current, 90.0, "telefon")
	check(s.effects.notification_left > 0.0)
	await run_until(1100)
	eq(s.score.collected_points, 20.0, "fosforlu x2")
	await run_until(1300)
	eq(s.ink.current, 100.0, "kartuş")
	eq(s.score.max_points, 35.0, "kitap spawn oldu, toplanmadı")


func test_kotu_arkadas_ceker_konsol_ters() -> void:
	var s := make([{"d": 700.0, "lane": 0, "code": "fr"}, {"d": 1400.0, "lane": 1, "code": "gc"}])
	await frames(2)
	s.start()
	s.handle_swipe("left")
	await run_until(790)
	await frames(15)
	eq(s.tuki.lane, 1, "bir şerit çekildi")
	await run_until(1480)
	check(s.effects.reversed())
	s.handle_swipe("left")
	await frames(15)
	eq(s.tuki.lane, 2, "ters kontrol")


func test_sayfa_sonu_ve_murekkep_bitisi() -> void:
	var s := make([{"d": 600.0, "lane": 1, "code": "nt"}, {"d": 800.0, "lane": 0, "code": "nt"}], 1100)
	await frames(2)
	s.start()
	await frames(300)
	eq(s.state, RunScene.State.FINISHED)
	eq(s.outcome["score"]["base"], 50.0)
	eq(s.outcome["score"]["score"], 52.0, "temiz kağıt +2")
	s.queue_free()
	var walls := [{"d": 500.0, "lane": 1, "code": "nt"}]
	for i in 10:
		walls.append({"d": 700.0 + i * 160.0, "lane": 1, "code": "ow"})
	var s2 := make(walls, 6000)
	await frames(2)
	s2.start()
	await frames(700)
	eq(s2.state, RunScene.State.FINISHED)
	check(s2.outcome["depleted"])
	check(s2.outcome["score"]["score"] <= 50.0)
