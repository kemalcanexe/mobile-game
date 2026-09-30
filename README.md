# TÜKENMEZ: GPA Run

> *"Mürekkebin bitebilir, hırsın bitmez."*

Bir tükenmez kalem (Tüki) olarak defter sayfasında 3 şeritli koşu. Her level bir sınav, 5 sınav bir ders,
her ders sonunda karneye bir harf notu ve 4.0 skalasında GPA. Her dönem ders seçilir, dönem sonunda karne
gelir (Dean's List / Probation), F alınan ders tekrar alınır. Flutter + Flame.

**Durum:** Faz 2 tamam: CALC 101, PHYS 101, CS 101; dönem, ders seçimi, karne, transkript.
Görsel yön için kullanıcı geri bildirimi (3D, daha eğlenceli): [`docs/FEEDBACK.md`](docs/FEEDBACK.md)

- Tasarım dokümanı: [`GAME_PROPOSAL.md`](GAME_PROPOSAL.md)
- Mimari ve JSON şemaları: [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)
- Kararlar ve varsayımlar: [`docs/DECISIONS.md`](docs/DECISIONS.md)

| Menü | İzlence | Oyun | Level sonu | Ders sonu |
|---|---|---|---|---|
| ![](docs/screenshots/01_menu.png) | ![](docs/screenshots/02_syllabus.png) | ![](docs/screenshots/04_gameplay.png) | ![](docs/screenshots/06_level_summary.png) | ![](docs/screenshots/07_course_result.png) |

| Ders seçimi | Karne | Transkript | CS 101 | PHYS 101 |
|---|---|---|---|---|
| ![](docs/screenshots/09_enrollment.png) | ![](docs/screenshots/10_term_report_deans.png) | ![](docs/screenshots/12_transcript.png) | ![](docs/screenshots/13_cs101_terminal.png) | ![](docs/screenshots/14_phys101_millimeter.png) |

## Çalıştırma

```bash
flutter pub get
flutter run            # bağlı cihaz veya emülatör/simülatör
flutter run -d chrome  # hızlı deneme (fare sürüklemesi = swipe)
```

## Kontroller

| Swipe | Aksiyon |
|---|---|
| ← → | Satır atla (şerit değiştir) |
| ↑ | Kalem kaldır (zıpla, yer engellerini aşar) |
| ↓ | Yatık yazı (eğil, hava engellerinin altından geçer). Havadayken hızla iner. |

## Test

```bash
flutter analyze
flutter test           # domain + data + flame_test + widget testleri
```

## İçerik ekleme

Yeni bir ders eklemek için kod değil veri eklenir: `assets/levels/<ders>/` altına `course.json`, 5 level
JSON'u ve isteğe bağlı bir `patterns.json` koy, ardından `assets/levels/courses.json`'a ekle ve
`pubspec.yaml`'daki `assets:` listesine klasörü yaz. Yükleme sırasında veri doğrulanır ve hatalar
satır satır raporlanır. Oyun sabitleri `assets/config/` altındadır.
