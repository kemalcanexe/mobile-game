extends MenuScreen
## Ana menü: logo, CGPA, dönem, bu dönemin dersleri.


func _init() -> void:
	hero_space = 0.0


func build(v: VBoxContainer) -> void:
	var p := Game.progress
	var logo := UiKit.vbox(-28)
	logo.add_child(UiKit.outlined(T.t("app_title"), 104, Color.WHITE, UiKit.BLUE_DARK))
	logo.add_child(UiKit.outlined(T.t("app_subtitle"), 60, UiKit.YELLOW, UiKit.INK))
	logo.add_child(UiKit.outlined(T.t("tagline"), 26, Color.WHITE, UiKit.INK))
	v.add_child(logo)
	v.add_child(UiKit.spacer(380))  # Tüki burada görünür

	var stats := UiKit.hbox(16)
	var gpa := UiKit.panel(UiKit.BLUE, 30)
	var gv := UiKit.vbox(0)
	gv.add_child(UiKit.label(T.t("cgpa"), 24, Color(1, 1, 1, 0.85)))
	gv.add_child(UiKit.label(Gpa.format(p.transcript.cgpa()), 64, Color.WHITE, UiKit.heavy()))
	gpa.add_child(gv)
	gpa.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stats.add_child(gpa)
	var sem := UiKit.panel(Color.WHITE, 30)
	var sv := UiKit.vbox(6)
	sv.add_child(UiKit.label(T.t("semester_n") % p.semester.index, 36, UiKit.INK, UiKit.heavy()))
	var tr := UiKit.button(T.t("transcript"), UiKit.PANEL_SOFT, Color("#C9D6F5"), UiKit.BLUE, 26)
	tr.pressed.connect(func() -> void: Game.goto("transcript"))
	sv.add_child(tr)
	sem.add_child(sv)
	sem.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stats.add_child(sem)
	v.add_child(stats)

	var offer := p.offer()
	if offer["probation"]:
		var warn := UiKit.panel(Color("#FFE3E3"), 24)
		warn.add_child(UiKit.label("⚠ %s. %s" % [T.t("probation"), T.t("probation_hint") % offer["max"]], 26, UiKit.RED_DARK))
		v.add_child(warn)

	if p.semester.needs_enrollment():
		var card := UiKit.panel(Color.WHITE, 32)
		var cv := UiKit.vbox(16)
		if offer["available"].is_empty():
			cv.add_child(UiKit.label(T.t("no_courses"), 32, UiKit.INK))
		else:
			cv.add_child(UiKit.label(T.t("enroll_hint") % p.semester.index, 34, UiKit.INK))
			var go := UiKit.primary(T.t("enroll_cta"), 44)
			go.pressed.connect(func() -> void: Game.goto("enrollment"))
			cv.add_child(go)
		card.add_child(cv)
		v.add_child(card)
	else:
		v.add_child(UiKit.outlined(T.t("this_term"), 40, Color.WHITE, UiKit.INK))
		for id in p.semester.enrolled:
			v.add_child(_course_card(id))
		if p.is_semester_complete():
			var rep := UiKit.blue(T.t("term_report_cta"), 40)
			rep.pressed.connect(func() -> void: Game.goto("semester_report", {"semester": p.semester.index}))
			v.add_child(rep)

	v.add_child(UiKit.spacer(10))
	v.add_child(_settings_row())
	var reset := UiKit.ghost(T.t("reset"), 24)
	reset.add_theme_color_override("font_color", Color.WHITE)
	var armed := [false]
	reset.pressed.connect(func() -> void:
		if armed[0]:
			Game.progress.reset()
			Game.goto("main")
		else:
			armed[0] = true
			reset.text = T.t("reset_confirm")
			reset.add_theme_color_override("font_color", UiKit.RED))
	v.add_child(reset)


func _course_card(id: String) -> Control:
	var p := Game.progress
	var course := Game.content.course(id)
	var theme: Dictionary = Game.content.world_cfg["themes"][id]
	var status := p.status_of(id)
	var card := UiKit.panel(Color.WHITE, 30)
	var h := UiKit.hbox(18)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var stripe := ColorRect.new()
	stripe.color = Color(theme["accent"])
	stripe.custom_minimum_size = Vector2(12, 0)
	h.add_child(stripe)
	var info := UiKit.vbox(0)
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_child(UiKit.label(course["code"], 42, UiKit.INK, UiKit.heavy()))
	info.add_child(UiKit.label('"%s"' % course["nickname"], 24, UiKit.MUTED))
	var st := T.t("status_" + status)
	if status == "inProgress":
		st = st % p.runs[id].scores.size()
	info.add_child(UiKit.label("%s · %s" % [T.t("credits") % int(course["credits"]), st], 24, UiKit.INK))
	h.add_child(info)
	var rec: CourseRecord = null
	for r in p.transcript.records_in(p.semester.index):
		if r.course_id == id:
			rec = r
	if rec != null:
		h.add_child(UiKit.grade_badge(rec.letter, 96))
	else:
		h.add_child(UiKit.label("▶", 56, Color(theme["accent"]), UiKit.heavy()))
	card.add_child(h)
	UiKit.tap_card(card, func() -> void: Game.goto("course", {"course": id}))
	return card


## Müzik / efekt / titreşim aç-kapa düğmeleri.
func _settings_row() -> Control:
	var h := UiKit.hbox(12)
	var items := [
		["set_music", func() -> bool: return Sound.music_on, func(on: bool) -> void: Sound.set_music_on(on)],
		["set_sfx", func() -> bool: return Sound.sfx_on, func(on: bool) -> void: Sound.set_sfx_on(on)],
		["set_haptics", func() -> bool: return Sound.haptics_on, func(on: bool) -> void: Sound.set_haptics_on(on)],
	]
	for it in items:
		var key: String = it[0]
		var getter: Callable = it[1]
		var setter: Callable = it[2]
		var b := UiKit.button("", Color.WHITE, Color("#C9D6F5"), UiKit.INK, 24)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var refresh := func() -> void:
			var on: bool = getter.call()
			b.text = "%s %s" % [T.t(key), "✓" if on else "✗"]
			b.add_theme_color_override("font_color", UiKit.GREEN_DARK if on else UiKit.RED_DARK)
		refresh.call()
		b.pressed.connect(func() -> void:
			setter.call(not getter.call())
			refresh.call())
		h.add_child(b)
	return h
