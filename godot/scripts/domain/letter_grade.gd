class_name LetterGrade
extends RefCounted
## Amerikan harf notu: alt sınır dahil, üst sınır hariç.

var symbol: String
var min_score: float
var points: float


func _init(p_symbol: String, p_min: float, p_points: float) -> void:
	symbol = p_symbol
	min_score = p_min
	points = p_points


func is_failing() -> bool:
	return points == 0.0


static func from_dict(d: Dictionary) -> LetterGrade:
	return LetterGrade.new(str(d["letter"]), float(d["min"]), float(d["points"]))
