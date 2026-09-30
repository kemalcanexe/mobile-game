class_name SpeedCurve
extends RefCounted
## Level içi hız çarpanı. İlerleme (0-1) mesafe üzerinden ölçülür; böylece
## Kahve oyunu yavaşlattığında desenler ve eğri bozulmaz.

var start := 1.0
var end := 1.0
var curve := "easeInOut"
var semester_multiplier := 1.0
## Boss faz geçişleri: bu ilerlemelerde hız bir kademe (step) artar.
var steps: Array = []
var step := 0.0


static func from_dict(d: Dictionary, p_semester := 1.0, boss: Dictionary = {}) -> SpeedCurve:
	var s := SpeedCurve.new()
	s.start = float(d["start"])
	s.end = float(d["end"])
	s.curve = str(d.get("curve", "easeInOut"))
	s.semester_multiplier = p_semester
	if not boss.is_empty():
		s.steps = boss.get("phases", [])
		s.step = float(boss.get("speedStep", 0.0))
	return s


func _ease(p: float) -> float:
	match curve:
		"linear":
			return p
		"easeIn":
			return p * p
		_:
			return p * p * (3.0 - 2.0 * p)


func multiplier_at(progress: float) -> float:
	var p := clampf(progress, 0.0, 1.0)
	var bonus := 0.0
	for at in steps:
		if p >= float(at):
			bonus += step
	return (start + (end - start) * _ease(p) + bonus) * semester_multiplier


## Verilen sürede bu eğriyle katedilecek mesafe: D = T·v0 / ∫₀¹ dp/m(p) (Simpson).
func distance_for(duration: float, base_speed: float) -> float:
	var steps := 200
	var h := 1.0 / steps
	var sum := 1.0 / multiplier_at(0) + 1.0 / multiplier_at(1)
	for i in range(1, steps):
		sum += (4.0 if i % 2 == 1 else 2.0) / multiplier_at(i * h)
	return duration * base_speed / (sum * h / 3.0)
