extends TestCase

var _content: Content
var _path := "user://test_save.json"


func c() -> Content:
	if _content == null:
		_content = Content.load_all()
	return _content


func fresh() -> Progress:
	var p := Progress.new(c(), _path)
	p.reset()
	return p


func cleanup() -> void:
	if FileAccess.file_exists(_path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(_path))


func play(p: Progress, id: String, score: float) -> Dictionary:
	var done := {}
	for k in Assessment.ORDER:
		done = p.record_level(id, k, score)
	return done


func test_icerik_gecerli() -> void:
	eq(c().errors, [] as Array[String], "veri hataları")
	eq(c().courses.size(), 3)
	eq(c().offered_in(1), ["calc101", "phys101", "cs101"])
	eq(c().offered_in(2), [])
	eq(int(c().course("cs101")["credits"]), 3)
	eq(float(c().course("calc101")["levels"]["final"]["speed"]["end"]), 1.75)


func test_dogrulayici_hatalari_yakalar() -> void:
	var course := {"id": "x", "patterns": {"bad": {"rows": ["fc ..", "ow ow ow", "fc nt ..", "zz .. .."]}}, "levels": {}}
	var errs := LevelValidator.validate(course, c().items, 3)
	var joined := "\n".join(errs)
	check(joined.contains("hücre bekleniyordu"))
	check(joined.contains("duvarla kapalı"))
	check(joined.contains("birden fazla toplanabilir"))
	check(joined.contains('bilinmeyen nesne kodu "zz"'))
	check(joined.contains("level'ı eksik"))


func test_hiz_egrisi_ve_mesafe() -> void:
	var s := SpeedCurve.from_dict({"start": 1.0, "end": 1.25, "curve": "easeInOut"})
	eq(s.multiplier_at(0), 1.0)
	eq(s.multiplier_at(1), 1.25)
	var d := s.distance_for(60, 300)
	var t := 0.0
	var x := 0.0
	var dt := 1.0 / 240.0
	while x < d:
		x += 300 * s.multiplier_at(x / d) * dt
		t += dt
	near(t, 60.0, 0.05)


func test_uretici_deterministik_ve_adil() -> void:
	for course in c().courses:
		for key in Assessment.ORDER:
			var lv: Dictionary = course["levels"][key]
			var a := LevelGenerator.generate(lv, course["patterns"], c().game_cfg)
			var b := LevelGenerator.generate(lv, course["patterns"], c().game_cfg)
			eq(a["events"].size(), b["events"].size(), "deterministik")
			var maxp := 0.0
			var prev := -1.0
			for e in a["events"]:
				var it: Dictionary = c().items[e["code"]]
				if it["kind"] == "collectible":
					maxp += float(it["points"])
				check(e["d"] >= prev, "sıralı")
				prev = e["d"]
			check(maxp > 300, "%s.%s toplanabilir" % [course["id"], key])


func test_ders_secimi_ve_donem() -> void:
	var p := fresh()
	check(p.semester.needs_enrollment())
	eq(p.status_of("calc101"), "notEnrolled")
	check(p.run_for("calc101") == null)
	var o := p.offer()
	eq(o["min"], 3)
	check(not p.enroll(["calc101"]))
	check(p.enroll(["calc101", "phys101", "cs101"]))
	check(not p.enroll(["calc101", "phys101", "cs101"]), "ikinci kez olmaz")
	eq(p.status_of("calc101"), "notStarted")
	p.record_level("calc101", "quiz1", 88)
	eq(p.status_of("calc101"), "inProgress")
	var p2 := Progress.new(c(), _path)
	p2.load_save()
	eq(p2.run_for("calc101").scores["quiz1"], 88.0, "kalıcı")


func test_tam_donem_deans_list() -> void:
	var p := fresh()
	p.enroll(["calc101", "phys101", "cs101"])
	play(p, "calc101", 95)
	var d := play(p, "phys101", 90)
	eq(d["letter"], "A-")
	check(not d["semesterComplete"])
	check(not p.advance_semester())
	d = play(p, "cs101", 85)
	check(d["semesterComplete"])
	var r := p.report_for(1)
	near(r["semesterGpa"], (16 + 14.8 + 9) / 11.0, 1e-12)
	check(r["deansList"])
	check(p.advance_semester())
	eq(p.semester.index, 2)
	eq(p.offer()["available"], [])


func test_f_probation_retake() -> void:
	var p := fresh()
	p.enroll(["calc101", "phys101", "cs101"])
	play(p, "calc101", 40)
	play(p, "phys101", 45)
	play(p, "cs101", 75)
	check(p.report_for(1)["probation"])
	p.advance_semester()
	var o := p.offer()
	eq(o["available"], ["calc101", "phys101"])
	check(o["probation"])
	eq(o["max"], 3)
	check(p.check_enrollment(["calc101"]).has("missingRetake"))
	check(p.enroll(["calc101", "phys101"]))
	eq(p.run_for("calc101").attempt, 2)
	var d := play(p, "calc101", 85)
	near(d["cgpaBefore"], 6.0 / 11.0, 1e-12)
	eq(p.transcript.active_record_for("calc101").semester, 2)
	near(p.transcript.semester_gpa(1), 6.0 / 11.0, 1e-12)


func test_eski_ve_bozuk_kayit() -> void:
	var f := FileAccess.open(_path, FileAccess.WRITE)
	f.store_string(JSON.stringify({"version": 1, "transcript": [], "runs": {"calc101": {"courseId": "calc101", "attempt": 1, "scores": {"quiz1": 70}}}}))
	f.close()
	var p := Progress.new(c(), _path)
	p.load_save()
	eq(p.semester.enrolled, ["calc101"] as Array[String])
	eq(p.status_of("calc101"), "inProgress")
	f = FileAccess.open(_path, FileAccess.WRITE)
	f.store_string("{bozuk")
	f.close()
	p.load_save()
	eq(p.transcript.records.size(), 0)
