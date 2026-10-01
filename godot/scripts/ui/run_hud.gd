class_name RunHud
extends CanvasLayer
## Koşu arayüzü: skor, mürekkep kalemi, ilerleme, efektler, bildirim,
## başlangıç / mola / sınav sonu panelleri.

var run: RunScene
var root: Control
var score_label: Label
var pct_label: Label
var progress_bar: ProgressBar
var ink_bar: ProgressBar
var ink_icon: Label
var chips: VBoxContainer
var notif: PanelContainer
var start_panel: Control
var pause_panel: Control
var summary_panel: Control
var banner: Label
var vignette: TextureRect
var confetti: CPUParticles2D
var question_panel: PanelContainer
var question_label: Label
var _chip_nodes := {}


func _init(p_run: RunScene) -> void:
	run = p_run
	name = "Hud"
	process_mode = Node.PROCESS_MODE_ALWAYS


func _ready() -> void:
	root = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	_build_overlays()
	_build_top()
	_build_ink()
	_build_chips()
	_build_notification()
	_build_question()
	banner = UiKit.outlined("", 64, UiKit.YELLOW, UiKit.RED_DARK)
	banner.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	banner.position.y = 230
	banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner.visible = false
	root.add_child(banner)
	_show_start()
	run.hud_update.connect(_refresh)
	run.popup.connect(_popup)
	run.effect_event.connect(_on_effect)
	run.banner.connect(_flash_banner)
	run.question.connect(_show_question)
	run.finished.connect(_show_summary)
	_set_playing_visible(false)


func _top_margin() -> float:
	var safe := DisplayServer.get_display_safe_area()
	var win := DisplayServer.window_get_size()
	if win.y <= 0:
		return 24.0
	return 24.0 + float(safe.position.y) * root.get_viewport_rect().size.y / float(win.y)


func _build_top() -> void:
	var bar := UiKit.hbox(14)
	bar.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	bar.offset_left = 20
	bar.offset_right = -20
	bar.offset_top = _top_margin()
	bar.name = "TopBar"
	root.add_child(bar)
	var score_box := UiKit.panel(Color(1, 1, 1, 0.92), 26)
	var sv := UiKit.vbox(0)
	score_label = UiKit.label("0", 44, UiKit.BLUE, UiKit.heavy())
	pct_label = UiKit.label("%0", 22, UiKit.MUTED)
	sv.add_child(score_label)
	sv.add_child(pct_label)
	score_box.add_child(sv)
	score_box.custom_minimum_size = Vector2(150, 0)
	(score_box.get_theme_stylebox("panel") as StyleBoxFlat).content_margin_top = 8
	(score_box.get_theme_stylebox("panel") as StyleBoxFlat).content_margin_bottom = 8
	bar.add_child(score_box)
	progress_bar = ProgressBar.new()
	progress_bar.show_percentage = false
	progress_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	progress_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	progress_bar.custom_minimum_size = Vector2(0, 30)
	var bg := UiKit.style(Color(1, 1, 1, 0.85), 15, 0.1, UiKit.INK, 3)
	bg.set_content_margin_all(0)
	var fill := UiKit.style(UiKit.YELLOW, 15, 0.0, UiKit.INK, 3)
	fill.set_content_margin_all(0)
	progress_bar.add_theme_stylebox_override("background", bg)
	progress_bar.add_theme_stylebox_override("fill", fill)
	progress_bar.max_value = 1.0
	bar.add_child(progress_bar)
	var pause := UiKit.button("II", UiKit.BLUE, UiKit.BLUE_DARK, Color.WHITE, 34)
	pause.custom_minimum_size = Vector2(96, 96)
	pause.pressed.connect(_pause)
	bar.add_child(pause)


