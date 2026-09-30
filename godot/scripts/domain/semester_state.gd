class_name SemesterState
extends RefCounted
## İçinde bulunulan dönem ve o dönem kayıt olunan dersler.

var index := 1
var enrolled: Array[String] = []


static func create(p_index := 1, p_enrolled: Array[String] = []) -> SemesterState:
	var s := SemesterState.new()
	s.index = p_index
	s.enrolled = p_enrolled.duplicate()
	return s


func needs_enrollment() -> bool:
	return enrolled.is_empty()


func is_enrolled(course_id: String) -> bool:
	return enrolled.has(course_id)


func with_enrollment(ids: Array[String]) -> SemesterState:
	return SemesterState.create(index, ids)


func next() -> SemesterState:
	return SemesterState.create(index + 1)


func to_dict() -> Dictionary:
	return {"index": index, "enrolled": enrolled}


static func from_dict(d: Dictionary) -> SemesterState:
	var ids: Array[String] = []
	for x in d.get("enrolled", []):
		ids.append(str(x))
	return SemesterState.create(int(d.get("index", 1)), ids)
