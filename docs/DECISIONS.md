# Kararlar ve Varsayımlar ("Anladıklarım")

ADIM 0'daki soruların hepsine **varsayılan** cevabı verildi. Bu dosya o cevapları, proposal'dan
kurtarılan değerleri ve uygulama sırasında verilen küçük kararları listeler.

## ADIM 0 cevapları (hepsi varsayılan)

| # | Konu | Karar |
|---|---|---|
| 1 | Dil | Oyun içi Türkçe; baştan `flutter_localizations` + ARB (`lib/app/l10n/app_tr.arb`). Ders kodları ve harf notları İngilizce. |
| 2 | MVP dersi | CALC 101 "Limitsiz Acı", kareli kağıt, 4 kredi |
| 3 | Cihazlar | Telefon öncelikli; tablette oyun alanı ortalanır. **Sapma:** Flutter 3.47'nin tabanı nedeniyle iOS 15.0 ve Android minSdk 24 (önerilen 13/23 değil). |
| 4 | Yön | Yalnızca portre (Android manifest, iOS Info.plist ve `SystemChrome` ile kilitli) |
| 5 | Süre ve hız | 60/80/60/75/90 sn; 1,00x–1,75x. Level uzunluğu **mesafe** olarak hesaplanır. |
| 6 | Ağırlıklar ve harfler | 10/30/10/20/30 ve proposal'daki tablo (`assets/config/grading.json`) |
| 7 | Cezalar | Proposal'daki gibi. MVP dikkat dağıtıcıları: Telefon, Oyun konsolu, Kötü arkadaş ("Hadi kantine!") |
| 8 | Swipe | Eşikler config'de; ayar ekranı ve dokunma bölgeleri Faz 5'e kaldı |
| 9 | Asset | Tamamen programatik doodle (seed'li wobble + boil) |
| 10 | Font | Caveat (başlık ve sayı) + Patrick Hand (UI), OFL, projeye gömülü |
| 11 | Ses ve haptik | Ses Faz 5'te. Haptik MVP'de var (`HapticFeedback`, paket gerektirmiyor). |
| 12 | State | Riverpod (menü ve ilerleme). Oyun state'i Flame içinde kalır. |
| 13 | Kayıt | Local, `SharedPreferencesWithCache` içinde JSON, `SaveRepository` arayüzünün arkasında |
| 14 | Reklam/IAP | Yok |
| 15 | Paket kimliği | `com.kemalcanexe.tukenmez`, proje adı `tukenmez_gpa_run` |
| 16 | Git | Faz sonunda `claude/new-session-2kv797` branch'ine push, PR yok |
| 17 | Test ve demo | Emülatör yok. Doğrulama: `flutter test` + web build + headless Chromium ekran görüntüleri (`docs/screenshots/`) |

## Proposal'dan kurtarılan değerler

Yüklenen Markdown'da `%XX` kalıpları URL-decode edilerek bozulmuştu (`%10` → kontrol karakteri,
`%30` → `0`, `%50` → `P` gibi). Orijinal değerler geri çevrildi:

| Yer | Değer | Not |
|---|---|---|
| §7 ağırlıklar | %10 / %30 / %10 / %20 / %30 | |
| §7 final stretch | son %15 | `game.json → scroll.finalStretchProgress = 0.85` |
| §8.2 Kahve | oyun %30 yavaşlar | |
| §9 düşük mürekkep | %25 | |
| §9 Temiz Kağıt | **≥ %50 mürekkep** | ADIM 0'da 80 önerilmişti; orijinal değer 50 olduğu için 50 kullanıldı. |
| §11 boss fazları | %33 ve %66 | Faz 3 |
| §21 metrikler | D1 ≥ %40, D7 ≥ %15, ilk ders tamamlama ≥ %70, retake %10-25 | |

## Kural yorumları (spesifikasyonda açık olmayanlar)