## Mürekkep haznesi: kapaklı, pirinç uçlu bir kalem gövdesi gibi dolup boşalır.
func _build_ink() -> void:
	var box := UiKit.vbox(0)
	box.position = Vector2(30, _top_margin() + 140)
	box.name = "InkBox"
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	var cap := Panel.new()
	cap.custom_minimum_size = Vector2(46, 44)
	var cs := UiKit.style(Color("#1F3A93"), 20, 0.15)
	cs.corner_radius_bottom_left = 6
	cs.corner_radius_bottom_right = 6
	cap.add_theme_stylebox_override("panel", cs)
	box.add_child(cap)
	ink_bar = ProgressBar.new()
	ink_bar.fill_mode = ProgressBar.FILL_BOTTOM_TO_TOP
	ink_bar.show_percentage = false
	ink_bar.custom_minimum_size = Vector2(40, 250)
	ink_bar.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	ink_bar.max_value = 1.0
	ink_bar.value = 1.0
	var bg := UiKit.style(Color(1, 1, 1, 0.88), 6, 0.12, Color("#1F3A93"), 3)
	bg.set_content_margin_all(0)
	var fill := UiKit.style(Color("#1F3A93"), 4, 0.0)
	fill.set_content_margin_all(0)
	ink_bar.add_theme_stylebox_override("background", bg)
	ink_bar.add_theme_stylebox_override("fill", fill)
	box.add_child(ink_bar)
	var tip := Panel.new()
	tip.custom_minimum_size = Vector2(40, 30)
	var ts := UiKit.style(Color("#E7B65A"), 4, 0.0)
	ts.corner_radius_bottom_left = 20
	ts.corner_radius_bottom_right = 20
	tip.add_theme_stylebox_override("panel", ts)
	box.add_child(tip)
	ink_icon = UiKit.label("MÜREKKEP", 16, Color.WHITE, UiKit.heavy(), HORIZONTAL_ALIGNMENT_CENTER)
	ink_icon.autowrap_mode = TextServer.AUTOWRAP_OFF
	ink_icon.add_theme_constant_override("outline_size", 6)
	ink_icon.add_theme_color_override("font_outline_color", UiKit.INK)
	box.add_child(ink_icon)
	root.add_child(box)


func _build_chips() -> void:
	chips = UiKit.vbox(10)
	chips.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	chips.position = Vector2(root.get_viewport_rect().size.x - 170, _top_margin() + 150)
	chips.custom_minimum_size = Vector2(150, 0)
	root.add_child(chips)
	for k in [["scoreMultiplier", "effect_double", UiKit.YELLOW], ["slowMotion", "effect_focus", Color("#E8C9A0")],
			["reverseControls", "effect_reverse", Color("#D9C2FF")], ["shield", "effect_shield", Color("#BDEFFF")],
			["magnet", "effect_magnet", Color("#FFC9C9")], ["preview", "effect_preview", Color("#C4F2DC")],
			["wobble", "effect_wobble", Color("#D7F7C4")], ["sleep", "effect_sleep", Color("#E3DAFF")],
			["group", "effect_group", Color("#E6D4FF")], ["office", "effect_office", Color("#FFE7A8")],
			["gravity", "effect_gravity", Color("#D9C2FF")], ["ice", "effect_ice", Color("#CFF3FF")]]:
		var p := UiKit.panel(k[2], 22)
		var st := p.get_theme_stylebox("panel") as StyleBoxFlat
		st.content_margin_top = 6
		st.content_margin_bottom = 6
		p.add_child(UiKit.label(T.t(k[1]), 30, UiKit.INK, UiKit.heavy(), HORIZONTAL_ALIGNMENT_CENTER))
		p.visible = false
		chips.add_child(p)
		_chip_nodes[k[0]] = p


## Dizi maratonu (tünel görüş) ve parti (ekranı kaplayan konfeti) katmanları.
func _build_overlays() -> void:
	vignette = TextureRect.new()
	var gt := GradientTexture2D.new()
	gt.fill = GradientTexture2D.FILL_RADIAL
	gt.fill_from = Vector2(0.5, 0.5)
	gt.fill_to = Vector2(1.0, 0.5)
	var g := Gradient.new()
	g.set_color(0, Color(0, 0, 0, 0))
	g.set_color(1, Color(0.02, 0.0, 0.06, 1))
	g.add_point(0.45, Color(0, 0, 0, 0))
	g.add_point(0.8, Color(0.03, 0.0, 0.08, 0.95))
	gt.gradient = g
	vignette.texture = gt
	vignette.stretch_mode = TextureRect.STRETCH_SCALE
	vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vignette.modulate.a = 0.0
	root.add_child(vignette)
	var vp := root.get_viewport_rect().size
	confetti = CPUParticles2D.new()
	confetti.emitting = false
	confetti.amount = 260
	confetti.lifetime = 2.2
	confetti.position = Vector2(vp.x / 2.0, -20)
	confetti.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	confetti.emission_rect_extents = Vector2(vp.x / 2.0, 10)
	confetti.direction = Vector2(0, 1)
	confetti.spread = 25
	confetti.gravity = Vector2(0, 520)
	confetti.initial_velocity_min = 180
	confetti.initial_velocity_max = 420
	confetti.angular_velocity_min = -540
	confetti.angular_velocity_max = 540
	confetti.scale_amount_min = 10
	confetti.scale_amount_max = 22
	var cr := Gradient.new()
	cr.offsets = PackedFloat32Array([0.0, 0.25, 0.5, 0.75, 1.0])
	cr.colors = PackedColorArray([UiKit.YELLOW, Color("#FF5FA2"), UiKit.BLUE, UiKit.GREEN, UiKit.PURPLE])
	confetti.color_initial_ramp = cr
	root.add_child(confetti)


