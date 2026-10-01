class_name Location
extends RefCounted
## Bir kampüs mekânının tabanı. Alt sınıflar build_chunk() içinde 30 m'lik bir
## parçayı kurar; parça merkezi (0,0,0), yol -z yönünde ilerler.

var id := ""
var preset: Dictionary
var cfg: Dictionary
var accent := Color("#2E6BFF")
var sign_text := ""
var lane_w := 2.6
var chunk_len := 30.0
## Yolun yarı genişliği (şeritler + kenar payı).
var half_road := 4.6


func setup(p_id: String, p_preset: Dictionary, p_cfg: Dictionary, p_accent: Color, p_sign: String) -> void:
	id = p_id
	preset = p_preset
	cfg = p_cfg
	accent = p_accent
	sign_text = p_sign
	lane_w = float(cfg["laneWidth"])
	chunk_len = float(cfg["world"]["chunkLength"])
	half_road = lane_w * 1.5 + 0.7


## c: parça düğümü (yerel koordinat), i: parça indeksi, rng: indekse göre seed'li.
func build_chunk(_c: Node3D, _i: int, _rng: RandomNumberGenerator) -> void:
	pass


## Ders tabelası kemeri her kaç parçada bir çıksın.
func sign_every() -> int:
	return 4


static func create(p_id: String) -> Location:
	match p_id:
		"library":
			return LocLibrary.new()
		"gym":
			return LocGym.new()
		"cafeteria":
			return LocCafeteria.new()
		"lab":
			return LocLab.new()
	return LocQuad.new()


# ---------------------------------------------------------------- ortak parçalar

## Yolun üstünden geçen tabela kemeri (dersin renginde).
func arch(c: Node3D, z: float, frame: Color, text: String, h := 7.4) -> void:
	var b := LocKit.BoxBatch.new(0.55)
	for s in [-1.0, 1.0]:
		b.add(Vector3(0.8, h, 0.8), Vector3(s * (half_road + 0.5), h / 2.0, z), frame)
		b.add(Vector3(1.1, 0.3, 1.1), Vector3(s * (half_road + 0.5), h, z), frame.darkened(0.2))
	b.add(Vector3(half_road * 2 + 2.0, 1.3, 0.6), Vector3(0, h - 0.4, z), accent)
	b.add(Vector3(half_road * 2 + 2.3, 0.18, 0.7), Vector3(0, h + 0.3, z), frame.darkened(0.2))
	b.add(Vector3(half_road * 2 + 2.3, 0.18, 0.7), Vector3(0, h - 1.1, z), frame.darkened(0.2))
	b.flush(c)
	LocKit.label(c, text, 110, Color.WHITE, accent.darkened(0.55), Vector3(0, h - 0.4, z + 0.32))


## Animasyonlu öğrenci (Kenney Mini Characters).
func student(c: Node3D, pos: Vector3, rot_y: float, rng: RandomNumberGenerator, anim := "idle") -> Node3D:
	var names := ["character-female-a", "character-female-b", "character-female-c", "character-female-d",
		"character-male-a", "character-male-b", "character-male-c", "character-male-d"]
	var n := LocKit.model(c, "students", names[rng.randi() % names.size()], pos, rot_y, 1.0, false)
	var ap := n.find_child("AnimationPlayer", true, false) as AnimationPlayer
	if ap and ap.has_animation(anim):
		ap.get_animation(anim).loop_mode = Animation.LOOP_LINEAR
		ap.play(anim)
		ap.seek(rng.randf() * 2.0, true)
		ap.speed_scale = rng.randf_range(0.85, 1.15)
	return n
