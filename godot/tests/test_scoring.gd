extends TestCase


func _score(collected: float, penalty := 0.0, bonus := 0.0, ink := 40.0, depleted := false, maxp := 200.0) -> Dictionary:
	return LevelScore.compute(rules(), maxp, collected, penalty, bonus, ink, depleted)


func test_level_skoru() -> void:
	var r := _score(170, 20)
	eq(r["raw"], 150.0)
	eq(r["base"], 75.0)
	eq(r["score"], 75.0)
	eq(_score(10, 50)["score"], 0.0, "negatif clamp")
	eq(_score(300)["score"], 100.0, "fosforlu clamp")
	eq(_score(180, 0, 6)["score"], 96.0, "bonus")
	eq(_score(198, 0, 6)["score"], 100.0, "bonus tavan")
	eq(_score(100, 0, 0, 50)["clean"], 2.0, "temiz kağıt")
	eq(_score(100, 0, 0, 49.9)["clean"], 0.0)
	eq(_score(0, 0, 0, 40, false, 0)["base"], 0.0, "maks 0")


func test_murekkep_bitince_50_tavani() -> void:
	var r := _score(180, 0, 3, 0, true)
	eq(r["score"], 50.0)
	check(r["capped"])
	eq(r["clean"], 0.0)
	var low := _score(60, 0, 0, 0, true)
	eq(low["score"], 30.0)
	check(not low["capped"])


func test_tracker() -> void:
	var t := LevelScore.new()
	t.register_spawn(10)
	t.register_spawn(10)
	t.collect(10, 2)
	t.penalize(-5)
	t.add_extra_credit(3)
	eq(t.max_points, 20.0)
	eq(t.collected_points, 20.0)
	eq(t.penalty_points, 5.0)
	eq(t.raw_points(), 15.0)
	eq(t.bonus_count, 1)
	eq(t.finish(rules(), 90, false)["score"], 80.0)


func test_murekkep() -> void:
	var ink := InkState.new(100, 25)
	ink.apply(25)
	eq(ink.current, 100.0)
	ink.apply(-80)
	check(ink.is_low())
	near(ink.fraction(), 0.2, 1e-12)
	ink.apply(-50)
	check(ink.is_empty())


func test_olay_puanlari_maksimuma_eklenmez() -> void:
	var s := LevelScore.new()
	s.register_spawn(100)
	s.collect(60)
	s.add_event_points(20)
	s.add_event_penalty(-10)
	eq(s.raw_points(), 70.0, "60 + 20 − 10")
	var r := s.finish(rules(), 40.0, false)
	eq(r["max"], 100.0, "maksimum değişmez")
	eq(r["collected"], 60.0, "dökümde toplanan ayrı")
	eq(r["events"], 10.0, "olaylar net +10")
	eq(r["base"], 70.0)