func _build_question() -> void:
	question_panel = UiKit.panel(UiKit.INK, 26)
	question_label = UiKit.label("", 44, Color.WHITE, UiKit.heavy(), HORIZONTAL_ALIGNMENT_CENTER)
	question_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	question_panel.add_child(question_label)
	question_panel.visible = false
	question_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(question_panel)


func _show_question(text: String) -> void:
	if text == "":
		if question_panel.visible:
			var tw := create_tween()
			tw.tween_property(question_panel, "modulate:a", 0.0, 0.2)
			tw.tween_callback(func() -> void: question_panel.visible = false)
		return
	question_label.text = text
	var vp := root.get_viewport_rect().size
	question_panel.visible = true
	question_panel.modulate.a = 1.0
	question_panel.reset_size()
	var w := maxf(question_panel.get_combined_minimum_size().x, 300.0)
	question_panel.size = Vector2(w, question_panel.get_combined_minimum_size().y)
	question_panel.position = Vector2((vp.x - w) / 2.0, _top_margin() + 96)
	question_panel.pivot_offset = question_panel.size / 2.0
	question_panel.scale = Vector2(0.6, 0.6)
	create_tween().tween_property(question_panel, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK)


func _build_notification() -> void:
	notif = UiKit.panel(Color.WHITE, 26)
	var h := UiKit.hbox(14)
	var dot := UiKit.label("•", 60, UiKit.RED)
	h.add_child(dot)
	var v := UiKit.vbox(0)
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.add_child(UiKit.label(T.t("notif_title"), 28, UiKit.INK, UiKit.heavy()))
	v.add_child(UiKit.label(T.t("notif_body"), 24, UiKit.MUTED))
	h.add_child(v)
	notif.add_child(h)
	notif.custom_minimum_size = Vector2(380, 0)
	notif.size = Vector2(380, 0)
	notif.visible = false
	root.add_child(notif)


func _set_playing_visible(v: bool) -> void:
	for n in ["TopBar", "InkBox"]:
		root.get_node(n).visible = v


func _refresh() -> void:
	var s := run.score
	score_label.text = str(roundi(s.raw_points()))
	var pct := 0 if s.max_points <= 0 else roundi(clampf(s.raw_points() / s.max_points * 100.0, 0, 100))
	pct_label.text = "%" + str(pct)
	progress_bar.value = run.progress()
	ink_bar.value = run.ink.fraction()
	var fill := ink_bar.get_theme_stylebox("fill") as StyleBoxFlat
	fill.bg_color = UiKit.RED if run.ink.is_low() else Color("#1F3A93")
	var e := run.effects
	_chip_nodes["scoreMultiplier"].visible = e.multiplier_left > 0.0
	_chip_nodes["slowMotion"].visible = e.slow_left > 0.0
	_chip_nodes["reverseControls"].visible = e.reversed()
	_chip_nodes["shield"].visible = e.shield > 0
	_chip_nodes["magnet"].visible = e.magnet_left > 0.0
	_chip_nodes["preview"].visible = e.preview_left > 0.0
	_chip_nodes["wobble"].visible = e.wobbly()
	_chip_nodes["sleep"].visible = e.asleep()
	_chip_nodes["group"].visible = run.director.group_left > 0.0
	_chip_nodes["office"].visible = run.director.office_left > 0.0
	_chip_nodes["gravity"].visible = run.tuki.zone == "gravity"
	_chip_nodes["ice"].visible = run.tuki.zone == "ice"
	var tunnel_a := float(run.cfg["effects"]["tunnelAlpha"])
	vignette.modulate.a = lerpf(vignette.modulate.a, tunnel_a if e.tunnel_left > 0.0 else 0.0, 0.12)
	confetti.emitting = e.confetti_left > 0.0
	if notif.visible and e.notification_left <= 0.0:
		notif.visible = false


func _on_effect(kind: String) -> void:
	match kind:
		"notification":
			notif.visible = true
			var vp := root.get_viewport_rect().size
			var left := randi() % 2 == 0
			notif.position = Vector2(24 if left else vp.x - 404, _top_margin() + 130)
			notif.modulate.a = 0.0
			create_tween().tween_property(notif, "modulate:a", 1.0, 0.15)
		"finalStretch":
			_flash_banner(T.t("final_stretch"), UiKit.YELLOW)


