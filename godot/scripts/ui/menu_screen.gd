class_name MenuScreen
extends Node3D
## Menü ekranlarının tabanı: arkada canlı 3D kampüs (Tüki bekler, kamera
## yavaşça döner), önde kaydırılabilir arayüz.

var theme_id := "calc101"
## Arayüz başlamadan önce 3D sahne için bırakılan boşluk (Tüki görünsün).
var hero_space := 0.0
var dim := 0.0
var content_box: VBoxContainer
var ui_root: Control
var tuki_model: TukiModel
var _cam: Camera3D
var _t := 0.0


func _ready() -> void:
	Sound.music("menu")
	Sound.scratch(false)
	Sound.set_night(false)
	_build_backdrop()
	var layer := CanvasLayer.new()
	add_child(layer)
	ui_root = Control.new()
	ui_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(ui_root)
	if dim > 0.0:
		var shade := ColorRect.new()
		shade.color = Color(0.93, 0.95, 1.0, dim)
		shade.set_anchors_preset(Control.PRESET_FULL_RECT)
		shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ui_root.add_child(shade)
	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	ui_root.add_child(scroll)
	content_box = UiKit.vbox(22)
	content_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var m := UiKit.margin(content_box, 28, int(_safe_top()) + 20, 28, 48)
	m.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(m)
	if hero_space > 0.0:
		content_box.add_child(UiKit.spacer(hero_space))
	build(content_box)
	_animate_in()


## Alt sınıflar içeriği burada kurar.
func build(_v: VBoxContainer) -> void:
	pass


func _safe_top() -> float:
	var safe := DisplayServer.get_display_safe_area()
	var win := DisplayServer.window_get_size()
	if win.y <= 0:
		return 0.0
	return float(safe.position.y) * get_viewport().get_visible_rect().size.y / float(win.y)


func _build_backdrop() -> void:
	var cfg := Game.content.world_cfg
	var theme: Dictionary = cfg["themes"].get(theme_id, cfg["themes"]["calc101"])
	var we := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var sm := ProceduralSkyMaterial.new()
	sm.sky_top_color = Color(theme["skyTop"])
	sm.sky_horizon_color = Color(theme["skyHorizon"])
	sm.ground_horizon_color = Color(theme["skyHorizon"])
	sky.sky_material = sm
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(theme["skyHorizon"]).lerp(Color("#FFF6EA"), 0.75)
	env.ambient_light_energy = float(theme["ambient"])
	env.fog_enabled = true
	env.fog_light_color = Color(theme["fog"])
	env.fog_density = 0.004
	we.environment = env
	add_child(we)
	var sun := DirectionalLight3D.new()
	sun.light_color = Color(theme["sunColor"])
	sun.light_energy = float(theme["sunEnergy"])
	sun.rotation_degrees = Vector3(float(theme["sunPitch"]), 35, 0)
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 40.0
	add_child(sun)
	var campus := Campus.new()
	campus.setup(theme, cfg)
	add_child(campus)
	campus.update_for(8.0)
	var holder := Node3D.new()
	add_child(holder)
	tuki_model = TukiModel.new()
	holder.add_child(tuki_model)
	holder.position = Vector3(0, 0.02, -2.0)
	_cam = Camera3D.new()
	_cam.fov = 55
	add_child(_cam)
	_place_cam()


func _place_cam() -> void:
	var a := sin(_t * 0.25) * 0.45
	var target := Vector3(0, 1.1, -2.0)
	_cam.position = target + Vector3(sin(a) * 6.2, 1.6, -cos(a) * 6.2)
	# Tüki ekranın üst kısmında kalsın: bakış noktası aşağıda
	_cam.look_at(target + Vector3(0, -2.2 if hero_space > 0.0 else -0.4, 0))


func _process(delta: float) -> void:
	_t += delta
	_place_cam()


func _animate_in() -> void:
	content_box.modulate.a = 0.0
	content_box.position.y += 30
	var tw := create_tween().set_parallel(true)
	tw.tween_property(content_box, "modulate:a", 1.0, 0.25)
	tw.tween_property(content_box, "position:y", content_box.position.y - 30, 0.3).set_trans(Tween.TRANS_CUBIC)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		go_back()


## Android geri tuşu / ekrandaki geri butonu.
func go_back() -> void:
	Game.goto("main")


func back_button(v: VBoxContainer) -> void:
	var b := UiKit.ghost(T.t("back"), 30)
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.add_theme_color_override("font_color", UiKit.INK)
	b.pressed.connect(go_back)
	v.add_child(b)


## Başlık + alt başlık (3D sahne üstünde okunur).
func header(v: VBoxContainer, title: String, subtitle := "") -> void:
	v.add_child(UiKit.outlined(title, 64, Color.WHITE, UiKit.BLUE_DARK))
	if subtitle != "":
		v.add_child(UiKit.outlined(subtitle, 28, Color.WHITE, UiKit.INK))


## İki sütunlu satır: sol etiket genişler.
func row(cells: Array, sizes: Array, colors: Array = [], fonts: Array = []) -> HBoxContainer:
	var h := UiKit.hbox(8)
	for i in cells.size():
		var col: Color = colors[i] if i < colors.size() else UiKit.INK
		var f: Font = fonts[i] if i < fonts.size() else UiKit.bold()
		var l := UiKit.label(str(cells[i]), 28, col, f, HORIZONTAL_ALIGNMENT_RIGHT if i == cells.size() - 1 else HORIZONTAL_ALIGNMENT_LEFT)
		l.autowrap_mode = TextServer.AUTOWRAP_OFF
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		l.size_flags_stretch_ratio = float(sizes[i])
		l.clip_text = true
		h.add_child(l)
	return h


static func fmt(v: float) -> String:
	return str(roundi(v)) if is_equal_approx(v, roundf(v)) else "%.1f" % v
