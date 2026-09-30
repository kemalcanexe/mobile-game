class_name LaneObject
extends Area3D
## Şeritteki nesne. Tüki'nin hitbox'ı ile örtüşünce koşu sahnesine bildirilir.

signal touched(obj: LaneObject)

var item: Dictionary
var code: String
## Plan olayındaki ek alanlar (soru kapısı cevabı vb.).
var extra: Dictionary = {}
var lane := 1
var resolved := false
var visual: Node3D
var spin := false
var _t := 0.0
var _box_size := Vector3.ONE
var _marker: Node3D
var _lane_w := 2.6
var _hop_t := 0.0
var _hopping := false

const HAZARDS := ["groundObstacle", "airObstacle", "wall", "distraction", "bug"]
const GOODS := ["collectible", "bonus", "powerUp"]


func setup(p_code: String, p_item: Dictionary, p_lane: int, lane_w: float) -> void:
	code = p_code
	item = p_item
	lane = p_lane
	_lane_w = lane_w
	collision_layer = 4
	collision_mask = 0
	monitoring = false
	var built := ItemFactory.build(item, lane_w, extra)
	visual = built["node"]
	spin = built["spin"]
	add_child(visual)
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	_box_size = built["size"]
	bs.size = _box_size
	cs.shape = bs
	cs.position = built["center"]
	add_child(cs)
	_t = randf() * TAU


func kind() -> String:
	return item["kind"]


func is_hazard() -> bool:
	return kind() in HAZARDS


func is_good() -> bool:
	return kind() in GOODS


## Syllabus: tehlikeli nesnenin üstünde kırmızı "!" ve yerde uyarı halkası.
func set_marked(on: bool) -> void:
	if on == (_marker != null) or resolved:
		return
	if not on:
		_marker.queue_free()
		_marker = null
		return
	_marker = Node3D.new()
	var bang := Models.label("!", 140, Color.WHITE, Color("#D12F2F"))
	bang.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	bang.no_depth_test = true
	bang.position.y = _box_size.y + 1.2
	_marker.add_child(bang)
	var ring := MeshInstance3D.new()
	var tm := TorusMesh.new()
	tm.inner_radius = 0.95
	tm.outer_radius = 1.15
	ring.mesh = tm
	ring.material_override = Models.mat(Color("#FF4D4D"), 0.5, 1.5)
	ring.position.y = 0.05
	ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_marker.add_child(ring)
	add_child(_marker)


func is_marked() -> bool:
	return _marker != null


func _process(delta: float) -> void:
	if not resolved and item.has("behavior"):
		_behave(delta)
	if spin and not resolved:
		_t += delta
		visual.rotation.y = _t * 2.2
		visual.position.y = sin(_t * 3.0) * 0.12


## CS bug'ı: aralıklarla komşu şeride sıçrar (önce titreyip uyarır).
func _behave(delta: float) -> void:
	var b: Dictionary = item["behavior"]
	if b["type"] != "laneHop" or _hopping:
		return
	_hop_t += delta
	var interval := float(b["interval"])
	var warn := float(b["warn"])
	if _hop_t > interval - warn:
		visual.rotation.z = sin(_hop_t * 60.0) * 0.12
	if _hop_t < interval:
		return
	_hop_t = 0.0
	var dir := 1 if lane == 0 else (-1 if lane == 2 else (1 if randi() % 2 == 0 else -1))
	lane += dir
	_hopping = true
	visual.rotation.z = 0.0
	var tw := create_tween().set_parallel(true)
	tw.tween_property(self, "position:x", (lane - 1) * _lane_w, float(b["hopTime"])).set_trans(Tween.TRANS_SINE)
	tw.tween_property(visual, "position:y", 0.6, float(b["hopTime"]) / 2.0)
	tw.chain().tween_property(visual, "position:y", 0.0, float(b["hopTime"]) / 2.0)
	tw.chain().tween_callback(func() -> void: _hopping = false)
	if get_viewport() and get_viewport().get_camera_3d() and global_position.distance_to(get_viewport().get_camera_3d().global_position) < 30.0:
		Sound.play("bug", randf_range(0.9, 1.2))


## Toplanınca: büyüyüp kaybolur.
func pop() -> void:
	resolved = true
	var tw := create_tween().set_parallel(true)
	tw.tween_property(visual, "scale", Vector3.ONE * 1.8, 0.18)
	tw.tween_property(visual, "position:y", visual.position.y + 1.2, 0.18)
	tw.chain().tween_callback(queue_free)


## Çarpılınca: görsel fizik gövdesine dönüşüp savrulur (Jolt).
func knock(impulse: Vector3) -> void:
	resolved = true
	var rb := RigidBody3D.new()
	rb.collision_layer = 8
	rb.collision_mask = 1 | 8
	rb.mass = 3.0
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = _box_size.clamp(Vector3.ONE * 0.3, Vector3(4, 3, 3))
	cs.shape = bs
	cs.position = Vector3(0, _box_size.y / 2.0, 0)
	rb.add_child(cs)
	var world_xf := global_transform
	get_parent().add_child(rb)
	rb.global_transform = world_xf
	visual.reparent(rb, false)
	rb.apply_central_impulse(impulse * rb.mass)
	rb.apply_torque_impulse(Vector3(randf_range(-6, 6), randf_range(-4, 4), randf_range(-6, 6)))
	get_tree().create_timer(2.5).timeout.connect(rb.queue_free)
	queue_free()