func _flash_banner(text: String, color: Color = UiKit.YELLOW) -> void:
	banner.text = text
	banner.add_theme_color_override("font_color", color)
	banner.visible = true
	banner.size.x = root.get_viewport_rect().size.x
	banner.position.x = 0
	banner.pivot_offset = Vector2(banner.size.x / 2.0, 40)
	banner.scale = Vector2(2.2, 2.2)
	banner.modulate.a = 1.0
	var tw := create_tween()
	tw.tween_property(banner, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK)
	tw.tween_interval(1.4)
	tw.tween_property(banner, "modulate:a", 0.0, 0.5)


func _popup(text: String, color: Color) -> void:
	var l := UiKit.outlined(text, 52, color, Color.WHITE)
	var vp := root.get_viewport_rect().size
	l.position = Vector2(vp.x / 2.0 - 120 + randf_range(-40, 40), vp.y * 0.52)
	l.custom_minimum_size = Vector2(240, 0)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(l)
	var tw := create_tween().set_parallel(true)
	tw.tween_property(l, "position:y", l.position.y - 150, 0.7)
	tw.tween_property(l, "modulate:a", 0.0, 0.7).set_delay(0.25)
	tw.chain().tween_callback(l.queue_free)


# ------------------------------------------------------------ paneller

func _overlay(dim := 0.45) -> Control:
	var o := ColorRect.new()
	o.color = Color(0.05, 0.08, 0.15, dim)
	o.set_anchors_preset(Control.PRESET_FULL_RECT)
	o.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(o)
	return o


func _center_panel(parent: Control, content: Control, bottom := false) -> PanelContainer:
	var center: Container = CenterContainer.new()
	if bottom:
		# alt kısma yasla: sahnedeki Tüki görünsün
		var vb := UiKit.vbox(0)
		vb.alignment = BoxContainer.ALIGNMENT_END
		center = vb
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	if bottom:
		center.offset_bottom = -36
	parent.add_child(center)
	var p := UiKit.panel(Color.WHITE, 40)
	p.custom_minimum_size = Vector2(min(620.0, root.get_viewport_rect().size.x - 48), 0)
	p.add_child(content)
	p.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	center.add_child(p)
	p.pivot_offset = p.custom_minimum_size / 2.0
	p.scale = Vector2(0.85, 0.85)
	p.modulate.a = 0.0
	var tw := p.create_tween().set_parallel(true)
	tw.tween_property(p, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK)
	tw.tween_property(p, "modulate:a", 1.0, 0.2)
	return p


func _show_start() -> void:
	start_panel = _overlay(0.25)
	var v := UiKit.vbox(14)
	var course := run.content.course(run.course_id)
	v.add_child(UiKit.label(course["code"] + " · " + run.theme["name"], 26, UiKit.MUTED))
	v.add_child(UiKit.label(Assessment.display_name(run.assessment), 64, UiKit.INK, UiKit.heavy()))
	v.add_child(UiKit.spacer(6))
	for line in [["←→", "ready_swipe_lr"], ["↑", "ready_swipe_up"], ["↓", "ready_swipe_down"]]:
		var h := UiKit.hbox(14)
		var icon := UiKit.label(line[0], 36, UiKit.BLUE, UiKit.heavy())
		icon.custom_minimum_size = Vector2(64, 0)
		h.add_child(icon)
		var l := UiKit.label(T.t(line[1]), 28)
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		h.add_child(l)
		v.add_child(h)
	v.add_child(UiKit.label(T.t("ready_ink"), 26, UiKit.RED))
	v.add_child(UiKit.spacer(10))
	var go := UiKit.primary(T.t("start"), 48)
	go.pressed.connect(func() -> void:
		hide_start()
		run.start())
	v.add_child(go)
	var back := UiKit.ghost(T.t("back"))
	back.pressed.connect(func() -> void: Game.goto("course", {"course": run.course_id}))
	v.add_child(back)
	_center_panel(start_panel, v, true)


func hide_start() -> void:
	if is_instance_valid(start_panel):
		start_panel.queue_free()
	_set_playing_visible(true)


