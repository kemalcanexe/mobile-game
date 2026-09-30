class_name Progress
extends RefCounted
## Oyuncu ilerlemesi: transkript, devam eden dersler, dönem. JSON olarak saklanır.

signal changed

const VERSION := 3

var content: Content
var save_path: String
var transcript := Transcript.new()
var runs := {}  # course_id -> CourseRun
var semester := SemesterState.create()


func _init(p_content: Content, p_save_path := "user://save.json") -> void:
	content = p_content
	save_path = p_save_path


func rules() -> GradingRules:
	return content.grading


# ------------------------------------------------------------------ kayıt

func load_save() -> void:
	transcript = Transcript.new()
	runs = {}
	semester = SemesterState.create()
	if not FileAccess.file_exists(save_path):
		return
	var json := JSON.new()
	if json.parse(FileAccess.get_file_as_string(save_path)) != OK or not (json.data is Dictionary):
		return  # bozuk kayıt: boş başla
	var data: Dictionary = json.data
	transcript = Transcript.from_array(data.get("transcript", []))
	for id in data.get("runs", {}):
		runs[id] = CourseRun.from_dict(data["runs"][id])
	if data.has("semester"):
		semester = SemesterState.from_dict(data["semester"])
	else:
		# eski kayıt: ilk dönem, alınmış dersler kayıtlı sayılır
		var ids: Array[String] = []
		for r in transcript.records:
			if not ids.has(r.course_id):
				ids.append(r.course_id)
		for id in runs:
			if not ids.has(id):
				ids.append(id)
		semester = SemesterState.create(1, ids)


func _commit() -> void:
	var data := {"version": VERSION, "transcript": transcript.to_array(), "runs": {}, "semester": semester.to_dict()}
	for id in runs:
		data["runs"][id] = runs[id].to_dict()
	var f := FileAccess.open(save_path, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(data))
		f.close()
	changed.emit()


func reset() -> void:
	if FileAccess.file_exists(save_path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))
	transcript = Transcript.new()
	runs = {}
	semester = SemesterState.create()
	changed.emit()


# ------------------------------------------------------------ ders seçimi

func on_probation() -> bool:
	return AcademicStanding.is_on_probation(rules(), transcript.cgpa())


## {available, retakes, probation, min, max}
func offer() -> Dictionary:
	var retakes := transcript.failed_course_ids()
	var available: Array = retakes.duplicate()
	for id in content.offered_in(semester.index):
		if transcript.active_record_for(id) == null and not retakes.has(id):
			available.append(id)
	var prob := on_probation()
	var e := rules().enrollment
	return {"available": available, "retakes": retakes, "probation": prob,
		"min": e.min_for(available.size(), prob), "max": e.max_for(prob)}


func check_enrollment(selected: Array) -> Array[String]:
	var o := offer()
	return rules().enrollment.validate(selected, o["available"], o["retakes"], o["probation"])


func enroll(selected: Array) -> bool:
	if not semester.needs_enrollment() or not check_enrollment(selected).is_empty():
		return false
	var ids: Array[String] = []
	for s in selected:
		ids.append(str(s))
	semester = semester.with_enrollment(ids)
	_commit()
	return true


# ------------------------------------------------------------------ dersler

## "notEnrolled" | "notStarted" | "inProgress" | "passed" | "failed"
func status_of(course_id: String) -> String:
	if not semester.is_enrolled(course_id):
		return "notEnrolled"
	if runs.has(course_id):
		return "inProgress"
	if not transcript.has_record_in(course_id, semester.index):
		return "notStarted"
	var r := transcript.active_record_for(course_id)
	return "failed" if r == null or r.is_failing() else "passed"


func run_for(course_id: String) -> CourseRun:
	if not semester.is_enrolled(course_id):
		return null
	if runs.has(course_id):
		return runs[course_id]
	if transcript.has_record_in(course_id, semester.index):
		return null
	return CourseRun.create(course_id, transcript.attempts_for(course_id) + 1)


func is_semester_complete() -> bool:
	if semester.needs_enrollment():
		return false
	for id in semester.enrolled:
		if not transcript.has_record_in(id, semester.index):
			return false
	return true


## Level skorunu kaydeder. Ders bittiyse özet sözlüğü, değilse {} döner.
func record_level(course_id: String, assessment: String, score: float) -> Dictionary:
	var current := run_for(course_id)
	if current == null:
		return {}
	var run := current.with_score(assessment, score)
	if run == null:
		return {}
	if not run.is_complete():
		runs[course_id] = run
		_commit()
		return {}
	var course := content.course(course_id)
	var course_score := rules().course_score(run.scores)
	var letter := rules().letter_for(course_score)
	var before := transcript.cgpa()
	var rec := CourseRecord.create(course_id, course["code"], int(course["credits"]), semester.index,
			course_score, letter.symbol, letter.points, run.attempt, run.scores)
	var next := transcript.add_result(rec, rules().retakeable_letters)
	if next == null:
		return {}
	transcript = next
	runs.erase(course_id)
	_commit()
	return {"courseId": course_id, "scores": run.scores, "courseScore": course_score,
		"letter": letter.symbol, "gradePoints": letter.points, "cgpaBefore": before,
		"cgpaAfter": transcript.cgpa(), "attempt": run.attempt,
		"semesterComplete": is_semester_complete()}


# ------------------------------------------------------------- dönem sonu

func report_for(sem: int) -> Dictionary:
	var gpa := transcript.semester_gpa(sem)
	var c := transcript.cgpa()
	return {"semester": sem, "records": transcript.records_in(sem), "semesterGpa": gpa, "cgpa": c,
		"deansList": AcademicStanding.is_deans_list(rules(), gpa),
		"probation": AcademicStanding.is_on_probation(rules(), c)}


func advance_semester() -> bool:
	if not is_semester_complete():
		return false
	semester = semester.next()
	runs = {}
	_commit()
	return true
