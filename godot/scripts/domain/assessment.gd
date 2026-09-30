class_name Assessment
## Bir dersin izlencesindeki değerlendirmeler (her biri bir level).

const QUIZ1 := "quiz1"
const MIDTERM := "midterm"
const QUIZ2 := "quiz2"
const PROJECT := "project"
const FINAL := "final"

## İzlence sırası.
const ORDER: Array[String] = [QUIZ1, MIDTERM, QUIZ2, PROJECT, FINAL]

const NAMES := {
	QUIZ1: "Quiz 1",
	MIDTERM: "Midterm",
	QUIZ2: "Quiz 2",
	PROJECT: "Proje / Lab",
	FINAL: "Final",
}


static func is_valid(key: String) -> bool:
	return ORDER.has(key)


static func display_name(key: String) -> String:
	return NAMES.get(key, key)
