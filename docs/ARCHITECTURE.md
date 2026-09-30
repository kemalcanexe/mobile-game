# Mimari

> **Güncel sürüm Godot (godot/).** Aşağıda önce 3D sürüm, sonra Flutter (2D) sürümün mimarisi var.

## Godot 3D sürüm

```
godot/
  project.godot, export_presets.cfg
  data/                      # oyun verisi (JSON): config/, levels/ (Flutter ile aynı format)
    config/world3d.json      # 3D ölçek, oyuncu fiziği, kamera, ders temaları
  assets/models/             # Kenney CC0 GLB modelleri
  assets/fonts/              # Baloo 2 + Noto Sans Symbols 2
  scripts/
    domain/                  # saf kurallar: LetterGrade, GradeScale, GradingRules, Gpa, CourseRecord,
                             # Transcript, AcademicStanding, CourseRun, SemesterState, EnrollmentRules,
                             # LevelScore, InkState
    data/                    # Content (JSON yükleme), LevelValidator, SpeedCurve, LevelGenerator, Progress (kayıt)
    autoload/game.gd         # Game: içerik + ilerleme + sahne geçişi
    game/                    # RunScene (koşu), Tuki + TukiModel, Campus (chunk'lı dünya), LaneObject,
                             # ItemFactory, InkTrail, SwipeDetector, EffectState, Fx, Models
    ui/                      # UiKit, T (metinler), RunHud, MenuScreen + 6 ekran
  scenes/                    # main, enrollment, course, run, course_result, semester_report, transcript
  tests/                     # headless test koşucusu + 36 test (domain, veri, gerçek fizikli koşu, derleme)
  tools/                     # xvfb ekran görüntüsü aracı, model ölçüm aracı
```

- **Koordinatlar:** Tüki `-z` yönünde koşar, şeritler `x = (şerit-1) × 2,6 m`. Level verisi 2D piksel; `unitsPerPixel` ile metreye çevrilir.
- **Fizik:** Tüki `CharacterBody3D` (kapsül), yer `WorldBoundaryShape3D`. Nesneler `Area3D`; Tüki'nin hitbox'ı ile örtüşünce kural uygulanır. Kayarken kapsül 0,7 m'ye iner.
- **Dünya:** 30 m'lik parçalar önde üretilir, arkada silinir; içerik parça indeksine göre seed'li.
- **Kayıt:** `user://save.json` (sürüm 3; eski kayıtlar taşınır).

## Flutter 2D sürüm (Faz 1-2)

## Paketler (pub.dev'den doğrulandı, 30.09.2026)

| Paket | Sürüm | Neden |
|---|---|---|
| Flutter / Dart | 3.47.5 / 3.13.4 | stable |
| `flame` | ^1.38.2 | oyun döngüsü, bileşenler, çarpışma, drag olayları |
| `flame_test` | ^2.3.1 | `testWithGame` ile bileşen testleri |
| `flutter_riverpod` | ^3.4.3 | menü ve ilerleme state'i |
| `shared_preferences` | ^2.5.5 | local kayıt (`SharedPreferencesWithCache`) |
| `flutter_localizations` + `intl` | SDK | TR i18n (gen-l10n) |

## Klasör yapısı

```
lib/
  main.dart                      # portre kilidi, prefs, ProviderScope
  app/                           # app shell, tema, palet, i18n, içerik yükleyici, ilerleme
    l10n/app_tr.arb              # bütün metinler (generated/ otomatik)
    game_content.dart            # açılışta tüm JSON'ları yükler
    progress_controller.dart     # Riverpod Notifier: sınav kaydı, ders bitişi, retake
  domain/                        # SAF DART, Flutter/Flame bağımlılığı yok
    grading/                     # AssessmentType, LetterGrade/GradeScale, GradingRules,
                                 # GradeCalculator, GpaCalculator
    progression/                 # CourseRecord, Transcript, RetakePolicy,
                                 # AcademicStanding, CourseRun, SemesterState,
                                 # EnrollmentRules
    scoring/                     # InkState, LevelScoreTracker, LevelScoreResult
  data/
    models/level_definition.dart # LevelDefinition, PatternDef, CourseDefinition…
    level_repository.dart        # assets/levels yükleme
    level_validator.dart         # şema dışı mantık doğrulaması
    save_repository.dart         # KeyValueStore + SaveData (JSON)
    comment_bank.dart            # hocanın yorumları
  game/
    tukenmez_game.dart           # FlameGame + HasCollisionDetection + DragCallbacks
    level_setup.dart             # oyunun ihtiyaç duyduğu her şey (asset yüklemez)
    config/                      # GameConfig, ItemCatalog (game.json, items.json)
    systems/                     # SpeedCurve, LevelGenerator, LaneSystem,
                                 # CollisionRules, EffectState (hepsi saf Dart)
    input/                       # SwipeDetector, InputBuffer (saf Dart)
    doodle/                      # WobblyPen, item/pen çizimleri, ArtCache (Picture)
    components/                  # Pen, LaneObject, Spawner, InkTrail, PaperBackground,
      effects/                   # FloatingText, PaperDecal, NotificationBubble, Stamp
    hud_state.dart, page_map.dart
  ui/
    screens/                     # MainMenu, Enrollment, Course (izlence), Game,
                                 # CourseResult, SemesterResult (karne), Transcript
    overlays/                    # Start, HUD, Pause, LevelSummary
    widgets/                     # PostItButton, TornCard, GradeStamp, InkMeter, PageMapView…
assets/
  config/   grading.json, game.json, items.json, comments.json
  levels/   courses.json, common/patterns.json, calc101/{course,patterns,quiz1,midterm,quiz2,project,final}.json
  fonts/
test/
  domain/ data/ game/ app/ ui/
```

