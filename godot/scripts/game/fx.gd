class_name Fx
## Tek seferlik parçacık patlamaları (Compatibility'de çalışan CPUParticles3D).


static func burst(parent: Node, pos: Vector3, color: Color, amount := 18, speed := 5.0, size := 0.12, life := 0.6) -> void:
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
	p.gravity = Vector3(0, -12, 0)
	p.scale_amount_min = 0.6
	p.scale_amount_max = 1.2
	var mesh := SphereMesh.new()
	mesh.radius = size
	mesh.height = size * 2.0
	mesh.radial_segments = 6
	mesh.rings = 3
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.albedo_color = color
	mesh.material = m
	p.mesh = mesh
	parent.add_child(p)
	p.global_position = pos
	p.emitting = true
	parent.get_tree().create_timer(life + 0.2).timeout.connect(p.queue_free)


## Bitiş kapısında konfeti.
static func confetti(parent: Node, pos: Vector3) -> void:
	for c in [Color("#FFD23F"), Color("#2E6BFF"), Color("#FF4D4D"), Color("#2BC48A")]:
		burst(parent, pos, c, 30, 11.0, 0.14, 1.6)
