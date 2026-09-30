extends Node
## Ses: efekt havuzu, katmanlı müzik, kalem cızırtısı ve titreşim.
## Ayarlar (müzik/efekt/titreşim açık mı) user://settings.json'da saklanır.

const CONFIG := "res://data/config/audio.json"
const SETTINGS := "user://settings.json"
const MUSIC_BUS := "Music"
const SFX_BUS := "Sfx"

var cfg: Dictionary = {}
var music_on := true
var sfx_on := true
var haptics_on := true

var _streams := {}
var _voices: Array[AudioStreamPlayer] = []
var _next_voice := 0
var _music: AudioStreamPlayer
var _lead: AudioStreamPlayer
var _scratch: AudioStreamPlayer
var _track := ""
var _lowpass: AudioEffectLowPassFilter
var _combo := 0
var _combo_timer := 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var f := FileAccess.open(CONFIG, FileAccess.READ)
	if f:
		var parsed = JSON.parse_string(f.get_as_text())
		if parsed is Dictionary:
			cfg = parsed
	if cfg.is_empty():
		push_error("audio.json okunamadı")
		return
	_setup_buses()
	for i in int(cfg["voices"]):
		var p := AudioStreamPlayer.new()
		p.bus = SFX_BUS
		add_child(p)
		_voices.append(p)
	_music = _player(MUSIC_BUS)
	_lead = _player(MUSIC_BUS)
	_scratch = _player(SFX_BUS)
	_scratch.stream = _load("res://assets/audio/sfx/pen_scratch.wav")
	_scratch.volume_db = float(cfg["scratch"]["db"])
	_load_settings()


func _player(bus: String) -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.bus = bus
	add_child(p)
	return p


func _setup_buses() -> void:
	for bus in [MUSIC_BUS, SFX_BUS]:
		if AudioServer.get_bus_index(bus) == -1:
			AudioServer.add_bus()
			var idx := AudioServer.bus_count - 1
			AudioServer.set_bus_name(idx, bus)
			AudioServer.set_bus_send(idx, "Master")
	var music_idx := AudioServer.get_bus_index(MUSIC_BUS)
	AudioServer.set_bus_volume_db(music_idx, float(cfg["musicDb"]))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(SFX_BUS), float(cfg["sfxDb"]))
	_lowpass = AudioEffectLowPassFilter.new()
	_lowpass.cutoff_hz = float(cfg["dayCutoffHz"])
	AudioServer.add_bus_effect(music_idx, _lowpass)


func _load(path: String) -> AudioStream:
	if not _streams.has(path):
		_streams[path] = load(path) if ResourceLoader.exists(path) else null
	return _streams[path]


func _process(delta: float) -> void:
	if _combo_timer > 0.0:
		_combo_timer -= delta
		if _combo_timer <= 0.0:
			_combo = 0


# ------------------------------------------------------------------ efekt

## Adı verilen efekti çalar; seviyesi audio.json'daki tablodan gelir.
func play(sfx_name: String, pitch := 1.0, extra_db := 0.0) -> void:
	if not sfx_on or cfg.is_empty():
		return
	var stream := _load("res://assets/audio/sfx/%s.wav" % sfx_name)
	if stream == null:
		push_warning("ses yok: " + sfx_name)
		return
	var p := _voices[_next_voice]
	_next_voice = (_next_voice + 1) % _voices.size()
	p.stream = stream
	p.pitch_scale = pitch
	p.volume_db = float(cfg["sfx"].get(sfx_name, 0.0)) + extra_db
	p.play()


## Arka arkaya toplamada pitch kademeli yükselir (kombo hissi).
func play_collect(big := false) -> void:
	var c: Dictionary = cfg["collectPitch"]
	var pitch := minf(1.0 + _combo * float(c["step"]), float(c["max"]))
	_combo += 1
	_combo_timer = float(c["resetSeconds"])
	play("collect_big" if big else "collect", pitch)


func vibrate(kind: String) -> void:
	if haptics_on and not cfg.is_empty():
		Input.vibrate_handheld(int(cfg["haptics"].get(kind, 20)))


# ------------------------------------------------------------------ müzik

## Parçayı çapraz geçişle değiştirir. "" müziği durdurur.
func music(track: String) -> void:
	if cfg.is_empty() or track == _track:
		return
	_track = track
	var fade := float(cfg["crossfade"])
	var tw := create_tween()
	tw.tween_property(_music, "volume_db", -40.0, fade * 0.5)
	tw.parallel().tween_property(_lead, "volume_db", -60.0, fade * 0.5)
	tw.tween_callback(func() -> void:
		_music.stop()
		_lead.stop()
		if track == "" or not cfg["tracks"].has(track):
			return
		_music.stream = _load(cfg["tracks"][track])
		_music.volume_db = -40.0
		if music_on:
			_music.play()
		# melodi katmanı yalnızca koşu parçasında, sessiz başlar
		if track == "run" and cfg["tracks"].has("runLead"):
			_lead.stream = _load(cfg["tracks"]["runLead"])
			_lead.volume_db = -60.0
			if music_on:
				_lead.play()
	)
	tw.tween_property(_music, "volume_db", 0.0, fade * 0.5)


func current_track() -> String:
	return _track


## Melodi katmanını açar/kapatır (koşuda ilerleme ile).
func set_lead(on: bool) -> void:
	if not _lead.playing:
		return
	create_tween().tween_property(_lead, "volume_db", 0.0 if on else -60.0, float(cfg["layerFade"]))


## All-nighter: müzik boğuklaşır (alçak geçiren süzgeç).
func set_night(on: bool) -> void:
	if _lowpass == null:
		return
	var target := float(cfg["nightCutoffHz"] if on else cfg["dayCutoffHz"])
	create_tween().tween_property(_lowpass, "cutoff_hz", target, float(cfg["layerFade"]))


# --------------------------------------------------------- kalem cızırtısı

func scratch(on: bool) -> void:
	if _scratch == null:
		return
	if on and sfx_on and not _scratch.playing:
		_scratch.play()
	elif not on:
		_scratch.stop()


## 0-1 hız oranına göre cızırtı perdesi; mürekkep azsa perde düşer.
func scratch_speed(t: float, low_ink: bool) -> void:
	var s: Dictionary = cfg["scratch"]
	var pitch := lerpf(float(s["pitchMin"]), float(s["pitchMax"]), clampf(t, 0.0, 1.0))
	if low_ink:
		pitch *= float(s["lowInkPitch"])
	_scratch.pitch_scale = pitch


# ------------------------------------------------------------------ ayarlar

func set_music_on(on: bool) -> void:
	music_on = on
	if on and _track != "" and not _music.playing:
		_music.play()
		if _track == "run":
			_lead.play()
	elif not on:
		_music.stop()
		_lead.stop()
	_save_settings()


func set_sfx_on(on: bool) -> void:
	sfx_on = on
	if not on:
		_scratch.stop()
	_save_settings()


func set_haptics_on(on: bool) -> void:
	haptics_on = on
	_save_settings()


func _load_settings() -> void:
	if not FileAccess.file_exists(SETTINGS):
		return
	var f := FileAccess.open(SETTINGS, FileAccess.READ)
	var d = JSON.parse_string(f.get_as_text()) if f else null
	if d is Dictionary:
		music_on = bool(d.get("music", true))
		sfx_on = bool(d.get("sfx", true))
		haptics_on = bool(d.get("haptics", true))


func _save_settings() -> void:
	var f := FileAccess.open(SETTINGS, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify({"music": music_on, "sfx": sfx_on, "haptics": haptics_on}))
