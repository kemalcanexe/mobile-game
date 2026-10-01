class_name Fx
## Tek seferlik parçacık patlamaları (Compatibility'de çalışan CPUParticles3D).
## Yumuşak ışık lekeleri ve yıldızlar; ömürleri boyunca küçülüp söner.

static var _glow_tex: GradientTexture2D
static var _mats := {}


static func _glow_texture() -> GradientTexture2D:
	if _glow_tex == null:
		var g := Gradient.new()
		g.set_color(0, Color(1, 1, 1, 1))
		g.set_color(1, Color(1, 1, 1, 0))
		g.add_point(0.35, Color(1, 1, 1, 0.85))
		_glow_tex = GradientTexture2D.new()
		_glow_tex.gradient = g
		_glow_tex.fill = GradientTexture2D.FILL_RADIAL
		_glow_tex.fill_from = Vector2(0.5, 0.5)
		_glow_tex.fill_to = Vector2(1.0, 0.5)
		_glow_tex.width = 64
		_glow_tex.height = 64
	return _glow_tex


static func _glow_mat(color: Color) -> StandardMaterial3D:
	var key := "g" + color.to_html()
	if not _mats.has(key):
		var m := StandardMaterial3D.new()
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		m.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
		m.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
		m.albedo_texture = _glow_texture()
		m.albedo_color = color
		m.vertex_color_use_as_albedo = true
		_mats[key] = m
	return _mats[key]


static func _star_mat(color: Color) -> StandardMaterial3D:
	var key := "s" + color.to_html()
	if not _mats.has(key):
		var m := StandardMaterial3D.new()
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		m.albedo_color = color
		m.vertex_color_use_as_albedo = true
		_mats[key] = m
	return _mats[key]


static func _shrink_curve() -> Curve:
	var c := Curve.new()
	c.add_point(Vector2(0, 1))
	c.add_point(Vector2(0.7, 0.8))
	c.add_point(Vector2(1, 0))
	return c


static func _fade(color: Color) -> Gradient:
	var g := Gradient.new()
	g.set_color(0, Color(1, 1, 1, 1))
	g.set_color(1, Color(1, 1, 1, 0))
	return g


static func burst(parent: Node, pos: Vector3, color: Color, amount := 18, speed := 5.0, size := 0.12, life := 0.6) -> void:
	# ışık lekeleri
	var p := _base(amount, speed, life)
	var q := QuadMesh.new()
	q.size = Vector2.ONE * size * 4.0
	q.material = _glow_mat(color)
	p.mesh = q
	_emit(parent, p, pos, life)
	# yıldızlar (daha az, daha hızlı döner)
	var s := _base(maxi(3, amount / 4), speed * 1.1, life * 1.1)
	s.mesh = ShapeLib.star(size * 1.6, size * 0.7, size * 0.5)
	s.mesh.surface_set_material(0, _star_mat(color.lightened(0.25)))
	s.angular_velocity_min = -540.0
	s.angular_velocity_max = 540.0
	s.particle_flag_rotate_y = true
	_emit(parent, s, pos, life * 1.1)


static func _base(amount: int, speed: float, life: float) -> CPUParticles3D:
	var p := CPUParticles3D.new()
	p.one_shot = true
	p.emitting = false
	p.amount = amount
	p.lifetime = life
	p.explosiveness = 1.0
	p.direction = Vector3.UP
	p.spread = 70.0
	p.initial_velocity_min = speed * 0.5
	p.initial_velocity_max = speed
	p.gravity = Vector3(0, -10, 0)
	p.damping_min = 2.0
	p.damping_max = 4.0
	p.scale_amount_min = 0.6
	p.scale_amount_max = 1.2
	p.scale_amount_curve = _shrink_curve()
	p.color_ramp = _fade(Color.WHITE)
	return p


static func _emit(parent: Node, p: CPUParticles3D, pos: Vector3, life: float) -> void:
	parent.add_child(p)
	p.global_position = pos
	p.emitting = true
	parent.get_tree().create_timer(life + 0.3).timeout.connect(p.queue_free)


## Bitiş kapısında konfeti.
static func confetti(parent: Node, pos: Vector3) -> void:
	for c in [Color("#FFD23F"), Color("#2E6BFF"), Color("#FF4D4D"), Color("#2BC48A")]:
		burst(parent, pos, c, 30, 11.0, 0.14, 1.6)
