extends SceneTree
## Bütün derslerin bütün level'larını basit bir botla baştan sona oynatır;
## çalışma hatalarını yakalar ve denge için skor özetini yazar.
##   godot --headless --fixed-fps 60 --path . -s res://tools/soak.gd
## BOT=perfect (varsayılan) ya da BOT=sloppy (tepki gecikmeli, arada hata yapar).

const LOOK := 30.0
## RunState.RUNNING; oyun sınıfları autoload'lar hazır olduktan sonra yüklenir.
const RUNNING := 1

var sloppy := false
var rng := RandomNumberGenerator.new()


func _initialize() -> void:
	sloppy = OS.get_environment("BOT") == "sloppy"
	rng.seed = 7
	await process_frame
	var game: Node = root.get_node("Game")
	var only := OS.get_environment("ONLY")
	var lines: Array[String] = []
	for course in game.content.courses:
		for key in Assessment.ORDER:
			var id := "%s.%s" % [course["id"], key]
			if only != "" and not id.begins_with(only):
				continue
			var r := await _play(course["id"], key)
			print("%s bitti" % id)
			lines.append("%-16s skor=%5.1f harf=%-2s topla=%3d çarp=%2d olay=+%.0f/-%.0f mürekkep=%3.0f %s" % [id, r["score"],
				game.content.grading.letter_for(r["score"]).symbol, r["collected"], r["hits"], r["ev_plus"], r["ev_minus"], r["ink"],
				"BİTTİ" if r["depleted"] else ""])
	for l in lines:
		print(l)
	quit()


func _play(course_id: String, key: String) -> Dictionary:
	var s = load("res://scripts/game/run_scene.gd").new()
	s.course_id = course_id
	s.assessment = key
	s.record_progress = false
	s.with_hud = false
	root.get_node("Game").params = {}
	root.add_child(s)
	await physics_frame
	s.start()
	var guard := 0
	var think := 0.0
	while s.state == RUNNING and guard < 60 * 150:
		await physics_frame
		guard += 1
		think -= 1.0 / 60.0
		# güvenlik: Tüki zeminden düşerse rapora yaz
		if s.tuki.position.y < -0.3 and not s.has_meta("fell"):
			s.set_meta("fell", true)
			printerr("  DÜŞTÜ %s.%s t=%.2f mesafe=%d" % [course_id, key, guard / 60.0, s.distance])
		if think <= 0.0:
			think = rng.randf_range(0.12, 0.3) if sloppy else 0.0
			_decide(s)
	var out := {"score": float(s.outcome.get("score", {}).get("score", 0.0)), "collected": s.score.collected_count,
		"hits": s.score.hit_count, "ev_plus": s.score.event_points, "ev_minus": s.score.event_penalty, "ink": s.ink.current,
		"depleted": s.outcome.get("depleted", false)}
	s.queue_free()
	await process_frame
	return out


## Basit karar: önümüzdeki 16 m'de her şeridin tehlike/ödül puanı.
func _decide(s) -> void:
	var tz: float = s.tuki.position.z
	var cost := [0.0, 0.0, 0.0]
	var need := ["", "", ""]
	var nearest := [INF, INF, INF]
	for o in s.objects():
		if not is_instance_valid(o) or o.resolved:
			continue
		var ahead: float = tz - o.position.z
		if ahead < -0.5 or ahead > LOOK:
			continue
		var ln: int = clampi(roundi(o.position.x / s.lane_w) + 1, 0, 2)
		match o.kind():
			"wall", "distraction":
				cost[ln] += 100.0 / maxf(ahead, 1.0)
			"groundObstacle", "bug":
				if ahead < nearest[ln]:
					nearest[ln] = ahead
					need[ln] = "up"
				cost[ln] += 2.0
			"airObstacle":
				if ahead < nearest[ln]:
					nearest[ln] = ahead
					need[ln] = "down"
				cost[ln] += 2.0
			"collectible", "bonus", "powerUp", "ramp":
				cost[ln] -= 6.0 / maxf(ahead, 1.0)
			"gate":
				if o.item["art"] != "answerGate":
					cost[ln] -= 30.0 / maxf(ahead, 1.0)
				else:
					var right: bool = o.extra.get("correct", false)
					if sloppy and rng.randf() < 0.3:
						right = not right
					cost[ln] += -40.0 if right else 40.0
	# yoklama: yeşil şeride git
	for sp in s.director._active:
		if sp["type"] == "rollCall" and sp["started"] and not sp.get("done", false):
			cost[int(sp["lane"])] -= 30.0
	var cur: int = s.tuki.target_lane
	var best := cur
	for ln in 3:
		# komşu şeritler tercih edilir (tek hamle)
		var c: float = cost[ln] + absf(ln - cur) * 1.5
		if c < cost[best] + absf(best - cur) * 1.5 - 0.5:
			best = ln
	if sloppy and rng.randf() < 0.05:
		best = clampi(cur + (1 if rng.randf() < 0.5 else -1), 0, 2)
	if best != cur:
		s.handle_swipe("right" if best > cur else "left")
		return
	var d: float = nearest[cur]
	var react := 5.5 if not sloppy else rng.randf_range(3.5, 7.5)
	if need[cur] != "" and d < react:
		var dir: String = need[cur]
		# yerçekimi bölgesinde kontroller ters: bot doğru jesti gönderir
		if s.tuki.zone == "gravity":
			dir = "down" if dir == "up" else "up"
		s.handle_swipe(dir)
