class_name CourseRecord
extends RefCounted
## Transkriptte tek bir ders denemesi.

var course_id: String
var course_code: String
var credits: int
var semester: int
var score: float
var letter: String
var grade_points: float
var attempt := 1
## Retake ile yerine yenisi geçtiyse true ("R"); CGPA'e girmez.
var replaced := false
var assessment_scores := {}


static func create(p_id: String, p_code: String, p_credits: int, p_semester: int, p_score: float,
		p_letter: String, p_points: float, p_attempt := 1, p_scores := {}) -> CourseRecord:
	var r := CourseRecord.new()
	r.course_id = p_id
	r.course_code = p_code
	r.credits = p_credits
	r.semester = p_semester
	r.score = p_score
	r.letter = p_letter
	r.grade_points = p_points
	r.attempt = p_attempt
	r.assessment_scores = p_scores.duplicate()
	return r


func is_retake() -> bool:
	return attempt > 1


func is_failing() -> bool:
	return grade_points == 0.0


func copy_replaced() -> CourseRecord:
	var r := CourseRecord.create(course_id, course_code, credits, semester, score, letter,
			grade_points, attempt, assessment_scores)
	r.replaced = true
	return r


func to_dict() -> Dictionary:
	return {
		"courseId": course_id, "courseCode": course_code, "credits": credits,
		"semester": semester, "score": score, "letter": letter, "gradePoints": grade_points,
		"attempt": attempt, "replaced": replaced, "assessmentScores": assessment_scores,
	}


static func from_dict(d: Dictionary) -> CourseRecord:
	var r := CourseRecord.create(str(d["courseId"]), str(d["courseCode"]), int(d["credits"]),
			int(d["semester"]), float(d["score"]), str(d["letter"]), float(d["gradePoints"]),
			int(d.get("attempt", 1)), d.get("assessmentScores", {}))
	r.replaced = bool(d.get("replaced", false))
	return r
