# TÜKENMEZ: GPA Run

> *"Mürekkebin bitebilir, hırsın bitmez."*

Kampüste koşan 3D bir tükenmez kalem: **Tüki**. Her koşu bir sınav, 5 sınav bir ders, her ders sonunda
karneye harf notu ve 4.0 skalasında GPA. Her dönem ders seçilir, dönem sonunda karne gelir
(Dean's List / Probation), F alınan ders tekrar alınır.

**Güncel sürüm: `godot/` (Godot 4.7.2, 3D).** Kökteki Flutter projesi (`lib/`, `test/`) 2D ilk sürümdür ve
referans olarak duruyor.

| Menü | Sınav başı | Koşu | Ders sonucu | Karne |
|---|---|---|---|---|
| ![](docs/screenshots/3d/01_menu.png) | ![](docs/screenshots/3d/04_start.png) | ![](docs/screenshots/3d/05_run_collect.png) | ![](docs/screenshots/3d/09_course_result.png) | ![](docs/screenshots/3d/10_term_report.png) |

| Engeller | CS 101 gece | İzlence | Sınav sonu | Transkript |
|---|---|---|---|---|
| ![](docs/screenshots/3d/06_run_walls.png) | ![](docs/screenshots/3d/07_cs101_night.png) | ![](docs/screenshots/3d/03_syllabus.png) | ![](docs/screenshots/3d/08_exam_summary.png) | ![](docs/screenshots/3d/11_transcript.png) |

**Faz 4: olaylar, tema mekanikleri, boss**

| Yoklama | Soru kapısı | Türev rampası | Yerçekimi bölgesi | Buz bölgesi |
|---|---|---|---|---|
| ![](docs/screenshots/3d/12_rollcall.png) | ![](docs/screenshots/3d/13_question_gate.png) | ![](docs/screenshots/3d/14_derivative_ramp.png) | ![](docs/screenshots/3d/15_gravity_zone.png) | ![](docs/screenshots/3d/16_ice_zone.png) |

| Prof. Kırmızı | All-nighter | Çalışma grubu | Kalkan + Syllabus |
|---|---|---|---|
| ![](docs/screenshots/3d/17_prof_kirmizi.png) | ![](docs/screenshots/3d/18_all_nighter.png) | ![](docs/screenshots/3d/19_study_group.png) | ![](docs/screenshots/3d/20_shield_syllabus.png) |

- Tasarım dokümanı: [`GAME_PROPOSAL.md`](GAME_PROPOSAL.md)
- Kararlar: [`docs/DECISIONS.md`](docs/DECISIONS.md) · Mimari: [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)
- Kullanıcı geri bildirimi: [`docs/FEEDBACK.md`](docs/FEEDBACK.md)

## Çalıştırma (3D)

1. [Godot 4.7.2](https://godotengine.org/download) indir.
2. `godot/project.godot` dosyasını aç, **F5** ile çalıştır. Bilgisayarda klavye: ← → şerit, ↑ zıpla, ↓ kay.

```bash
# Testler (headless, gerçek fizikle)
godot --headless --fixed-fps 60 --path godot -s res://tests/run_tests.gd

# Bütün level'ları botla oynat (çalışma hatası + denge raporu)
godot --headless --fixed-fps 60 --path godot -s res://tools/soak.gd

# Sesleri yeniden üret (numpy gerekir)
python3 godot/tools/gen_audio.py

# Android APK / Web
godot --headless --path godot --export-release "Android" ../build_godot/android/tukenmez.apk
godot --headless --path godot --export-release "Web" ../build_godot/web/index.html
```

Android release imzası için `GODOT_ANDROID_KEYSTORE_RELEASE_PATH/USER/PASSWORD` ortam değişkenleri kullanılır
(anahtar repoda tutulmaz).

## Kontroller

| Swipe | Aksiyon |
|---|---|
| ← → | Şerit değiştir |
| ↑ | Zıpla (bariyer ve konilerin üstünden) |
| ↓ | Kay (afişlerin altından); havadayken hızla in |

## İçerik ekleme

Yeni ders = veri: `godot/data/levels/<ders>/` altına `course.json`, 5 level JSON'u, `patterns.json` ve
`questions.json` (soru kapıları; ilk şık doğru cevap);
`courses.json` ve `curriculum.json`'a ekle; `world3d.json → themes` altına dersin kampüs temasını yaz.
Level JSON'unda `events` (yoklama, pop quiz, grup ödevi, ofis saati, soru kapısı), `zones`
(yerçekimi, buz), finallerde `boss` ve `allNighter` alanları olayları tanımlar; kuralları
`godot/data/config/events.json`'dadır. Yükleme sırasında veri doğrulanır.
