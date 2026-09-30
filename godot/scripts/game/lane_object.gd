class_name LaneObject
extends Area3D
## Şeritteki nesne. Tüki'nin hitbox'ı ile örtüşünce koşu sahnesine bildirilir.

signal touched(obj: LaneObject)

var item: Dictionary
var code: String
var lane := 1
var resolved := false
var visual: Node3D
var spin := false
var _t := 0.0
var _box_size := Vector3.ONE


func setup(p_code: String, p_item: Dictionary, p_lane: int, lane_w: float) -> void:
	code = p_code
	item = p_item
	lane = p_lane
	collision_layer = 4
	collision_mask = 0
	monitoring = false
	var built := ItemFactory.build(item, lane_w)
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


func _process(delta: float) -> void:
	if spin and not resolved:
		_t += delta
		visual.rotation.y = _t * 2.2
		visual.position.y = sin(_t * 3.0) * 0.12


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
