extends Node3D
## Nesne vitrini (xvfb altında): CODES listesindeki nesneleri LOC mekânının
## görünümüyle ızgaraya dizer ve OUT.png kaydeder.
##   CODES=fc,nt,fx LOC=library COLS=4 OUT=/tmp/v.png

func _ready() -> void:
	ItemArt.location = OS.get_environment("LOC")
	var codes := OS.get_environment("CODES").split(",", false)
	var cols := int(OS.get_environment("COLS")) if OS.get_environment("COLS") != "" else 4
	var preset := Game.content.location_preset(ItemArt.location if ItemArt.location != "" else "quad")
	var amb := Ambience.build(self, preset, 40.0)
	(amb["env"] as Environment).fog_enabled = false
	var floor := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(80, 80)
	floor.mesh = pm
	floor.material_override = LocKit.mat(Color(preset["far"]).lerp(Color.WHITE, 0.35), 0.9)
	add_child(floor)
	var gap := 3.2
	var rows := ceili(float(codes.size()) / cols)
	for i in codes.size():
		var item: Dictionary = Game.content.items[codes[i]]
		var built := ItemFactory.build(item, 2.6, {"text": "2x", "correct": true})
		var n: Node3D = built["node"]
		n.position = Vector3((i % cols - (cols - 1) / 2.0) * gap, 0, (i / cols - (rows - 1) / 2.0) * gap * 1.1)
		n.rotation.y = 0.35
		add_child(n)
		var l := Label3D.new()
		l.text = "%s · %s" % [codes[i], item["id"]]
		l.font = UiKit.font()
		l.font_size = 40
		l.pixel_size = 0.006
		l.modulate = Color("#1E2A3A")
		l.outline_size = 8
		l.outline_modulate = Color.WHITE
		l.rotation.x = -0.9
		l.position = n.position + Vector3(0, 0.05, 1.3)
		add_child(l)
	var cam := Camera3D.new()
	cam.fov = 40
	add_child(cam)
	cam.position = Vector3(0, 4.5 + rows * 2.2, 5.5 + rows * 2.8)
	cam.look_at(Vector3(0, 0.9, 0.3))
	for f in 8:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(OS.get_environment("OUT"))
	get_tree().quit()
