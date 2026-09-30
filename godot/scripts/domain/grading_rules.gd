class_name GradingRules
extends RefCounted
## data/config/grading.json'un tamamı. Hata varsa [member error] dolu gelir.

var weights := {}  # assessment -> ağırlık
var scale: GradeScale
var level_max := 100.0
var clean_paper_credit := 2.0
var clean_paper_min_ink := 50.0
var ink_out_cap := 50.0
var deans_list_min := 3.5
var probation_below := 2.0
var honors: Array = []  # [{id, min}] yüksekten düşüğe
var enrollment: EnrollmentRules
var retakeable_letters: Array = []
var error := ""


static func from_dict(d: Dictionary) -> GradingRules:
	var r := GradingRules.new()
	for a in d.get("assessments", []):
		r.weights[str(a["type"])] = float(a["weight"])
	var sum := 0.0
	for key in Assessment.ORDER:
		if not r.weights.has(key):
			r.error = "Ağırlığı eksik değerlendirme: %s" % key
			return r
		sum += r.weights[key]
	if absf(sum - 1.0) > 1e-6:
		r.error = "Değerlendirme ağırlıklarının toplamı 1 olmalı: %s" % sum
		return r
	r.scale = GradeScale.from_array(d["scale"])
	if r.scale.error != "":
		r.error = r.scale.error
		return r
	var ls: Dictionary = d["levelScore"]
	r.level_max = float(ls["max"])
	r.clean_paper_credit = float(ls["cleanPaperCredit"])
	r.clean_paper_min_ink = float(ls["cleanPaperMinInk"])
	r.ink_out_cap = float(ls["inkOutCap"])
	var st: Dictionary = d["standing"]
	r.deans_list_min = float(st["deansListMinSemesterGpa"])
	r.probation_below = float(st["probationBelowCgpa"])
	for h in st["honors"]:
		r.honors.append({"id": str(h["id"]), "min": float(h["minCgpa"])})
	r.honors.sort_custom(func(a, b) -> bool: return a["min"] > b["min"])
	r.enrollment = EnrollmentRules.from_dict(d["enrollment"])
	r.retakeable_letters = d["retake"]["retakeableLetters"]
	return r


## ders_skoru = Σ(level_skoru × ağırlık). Eksik skor varsa -1 döner.
func course_score(scores: Dictionary) -> float:
	var total := 0.0
	for key in Assessment.ORDER:
		if not scores.has(key):
			return -1.0
		total += float(scores[key]) * weights[key]
	return total


func contribution(assessment: String, score: float) -> float:
	return score * weights[assessment]


func letter_for(score: float) -> LetterGrade:
	return scale.grade_for(score)
