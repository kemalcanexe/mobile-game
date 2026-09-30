extends MenuScreen
## Dönem karnesi: dersler, dönem GPA'i, CGPA, Dean's List / Probation.

var semester := 1


func _init() -> void:
	semester = int(Game.params.get("semester", 1))
	dim = 0.3


func build(v: VBoxContainer) -> void:
	var p := Game.progress
	var r := p.report_for(semester)
	back_button(v)
	header(v, T.t("term_report"), T.t("semester_n") % semester)
	var card := UiKit.panel(Color.WHITE, 32)
	var cv := UiKit.vbox(10)
	cv.add_child(row([T.t("col_course"), T.t("col_credits"), T.t("col_grade")], [5, 2, 2], [UiKit.MUTED, UiKit.MUTED, UiKit.MUTED]))
	for rec in r["records"]:
		var col := UiKit.RED if rec.is_failing() else UiKit.INK
		cv.add_child(row([rec.course_code + (" (R)" if rec.is_retake() else ""), str(rec.credits), rec.letter.replace("-", "−")],
				[5, 2, 2], [col, col, UiKit.grade_color(rec.letter)], [UiKit.bold(), UiKit.bold(), UiKit.heavy()]))
	cv.add_child(HSeparator.new())
	cv.add_child(row([T.t("semester_gpa"), Gpa.format(r["semesterGpa"])], [5, 3], [UiKit.BLUE, UiKit.BLUE], [UiKit.heavy(), UiKit.heavy()]))
	cv.add_child(row([T.t("cgpa"), Gpa.format(r["cgpa"])], [5, 3], [UiKit.BLUE, UiKit.BLUE], [UiKit.heavy(), UiKit.heavy()]))
	card.add_child(cv)
	v.add_child(card)
	if r["deansList"] or r["probation"]:
		var stamp := UiKit.panel(UiKit.GOLD if r["deansList"] else UiKit.RED, 36)
		var sv := UiKit.vbox(0)
		sv.add_child(UiKit.outlined("★ " + T.t("deans_list") + " ★" if r["deansList"] else T.t("probation_stamp"), 56, Color.WHITE, Color(0, 0, 0, 0.35)))
		sv.get_child(0).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var hint := T.t("deans_hint") if r["deansList"] else T.t("probation_hint") % Game.content.grading.enrollment.probation_max
		sv.add_child(UiKit.label(hint, 26, Color.WHITE, UiKit.bold(), HORIZONTAL_ALIGNMENT_CENTER))
		stamp.add_child(sv)
		stamp.rotation_degrees = -3
		v.add_child(stamp)
		stamp.modulate.a = 0.0
		var tw := create_tween()
		tw.tween_interval(0.4)
		tw.tween_callback(func() -> void:
			stamp.pivot_offset = stamp.size / 2.0
			stamp.scale = Vector2(2.2, 2.2))
		tw.tween_property(stamp, "modulate:a", 1.0, 0.05)
		tw.parallel().tween_property(stamp, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK)
		tw.tween_callback(func() -> void: Input.vibrate_handheld(80))
	if p.semester.index == semester and p.is_semester_complete():
		var nxt := UiKit.primary(T.t("next_term"), 44)
		nxt.pressed.connect(func() -> void:
			Game.progress.advance_semester()
			Game.goto("main"))
		v.add_child(nxt)
