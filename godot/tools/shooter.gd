extends Node
## Ekran görüntüsü aracı (xvfb altında): SCENE sahnesini açar, SHOTS
## saniyelerinde OUT_<n>.png kaydeder. RUN=1 ise koşuyu başlatır,
## SWIPES="1.0:left,2.5:up" zamanlanmış swipe'lar gönderir. PLAN=plan.json
## koşuya elle yazılmış bir yerleşim verir. SHOTS_D="800,1500" süre yerine
## koşu mesafesinde çeker.

func _ready() -> void:
	var params := {}
	if OS.get_environment("COURSE") != "":
		params = {"course": OS.get_environment("COURSE"), "assessment": OS.get_environment("ASSESS")}
	Game.params = params
	var save := OS.get_environment("SAVE_JSON")
	if save != "":
		var f := FileAccess.open(Game.progress.save_path, FileAccess.WRITE)
		f.store_string(FileAccess.get_file_as_string(save) if save.ends_with(".json") else save)
		f.close()
		Game.progress.load_save()
	elif OS.get_environment("RESET") == "1":
		Game.progress.reset()
	if OS.get_environment("COMPLETION") != "":
		params["completion"] = JSON.parse_string(FileAccess.get_file_as_string(OS.get_environment("COMPLETION")))
	for kv in OS.get_environment("PARAMS").split(";", false):
		var p := kv.split("=")
		params[p[0]] = int(p[1]) if p[1].is_valid_int() else p[1]
	var scene: Node = load(OS.get_environment("SCENE")).instantiate()
	# PLAN=plan.json: koşu sahnesine elle yazılmış yerleşim ({total, events, specials})
	if scene is RunScene and OS.get_environment("PLAN") != "":
		scene.plan_override = JSON.parse_string(FileAccess.get_file_as_string(OS.get_environment("PLAN")))
	get_tree().root.add_child.call_deferred(scene)
	await get_tree().process_frame
	await get_tree().process_frame
	var t0 := Time.get_ticks_msec()
	var shots := Array(OS.get_environment("SHOTS").split(",", false)).map(func(x): return float(x))
	# SHOTS_D: süre yerine koşu mesafesinde (piksel birimi) çek
	var by_distance := OS.get_environment("SHOTS_D") != ""
	if by_distance:
		shots = Array(OS.get_environment("SHOTS_D").split(",", false)).map(func(x): return float(x))
	var swipes := []
	for s in OS.get_environment("SWIPES").split(",", false):
		var parts := s.split(":")
		swipes.append([float(parts[0]), parts[1]])
	if OS.get_environment("RUN") == "1":
		var run := _find_run(get_tree().root)
		if run:
			run.start()
			var hud := run.get_node_or_null("Hud")
			if hud and hud.has_method("hide_start"):
				hud.hide_start()
	var n := 0
	while n < shots.size():
		await get_tree().process_frame
		var el := (Time.get_ticks_msec() - t0) / 1000.0
		for sw in swipes.duplicate():
			if el >= sw[0]:
				var run := _find_run(get_tree().root)
				if run:
					run.handle_swipe(sw[1])
				swipes.erase(sw)
		var run_now := _find_run(get_tree().root) if by_distance else null
		var reached: bool = (run_now != null and run_now.distance >= shots[n]) if by_distance else el >= shots[n]
		if by_distance and el > float(OS.get_environment("TIMEOUT_S") if OS.get_environment("TIMEOUT_S") != "" else "170"):
			break
		if reached and OS.get_environment("PERF") == "1":
			print("PERF draw=%d objects=%d prims=%d fps=%d" % [
				Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),
				Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME),
				Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME),
				Performance.get_monitor(Performance.TIME_FPS)])
		if reached:
			await RenderingServer.frame_post_draw
			get_viewport().get_texture().get_image().save_png("%s_%d.png" % [OS.get_environment("OUT"), n])
			n += 1
	get_tree().quit()


func _find_run(n: Node) -> Node:
	if n is RunScene:
		return n
	for c in n.get_children():
		var r := _find_run(c)
		if r:
			return r
	return null
