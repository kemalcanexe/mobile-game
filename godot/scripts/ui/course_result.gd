extends MenuScreen
## Ders sonu: ağırlıklar tek tek toplanır, harf damgası vurulur, GPA değişir.

var c: Dictionary
var _rows: Array[Control] = []
var _total: Label
var _badge: Control
var _gpa_box: Control
var _button: Button


func _init() -> void:
	c = Game.params.get("completion", {})
	theme_id = c.get("courseId", "calc101")
	dim = 0.3


func build(v: VBoxContainer) -> void:
	var content := Game.content
	var course := content.course(c["courseId"])
	header(v, T.t("course_result"), '%s · "%s"' % [course["code"], course["nickname"]])
	var card := UiKit.panel(Color.WHITE, 32)
	var cv := UiKit.vbox(10)
	cv.add_child(row([T.t("col_exam"), T.t("col_weight"), T.t("col_score"), T.t("col_contrib")], [4, 2, 2, 2],
			[UiKit.MUTED, UiKit.MUTED, UiKit.MUTED, UiKit.MUTED]))
	for key in Assessment.ORDER:
		var sc := float(c["scores"][key])
		var r := row([Assessment.display_name(key), "%" + str(roundi(content.grading.weights[key] * 100)), fmt(sc),
				"%.1f" % content.grading.contribution(key, sc)], [4, 2, 2, 2])
		r.modulate.a = 0.0
		_rows.append(r)
		cv.add_child(r)
	cv.add_child(HSeparator.new())
	var th := UiKit.hbox()
	var tl := UiKit.label(T.t("total"), 40, UiKit.BLUE, UiKit.heavy())
	tl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	th.add_child(tl)
	_total = UiKit.label("0.0", 48, UiKit.BLUE, UiKit.heavy())
	th.add_child(_total)
	cv.add_child(th)
	card.add_child(cv)
	v.add_child(card)
	_badge = UiKit.grade_badge(c["letter"], 180)
	_badge.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_badge.modulate.a = 0.0
	v.add_child(_badge)
	_gpa_box = UiKit.panel(Color.WHITE, 30)
	var gv := UiKit.vbox(0)
	gv.add_child(UiKit.label(T.t("gpa"), 26, UiKit.MUTED, null, HORIZONTAL_ALIGNMENT_CENTER))
	var before := float(c["cgpaBefore"])
	var after := float(c["cgpaAfter"])
	var arrow := ""
	var col := UiKit.INK
	if before >= 0.0 and after > before:
		arrow = "  ▲"
		col = UiKit.GREEN_DARK
	elif before >= 0.0 and after < before:
		arrow = "  ▼"
		col = UiKit.RED
	gv.add_child(UiKit.label("%s  →  %s%s" % [Gpa.format(before), Gpa.format(after), arrow], 56, col, UiKit.heavy(), HORIZONTAL_ALIGNMENT_CENTER))
	if float(c["gradePoints"]) == 0.0:
		gv.add_child(UiKit.label(T.t("retake_quip"), 28, UiKit.RED, UiKit.bold(), HORIZONTAL_ALIGNMENT_CENTER))
	_gpa_box.add_child(gv)
	_gpa_box.modulate.a = 0.0
	v.add_child(_gpa_box)
	if c.get("semesterComplete", false):
		_button = UiKit.blue(T.t("see_term_report"), 40)
		_button.pressed.connect(func() -> void: Game.goto("semester_report", {"semester": Game.progress.semester.index}))
	else:
		_button = UiKit.primary(T.t("back_to_course"), 40)
		_button.pressed.connect(func() -> void: Game.goto("course", {"course": c["courseId"]}))
	_button.modulate.a = 0.0
	_button.disabled = true
	v.add_child(_button)
	_play()


func _play() -> void:
	var tw := create_tween()
	var running := [0.0]
	for i in _rows.size():
		var key: String = Assessment.ORDER[i]
		var contrib := Game.content.grading.contribution(key, float(c["scores"][key]))
		tw.tween_property(_rows[i], "modulate:a", 1.0, 0.18)
		tw.tween_callback(func() -> void:
			running[0] += contrib
			_total.text = "%.1f" % running[0])
		tw.tween_interval(0.2)
	tw.tween_interval(0.3)
	tw.tween_callback(func() -> void:
		_total.text = "%.1f" % float(c["courseScore"])
		_badge.pivot_offset = _badge.size / 2.0
		_badge.scale = Vector2(3, 3))
	tw.tween_property(_badge, "modulate:a", 1.0, 0.05)
	tw.parallel().tween_property(_badge, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK)
	tw.tween_callback(func() -> void:
		Sound.play("stamp")
		Sound.vibrate("stamp")
		var gp := float(c.get("gradePoints", 0.0))
		if tuki_model:
			tuki_model.emote("victory" if gp >= 3.0 else ("sad" if gp == 0.0 else "wave")))
	tw.tween_property(_gpa_box, "modulate:a", 1.0, 0.3)
	tw.tween_property(_button, "modulate:a", 1.0, 0.2)
	tw.tween_callback(func() -> void: _button.disabled = false)


func go_back() -> void:
	Game.goto("course", {"course": c["courseId"]})
