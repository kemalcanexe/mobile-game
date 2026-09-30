extends SceneTree
## Headless test koşucusu: godot --headless --path . -s res://tests/run_tests.gd


func _initialize() -> void:
	var total := 0
	var failed: Array[String] = []
	var dir := DirAccess.open("res://tests")
	var files := Array(dir.get_files()).filter(func(f: String) -> bool: return f.begins_with("test_") and f.ends_with(".gd") and f != "test_case.gd")
	files.sort()
	for f in files:
		var script: GDScript = load("res://tests/" + f)
		for m in script.get_script_method_list():
			var name: String = m["name"]
			if not name.begins_with("test_"):
				continue
			var t: TestCase = script.new()
			t.current = "%s::%s" % [f.get_basename(), name]
			var r = t.call(name)
			if r is Object and r.has_method("is_valid"):
				await r
			total += 1
			failed.append_array(t.failures)
			if t.has_method("cleanup"):
				t.cleanup()
	for msg in failed:
		print("FAIL ", msg)
	print("%d test, %d hata" % [total, failed.size()])
	quit(1 if failed.size() > 0 else 0)
