class_name TukiModel
extends Node3D
## Tüki 2.0'ın görseli: tools/blender/tuki.py ile üretilen iskeletli model.
## Bacak yok; ucunun üstünde süzülür. Animasyonlar glTF'ten gelir, geçişler
## yumuşatılır; eğilme ve ezilme gibi anlık tepkiler burada kodla eklenir.

const SCENE := "res://assets/models/tuki/tuki.glb"
## Model Blender'da ~2,45 m; oyunda Tüki'nin boyu ~1,8 m.
const MODEL_SCALE := 0.74
const LOOPS := ["idle", "glide", "air", "slide", "victory", "sad", "wave"]
## Oyundaki poz adı → animasyon.
const POSES := {"idle": "idle", "run": "glide", "air": "air", "slide": "slide", "stumble": "stumble",
	"victory": "victory", "sad": "sad", "wave": "wave"}
const BLEND := 0.14

var pose := "idle"
var run_speed := 1.0
var lean := 0.0  # şerit değiştirirken yana yatma (-1..1)

var holder: Node3D
var anim: AnimationPlayer
var _current := ""
var _squash := 0.0
var _flash: StandardMaterial3D
var _meshes: Array[MeshInstance3D] = []


func _ready() -> void:
	holder = Node3D.new()
	add_child(holder)
	var model: Node3D = (load(SCENE) as PackedScene).instantiate()
	model.scale = Vector3.ONE * MODEL_SCALE
	# Blender'da yüz -Y'ye, glTF'te +Z'ye bakar; oyunda Tüki -Z'ye koşar.
	model.rotation.y = PI
	holder.add_child(model)
	anim = model.find_child("AnimationPlayer", true, false) as AnimationPlayer
	for n in LOOPS:
		if anim and anim.has_animation(n):
			anim.get_animation(n).loop_mode = Animation.LOOP_LINEAR
	_collect_meshes(model)
	_flash = StandardMaterial3D.new()
	_flash.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_flash.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_flash.albedo_color = Color(1.0, 0.3, 0.3, 0.0)
	_play("idle")


func _collect_meshes(n: Node) -> void:
	if n is MeshInstance3D:
		_meshes.append(n)
	for c in n.get_children():
		_collect_meshes(c)


func _play(name: String) -> void:
	if anim == null or name == _current or not anim.has_animation(name):
		return
	_current = name
	anim.play(name, BLEND)


## Poz adının modelde animasyonu var mı (testler ve ekranlar için).
func has_pose(name: String) -> bool:
	return anim != null and anim.has_animation(str(POSES.get(name, "")))


## Menü ve sonuç ekranları için: "victory", "sad", "wave" …
func emote(name: String) -> void:
	pose = name


## İniş/kalkışta ezilip uzama efekti.
func squash(amount: float) -> void:
	_squash = amount


func flash_hit() -> void:
	for m in _meshes:
		m.material_overlay = _flash
	_flash.albedo_color.a = 0.55
	var tw := create_tween()
	tw.tween_property(_flash, "albedo_color:a", 0.0, 0.35)
	tw.tween_callback(func() -> void:
		for m in _meshes:
			if is_instance_valid(m):
				m.material_overlay = null)


func _process(delta: float) -> void:
	_play(POSES.get(pose, "idle"))
	if anim:
		anim.speed_scale = run_speed if _current == "glide" else 1.0
	_squash = lerpf(_squash, 0.0, clampf(delta * 10.0, 0, 1))
	holder.scale = Vector3(1.0 + _squash * 0.35, 1.0 - _squash * 0.6, 1.0 + _squash * 0.35)
	# şerit değişiminde gövde yana yatar ve hafifçe o yöne döner
	var k := clampf(delta * 12.0, 0, 1)
	holder.rotation.z = lerpf(holder.rotation.z, -lean * 0.32, k)
	holder.rotation.y = lerpf(holder.rotation.y, -lean * 0.18, k)
