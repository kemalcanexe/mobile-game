class_name GradeScale
extends RefCounted
## Skoru harfe çeviren tablo. Yüksekten düşüğe sıralı tutulur.

## Kayan nokta toplamlarından gelen (96.99999999999999 gibi) hataları yutar.
const EPSILON := 1e-9

var grades: Array[LetterGrade] = []
var error := ""


func _init(p_grades: Array[LetterGrade]) -> void:
	grades = p_grades.duplicate()
	grades.sort_custom(func(a: LetterGrade, b: LetterGrade) -> bool: return a.min_score > b.min_score)
	if grades.is_empty() or grades[-1].min_score > 0.0:
		error = "Harf tablosu 0 alt sınırlı bir harf içermeli."


static func from_array(arr: Array) -> GradeScale:
	var list: Array[LetterGrade] = []
	for d in arr:
		list.append(LetterGrade.from_dict(d))
	return GradeScale.new(list)


func grade_for(score: float) -> LetterGrade:
	for g in grades:
		if score + EPSILON >= g.min_score:
			return g
	return grades[-1]


func by_symbol(symbol: String) -> LetterGrade:
	for g in grades:
		if g.symbol == symbol:
			return g
	return null
