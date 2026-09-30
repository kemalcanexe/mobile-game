extends MenuScreen
## Ders seçimi (Ekle-Bırak haftası).

var selected: Array = []
var counter: Label
var confirm: Button
var _cards := {}


func _init() -> void:
	dim = 0.35


func build(v: VBoxContainer) -> void:
	var p := Game.progress
	var offer := p.offer()
	selected = offer["available"].slice(0, offer["max"])
	back_button(v)
	header(v, T.t("enroll_title"), T.t("enroll_sub") % p.semester.index)
	if offer["probation"]:
		var warn := UiKit.panel(Color("#FFE3E3"), 24)
		warn.add_child(UiKit.label(T.t("probation_hint") % offer["max"], 26, UiKit.RED_DARK))
		v.add_child(warn)
	for id in offer["available"]:
		v.add_child(_option(id, offer["retakes"].has(id)))
	counter = UiKit.outlined("", 28, Color.WHITE, UiKit.INK)
	counter.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(counter)
	confirm = UiKit.primary(T.t("enroll_confirm"), 44)
	confirm.pressed.connect(func() -> void:
		if Game.progress.enroll(selected):
			Game.goto("main"))
	v.add_child(confirm)
	_refresh()


func _option(id: String, retake: bool) -> Control:
	var course := Game.content.course(id)
	var card := UiKit.panel(Color.WHITE, 30)
	var h := UiKit.hbox(20)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var check := UiKit.label("", 60, UiKit.RED if retake else UiKit.BLUE, UiKit.heavy())
	check.custom_minimum_size = Vector2(70, 0)
	check.autowrap_mode = TextServer.AUTOWRAP_OFF
	h.add_child(check)
	var info := UiKit.vbox(0)
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_child(UiKit.label(course["code"], 40, UiKit.INK, UiKit.heavy()))
	info.add_child(UiKit.label('"%s" · %s' % [course["nickname"], T.t("credits") % int(course["credits"])], 24, UiKit.MUTED))
	if retake:
		info.add_child(UiKit.label(T.t("enroll_retake"), 24, UiKit.RED))
	h.add_child(info)
	card.add_child(h)
	_cards[id] = [card, check]
	UiKit.tap_card(card, func() -> void:
		if retake:
			return
		if selected.has(id):
			selected.erase(id)
		else:
			selected.append(id)
		_refresh())
	return card


func _refresh() -> void:
	var o := Game.progress.offer()
	var issues := Game.progress.check_enrollment(selected)
	for id in _cards:
		var on := selected.has(id)
		(_cards[id][1] as Label).text = "☑" if on else "☐"
		(_cards[id][0] as PanelContainer).modulate = Color.WHITE if on else Color(1, 1, 1, 0.7)
	counter.text = T.t("enroll_counter") % [selected.size(), o["min"], o["max"]]
	counter.add_theme_color_override("font_color", Color.WHITE if issues.is_empty() else Color("#FFB3B3"))
	confirm.disabled = not issues.is_empty() or o["available"].is_empty()
