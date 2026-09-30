class_name Content
extends RefCounted
## Açılışta bir kez yüklenen bütün oyun verisi (res://data).

const ROOT := "res://data/"

var game_cfg: Dictionary
var world_cfg: Dictionary
var items: Dictionary = {}  # code -> item
var grading: GradingRules
var comments: Dictionary
var courses: Array = []  # [course dict]
var courses_by_id: Dictionary = {}
var curriculum: Dictionary
var errors: Array[String] = []


static func read_json(path: String) -> Variant:
	var text := FileAccess.get_file_as_string(ROOT + path)
	return JSON.parse_string(text)


static func load_all() -> Content:
	var c := Content.new()
	c.game_cfg = read_json("config/game.json")
	c.world_cfg = read_json("config/world3d.json")
	for it in read_json("config/items.json")["items"]:
		c.items[it["code"]] = it
	c.grading = GradingRules.from_dict(read_json("config/grading.json"))
	if c.grading.error != "":
		c.errors.append(c.grading.error)
	c.comments = read_json("config/comments.json")
	for path in read_json("levels/courses.json")["courses"]:
		var course := _load_course(path)
		c.errors.append_array(LevelValidator.validate(course, c.items, int(c.game_cfg["world"]["laneCount"])))
		c.courses.append(course)
		c.courses_by_id[course["id"]] = course
	c.curriculum = read_json("levels/curriculum.json")
	for s in c.curriculum["semesters"]:
		for id in s["offered"]:
			if not c.courses_by_id.has(id):
				c.errors.append("curriculum.json: tanımsız ders %s" % id)
	return c


static func _load_course(path: String) -> Dictionary:
	var course: Dictionary = read_json("levels/" + path)
	var patterns := {}
	for f in course["patternFiles"]:
		var p: Dictionary = read_json("levels/" + f)["patterns"]
		patterns.merge(p)
	course["patterns"] = patterns
	var levels := {}
	for key in course["levels"]:
		levels[key] = read_json("levels/" + course["levels"][key])
	course["levels"] = levels
	return course


func course(id: String) -> Dictionary:
	return courses_by_id[id]


func offered_in(semester: int) -> Array:
	for s in curriculum["semesters"]:
		if int(s["index"]) == semester:
			return s["offered"]
	return []


func required_semesters() -> int:
	return int(curriculum["requiredSemesters"])


## Hocanın yorumu: harfin ilk karakterine göre seed'li seçim.
func comment_for(letter: String, ink_out: bool, seed: int) -> String:
	var lang: Dictionary = comments["tr"]
	var key := "inkOut" if ink_out else letter.substr(0, 1)
	var list: Array = lang.get(key, lang["C"])
	return list[absi(seed) % list.size()]
