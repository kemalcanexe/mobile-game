class_name LevelValidator
## Ders verisinin mantık kontrolleri. Boş liste = geçerli.


static func validate(course: Dictionary, items: Dictionary, lane_count: int) -> Array[String]:
	var errors: Array[String] = []
	var patterns: Dictionary = course["patterns"]
	for id in patterns:
		var rows: Array = patterns[id]["rows"]
		if rows.is_empty():
			errors.append('desen "%s": satır yok' % id)
		for i in rows.size():
			var cells := LevelGenerator.split_row(rows[i])
			if cells.size() != lane_count:
				errors.append('desen "%s" satır %d: %d hücre bekleniyordu, %d geldi' % [id, i, lane_count, cells.size()])
			var walls := 0
			var collectibles := 0
			for c in cells:
				if c == LevelGenerator.EMPTY:
					continue
				if not items.has(c):
					errors.append('desen "%s" satır %d: bilinmeyen nesne kodu "%s"' % [id, i, c])
					continue
				if items[c]["kind"] == "wall":
					walls += 1
				if items[c]["kind"] == "collectible" and float(items[c].get("points", 0)) > 0:
					collectibles += 1
			if walls >= lane_count:
				errors.append('desen "%s" satır %d: bütün şeritler duvarla kapalı' % [id, i])
			if collectibles > 1:
				errors.append('desen "%s" satır %d: aynı satırda birden fazla toplanabilir' % [id, i])
	for key in Assessment.ORDER:
		if not course["levels"].has(key):
			errors.append('%s: "%s" level\'ı eksik' % [course["id"], key])
			continue
		var lv: Dictionary = course["levels"][key]
		var where: String = lv["id"]
		if lv["assessment"] != key:
			errors.append('%s: assessment "%s" ama "%s" olarak bağlandı' % [where, lv["assessment"], key])
		if float(lv["durationSeconds"]) <= 0:
			errors.append("%s: süre pozitif olmalı" % where)
		if float(lv["speed"]["start"]) <= 0 or float(lv["speed"]["end"]) < float(lv["speed"]["start"]):
			errors.append("%s: hız 0 < start ≤ end olmalı" % where)
		if int(lv["gapRows"]["min"]) < 0 or int(lv["gapRows"]["max"]) < int(lv["gapRows"]["min"]):
			errors.append("%s: gapRows 0 ≤ min ≤ max olmalı" % where)
		if lv["pool"].is_empty():
			errors.append("%s: desen havuzu boş" % where)
		for e in lv["pool"] + lv.get("script", []):
			if not patterns.has(e["pattern"]):
				errors.append('%s: "%s" deseni tanımsız' % [where, e["pattern"]])
		for e in lv["pool"]:
			if float(e["weight"]) <= 0:
				errors.append('%s: "%s" ağırlığı pozitif olmalı' % [where, e["pattern"]])
	return errors
