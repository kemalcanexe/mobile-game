class_name Ambience
## Mekân ön ayarından ortam kurar: gökyüzü/arka plan, AgX tonlama, ışıma,
## ortam gölgesi, sis ve güneş. RunScene ve menüler aynı kurucuyu kullanır.


## Dönen sözlük: {env: Environment, sky: ProceduralSkyMaterial, sun: DirectionalLight3D}
static func build(parent: Node, p: Dictionary, shadow_distance := 70.0) -> Dictionary:
	var we := WorldEnvironment.new()
	var env := Environment.new()
	var sm := ProceduralSkyMaterial.new()
	sm.sky_top_color = Color(p["skyTop"])
	sm.sky_horizon_color = Color(p["skyHorizon"])
	sm.ground_horizon_color = Color(p["skyHorizon"])
	sm.ground_bottom_color = Color(p["far"]).darkened(0.3)
	sm.sun_angle_max = 20.0
	var sky := Sky.new()
	sky.sky_material = sm
	env.sky = sky
	if str(p.get("background", "")) != "":
		env.background_mode = Environment.BG_COLOR
		env.background_color = Color(p["background"])
	else:
		env.background_mode = Environment.BG_SKY
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(p["ambient"])
	env.ambient_light_energy = float(p["ambientEnergy"])
	env.tonemap_mode = Environment.TONE_MAPPER_AGX
	env.tonemap_exposure = float(p["exposure"])
	env.glow_enabled = float(p["glow"]) > 0.0
	env.glow_intensity = float(p["glow"])
	env.glow_bloom = 0.05
	env.ssao_enabled = true
	env.fog_enabled = true
	env.fog_light_color = Color(p["fog"])
	env.fog_density = float(p["fogDensity"])
	env.fog_sky_affect = 0.3
	env.adjustment_enabled = true
	env.adjustment_saturation = float(p["saturation"])
	env.adjustment_contrast = 1.05
	we.environment = env
	parent.add_child(we)
	var sun := DirectionalLight3D.new()
	sun.light_color = Color(p["sunColor"])
	sun.light_energy = float(p["sunEnergy"])
	sun.rotation_degrees = Vector3(float(p["sunRot"][0]), float(p["sunRot"][1]), 0)
	sun.shadow_enabled = true
	sun.shadow_blur = 1.5
	sun.shadow_bias = 0.04
	# iç mekânda uzak gölgeye gerek yok (telefon için ucuz)
	sun.directional_shadow_max_distance = shadow_distance * (0.6 if bool(p.get("indoor", false)) else 1.0)
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
	parent.add_child(sun)
	return {"env": env, "sky": sm, "sun": sun}
