extends TestCase


func test_harf_sinirlari() -> void:
	var s := rules().scale
	var cases := {100.0: "A+", 97.0: "A+", 96.99: "A", 93.0: "A", 92.99: "A-", 90.0: "A-", 89.99: "B+",
		87.0: "B+", 83.0: "B", 80.0: "B-", 79.99: "C+", 77.0: "C+", 73.0: "C", 70.0: "C-", 67.0: "D+",
		63.0: "D", 60.0: "D-", 59.99: "F", 0.0: "F", -5.0: "F"}
	for score in cases:
		eq(s.grade_for(score).symbol, cases[score], "skor %s" % score)


func test_puanlar_ve_kayan_nokta() -> void:
	var s := rules().scale
	eq(s.by_symbol("A+").points, 4.0)
	eq(s.by_symbol("A-").points, 3.7)
	eq(s.by_symbol("D-").points, 0.7)
	check(s.by_symbol("F").is_failing())
	check(not s.by_symbol("D-").is_failing())
	check(s.by_symbol("E") == null)
	eq(s.grade_for(96.99999999999999).symbol, "A+")
	eq(s.grade_for(96.9999).symbol, "A")


func test_sifirsiz_tablo_reddedilir() -> void:
	var list: Array[LetterGrade] = [LetterGrade.new("A", 90, 4)]
	check(GradeScale.new(list).error != "")


func test_agirlikli_ders_skoru() -> void:
	var r := rules()
	eq(r.weights["quiz1"], 0.10)
	eq(r.weights["midterm"], 0.30)
	eq(r.weights["final"], 0.30)
	var sc := {"quiz1": 100, "midterm": 80, "quiz2": 90, "project": 70, "final": 60}
	near(r.course_score(sc), 75.0, 1e-9)
	eq(r.letter_for(75).symbol, "C")
	var all97 := {"quiz1": 97, "midterm": 97, "quiz2": 97, "project": 97, "final": 97}
	eq(r.letter_for(r.course_score(all97)).symbol, "A+")
	eq(r.course_score({"quiz1": 100}), -1.0, "eksik skor")
	near(r.contribution("final", 80), 24.0, 1e-9)


func test_bozuk_config_reddedilir() -> void:
	var d := json("res://data/config/grading.json")
	d["assessments"][0]["weight"] = 0.5
	check(GradingRules.from_dict(d).error != "", "ağırlık toplamı")
	d = json("res://data/config/grading.json")
	d["assessments"].pop_back()
	check(GradingRules.from_dict(d).error != "", "eksik ağırlık")
	check(rules().error == "")
