class_name ShapeLib
## Kodla üretilen yumuşak hatlı mesh'ler (önbellekli): yuvarlatılmış kutu,
## yıldız. Oyuncak görünümlü nesneler için düz BoxMesh yerine kullanılır.

static var _cache := {}


## Köşeleri yuvarlatılmış kutu (XY düzleminde yuvarlak köşe, Z'de düz kalınlık,
## ön/arka kenarlarda küçük pah). size: tam boyut, r: köşe yarıçapı.
static func rounded_box(size: Vector3, r: float, seg := 5) -> ArrayMesh:
	var key := "rb|%s|%.3f|%d" % [size, r, seg]
	if _cache.has(key):
		return _cache[key]
	r = minf(r, minf(size.x, size.y) * 0.5 - 0.001)
	var hx := size.x / 2.0 - r
	var hy := size.y / 2.0 - r
	var hz := size.z / 2.0
	var bevel := minf(r * 0.5, hz * 0.6)
	# yuvarlak dikdörtgen çevre noktaları (saat yönünün tersine)
	var ring: Array[Vector2] = []
	var corners := [Vector2(hx, hy), Vector2(-hx, hy), Vector2(-hx, -hy), Vector2(hx, -hy)]
	for ci in 4:
		for k in seg + 1:
			var a := (ci * 0.5 + float(k) / seg * 0.5) * PI
			ring.append(corners[ci] + Vector2(cos(a), sin(a)) * r)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var n := ring.size()
	# katmanlar: ön yüz (pah içeride), ön pah, yan, arka pah, arka yüz
	var inset := func(p: Vector2, d: float) -> Vector2:
		return p * ((p.length() - d) / maxf(p.length(), 0.0001)) if p.length() > d else p
	var layers := [
		{"z": hz, "d": bevel},
		{"z": hz - bevel, "d": 0.0},
		{"z": -hz + bevel, "d": 0.0},
		{"z": -hz, "d": bevel},
	]
	# yan yüzeyler ve pahlar
	for li in 3:
		var A: Dictionary = layers[li]
		var B: Dictionary = layers[li + 1]
		for i in n:
			var j := (i + 1) % n
			var a0: Vector2 = inset.call(ring[i], A["d"])
			var a1: Vector2 = inset.call(ring[j], A["d"])
			var b0: Vector2 = inset.call(ring[i], B["d"])
			var b1: Vector2 = inset.call(ring[j], B["d"])
			var p := [Vector3(a0.x, a0.y, A["z"]), Vector3(a1.x, a1.y, A["z"]), Vector3(b1.x, b1.y, B["z"]), Vector3(b0.x, b0.y, B["z"])]
			for t in [[0, 1, 2], [0, 2, 3]]:
				for vi in t:
					st.add_vertex(p[vi])
	# ön ve arka kapak (yelpaze)
	for side in [1.0, -1.0]:
		var d := bevel
		for i in n:
			var j := (i + 1) % n
			var a: Vector2 = inset.call(ring[i], d)
			var b: Vector2 = inset.call(ring[j], d)
			var c := Vector3(0, 0, side * hz)
			var pa := Vector3(a.x, a.y, side * hz)
			var pb := Vector3(b.x, b.y, side * hz)
			# Godot'da ön yüz, bakana göre saat yönünde sarılır
			if side > 0:
				st.add_vertex(c); st.add_vertex(pb); st.add_vertex(pa)
			else:
				st.add_vertex(c); st.add_vertex(pa); st.add_vertex(pb)
	st.generate_normals()
	var mesh := st.commit()
	_cache[key] = mesh
	return mesh


## Kalın beş köşeli yıldız (Z ekseni boyunca kalınlık).
static func star(r_out: float, r_in: float, depth: float) -> ArrayMesh:
	var key := "star|%.3f|%.3f|%.3f" % [r_out, r_in, depth]
	if _cache.has(key):
		return _cache[key]
	var pts: Array[Vector2] = []
	for k in 10:
		var a := PI / 2.0 + k * PI / 5.0
		var rr := r_out if k % 2 == 0 else r_in
		pts.append(Vector2(cos(a), sin(a)) * rr)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var hz := depth / 2.0
	for i in 10:
		var j := (i + 1) % 10
		var a := pts[i]
		var b := pts[j]
		# ön/arka: merkez hafif kabarık
		st.add_vertex(Vector3(0, 0, hz * 1.6)); st.add_vertex(Vector3(b.x, b.y, hz)); st.add_vertex(Vector3(a.x, a.y, hz))
		st.add_vertex(Vector3(0, 0, -hz * 1.6)); st.add_vertex(Vector3(a.x, a.y, -hz)); st.add_vertex(Vector3(b.x, b.y, -hz))
		# yan
		var p := [Vector3(a.x, a.y, hz), Vector3(b.x, b.y, hz), Vector3(b.x, b.y, -hz), Vector3(a.x, a.y, -hz)]
		for t in [[0, 1, 2], [0, 2, 3]]:
			for vi in t:
				st.add_vertex(p[vi])
	st.generate_normals()
	var mesh := st.commit()
	_cache[key] = mesh
	return mesh


static func mesh_node(mesh: Mesh, m: Material, pos := Vector3.ZERO, rot := Vector3.ZERO) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = m
	mi.position = pos
	mi.rotation = rot
	return mi