1. **Fosforlu çarpanı** yalnızca toplananlara uygulanır, cezalara uygulanmaz.
2. **`maks_puan`** yalnızca Flashcard, Ders notu, Formül ve Kitap'ın çarpansız değerlerinden oluşur. Bonus Soru ve güçlendiriciler dahil değildir.
3. **Mürekkep** yalnızca çarpışmalarla azalır. Kartuş toplandığında en fazla 100 olur.
4. **Dikkat dağıtıcılar** her pozda (zıplarken ve eğilirken de) temas eder. Sadece yer engelleri zıplayarak, hava engelleri eğilerek aşılır. Aksi halde zıplamak her şeyi çözerdi.
5. **Fast-fall:** havadayken aşağı swipe atınca kalem iner ve doğrudan eğilir (Subway Surfers'taki roll gibi).
6. **Kahve** yalnızca sayfanın akış hızını yavaşlatır. Kalem hareketleri ve efekt süreleri gerçek zamanda akar.
7. **Kötü arkadaş:** kenar şeritteyse ortaya, ortadaysa seed'li rastgele bir yana çeker.
8. **Konsol debuff'ı** yalnızca sol ve sağı ters çevirir.
9. **Level tekrarı yok.** Level bitince skor hemen kaydedilir. Sınavdan çıkılırsa o level baştan başlar. Dersin tekrarı yalnızca F sonrası retake ile olur.
10. **Retake:** eski kayıt "R" (replaced) olarak saklanır ve CGPA'e girmez. İlk dönemin GPA'i tarihsel olarak değişmez.
11. **Mezuniyet için "F'siz"** şartı, düzeltilmemiş F olmaması anlamına gelir.
12. **Desen kuralı:** bir satırda en fazla bir toplanabilir olabilir. Aksi halde %100'e ulaşmak imkânsızlaşır. `LevelValidator` bu kuralı zorunlu kılar.

## Teknik kararlar

- **Swipe:** parmak eşik mesafesini geçtiği anda tetiklenir (sürükleme bitmeden). Kısa ve hızlı fırlatmalar bırakışta hız eşiğiyle yakalanır.
- **Kamera:** dünya genişliği 360 birimdir. Zoom `min(genişlik/360, yükseklik/600)` olarak hesaplanır. Uzun telefonlarda görünür yükseklik artar, tablette oyun alanı ortalanır.
- **Konum:** nesnelerin konumu her karede global kaydırma mesafesinden hesaplanır (`y = penY − (d_olay − d)`). Nesnelerin kendi hızları yoktur.
- **Hitbox'lar:** Flame `HasCollisionDetection` kullanılır. Kalem aktif, nesneler pasif hitbox'tır. Kurallar `CollisionRules` sınıfında saf Dart olarak durur.
- **Performans:** nesneler havuzdan (object pool) gelir. Mürekkep izi sabit boyutlu bir halka tamponda (`Float64List`) tutulur. Çizimler `Picture` olarak önbelleğe alınır.
- **HUD:** `ValueNotifier` kullanılır ve yalnızca görünür bir değişiklikte bildirim yapar.

## Faz 2 kararları

1. **Müfredat verisi:** `assets/levels/curriculum.json` her dönemde sunulan dersleri tanımlar. Şu an yalnızca 1. dönem tanımlı (CALC 101, PHYS 101, CS 101). Tanımsız dönemlerde yalnızca retake dersleri sunulur. Yeni ders gelene kadar menü "Yeni dersler yakında" gösterir.
2. **Ders seçimi:** Bir dönemde 3-4 ders alınır, Probation'da en fazla 3 (`grading.json → enrollment`). Sunulan ders sayısı alt sınırdan azsa alt sınır o sayıya iner.
3. **F alınan ders bir sonraki dönem zorunlu seçilir** (yer olduğu sürece) ve ders seçimi ekranında kilitli gelir. Faz 1'deki "Dersi tekrar al" butonu kaldırıldı; retake artık ders seçimiyle yapılır.
4. **Retake notu, alındığı dönemin kaydına yazılır.** Eski kayıt "R" olur; ilk dönemin GPA'i tarihsel olarak değişmez.
5. **Dönem, kayıtlı bütün dersler bitince tamamlanır.** Karne ekranından "Sonraki döneme geç" ile ilerlenir. Karnede Dean's List (dönem GPA ≥ 3.50) altın yıldız, Probation (CGPA < 2.00) kırmızı damga olarak gösterilir.
6. **Kayıt formatı v2:** Kayıt dosyasına dönem bilgisi eklendi. v1 kayıtları otomatik taşınır: ilk dönem sayılır, alınmış dersler kayıtlı kabul edilir.
7. **Kağıt temaları:** CALC 101 kareli, PHYS 101 turuncu milimetrik, CS 101 koyu "terminal" (fosfor yeşili mürekkep izi, açık renkli HUD). Temalar `lib/app/paper_theme.dart` içinde; oyun ve menü aynı temayı kullanır.
8. **Yeni derslerin toplanabilirleri:** PHYS 101'de `F=ma` kartı (`fp`), CS 101'de `{ }` kartı (`fk`); ikisi de CALC'taki formül kartı gibi 15 puan. Ders tema mekanikleri (yerçekimi terslenmesi, bug'lar vb.) Faz 3'te.
9. **Kredi:** CALC 101 ve PHYS 101 4 kredi, CS 101 3 kredi.

