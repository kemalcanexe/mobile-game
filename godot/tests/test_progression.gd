extends TestCase


func test_gpa_kredi_agirlikli() -> void:
	var t := Transcript.new([rec("calc101", "A", 4.0, 4), rec("phys101", "B", 3.0, 3)])
	near(t.cgpa(), 25.0 / 7.0, 1e-12)
	eq(Gpa.format(t.cgpa()), "3.57")
	eq(Gpa.format(Transcript.new().cgpa()), "—")


func test_donem_gpa() -> void:
	var t := Transcript.new([rec("a", "A", 4.0, 3, 1), rec("b", "C", 2.0, 3, 2)])
	eq(t.semester_gpa(1), 4.0)
	eq(t.semester_gpa(2), 2.0)
	eq(t.cgpa(), 3.0)
	eq(t.semester_gpa(3), Gpa.UNDEFINED)
	eq(t.semesters(), [1, 2] as Array[int])


func test_retake_yeni_not_yerine_gecer() -> void:
	var r := rules()
	var t := Transcript.new([rec("calc101", "F", 0, 4), rec("phys101", "B", 3.0, 3)])
	check(t.has_unresolved_failure())
	eq(t.failed_course_ids(), ["calc101"] as Array[String])
	t = t.add_result(rec("calc101", "B+", 3.3, 4, 2, 2), r.retakeable_letters)
	eq(t.records.size(), 3)
	check(t.records[0].replaced, "eski kayıt R")
	eq(t.active_record_for("calc101").letter, "B+")
	near(t.cgpa(), (3.3 * 4 + 3.0 * 3) / 7.0, 1e-12)
	near(t.semester_gpa(1), 9.0 / 7.0, 1e-12, "tarihsel dönem GPA")
	eq(t.attempts_for("calc101"), 2)
	check(not t.has_unresolved_failure())


func test_gecilen_ders_tekrar_alinamaz() -> void:
	var t := Transcript.new([rec("calc101", "D-", 0.7)])
	check(t.add_result(rec("calc101", "A", 4.0), rules().retakeable_letters) == null)


func test_transcript_json() -> void:
	var r := rules()
	var t := Transcript.new([rec("calc101", "F", 0)])
	t = t.add_result(CourseRecord.create("calc101", "CALC 101", 3, 2, 95, "A", 4.0, 2, {"final": 88.0}), r.retakeable_letters)
	var back := Transcript.from_array(JSON.parse_string(JSON.stringify(t.to_array())))
	check(back.records[0].replaced)
	check(back.records[1].is_retake())
	eq(back.records[1].assessment_scores["final"], 88.0)
	eq(back.cgpa(), t.cgpa())
	var old := CourseRecord.from_dict({"courseId": "x", "courseCode": "X", "credits": 3, "semester": 1,
		"score": 90, "letter": "A-", "gradePoints": 3.7})
	eq(old.attempt, 1)
	check(not old.replaced)


func test_akademik_durum() -> void:
	var r := rules()
	check(AcademicStanding.is_deans_list(r, 3.5))
	check(not AcademicStanding.is_deans_list(r, 3.49))
	check(not AcademicStanding.is_deans_list(r, Gpa.UNDEFINED))
	check(AcademicStanding.is_on_probation(r, 1.99))
	check(not AcademicStanding.is_on_probation(r, 2.0))
	eq(AcademicStanding.honor_for(r, 3.49), "")
	eq(AcademicStanding.honor_for(r, 3.5), "cum_laude")
	eq(AcademicStanding.honor_for(r, 3.7), "magna_cum_laude")
	eq(AcademicStanding.honor_for(r, 3.9), "summa_cum_laude")
	var ok := Transcript.new([rec("a", "B", 3.0)])
	check(AcademicStanding.can_graduate(r, ok, 8, 8))
	check(not AcademicStanding.can_graduate(r, ok, 7, 8))
	check(not AcademicStanding.can_graduate(r, Transcript.new([rec("a", "A", 4), rec("b", "F", 0)]), 8, 8))


func test_course_run_sirasi() -> void:
	var run := CourseRun.create("calc101")
	eq(run.next_assessment(), "quiz1")
	run = run.with_score("quiz1", 90)
	eq(run.next_assessment(), "midterm")
	check(run.with_score("final", 90) == null)
	for k in ["midterm", "quiz2", "project", "final"]:
		run = run.with_score(k, 80)
	check(run.is_complete())
	var back := CourseRun.from_dict(JSON.parse_string(JSON.stringify(run.to_dict())))
	eq(back.scores["quiz1"], 90.0)


func test_ders_secimi_kurallari() -> void:
	var e := rules().enrollment
	eq(e.max_for(false), 4)
	eq(e.max_for(true), 3)
	eq(e.min_for(2, false), 2)
	eq(e.min_for(6, false), 3)
	var av := ["a", "b", "c", "d", "e"]
	eq(e.validate(["a", "b", "c"], av, [], false), [] as Array[String])
	eq(e.validate(["a", "b"], av, [], false), ["tooFew"] as Array[String])
	eq(e.validate(["a", "b", "c", "d", "e"], av, [], false), ["tooMany"] as Array[String])
	check(e.validate(["a", "a", "b", "c"], av, [], false).has("duplicate"))
	check(e.validate(["a", "b", "z"], av, [], false).has("notOffered"))
	eq(e.validate(["a", "b", "c", "d"], av, [], true), ["tooMany"] as Array[String])
	eq(e.validate(["b", "c", "d"], av, ["a"], false), ["missingRetake"] as Array[String])


func test_donem_durumu() -> void:
	var s := SemesterState.create()
	check(s.needs_enrollment())
	s = s.with_enrollment(["calc101", "cs101"] as Array[String])
	check(s.is_enrolled("cs101"))
	var back := SemesterState.from_dict(JSON.parse_string(JSON.stringify(s.to_dict())))
	eq(back.enrolled.size(), 2)
	eq(s.next().index, 2)
	check(s.next().needs_enrollment())
