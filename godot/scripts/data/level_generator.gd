class_name LevelGenerator
extends RefCounted
## Level tanımı + desen kütüphanesinden seed'li, deterministik spawn planı.
## Mesafeler level verisinin biriminde (piksel) üretilir.

const EMPTY := ".."


## Dönen sözlük: {total: float, events: [{d, lane, code}]} (d'ye göre sıralı).
static func generate(level: Dictionary, patterns: Dictionary, cfg: Dictionary, semester_mult := 1.0) -> Dictionary:
	var curve := SpeedCurve.from_dict(level["speed"], semester_mult)
	var scroll: Dictionary = cfg["scroll"]
	var base_speed := float(scroll["baseSpeed"])
	var row := float(scroll["rowSpacing"])
	var total := curve.distance_for(float(level["durationSeconds"]), base_speed)
	var rng := RandomNumberGenerator.new()
	rng.seed = int(level["seed"])
	var events: Array = []
	var end := total - int(scroll["endMarginRows"]) * row
	var cursor := float(scroll["warmupSeconds"]) * base_speed * curve.multiplier_at(0)
	var script: Array = level.get("script", []).duplicate()
	script.sort_custom(func(a, b) -> bool: return float(a["at"]) < float(b["at"]))
	var si := 0
	var gap_min := int(level["gapRows"]["min"])
	var gap_max := int(level["gapRows"]["max"])
	while cursor < end:
		var progress := cursor / total
		var pat: Dictionary
		if si < script.size() and float(script[si]["at"]) <= progress:
			pat = patterns[script[si]["pattern"]]
			si += 1
		else:
			pat = patterns[_pick(level["pool"], progress, rng)]
		var rows: Array = pat["rows"]
		var mirror: bool = bool(pat.get("mirror", true)) and rng.randi() % 2 == 1
		for r in rows.size():
			var d := cursor + r * row
			if d > end:
				break
			var cells := split_row(rows[r])
			for lane in cells.size():
				var code: String = cells[cells.size() - 1 - lane] if mirror else cells[lane]
				if code != EMPTY:
					events.append({"d": d, "lane": lane, "code": code})
		var gap := gap_min + rng.randi_range(0, gap_max - gap_min)
		cursor += (rows.size() + gap) * row
	return {"total": total, "events": events}


static func split_row(row: String) -> PackedStringArray:
	var out := PackedStringArray()
	for c in row.strip_edges().split(" ", false):
		out.append(c)
	return out


static func _pick(pool: Array, progress: float, rng: RandomNumberGenerator) -> String:
	var eligible := pool.filter(func(e) -> bool:
		return progress >= float(e.get("from", 0.0)) and progress < float(e.get("to", 1.0)))
	if eligible.is_empty():
		eligible = pool
	var total := 0.0
	for e in eligible:
		total += float(e["weight"])
	var roll := rng.randf() * total
	for e in eligible:
		roll -= float(e["weight"])
		if roll <= 0.0:
			return e["pattern"]
	return eligible[-1]["pattern"]
