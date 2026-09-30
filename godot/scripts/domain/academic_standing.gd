class_name AcademicStanding
## Dean's List, Probation, onur dereceleri ve mezuniyet.


static func is_deans_list(rules: GradingRules, semester_gpa: float) -> bool:
	return semester_gpa >= 0.0 and semester_gpa >= rules.deans_list_min


static func is_on_probation(rules: GradingRules, cgpa: float) -> bool:
	return cgpa >= 0.0 and cgpa < rules.probation_below


## En yüksek uygun onur derecesinin kimliği; yoksa "".
static func honor_for(rules: GradingRules, cgpa: float) -> String:
	if cgpa < 0.0:
		return ""
	for h in rules.honors:
		if cgpa >= h["min"]:
			return h["id"]
	return ""


static func can_graduate(rules: GradingRules, transcript: Transcript, completed: int, required: int) -> bool:
	var c := transcript.cgpa()
	return completed >= required and not transcript.has_unresolved_failure() \
			and c >= 0.0 and not is_on_probation(rules, c)
