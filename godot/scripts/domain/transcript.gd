class_name Transcript
extends RefCounted
## Bütün ders denemeleri. Değişmez kullanılır: ekleme yeni Transcript döner.

var records: Array[CourseRecord] = []


func _init(p_records: Array[CourseRecord] = []) -> void:
	records = p_records.duplicate()


func active() -> Array[CourseRecord]:
	return records.filter(func(r: CourseRecord) -> bool: return not r.replaced)


func active_record_for(course_id: String) -> CourseRecord:
	for r in active():
		if r.course_id == course_id:
			return r
	return null


func attempts_for(course_id: String) -> int:
	return records.filter(func(r: CourseRecord) -> bool: return r.course_id == course_id).size()


static func can_retake(record: CourseRecord, retakeable_letters: Array) -> bool:
	return not record.replaced and retakeable_letters.has(record.letter)


## Yeni sonucu ekler. Dersin aktif kaydı varsa yalnızca retake edilebilir
## ise eklenir ve eski kayıt "R" olur. Geçilmiş dersse null döner.
func add_result(record: CourseRecord, retakeable_letters: Array) -> Transcript:
	var existing := active_record_for(record.course_id)
	var list: Array[CourseRecord] = []
	if existing == null:
		list = records.duplicate()
	elif can_retake(existing, retakeable_letters):
		for r in records:
			list.append(r.copy_replaced() if r == existing else r)
	else:
		return null
	list.append(record)
	return Transcript.new(list)


## Dönem GPA'i tarihseldir: o dönemin bütün kayıtları (R dahil).
func semester_gpa(semester: int) -> float:
	return Gpa.of(records_in(semester))


func cgpa() -> float:
	return Gpa.of(active())


func has_unresolved_failure() -> bool:
	return active().any(func(r: CourseRecord) -> bool: return r.is_failing())


func failed_course_ids() -> Array[String]:
	var out: Array[String] = []
	for r in active():
		if r.is_failing():
			out.append(r.course_id)
	return out


func semesters() -> Array[int]:
	var s: Array[int] = []
	for r in records:
		if not s.has(r.semester):
			s.append(r.semester)
	s.sort()
	return s


func records_in(semester: int) -> Array[CourseRecord]:
	return records.filter(func(r: CourseRecord) -> bool: return r.semester == semester)


func has_record_in(course_id: String, semester: int) -> bool:
	return records.any(func(r: CourseRecord) -> bool: return r.course_id == course_id and r.semester == semester)


func to_array() -> Array:
	return records.map(func(r: CourseRecord) -> Dictionary: return r.to_dict())


static func from_array(arr: Array) -> Transcript:
	var list: Array[CourseRecord] = []
	for d in arr:
		list.append(CourseRecord.from_dict(d))
	return Transcript.new(list)
