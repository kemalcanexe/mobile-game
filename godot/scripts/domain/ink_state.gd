class_name InkState
extends RefCounted
## Mürekkep barı (can sistemi).

var max_ink: float
var low_threshold: float
var current: float


func _init(p_max := 100.0, p_low := 25.0) -> void:
	max_ink = p_max
	low_threshold = p_low
	current = p_max


func fraction() -> float:
	return current / max_ink


func is_empty() -> bool:
	return current <= 0.0


func is_low() -> bool:
	return current < low_threshold


## Pozitif doldurur (tavan max), negatif azaltır (taban 0).
func apply(delta: float) -> void:
	current = clampf(current + delta, 0.0, max_ink)
