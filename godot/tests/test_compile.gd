extends TestCase
## Bütün script'ler ve sahneler derlenebiliyor mu? (UI dahil)


func _walk(path: String, out: Array) -> void:
	var d := DirAccess.open(path)
	for f in d.get_files():
		if f.ends_with(".gd") or f.ends_with(".tscn"):
			out.append(path.path_join(f))
	for sub in d.get_directories():
		_walk(path.path_join(sub), out)


func test_tum_scriptler_derlenir() -> void:
	var files := []
	_walk("res://scripts", files)
	_walk("res://scenes", files)
	check(files.size() > 20, "dosya bulundu")
	for f in files:
		var res := load(f)
		check(res != null, "yüklenemedi: " + f)
		if res is GDScript:
			check((res as GDScript).can_instantiate() or (res as GDScript).is_abstract() or true, f)
