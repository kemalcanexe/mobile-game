class_name LevelGenerator
extends RefCounted
## Level tanımı + desen kütüphanesinden seed'li, deterministik spawn planı.
## Mesafeler level verisinin biriminde (piksel) üretilir.
##
## Plan: {total, events: [{d, lane, code, ...}], specials: [{d, type, ...}]}.
## "specials" koşu sırasında olay yöneticisinin işlediği olaylardır (yoklama,
## soru kapısı, bölgeler, boss fazları); olay blokları desenlerin arasına
## yerleştirilir ve kendi nesnelerini üretir.

const EMPTY := ".."


static func generate(level: Dictionary, patterns: Dictionary, cfg: Dictionary, semester_mult := 1.0,
		questions: Array = [], events_cfg: Dictionary = {}) -> Dictionary:
	var curve := SpeedCurve.from_dict(level["speed"], semester_mult, level.get("boss", {}))
	var scroll: Dictionary = cfg["scroll"]
	var base_speed := float(scroll["baseSpeed"])
	var row := float(scroll["rowSpacing"])
	var total := curve.distance_for(float(level["durationSeconds"]), base_speed)
	var rng := RandomNumberGenerator.new()
	rng.seed = int(level["seed"])
	var events: Array = []
	var specials: Array = []
	var end := total - int(scroll["endMarginRows"]) * row
	var cursor := float(scroll["warmupSeconds"]) * base_speed * curve.multiplier_at(0)
	var script: Array = _sorted(level.get("script", []))
	var level_events: Array = _sorted(level.get("events", []))
	var si := 0
	var ei := 0
	var gap_min := int(level["gapRows"]["min"])
	var gap_max := int(level["gapRows"]["max"])
	var ctx := {"row": row, "rng": rng, "events": events, "specials": specials, "cfg": events_cfg,
		"questions": _shuffled(questions, rng), "qi": 0, "gate_id": 0}
	while cursor < end:
		var progress := cursor / total
		if ei < level_events.size() and float(level_events[ei]["at"]) <= progress:
			var speed := base_speed * curve.multiplier_at(progress)
			var used := _event_block(level_events[ei]["type"], cursor, speed, end, ctx)
			ei += 1
			cursor += used + gap_min * row
			continue
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
	# koşu boyunca süren durumlar
	for z in level.get("zones", []):
		specials.append({"type": "zone", "zone": z["type"], "d": float(z["at"]) * total,
			"length": int(z["rows"]) * row})
	if level.has("boss"):
		specials.append({"type": "boss", "d": 0.0})
		for p in level["boss"]["phases"]:
			specials.append({"type": "bossPhase", "d": float(p) * total})
	if level.has("allNighter") and events_cfg.has("allNighter"):
		specials.append({"type": "allNighter", "d": float(events_cfg["allNighter"]["from"]) * total})
	events.sort_custom(func(a, b) -> bool: return float(a["d"]) < float(b["d"]))
	specials.sort_custom(func(a, b) -> bool: return float(a["d"]) < float(b["d"]))
	return {"total": total, "events": events, "specials": specials}


## Olay bloğunu yerleştirir; kullandığı mesafeyi döndürür.
static func _event_block(type: String, cursor: float, speed: float, end: float, ctx: Dictionary) -> float:
	var row: float = ctx["row"]
	var rng: RandomNumberGenerator = ctx["rng"]
	var events: Array = ctx["events"]
	var specials: Array = ctx["specials"]
	var c: Dictionary = ctx["cfg"].get(type, {})
	match type:
		"rollCall":
			# yeşil şerit: 2 sn orada kal. Şeritte seyrek kartlar, diğerleri boş.
			var lane := rng.randi_range(0, 2)
			var lead := int(c["leadRows"])
			var window := ceili(float(c["windowSeconds"]) * speed / row)
			specials.append({"type": "rollCall", "d": cursor + lead * row, "length": window * row, "lane": lane})
			for r in range(lead, lead + window, 2):
				_add(events, cursor + r * row, lane, "fc", end)
			return (lead + window + 1) * row
		"popQuiz":
			# uyarısız not yağmuru; arada gizli telefonlar
			var rows := ceili(float(c["seconds"]) * speed / row)
			var lead := int(c["leadRows"])
			specials.append({"type": "popQuiz", "d": cursor, "length": (lead + rows) * row})
			for r in rows:
				var phone_lane := rng.randi_range(0, 2) if (r + 1) % int(c["phoneEvery"]) == 0 else -1
				for lane in 3:
					_add(events, cursor + (lead + r) * row, lane, c["phone"] if lane == phone_lane else c["item"], end)
			return (lead + rows) * row
		"groupProject":
			# tembel arkadaş takılır; "İş Bölümü" kapısı onu ayırır
			var after := int(c["gateAfterRows"])
			var gate_lane := rng.randi_range(0, 2)
			specials.append({"type": "groupProject", "d": cursor})
			var lane := rng.randi_range(0, 2)
			for r in range(1, after, 2):
				lane = clampi(lane + rng.randi_range(-1, 1), 0, 2)
				_add(events, cursor + r * row, lane, "nt", end)
			_add(events, cursor + after * row, gate_lane, c["gate"], end)
			return (after + 1) * row
		"officeHours":
			var lane := rng.randi_range(0, 2)
			specials.append({"type": "officeHours", "d": cursor + row, "lane": lane})
			_add(events, cursor + row, lane, c["gate"], end)
			return 2 * row
		"questionGate":
			var qs: Array = ctx["questions"]
			if qs.is_empty():
				return 0.0
			var q: Dictionary = qs[int(ctx["qi"]) % qs.size()]
			ctx["qi"] = int(ctx["qi"]) + 1
			var id := int(ctx["gate_id"])
			ctx["gate_id"] = id + 1
			var order := [0, 1, 2]
			_shuffle(order, rng)
			# soruyu okuyup karar vermek için hıza göre sabit süre
			var lead := ceili(float(c["leadSeconds"]) * speed / row)
			var gd := cursor + lead * row
			var correct_lane := order.find(0)
			specials.append({"type": "questionGate", "d": cursor, "gateD": gd, "id": id, "q": q["q"],
				"correct": correct_lane})
			for lane in 3:
				var e := _add(events, gd, lane, c["gate"], end)
				if not e.is_empty():
					e["gate"] = id
					e["text"] = q["answers"][order[lane]]
					e["correct"] = lane == correct_lane
			return (lead + 1 + int(c["afterRows"])) * row
	push_warning("bilinmeyen olay: " + type)
	return 0.0


static func _add(events: Array, d: float, lane: int, code: String, end: float) -> Dictionary:
	if d > end:
		return {}
	var e := {"d": d, "lane": lane, "code": code}
	events.append(e)
	return e


static func _sorted(list: Array) -> Array:
	var out := list.duplicate()
	out.sort_custom(func(a, b) -> bool: return float(a["at"]) < float(b["at"]))
	return out


static func _shuffle(a: Array, rng: RandomNumberGenerator) -> void:
	for i in range(a.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var t = a[i]
		a[i] = a[j]
		a[j] = t


static func _shuffled(a: Array, rng: RandomNumberGenerator) -> Array:
	var out := a.duplicate()
	_shuffle(out, rng)
	return out


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
