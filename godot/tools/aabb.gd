extends SceneTree
func _aabb(n: Node, xf: Transform3D) -> AABB:
	var box := AABB()
	var first := true
	var t: Transform3D = xf * ((n as Node3D).transform if n is Node3D else Transform3D())
	if n is MeshInstance3D:
		box = t * n.mesh.get_aabb()
		first = false
	for c in n.get_children():
		var b := _aabb(c, t)
		if b.size != Vector3.ZERO:
			box = b if first else box.merge(b)
			first = false
	return box
func _initialize() -> void:
	for dir in ["roads", "furniture", "food", "fantasy", "mini_forest", "students", "kk_furniture", "kk_restaurant"]:
		var d := DirAccess.open("res://assets/models/" + dir)
		for f in d.get_files():
			if f.ends_with(".glb"):
				var s: PackedScene = load("res://assets/models/%s/%s" % [dir, f])
				var n := s.instantiate()
				var b := _aabb(n, Transform3D())
				print("%s/%s size=%s pos=%s" % [dir, f, b.size.snappedf(0.01), b.position.snappedf(0.01)])
				n.free()
	quit()
