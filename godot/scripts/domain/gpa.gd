class_name Gpa
## Kredi ağırlıklı GPA: Σ(puan × kredi) / Σ(kredi). Hesapta yuvarlama yok.

## Hiç kredi yoksa GPA tanımsız.
const UNDEFINED := -1.0


static func of(records: Array) -> float:
	var weighted := 0.0
	var credits := 0
	for r in records:
		weighted += r.grade_points * r.credits
		credits += r.credits
	if credits == 0:
		return UNDEFINED
	return weighted / credits


static func format(v: float) -> String:
	return "—" if v < 0.0 else "%.2f" % v
