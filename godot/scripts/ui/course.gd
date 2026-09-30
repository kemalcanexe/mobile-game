extends MenuScreen
## Dersin izlencesi: 5 sınav, ağırlıklar, skorlar ve sıradaki sınav.

var course_id := "calc101"


func _init() -> void:
	course_id = Game.params.get("course", "calc101")
	theme_id = course_id
	hero_space = 0.0


func build(v: VBoxContainer) -> void:
	var p := Game.progress
	var content := Game.content
	var course := content.course(course_id)
	var theme: Dictionary = content.world_cfg["themes"][course_id]
	var accent := Color(theme["accent"])
	var status := p.status_of(course_id)
	var run := p.run_for(course_id)
	var record := p.transcript.active_record_for(course_id)
	back_button(v)
	header(v, course["code"], '"%s" · %s' % [course["nickname"], theme["name"]])
	var meta := T.t("credits") % int(course["credits"])
	if run != null and run.attempt > 1:
		meta += " · " + T.t("attempt") % run.attempt
	v.add_child(UiKit.outlined(meta, 26, Color.WHITE, UiKit.INK))
	v.add_child(UiKit.spacer(maxf(160.0, get_viewport().get_visible_rect().size.y * 0.22)))

	var card := UiKit.panel(Color.WHITE, 32)
	var cv := UiKit.vbox(10)
	cv.add_child(UiKit.label(T.t("syllabus"), 40, accent, UiKit.heavy()))
	cv.add_child(row([T.t("col_exam"), T.t("col_weight"), T.t("col_time"), T.t("col_score")], [4, 2, 2, 3],
			[UiKit.MUTED, UiKit.MUTED, UiKit.MUTED, UiKit.MUTED], [UiKit.bold(), UiKit.bold(), UiKit.bold(), UiKit.bold()]))
	var next := run.next_assessment() if run != null else ""
	var scores: Dictionary = run.scores if run != null else (record.assessment_scores if record != null else {})
	for key in Assessment.ORDER:
		var lv: Dictionary = course["levels"][key]
		var sc := "—"
		if scores.has(key):
			var val := float(scores[key])
			sc = "%s %s" % [fmt(val), content.grading.letter_for(val).symbol]
		var is_next: bool = key == next
		var col := accent if is_next else UiKit.INK
		var name := ("▶ " if is_next else "") + Assessment.display_name(key)
		cv.add_child(row([name, "%" + str(roundi(content.grading.weights[key] * 100)), "%d sn" % int(lv["durationSeconds"]), sc],
				[4, 2, 2, 3], [col, col, col, col], [UiKit.heavy() if is_next else UiKit.bold()]))
	card.add_child(cv)
	v.add_child(card)

	if next != "":
		var go := UiKit.primary(T.t("start_exam") % Assessment.display_name(next), 40)
		go.pressed.connect(func() -> void: Game.goto("run", {"course": course_id, "assessment": next}))
		v.add_child(go)
	elif status == "failed" and record != null:
		var box := UiKit.panel(Color.WHITE, 32)
		var bv := UiKit.vbox(10)
		var badge := UiKit.grade_badge(record.letter, 130)
		badge.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		bv.add_child(badge)
		bv.add_child(UiKit.label(T.t("retake_quip"), 30, UiKit.RED, UiKit.heavy(), HORIZONTAL_ALIGNMENT_CENTER))
		bv.add_child(UiKit.label(T.t("failed_next"), 24, UiKit.MUTED, null, HORIZONTAL_ALIGNMENT_CENTER))
		box.add_child(bv)
		v.add_child(box)
	elif record != null:
		var box := UiKit.panel(Color.WHITE, 32)
		var bv := UiKit.vbox(6)
		var badge := UiKit.grade_badge(record.letter, 140)
		badge.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		bv.add_child(badge)
		bv.add_child(UiKit.label(T.t("course_done"), 36, UiKit.INK, UiKit.heavy(), HORIZONTAL_ALIGNMENT_CENTER))
		bv.add_child(UiKit.label(fmt(record.score), 28, UiKit.MUTED, null, HORIZONTAL_ALIGNMENT_CENTER))
		box.add_child(bv)
		v.add_child(box)
	elif status == "notEnrolled":
		v.add_child(UiKit.outlined(T.t("status_notEnrolled"), 34, Color.WHITE, UiKit.INK))
