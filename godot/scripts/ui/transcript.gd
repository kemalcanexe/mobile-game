extends MenuScreen
## Transkript: dönem dönem bütün dersler, retake'ler ve GPA'ler.


func _init() -> void:
	dim = 0.35


func build(v: VBoxContainer) -> void:
	var p := Game.progress
	var t := p.transcript
	var rules := Game.content.grading
	back_button(v)
	var done := t.semesters().filter(func(s: int) -> bool: return s < p.semester.index).size()
	header(v, T.t("transcript"), T.t("graduation") % [done, Game.content.required_semesters()])
	if t.records.is_empty():
		var e := UiKit.panel(Color.WHITE, 30)
		e.add_child(UiKit.label(T.t("transcript_empty"), 30, UiKit.MUTED))
		v.add_child(e)
		return
	for sem in t.semesters():
		var card := UiKit.panel(Color.WHITE, 30)
		var cv := UiKit.vbox(8)
		var title := T.t("semester_n") % sem
		if AcademicStanding.is_deans_list(rules, t.semester_gpa(sem)):
			title += "  ★"
		cv.add_child(UiKit.label(title, 36, UiKit.BLUE, UiKit.heavy()))
		for rec in t.records_in(sem):
			var col := UiKit.MUTED if rec.replaced else (UiKit.RED if rec.is_failing() else UiKit.INK)
			var r := row([rec.course_code, str(rec.credits), fmt(rec.score), rec.letter.replace("-", "−") + (" R" if rec.replaced else "")],
					[5, 2, 2, 2], [col, col, col, col])
			if rec.replaced:
				r.modulate.a = 0.6
			cv.add_child(r)
		cv.add_child(HSeparator.new())
		cv.add_child(row([T.t("semester_gpa"), Gpa.format(t.semester_gpa(sem))], [5, 3], [UiKit.INK, UiKit.BLUE], [UiKit.bold(), UiKit.heavy()]))
		card.add_child(cv)
		v.add_child(card)
	var total := UiKit.panel(UiKit.BLUE, 30)
	var tv := UiKit.vbox(4)
	tv.add_child(row([T.t("cgpa"), Gpa.format(t.cgpa())], [5, 3], [Color.WHITE, Color.WHITE], [UiKit.heavy(), UiKit.heavy()]))
	if AcademicStanding.is_on_probation(rules, t.cgpa()):
		tv.add_child(UiKit.label(T.t("probation"), 26, UiKit.YELLOW))
	var honor := AcademicStanding.honor_for(rules, t.cgpa())
	if honor != "":
		tv.add_child(UiKit.label(T.t("honor") % T.t("honor_" + honor), 26, UiKit.YELLOW))
	if t.records.any(func(r: CourseRecord) -> bool: return r.replaced):
		tv.add_child(UiKit.label(T.t("transcript_r"), 22, Color(1, 1, 1, 0.8)))
	total.add_child(tv)
	v.add_child(total)
