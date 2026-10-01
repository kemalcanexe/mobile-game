extends Node
## Uygulama durumu: içerik, ilerleme ve ekranlar arası geçiş.

var content: Content
var progress: Progress
## Açılacak ekrana verilen parametreler.
var params := {}
## Ekran geçişinde mürekkep lekesi (üstte ayrı katman).
var _wipe: ColorRect
var _busy := false
const WIPE_TIME := 0.28


func _ready() -> void:
	content = Content.load_all()
	for e in content.errors:
		push_error(e)
	progress = Progress.new(content)
	progress.load_save()
	var layer := CanvasLayer.new()
	layer.layer = 120
	add_child(layer)
	_wipe = ColorRect.new()
	_wipe.set_anchors_preset(Control.PRESET_FULL_RECT)
	_wipe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sm := ShaderMaterial.new()
	sm.shader = load("res://assets/shaders/ink_wipe.gdshader")
	_wipe.material = sm
	_wipe.visible = false
	layer.add_child(_wipe)


## Ekran değiştirir: mürekkep lekesi ekranı kaplar, sahne değişir, leke çekilir.
func goto(scene: String, p_params := {}) -> void:
	params = p_params
	var path := "res://scenes/%s.tscn" % scene
	if _wipe == null or _busy or not is_inside_tree():
		get_tree().change_scene_to_file(path)
		return
	_busy = true
	var vp := get_viewport().get_visible_rect().size
	var sm := _wipe.material as ShaderMaterial
	sm.set_shader_parameter("aspect", vp.x / maxf(vp.y, 1.0))
	sm.set_shader_parameter("progress", 0.0)
	_wipe.visible = true
	_wipe.mouse_filter = Control.MOUSE_FILTER_STOP
	var tw := create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_method(func(v: float) -> void: sm.set_shader_parameter("progress", v), 0.0, 1.0, WIPE_TIME).set_ease(Tween.EASE_IN)
	tw.tween_callback(func() -> void:
		get_tree().paused = false
		get_tree().change_scene_to_file(path))
	tw.tween_interval(0.08)
	tw.tween_method(func(v: float) -> void: sm.set_shader_parameter("progress", v), 1.0, 0.0, WIPE_TIME).set_ease(Tween.EASE_OUT)
	tw.tween_callback(func() -> void:
		_wipe.visible = false
		_wipe.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_busy = false)
