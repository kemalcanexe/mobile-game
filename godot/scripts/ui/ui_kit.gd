class_name UiKit
## Mobil oyun arayüzü yapı taşları: tombul butonlar, yuvarlak paneller.

const BLUE := Color("#2E6BFF")
const BLUE_DARK := Color("#1E4FD1")
const YELLOW := Color("#FFD23F")
const YELLOW_DARK := Color("#E0A800")
const RED := Color("#FF4D4D")
const RED_DARK := Color("#D12F2F")
const GREEN := Color("#2BC48A")
const GREEN_DARK := Color("#1C9467")
const PURPLE := Color("#8B3DFF")
const INK := Color("#1E2A3A")
const MUTED := Color("#6B7A90")
const PANEL := Color("#FFFFFF")
const PANEL_SOFT := Color("#F2F6FF")
const GOLD := Color("#F5B700")

static var _font: FontFile
static var _bold: FontVariation
static var _heavy: FontVariation


static func font() -> FontFile:
	if _font == null:
		_font = load("res://assets/fonts/Baloo2.ttf")
		# Baloo 2'de olmayan semboller (☑ ⚠ ★ …) için yedek font
		_font.fallbacks = [load("res://assets/fonts/NotoSansSymbols2.ttf")]
	return _font


static func weight(w: int) -> FontVariation:
	var fv := FontVariation.new()
	fv.base_font = font()
	var wght := TextServerManager.get_primary_interface().name_to_tag("wght")
	fv.variation_opentype = {wght: w}
	return fv


static func bold() -> FontVariation:
	if _bold == null:
		_bold = weight(700)
	return _bold


static func heavy() -> FontVariation:
	if _heavy == null:
		_heavy = weight(800)
	return _heavy


