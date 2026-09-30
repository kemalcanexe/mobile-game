class_name EnrollmentRules
extends RefCounted
## Ders seçimi kuralları (grading.json → enrollment).

const DUPLICATE := "duplicate"
const NOT_OFFERED := "notOffered"
const TOO_FEW := "tooFew"
const TOO_MANY := "tooMany"
const MISSING_RETAKE := "missingRetake"

var min_courses := 3
var max_courses := 4
var probation_max := 3


static func from_dict(d: Dictionary) -> EnrollmentRules:
	var r := EnrollmentRules.new()
	r.min_courses = int(d["minCourses"])
	r.max_courses = int(d["maxCourses"])
	r.probation_max = int(d["probationMaxCourses"])
	return r


func max_for(on_probation: bool) -> int:
	return probation_max if on_probation else max_courses


## Seçilebilecek ders azsa alt sınır ona iner.
func min_for(available: int, on_probation: bool) -> int:
	return mini(mini(min_courses, available), max_for(on_probation))


## Sorun listesi; boşsa seçim geçerli.
func validate(selected: Array, available: Array, required_retakes: Array, on_probation: bool) -> Array[String]:
	var issues: Array[String] = []
	var unique := {}
	for c in selected:
		unique[c] = true
	if unique.size() != selected.size():
		issues.append(DUPLICATE)
	if unique.keys().any(func(c) -> bool: return not available.has(c)):
		issues.append(NOT_OFFERED)
	var mx := max_for(on_probation)
	if unique.size() < min_for(available.size(), on_probation):
		issues.append(TOO_FEW)
	if unique.size() > mx:
		issues.append(TOO_MANY)
	# Tekrar alınması gereken dersler, yer olduğu sürece seçilmek zorunda.
	for i in mini(required_retakes.size(), mx):
		if not unique.has(required_retakes[i]):
			issues.append(MISSING_RETAKE)
			break
	return issues
