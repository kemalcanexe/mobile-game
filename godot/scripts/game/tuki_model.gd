class_name TukiModel
extends Node3D
## Tüki'nin prosedürel 3D modeli ve animasyonları: kapaklı tükenmez gövde,
## iri gözler, kollar, spor ayakkabılı bacaklar.

const INK := Color("#1F3A93")
const INK_LIGHT := Color("#5B7FE0")
const BODY := Color("#F7F9FF")
const SHOE := Color("#FF4D4D")

var pose := "idle"  # idle | run | air | slide | stumble
var run_speed := 1.0
var lean := 0.0  # şerit değiştirirken yana yatma (-1..1)
var _t := 0.0
var _blink := 0.0
var _squash := 0.0

var body: Node3D
var leg_l: Node3D
var leg_r: Node3D
var arm_l: Node3D
var arm_r: Node3D
var eyes: Array[Node3D] = []
var _body_mat: StandardMaterial3D


func _ready() -> void:
	body = Node3D.new()
	body.name = "Body"
	add_child(body)
	_body_mat = Models.mat(BODY, 0.35)
	_body_mat.metallic_specular = 0.8
	# gövde
	_cyl(body, 0.27, 0.27, 1.05, Vector3(0, 1.05, 0), _body_mat)
	# içindeki mürekkep haznesi (yarı saydam gövde hissi için ince mavi çubuk görünür şerit)
	_cyl(body, 0.285, 0.285, 0.12, Vector3(0, 0.62, 0), Models.mat(INK_LIGHT, 0.5))
	# tutma yeri (kabartmalı)
	for k in 3:
		_cyl(body, 0.29, 0.29, 0.05, Vector3(0, 0.72 + k * 0.08, 0), Models.mat(INK_LIGHT.lightened(0.3), 0.6))
	# kapak ve klips
	_cyl(body, 0.3, 0.29, 0.38, Vector3(0, 1.74, 0), Models.mat(INK, 0.4))
	var dome := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 0.3
	sm.height = 0.3
	sm.is_hemisphere = true
	dome.mesh = sm
	dome.material_override = Models.mat(INK, 0.4)
	dome.position = Vector3(0, 1.93, 0)
	body.add_child(dome)
	var clip := Models.box(Vector3(0.07, 0.42, 0.06), INK.darkened(0.2), Vector3(0, 1.62, 0.33))
	clip.material_override = Models.mat(Color("#C9D3F2"), 0.25)
	clip.material_override.metallic = 0.9
	body.add_child(clip)
	# uç (aşağıda, bacakların arasında)
	var tip := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.27
	cm.bottom_radius = 0.05
	cm.height = 0.22
	tip.mesh = cm
	tip.material_override = Models.mat(Color("#FFD23F"), 0.3)
	tip.position = Vector3(0, 0.42, 0)
	body.add_child(tip)
	# yüz: koşu yönüne (-z) bakar
	for sx in [-1.0, 1.0]:
		var eye := Node3D.new()
		eye.position = Vector3(sx * 0.115, 1.3, -0.235)
		var white := MeshInstance3D.new()
		var ws := SphereMesh.new()
		ws.radius = 0.1
		ws.height = 0.2
		white.mesh = ws
		white.scale = Vector3(1, 1.15, 0.6)
		white.material_override = Models.mat(Color.WHITE, 0.25)
		eye.add_child(white)
		var pupil := MeshInstance3D.new()
		var ps := SphereMesh.new()
		ps.radius = 0.06
		ps.height = 0.12
		pupil.mesh = ps
		pupil.scale = Vector3(1, 1.1, 0.5)
		pupil.material_override = Models.mat(Color("#1E2A3A"), 0.15)
		pupil.position = Vector3(sx * -0.01, -0.01, -0.05)
		eye.add_child(pupil)
		var shine := MeshInstance3D.new()
		var hs := SphereMesh.new()
		hs.radius = 0.02
		hs.height = 0.04
		shine.mesh = hs
		shine.material_override = Models.mat(Color.WHITE, 0.1, 0.6)
		shine.position = Vector3(0.02, 0.025, -0.08)
		eye.add_child(shine)
		body.add_child(eye)
		eyes.append(eye)
		var cheek := MeshInstance3D.new()
		var cs := SphereMesh.new()
		cs.radius = 0.05
		cs.height = 0.1
		cheek.mesh = cs
		cheek.scale = Vector3(1.3, 0.7, 0.4)
		cheek.material_override = Models.mat(Color("#FF9DB0"), 0.6)
		cheek.position = Vector3(sx * 0.19, 1.17, -0.24)
		body.add_child(cheek)
	# gülümseme: yay boyunca küçük küreler
	for k in 7:
		var a := lerpf(-0.9, 0.9, k / 6.0)
		var dot := MeshInstance3D.new()
		var ds := SphereMesh.new()
		ds.radius = 0.018
		ds.height = 0.036
		dot.mesh = ds
		dot.material_override = Models.mat(Color("#1E2A3A"), 0.3)
		dot.position = Vector3(sin(a) * 0.075, 1.16 - cos(a) * 0.035 + 0.02, -0.27)
		body.add_child(dot)
	# kollar
	arm_l = _limb(body, Vector3(-0.3, 1.18, 0), 0.055, 0.45, INK)
	arm_r = _limb(body, Vector3(0.3, 1.18, 0), 0.055, 0.45, INK)
	arm_l.rotation.z = -0.35
	arm_r.rotation.z = 0.35
	# bacaklar + ayakkabılar
	leg_l = _limb(self, Vector3(-0.13, 0.55, 0), 0.07, 0.48, INK)
	leg_r = _limb(self, Vector3(0.13, 0.55, 0), 0.07, 0.48, INK)
	for leg in [leg_l, leg_r]:
		var shoe := Models.box(Vector3(0.17, 0.11, 0.28), SHOE, Vector3(0, -0.5, -0.05))
		shoe.material_override = Models.mat(SHOE, 0.5)
		leg.add_child(shoe)
		var sole := Models.box(Vector3(0.18, 0.04, 0.3), Color.WHITE, Vector3(0, -0.56, -0.05))
		leg.add_child(sole)


