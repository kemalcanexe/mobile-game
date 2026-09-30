class_name Tuki
extends CharacterBody3D
## Oyuncu: şerit değiştirme, gerçek yerçekimli zıplama, kayma, fast-fall.
## Çarpışmalar geometriktir: zıplayınca yer engelinin üstünden, kayınca hava
## engelinin altından geçilir.

signal landed

var lane := 1
var target_lane := 1
var lane_w := 2.6
var lane_time := 0.13
var gravity := 40.0
var jump_velocity := 13.0
var fast_fall_speed := 32.0
var slide_time := 0.65
var stumble_time := 0.4
var forward_speed := 0.0

var sliding := false
var _slide_left := 0.0
var _stumble_left := 0.0
var _was_on_floor := true
var _from_x := 0.0
var _lane_t := 1.0

var model: TukiModel
var body_shape: CollisionShape3D
var hitbox: Area3D
var hit_shape: CollisionShape3D
var stand_height := 1.7
var slide_height := 0.7
var radius := 0.38
var shield_radius := 1.25

## Tema bölgesi: "" | "gravity" (ay yerçekimi, kontroller ters) | "ice" (kayarak şerit değişimi).
var zone := ""
var gravity_scale := 1.0
var ice_lane_factor := 2.6
var zone_gravity_scale := 0.55
var lantern: OmniLight3D

var _shield: MeshInstance3D
var _magnet_ring: MeshInstance3D
var _status: Label3D


func configure(cfg: Dictionary) -> void:
	var p: Dictionary = cfg["player"]
	lane_w = float(cfg["laneWidth"])
	lane_time = float(p["laneChangeTime"])
	var h := float(p["jumpHeight"])
	var air := float(p["jumpAirTime"])
	# t_havada = 2·v0/g ve h = v0²/2g  ⇒  g = 8h/t², v0 = 4h/t
	gravity = 8.0 * h / (air * air)
	jump_velocity = 4.0 * h / air
	fast_fall_speed = float(p["fastFallSpeed"])
	slide_time = float(p["slideTime"])
	stumble_time = float(p["stumbleTime"])
	stand_height = float(p["height"])
	slide_height = float(p["slideHeight"])
	radius = float(p["radius"])


func _ready() -> void:
	collision_layer = 2
	collision_mask = 1
	floor_snap_length = 0.3
	body_shape = CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = radius
	cap.height = stand_height
	body_shape.shape = cap
	body_shape.position.y = stand_height / 2.0
	add_child(body_shape)
	hitbox = Area3D.new()
	hitbox.collision_layer = 0
	hitbox.collision_mask = 4
	hitbox.monitorable = false
	hit_shape = CollisionShape3D.new()
	var hcap := CapsuleShape3D.new()
	hcap.radius = radius * 0.8
	hcap.height = stand_height
	hit_shape.shape = hcap
	hit_shape.position.y = stand_height / 2.0
	hitbox.add_child(hit_shape)
	add_child(hitbox)
	model = TukiModel.new()
	add_child(model)
	model.rotation.y = 0.0
	_build_extras()


## Kalkan balonu, mıknatıs halkası ve baş üstü durum yazısı.
func _build_extras() -> void:
	_shield = MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = shield_radius
	sm.height = shield_radius * 2.0
	_shield.mesh = sm
	var m := StandardMaterial3D.new()
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.albedo_color = Color(0.3, 0.85, 1.0, 0.22)
	m.rim_enabled = true
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	_shield.material_override = m
	_shield.position.y = stand_height * 0.6
	_shield.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_shield.visible = false
	add_child(_shield)
	_magnet_ring = MeshInstance3D.new()
	var tm := TorusMesh.new()
	tm.inner_radius = 0.9
	tm.outer_radius = 1.05
	_magnet_ring.mesh = tm
	_magnet_ring.material_override = Models.mat(Color("#E23B3B"), 0.4, 1.2)
	_magnet_ring.position.y = 0.08
	_magnet_ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_magnet_ring.visible = false
	add_child(_magnet_ring)
	_status = Models.label("", 64, Color.WHITE, Color(0.1, 0.1, 0.2, 0.8))
	_status.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_status.position.y = stand_height + 0.9
	_status.no_depth_test = true
	add_child(_status)
	lantern = OmniLight3D.new()
	lantern.light_color = Color("#FFE2A8")
	lantern.light_energy = 0.0
	lantern.omni_range = 10.0
	lantern.position = Vector3(0, 2.4, 0.6)
	add_child(lantern)


func set_zone(z: String) -> void:
	zone = z
	gravity_scale = zone_gravity_scale if z == "gravity" else 1.0