## Faz 3 kararları (3D yenileme)

1. **Motor: Godot 4.7.2** (kullanıcı seçimi). Renderer: GL Compatibility; hem Android'de hem web'de aynı görünüm, düşük donanımda da çalışır. Fizik: Jolt.
2. **Dünya: kampüs** (kullanıcı seçimi). Her ders kendi bölgesi: CALC 101 güneşli Matematik Bölümü, PHYS 101 gün batımında Fizik Laboratuvarı, CS 101 gece ve neon lambalarla Bilgisayar Laboratuvarı. Temalar `godot/data/config/world3d.json` içinde.
3. **Oyun kuralları birebir taşındı** (GDScript): notlandırma, GPA, retake, dönem, ders seçimi, level skoru. Level verisi ve desenler aynı JSON; 2D piksel birimi `unitsPerPixel = 0.05` ile metreye çevrilir (300 px/s → 15 m/s, satır 3,6 m).
4. **Çarpışma kuralları fizikten doğar:** yer engelleri 1 m yüksekliğinde; gerçek yerçekimli zıplama (tepe 2,1 m, havada 0,62 sn) üstünden geçirir. Hava afişleri 1,2 m'nin üstünde; kayan Tüki (0,7 m) altından geçer. Toplanabilirler ve dikkat dağıtıcılar şerit boyu yüksek, zıplarken de temas edilir. Duvar (ansiklopedi yığını) her durumda çarpar.
5. **Çarpılan nesneler savrulur:** çarpışmada nesne Jolt fizik gövdesine dönüşür, ileri ve yola dışarı doğru uçar.
6. **Tüki 3D modeli kodla üretildi:** kapaklı tükenmez gövde, iri gözler, yanaklar, kollar, spor ayakkabılı bacaklar; koşu, zıplama, kayma, sendeleme animasyonları prosedürel. Arkasında yere mürekkep izi çizer, zıplarken iz kesilir.
7. **Çevre modelleri Kenney'nin CC0 kitleri:** binalar, lambalar, ağaçlar, banklar, bariyerler, koniler, kahve bardağı, kitaplar.
8. **Arayüz yeniden tasarlandı:** Baloo 2 fontu, tombul butonlar, yuvarlak kartlar; her menü ekranının arkasında canlı 3D kampüs ve Tüki. Sınav başında kamera Tüki'nin önündedir, "Başla"ya basınca arkasına süzülür.
9. **Test linki:** Godot web motoru 39,5 MB olduğu için 3 parçaya bölünüp sayfada birleştirilir (yayın sayfasının dosya başı 16 MB sınırı). Oyunun kendisi değişmeden çalışır.
10. **Android:** release APK (arm64 + armv7, 55 MB) şimdilik hata ayıklama anahtarıyla imzalı; mağaza için gerçek bir yükleme anahtarı gerekir.
