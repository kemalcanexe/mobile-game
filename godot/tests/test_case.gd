class_name TestCase
extends RefCounted
## Basit test tabanı: test_ ile başlayan metodlar çalıştırılır.

var failures: Array[String] = []
var current := ""


func check(cond: bool, msg := "") -> void:
	if not cond:
		failures.append("%s: %s" % [current, msg if msg != "" else "koşul sağlanmadı"])


func eq(actual, expected, msg := "") -> void:
	if typeof(actual) in [TYPE_FLOAT, TYPE_INT] and typeof(expected) in [TYPE_FLOAT, TYPE_INT]:
		if absf(float(actual) - float(expected)) > 1e-9:
			failures.append("%s: %s beklenen=%s gelen=%s" % [current, msg, expected, actual])
	elif actual != expected:
		failures.append("%s: %s beklenen=%s gelen=%s" % [current, msg, expected, actual])


func near(actual: float, expected: float, tol: float, msg := "") -> void:
	if absf(actual - expected) > tol:
		failures.append("%s: %s beklenen≈%s gelen=%s" % [current, msg, expected, actual])


static func json(path: String) -> Dictionary:
	return JSON.parse_string(FileAccess.get_file_as_string(path))


static func rules() -> GradingRules:
	return GradingRules.from_dict(json("res://data/config/grading.json"))


static func rec(id: String, letter: String, pts: float, credits := 3, semester := 1, attempt := 1) -> CourseRecord:
	return CourseRecord.create(id, id.to_upper(), credits, semester, 0.0, letter, pts, attempt)