static func label(text: String, size := 28, color := INK, f: Font = null, align := HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_override("font", f if f != null else bold())
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.horizontal_alignment = align
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l


## Beyaz gölgeli etiket (3D sahne üstünde okunur).
static func outlined(text: String, size := 40, color := Color.WHITE, outline := INK) -> Label:
	var l := label(text, size, color, heavy())
	l.add_theme_constant_override("outline_size", maxi(6, size / 6))
	l.add_theme_color_override("font_outline_color", outline)
	return l


static func style(bg: Color, radius := 28, shadow := 0.18, border := Color(0, 0, 0, 0), border_w := 0) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.set_corner_radius_all(radius)
	s.shadow_color = Color(0, 0, 0, shadow)
	s.shadow_size = 10 if shadow > 0 else 0
	s.shadow_offset = Vector2(0, 6)
	s.content_margin_left = 28
	s.content_margin_right = 28
	s.content_margin_top = 22
	s.content_margin_bottom = 22
	if border_w > 0:
		s.border_color = border
		s.set_border_width_all(border_w)
	return s


static func panel(bg := PANEL, radius := 32) -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", style(bg, radius))
	return p


## Alt kenarı koyu, basınca içeri giren tombul buton.
static func button(text: String, color := YELLOW, dark := YELLOW_DARK, text_color := INK, size := 40) -> Button:
	var b := Button.new()
	b.text = text
	b.add_theme_font_override("font", heavy())
	b.add_theme_font_size_override("font_size", size)
	for st in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		b.add_theme_color_override(st, text_color)
	b.add_theme_color_override("font_disabled_color", Color(text_color, 0.5))
	var normal := style(color, 30, 0.0)
	normal.border_width_bottom = 10
	normal.border_color = dark
	normal.content_margin_top = 18
	normal.content_margin_bottom = 14
	var hover := normal.duplicate()
	hover.bg_color = color.lightened(0.08)
	var pressed := normal.duplicate()
	pressed.border_width_bottom = 3
	pressed.content_margin_top = 25
	pressed.bg_color = color.darkened(0.05)
	var disabled := normal.duplicate()
	disabled.bg_color = Color(color, 0.45)
	disabled.border_color = Color(dark, 0.45)
	b.add_theme_stylebox_override("normal", normal)
	b.add_theme_stylebox_override("hover", hover)
	b.add_theme_stylebox_override("pressed", pressed)
	b.add_theme_stylebox_override("focus", hover)
	b.add_theme_stylebox_override("disabled", disabled)
	b.custom_minimum_size = Vector2(0, size * 2.3)
	return b


static func primary(text: String, size := 40) -> Button:
	return button(text, YELLOW, YELLOW_DARK, INK, size)


static func blue(text: String, size := 36) -> Button:
	return button(text, BLUE, BLUE_DARK, Color.WHITE, size)


static func ghost(text: String, size := 28) -> Button:
	var b := Button.new()
	b.text = text
	b.flat = true
	b.add_theme_font_override("font", bold())
	b.add_theme_font_size_override("font_size", size)
	b.add_theme_color_override("font_color", MUTED)
	return b


## Harf notu rozeti: renk nota göre.
static func grade_color(letter: String) -> Color:
	match letter.substr(0, 1):
		"A":
			return GREEN
		"B":
			return BLUE
		"C":
			return YELLOW_DARK
		"D":
			return Color("#FF8A3D")
		_:
			return RED


static func grade_badge(letter: String, size := 120) -> PanelContainer:
	var p := PanelContainer.new()
	var s := style(grade_color(letter), int(size / 2.0), 0.2, Color.WHITE, int(size / 16.0))
	s.set_content_margin_all(0)
	p.add_theme_stylebox_override("panel", s)
	p.custom_minimum_size = Vector2(size, size)
	p.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	p.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var l := outlined(letter.replace("-", "−"), int(size * 0.5), Color.WHITE, Color(0, 0, 0, 0.35))
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	p.add_child(l)
	return p


static func vbox(sep := 16) -> VBoxContainer:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", sep)
	return v


static func hbox(sep := 16) -> HBoxContainer:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", sep)
	# Yatay kutuda genişlemeyen etiketler satır kaydırırsa harf harf kırılır.
	h.child_entered_tree.connect(func(n: Node) -> void:
		if n is Label:
			(func() -> void:
				if is_instance_valid(n) and not (n.size_flags_horizontal & Control.SIZE_EXPAND):
					n.autowrap_mode = TextServer.AUTOWRAP_OFF).call_deferred())
	return h


static func margin(child: Control, l := 32, t := 32, r := 32, b := 32) -> MarginContainer:
	var m := MarginContainer.new()
	m.add_theme_constant_override("margin_left", l)
	m.add_theme_constant_override("margin_top", t)
	m.add_theme_constant_override("margin_right", r)
	m.add_theme_constant_override("margin_bottom", b)
	m.add_child(child)
	return m


static func spacer(h := 0.0) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(0, h)
	if h == 0.0:
		c.size_flags_vertical = Control.SIZE_EXPAND_FILL
	return c


## Basınca hafif zıplama animasyonu.
static func juicy(b: Button) -> void:
	b.pivot_offset = b.size / 2.0
	b.pressed.connect(func() -> void:
		b.pivot_offset = b.size / 2.0
		var tw := b.create_tween()
		tw.tween_property(b, "scale", Vector2(1.06, 1.06), 0.06)
		tw.tween_property(b, "scale", Vector2.ONE, 0.1))


## Paneli dokunulabilir kart yapar. Kaydırma hareketi dokunuş sayılmaz.
static func tap_card(card: Control, on_tap: Callable) -> void:
	card.mouse_filter = Control.MOUSE_FILTER_PASS
	var start := [Vector2.ZERO]
	card.gui_input.connect(func(e: InputEvent) -> void:
		if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT:
			if e.pressed:
				start[0] = e.position
			elif e.position.distance_to(start[0]) < 24.0:
				card.pivot_offset = card.size / 2.0
				var tw := card.create_tween()
				tw.tween_property(card, "scale", Vector2(0.97, 0.97), 0.05)
				tw.tween_property(card, "scale", Vector2.ONE, 0.08)
				tw.tween_callback(on_tap))