func _cyl(parent: Node3D, top: float, bottom: float, h: float, pos: Vector3, m: Material) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = top
	cm.bottom_radius = bottom
	cm.height = h
	cm.radial_segments = 24
	mi.mesh = cm
	mi.material_override = m
	mi.position = pos
	parent.add_child(mi)
	return mi


## Omuz/kalçadan dönen uzuv: pivot noktası üstte.
func _limb(parent: Node3D, pivot: Vector3, r: float, length: float, c: Color) -> Node3D:
	var p := Node3D.new()
	p.position = pivot
	var mi := MeshInstance3D.new()
	var cm := CapsuleMesh.new()
	cm.radius = r
	cm.height = length
	mi.mesh = cm
	mi.material_override = Models.mat(c, 0.5)
	mi.position = Vector3(0, -length / 2.0, 0)
	p.add_child(mi)
	parent.add_child(p)
	return p


## İniş/kalkışta ezilip uzama efekti.
func squash(amount: float) -> void:
	_squash = amount


func flash_hit() -> void:
	_body_mat.emission_enabled = true
	_body_mat.emission = Color("#FF4D4D")
	_body_mat.emission_energy_multiplier = 0.8
	var tw := create_tween()
	tw.tween_property(_body_mat, "emission_energy_multiplier", 0.0, 0.35)


func _process(delta: float) -> void:
	_t += delta
	_blink -= delta
	if _blink < -0.12:
		_blink = randf_range(2.0, 4.5)
	var eye_scale := 0.15 if _blink < 0.0 else 1.0
	for e in eyes:
		e.scale.y = lerpf(e.scale.y, eye_scale, 0.6)
	_squash = lerpf(_squash, 0.0, clampf(delta * 10.0, 0, 1))
	scale = Vector3(1.0 - _squash * 0.5, 1.0 + _squash, 1.0 - _squash * 0.5)

	var target_body_rot := Vector3.ZERO
	var target_body_y := 0.0
	match pose:
		"run":
			var f := 11.0 * run_speed
			var sw := sin(_t * f)
			leg_l.rotation.x = sw * 0.9
			leg_r.rotation.x = -sw * 0.9
			arm_l.rotation.x = -sw * 0.8
			arm_r.rotation.x = sw * 0.8
			target_body_y = absf(sin(_t * f)) * 0.08
			target_body_rot = Vector3(-0.14, 0, 0)
		"air":
			leg_l.rotation.x = lerpf(leg_l.rotation.x, -1.0, 0.25)
			leg_r.rotation.x = lerpf(leg_r.rotation.x, -0.6, 0.25)
			arm_l.rotation.x = lerpf(arm_l.rotation.x, -2.4, 0.2)
			arm_r.rotation.x = lerpf(arm_r.rotation.x, -2.4, 0.2)
			target_body_rot = Vector3(0.1, 0, 0)
		"slide":
			leg_l.rotation.x = lerpf(leg_l.rotation.x, -1.3, 0.3)
			leg_r.rotation.x = lerpf(leg_r.rotation.x, -1.3, 0.3)
			arm_l.rotation.x = lerpf(arm_l.rotation.x, 2.6, 0.3)
			arm_r.rotation.x = lerpf(arm_r.rotation.x, 2.6, 0.3)
			target_body_rot = Vector3(1.25, 0, 0)
			target_body_y = -0.35
		"stumble":
			target_body_rot = Vector3(-0.3, 0, sin(_t * 40.0) * 0.25)
		_:
			var b := sin(_t * 2.5)
			leg_l.rotation.x = lerpf(leg_l.rotation.x, 0.0, 0.2)
			leg_r.rotation.x = lerpf(leg_r.rotation.x, 0.0, 0.2)
			arm_l.rotation.x = b * 0.15
			arm_r.rotation.x = -b * 0.15
			target_body_y = b * 0.03
	target_body_rot.z += -lean * 0.35
	var k := clampf(delta * 14.0, 0, 1)
	rotation.x = lerpf(rotation.x, target_body_rot.x, k)
	rotation.z = lerpf(rotation.z, target_body_rot.z, k)
	body.position.y = lerpf(body.position.y, target_body_y, k)