## Rampadan fırlama: normal zıplamanın [param factor] katı hızla.
func launch(factor: float) -> void:
	_end_slide()
	velocity.y = jump_velocity * factor
	model.squash(0.35)


func set_shield(on: bool) -> void:
	_shield.visible = on
	if on:
		_shield.scale = Vector3.ONE * 0.2
		create_tween().tween_property(_shield, "scale", Vector3.ONE, 0.25).set_trans(Tween.TRANS_BACK)


func has_shield_visual() -> bool:
	return _shield.visible


func set_magnet(on: bool) -> void:
	_magnet_ring.visible = on


func set_status(text: String, color := Color.WHITE) -> void:
	_status.text = text
	_status.modulate = color


func lane_x(i: int) -> float:
	return (i - 1) * lane_w


func is_airborne() -> bool:
	return not is_on_floor()


## Hızlı çift swipe iki şerit atlatır.
func change_lane(delta: int) -> bool:
	var next := clampi(target_lane + delta, 0, 2)
	if next != target_lane:
		force_lane(next)
	return true


func force_lane(i: int) -> void:
	_from_x = position.x
	target_lane = clampi(i, 0, 2)
	_lane_t = 0.0


## Havadaysa false (input buffer inişte tekrar dener).
func try_jump() -> bool:
	if not is_on_floor():
		return false
	_end_slide()
	velocity.y = jump_velocity
	model.squash(0.25)
	return true


## Yerdeyse kayar; havadaysa hızla iner ve kayarak yere değer.
func slide_or_fast_fall() -> bool:
	if not is_on_floor():
		velocity.y = -fast_fall_speed
	_start_slide()
	return true


func stumble() -> void:
	_stumble_left = stumble_time
	model.flash_hit()


func _start_slide() -> void:
	sliding = true
	_slide_left = slide_time
	_set_height(slide_height)


func _end_slide() -> void:
	if sliding:
		sliding = false
		_set_height(stand_height)


func _set_height(h: float) -> void:
	(body_shape.shape as CapsuleShape3D).height = maxf(h, radius * 2.0)
	body_shape.position.y = maxf(h, radius * 2.0) / 2.0
	(hit_shape.shape as CapsuleShape3D).height = maxf(h, radius * 1.6)
	hit_shape.position.y = maxf(h, radius * 1.6) / 2.0


func _physics_process(delta: float) -> void:
	# yatay: hedef şeride yumuşak geçiş (ease-out)
	if _lane_t < 1.0:
		var lt := lane_time * (ice_lane_factor if zone == "ice" else 1.0)
		_lane_t = minf(1.0, _lane_t + delta / lt)
		var t := 1.0 - pow(1.0 - _lane_t, 3.0)
		if zone == "ice":
			# buzda momentum: hedefi biraz geçip geri kayar
			var c := 1.9
			t = 1.0 + (c + 1.0) * pow(_lane_t - 1.0, 3.0) + c * pow(_lane_t - 1.0, 2.0)
		position.x = lerpf(_from_x, lane_x(target_lane), t)
		if _lane_t >= 1.0:
			lane = target_lane
	else:
		position.x = lane_x(target_lane)
	# dikey: yerçekimi
	if not is_on_floor():
		velocity.y -= gravity * gravity_scale * delta
	velocity.x = 0.0
	velocity.z = -forward_speed
	move_and_slide()
	if is_on_floor() and not _was_on_floor:
		model.squash(0.3)
		landed.emit()
	_was_on_floor = is_on_floor()
	if sliding:
		_slide_left -= delta
		if _slide_left <= 0.0:
			_end_slide()
	if _stumble_left > 0.0:
		_stumble_left -= delta
	if _magnet_ring.visible:
		_magnet_ring.rotate_y(delta * 6.0)
		_magnet_ring.scale = Vector3.ONE * (1.0 + 0.08 * sin(Time.get_ticks_msec() * 0.01))
	if _shield.visible:
		_shield.rotate_y(delta * 1.5)
	# animasyon pozu
	model.run_speed = clampf(forward_speed / 15.0, 0.6, 1.8)
	var dx := lane_x(target_lane) - position.x
	model.lean = clampf(dx / lane_w, -1.0, 1.0) if _lane_t < 1.0 else 0.0
	if forward_speed <= 0.0:
		model.pose = "idle"
	elif _stumble_left > 0.0:
		model.pose = "stumble"
	elif sliding:
		model.pose = "slide"
	elif not is_on_floor():
		model.pose = "air"
	else:
		model.pose = "run"