## Veri akışı

```
JSON (assets) ──► GameContent ──► LevelGenerator(seed) ──► SpawnPlan
                                                         │
CourseScreen ─► GameScreen ─► LevelSetup ─► TukenmezGame ┘
                                   │ onFinished(LevelOutcome)
                                   ▼
                     ProgressController.recordLevel ──► SaveRepository (prefs)
                                   │ ders bittiyse
                                   ▼
                  GradeCalculator → Transcript.addResult → CourseResultScreen
```

## JSON şemaları

### Ders: `assets/levels/<ders>/course.json`
```json
{
  "id": "calc101", "code": "CALC 101", "title": "Calculus I", "nickname": "Limitsiz Acı",
  "credits": 4, "semester": 1, "paper": "grid",
  "patternFiles": ["common/patterns.json", "calc101/patterns.json"],
  "levels": { "quiz1": "calc101/quiz1.json", "midterm": "…", "quiz2": "…", "project": "…", "final": "…" }
}
```

### Desen: `patterns.json`
```json
{ "patterns": {
  "book_behind_spill": { "rows": ["og .. ..", "bk .. .."] },
  "integral_gate":     { "mirror": false, "rows": ["ow fx ow", ".. .. .."] }
} }
```
- Satırlar **geliş sırasındadır**: ilk satır Tüki'ye ilk ulaşır. Satırlar arası mesafe `game.json → scroll.rowSpacing` ile belirlenir.
- Her hücre `items.json`'daki 2 harfli bir koddur. `..` boş hücre demektir.
- `mirror` varsayılan olarak `true`'dur; desen rastgele (seed'li) aynalanabilir.
- Doğrulama: hücre sayısı şerit sayısına eşit olmalı, kod bilinmeli, bir satır tamamen duvar olamaz, aynı satırda iki toplanabilir olamaz.

### Level: `quiz1.json`
```json
{
  "id": "calc101.quiz1", "assessment": "quiz1",
  "durationSeconds": 60,
  "speed": { "start": 1.00, "end": 1.25, "curve": "easeInOut" },
  "seed": 101001,
  "gapRows": { "min": 2, "max": 4 },
  "script": [ { "at": 0.12, "pattern": "jump_intro" } ],
  "pool":   [ { "pattern": "cards_line", "weight": 4 },
              { "pattern": "book_behind_spill", "weight": 1, "from": 0.4 } ]
}
```
- Toplam mesafe `D = T · v0 / ∫₀¹ dp / m(p)` ile hesaplanır. `m(p)`, mesafe ilerlemesine göre hız çarpanıdır.
- Üretici önce `script` girdilerini `at` ilerlemesinde yerleştirir. Aradaki boşlukları `pool`'dan ağırlıklı ve seed'li seçimle doldurur (`from`/`to` ilerleme aralığına bakar).

### Müfredat: `curriculum.json`
```json
{ "requiredSemesters": 8,
  "semesters": [ { "index": 1, "offered": ["calc101", "phys101", "cs101"] } ] }
```

### Nesne: `items.json`
`code, id, kind (collectible|bonus|powerUp|distraction|groundObstacle|airObstacle|wall), art, points, ink, extraCredit, effect{type, value, duration}`

## Faz 1 iş kırılımı ve durum

| İş | Durum |
|---|---|
| Proje iskeleti, paketler, font, portre kilidi | ✅ |
| Kayan defter sayfası, 3 şerit, sabit kalem, mürekkep izi | ✅ |
| 4 yönlü swipe, fast-fall, input buffer | ✅ |
| JSON spawn desenleri (+ tüm zorunlu nesneler, Bonus Soru dahil) | ✅ |
| Level içi hız eğrisi + level'lar arası hız artışı | ✅ |
| Mürekkep barı, erken bitiş, 50 tavanı | ✅ |
| HUD (skor, canlı %, mürekkep, ilerleme, pause, efekt etiketleri) | ✅ |
| Level sonu (sayfa haritası, döküm, skor, harf, hoca yorumu) | ✅ |
| CALC 101'in 5 level'ı + ders sonu (ağırlıklı tablo, damga, GPA değişimi) | ✅ |
| Local kayıt | ✅ |
| domain unit testleri | ✅ |
| flame_test bileşen testleri | ✅ |
| `flutter analyze` temiz, `flutter test` yeşil, ekran görüntüleriyle doğrulama | ✅ (web build üzerinden) |

## Faz 2 iş kırılımı ve durum

| İş | Durum |
|---|---|
| Dönem modeli (`SemesterState`), ders seçme kuralları (`EnrollmentRules`), müfredat verisi | ✅ |
| Ders seçimi ekranı (zorunlu retake, Probation sınırı, canlı doğrulama) | ✅ |
| Transkript ekranı (dönem GPA, CGPA, "R", Dean's List yıldızı, onur adaylığı) | ✅ |
| Dönem sonu karnesi (Dean's List / Probation damgası, sonraki dönem) | ✅ |
| F sonrası retake akışı (sonraki dönemde zorunlu seçim) | ✅ |
| 2 yeni ders: PHYS 101 (milimetrik) ve CS 101 (terminal), 5'er level + desenler | ✅ |
| Kayıt formatı v2 ve v1'den otomatik taşıma | ✅ |