func _pause() -> void:
	if run.state != RunScene.State.RUNNING or get_tree().paused:
		return
	get_tree().paused = true
	Sound.scratch(false)
	pause_panel = _overlay(0.55)
	var v := UiKit.vbox(18)
	v.add_child(UiKit.label(T.t("pause"), 64, UiKit.INK, UiKit.heavy(), HORIZONTAL_ALIGNMENT_CENTER))
	var resume := UiKit.primary(T.t("resume"))
	resume.pressed.connect(func() -> void:
		get_tree().paused = false
		Sound.scratch(true)
		pause_panel.queue_free())
	v.add_child(resume)
	var quit := UiKit.button(T.t("quit_exam"), UiKit.RED, UiKit.RED_DARK, Color.WHITE, 32)
	quit.pressed.connect(func() -> void:
		get_tree().paused = false
		Game.goto("course", {"course": run.course_id}))
	v.add_child(quit)
	v.add_child(UiKit.label(T.t("quit_warn"), 24, UiKit.MUTED, null, HORIZONTAL_ALIGNMENT_CENTER))
	_center_panel(pause_panel, v)


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED:
		if run and run.state == RunScene.State.RUNNING:
			_pause()


func _show_summary(outcome: Dictionary) -> void:
	_set_playing_visible(false)
	summary_panel = _overlay(0.5)
	var r: Dictionary = outcome["score"]
	var letter := run.content.grading.letter_for(float(r["score"])).symbol
	var v := UiKit.vbox(10)
	var title := T.t("ink_out") if r["inkDepleted"] else T.t("page_end")
	v.add_child(UiKit.label(title, 56, UiKit.RED if r["inkDepleted"] else UiKit.BLUE, UiKit.heavy()))
	var rows := [
		[T.t("row_collected"), "+%s" % _fmt(r["collected"]), UiKit.BLUE],
		[T.t("row_penalty"), "−%s" % _fmt(r["penalty"]), UiKit.RED],
		[T.t("row_max"), _fmt(r["max"]), UiKit.INK],
		[T.t("row_base"), _fmt(r["base"]), UiKit.INK],
	]
	if r.get("events", 0.0) != 0.0:
		var ev := float(r["events"])
		rows.append([T.t("row_events"), ("+%s" if ev > 0 else "−%s") % _fmt(absf(ev)), UiKit.GREEN_DARK if ev > 0 else UiKit.RED])
	if r["bonus"] > 0:
		rows.append([T.t("row_bonus"), "+%s" % _fmt(r["bonus"]), UiKit.GOLD])
	if r["clean"] > 0:
		rows.append([T.t("row_clean"), "+%s" % _fmt(r["clean"]), UiKit.GREEN])
	if r["capped"]:
		rows.append([T.t("row_cap"), "≤ 50", UiKit.RED])
	for row in rows:
		var h := UiKit.hbox()
		var k := UiKit.label(row[0], 28, UiKit.MUTED)
		k.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		h.add_child(k)
		h.add_child(UiKit.label(row[1], 32, row[2], UiKit.heavy()))
		v.add_child(h)
	v.add_child(HSeparator.new())
	var big := UiKit.hbox(20)
	var sv := UiKit.vbox(0)
	sv.add_child(UiKit.label(T.t("level_score"), 26, UiKit.MUTED))
	sv.add_child(UiKit.label(_fmt(r["score"]), 88, UiKit.INK, UiKit.heavy()))
	sv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	big.add_child(sv)
	var badge := UiKit.grade_badge(letter, 150)
	big.add_child(badge)
	v.add_child(big)
	var seed := int(run.level["seed"]) + int(outcome["collected"])
	v.add_child(UiKit.label("“%s”" % run.content.comment_for(letter, r["inkDepleted"], seed), 30, UiKit.RED, UiKit.bold()))
	if outcome.has("bossReaction") and outcome["bossReaction"] != "":
		v.add_child(UiKit.label(T.t("boss_" + outcome["bossReaction"]), 26, UiKit.RED_DARK, UiKit.heavy()))
	v.add_child(UiKit.spacer(8))
	var completion: Dictionary = outcome.get("completion", {})
	var btn := UiKit.primary(T.t("see_course_result") if not completion.is_empty() else T.t("continue"))
	btn.pressed.connect(func() -> void:
		if completion.is_empty():
			Game.goto("course", {"course": run.course_id})
		else:
			Game.goto("course_result", {"completion": completion}))
	v.add_child(btn)
	_center_panel(summary_panel, v)
	badge.pivot_offset = Vector2(75, 75)
	badge.scale = Vector2(2.6, 2.6)
	badge.modulate.a = 0.0
	var tw := badge.create_tween()
	tw.tween_interval(0.35)
	tw.tween_property(badge, "modulate:a", 1.0, 0.05)
	tw.parallel().tween_property(badge, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK)
	tw.tween_callback(func() -> void:
		Sound.play("stamp")
		Sound.vibrate("stamp"))


static func _fmt(v: float) -> String:
	return str(roundi(v)) if is_equal_approx(v, roundf(v)) else "%.1f" % v
