class_name EffectState
extends RefCounted
## Süreli güçlendirici ve debuff'ların kalan süreleri (gerçek zamanla akar).

var multiplier_left := 0.0
var multiplier := 1.0
var slow_left := 0.0
var slow_fraction := 0.0
var reverse_left := 0.0
var notification_left := 0.0
## Kütüphane Kartı / Stack Overflow: bir sonraki olumsuz çarpışmayı yutar.
var shield := 0
var magnet_left := 0.0
var preview_left := 0.0
var sleep_left := 0.0
var tunnel_left := 0.0
var confetti_left := 0.0
var wobble_left := 0.0
var wobble_delay := 0.0
## "Derse girmeyelim": sıradaki yoklama otomatik kaçırılır.
var skip_class := false
var skip_show_left := 0.0
## Türev rampası: kısa süreli hız artışı.
var boost := 1.0
var boost_left := 0.0


func score_multiplier() -> float:
	return multiplier if multiplier_left > 0.0 else 1.0


func time_scale() -> float:
	var t := 1.0 - slow_fraction if slow_left > 0.0 else 1.0
	return t * (boost if boost_left > 0.0 else 1.0)


func reversed() -> bool:
	return reverse_left > 0.0


func asleep() -> bool:
	return sleep_left > 0.0


func wobbly() -> bool:
	return wobble_left > 0.0


func update(delta: float) -> void:
	multiplier_left = maxf(0.0, multiplier_left - delta)
	slow_left = maxf(0.0, slow_left - delta)
	reverse_left = maxf(0.0, reverse_left - delta)
	notification_left = maxf(0.0, notification_left - delta)
	magnet_left = maxf(0.0, magnet_left - delta)
	preview_left = maxf(0.0, preview_left - delta)
	sleep_left = maxf(0.0, sleep_left - delta)
	tunnel_left = maxf(0.0, tunnel_left - delta)
	confetti_left = maxf(0.0, confetti_left - delta)
	wobble_left = maxf(0.0, wobble_left - delta)
	skip_show_left = maxf(0.0, skip_show_left - delta)
	boost_left = maxf(0.0, boost_left - delta)
