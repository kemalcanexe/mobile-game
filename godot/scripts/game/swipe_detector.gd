class_name SwipeDetector
extends RefCounted
## Baskın eksene göre swipe sınıflandırma. Eşik geçildiği anda (parmak
## kalkmadan) swipe üretir; kısa hızlı fırlatmalar bırakışta yakalanır.

const LEFT := "left"
const RIGHT := "right"
const UP := "up"
const DOWN := "down"

var min_distance := 28.0
var min_fling := 380.0
var _acc := Vector2.ZERO
var _active := false
var _fired := false


func start() -> void:
	_acc = Vector2.ZERO
	_active = true
	_fired = false


func update(delta: Vector2) -> String:
	if not _active or _fired:
		return ""
	_acc += delta
	if _acc.length() < min_distance:
		return ""
	_fired = true
	return classify(_acc)


func end(velocity: Vector2) -> String:
	if not _active:
		return ""
	_active = false
	if _fired or velocity.length() < min_fling:
		return ""
	return classify(velocity)


static func classify(v: Vector2) -> String:
	if absf(v.x) > absf(v.y):
		return LEFT if v.x < 0 else RIGHT
	return UP if v.y < 0 else DOWN
