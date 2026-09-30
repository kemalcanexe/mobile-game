class_name LevelScore
extends RefCounted
## Level boyunca puan olaylarını biriktirir ve level skorunu hesaplar.
##
## level_skoru = clamp(ham/maks × 100, 0, 100) + ekstra kredi → tavan 100;
## mürekkep bittiyse min(skor, 50).

## Spawn olan bütün (+) nesnelerin çarpansız toplamı.
var max_points := 0.0
## Toplanan puan (Fosforlu çarpanı dahil).
var collected_points := 0.0
## Ceza (pozitif tutulur, çarpan uygulanmaz).
var penalty_points := 0.0
var extra_credit := 0.0
## Özel olaylardan (yoklama, soru kapısı, ofis saati) gelen puan ve cezalar.
## Maksimuma eklenmez: olaylar oyuncuya fırsat/risk olarak yansır.
var event_points := 0.0
var event_penalty := 0.0
var collected_count := 0
var hit_count := 0
var bonus_count := 0


func raw_points() -> float:
	return collected_points + event_points - penalty_points - event_penalty


func register_spawn(base_points: float) -> void:
	max_points += base_points


func collect(base_points: float, multiplier := 1.0) -> void:
	collected_points += base_points * multiplier
	collected_count += 1


func penalize(points: float) -> void:
	penalty_points += absf(points)
	hit_count += 1


func add_event_points(points: float) -> void:
	event_points += points


func add_event_penalty(points: float) -> void:
	event_penalty += absf(points)


func add_extra_credit(credit: float) -> void:
	extra_credit += credit
	bonus_count += 1


## Sonuç sözlüğü: şeffaf döküm için bütün ara değerler.
func finish(rules: GradingRules, ink_remaining: float, ink_depleted: bool) -> Dictionary:
	var r := compute(rules, max_points, collected_points + event_points, penalty_points + event_penalty,
		extra_credit, ink_remaining, ink_depleted)
	# döküm için olaylar ayrı gösterilir; skor hesabı yukarıda birlikte yapıldı
	r["collected"] = collected_points
	r["penalty"] = penalty_points
	r["events"] = event_points - event_penalty
	return r


static func compute(rules: GradingRules, maxp: float, collected: float, penalty: float, bonus: float,
		ink_remaining: float, ink_depleted: bool) -> Dictionary:
	var raw := collected - penalty
	var base := 0.0 if maxp <= 0.0 else clampf(raw / maxp * rules.level_max, 0.0, rules.level_max)
	var clean := rules.clean_paper_credit if (not ink_depleted and ink_remaining >= rules.clean_paper_min_ink) else 0.0
	var score := clampf(base + bonus + clean, 0.0, rules.level_max)
	var capped := false
	if ink_depleted and score > rules.ink_out_cap:
		score = rules.ink_out_cap
		capped = true
	return {
		"max": maxp, "collected": collected, "penalty": penalty, "raw": raw, "base": base,
		"bonus": bonus, "clean": clean, "inkDepleted": ink_depleted, "capped": capped, "score": score,
	}
