class_name EffectState
extends RefCounted
## Süreli güçlendirici ve debuff'ların kalan süreleri (gerçek zamanla akar).

var multiplier_left := 0.0
var multiplier := 1.0
var slow_left := 0.0
var slow_fraction := 0.0
var reverse_left := 0.0
var notification_left := 0.0


func score_multiplier() -> float:
	return multiplier if multiplier_left > 0.0 else 1.0


func time_scale() -> float:
	return 1.0 - slow_fraction if slow_left > 0.0 else 1.0


func reversed() -> bool:
	return reverse_left > 0.0


func update(delta: float) -> void:
	multiplier_left = maxf(0.0, multiplier_left - delta)
	slow_left = maxf(0.0, slow_left - delta)
	reverse_left = maxf(0.0, reverse_left - delta)
	notification_left = maxf(0.0, notification_left - delta)
