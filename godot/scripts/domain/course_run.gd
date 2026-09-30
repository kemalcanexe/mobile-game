class_name CourseRun
extends RefCounted
## Devam eden bir ders denemesi: hangi sınavlar bitti, skorları ne.

var course_id: String
var attempt := 1
var scores := {}


static func create(p_id: String, p_attempt := 1, p_scores := {}) -> CourseRun:
	var r := CourseRun.new()
	r.course_id = p_id
	r.attempt = p_attempt
	r.scores = p_scores.duplicate()
	return r


## Sıradaki sınav; hepsi bittiyse "".
func next_assessment() -> String:
	for key in Assessment.ORDER:
		if not scores.has(key):
			return key
	return ""


func is_complete() -> bool:
	return next_assessment() == ""


## Sıradaki sınav değilse null döner.
func with_score(assessment: String, score: float) -> CourseRun:
	if assessment != next_assessment():
		return null
	var s := scores.duplicate()
	s[assessment] = score
	return CourseRun.create(course_id, attempt, s)


func to_dict() -> Dictionary:
	return {"courseId": course_id, "attempt": attempt, "scores": scores}


static func from_dict(d: Dictionary) -> CourseRun:
	var s := {}
	for k in d.get("scores", {}):
		s[str(k)] = float(d["scores"][k])
	return CourseRun.create(str(d["courseId"]), int(d.get("attempt", 1)), s)
