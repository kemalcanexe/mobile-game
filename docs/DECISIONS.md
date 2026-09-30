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

## Faz 4 kararları (derinlik ve ses)

Kullanıcının isteği: "yaparken arada bana da göster". Ara ekran görüntüleri ve ses önizleme sayfası faz sırasında paylaşıldı.

1. **Ses kodla üretildi:** 41 efekt ve 4 müzik döngüsü (`menu`, koşu tabanı, koşu melodi katmanı, final) `tools/gen_audio.py` ile sentezlenir; lisans sorunu yok. Koşuda melodi katmanı ilerleme %45'i geçince açılır; kalem cızırtısı hızla incelir, mürekkep azalınca kalınlaşır; toplama sesi kombo ile yükselir; All-nighter'da müzik alçak geçiren süzgeçle boğuklaşır. Ayarlar (müzik / efekt / titreşim) ana menüde, `user://settings.json`'da.
2. **Güçlendiriciler:** Kütüphane Kartı ve CS'te Stack Overflow kartı bir çarpışmayı yutan kalkan; Syllabus 5 sn tehlikelerin üstüne kırmızı "!" ve yere halka koyar (3D'de "önceden gölge" yerine); Çalışma Grubu 6 sn yan şeritlerdeki (+) nesneleri mıknatıs gibi çeker.
3. **Dikkat dağıtıcılar:** yastık (1 sn girdi yok), dizi maratonu (3 sn tünel görüş), parti daveti (3 sn ekranı kaplayan konfeti), "Cuma gecesi" şişesi (karikatür, gözlüklü; 3 sn kamera sallanır ve şerit geçişleri 0,22 sn gecikir), "Derse girmeyelim" arkadaşı (sıradaki yoklama otomatik kaçar).
4. **Özel olaylar plana yerleşir:** level JSON'undaki `events` listesi üreticide kendi bloklarını oluşturur, `specials` olarak koşuya gider; kurallar `data/config/events.json`'da.
   - Yoklama: yeşil şerit + kürsüde profesör; 2 sn orada kalırsan +10, kalmazsan −5.
   - Pop Quiz: 4 sn üç şeritte not yağmuru, araya gizli telefonlar karışır.
   - Grup Ödevi: tembel arkadaş 8 sn puanın yarısını alır; "İş Bölümü" kapısı onu ayırır.
   - Ofis Saati: kapıdan geçince önündeki engeller kaybolur, şeridine bonus notlar dizilir.
   - Soru Kapıları: her ders için 10 soruluk bankadan (`levels/<ders>/questions.json`); doğru +20, yanlış −10.
   - All-nighter: finallerde sahne kararır, Tüki'nin feneri ve kahvelerin ışığı kalır.
5. **Olay puanları maksimuma eklenmez:** Pop Quiz ve ofis saati notları (`nq`), yoklama ve soru kapısı puanları ayrı tutulur (`event_points` / `event_penalty`) ve döküme "Olaylar" satırı olarak yazılır. Böylece olaylar fırsat/risktir, kaçırmak %100'ü imkânsız kılmaz.
6. **Tema mekanikleri:**
   - CALC 101: türev rampası. Tüki'yi fırlatır; 2 sn hız ×1,35 ve puan ×2 verir.
   - PHYS 101: yerçekimi bölgesi (ay yerçekimi, ↑/↓ yer değiştirir) ve sürtünmesiz buz bölgesi (şerit değişimi yavaş ve hedefi geçip geri kayar).
   - CS 101: aralıklarla şerit değiştiren bug'lar (zıplanır) ve Stack Overflow kalkanı.
   - Ertelenenler: asimptot duvarları ve Infinite loop bölümü; tasarımları 3D'de ayrıca düşünülmeli.
7. **Prof. Kırmızı:**
   - Görünüm: her finalde yolun önünde süzülen dev kırmızı kalem. Gözlüklü, derse göre kostüm giyer: CALC'ta mezuniyet kepi, PHYS'te laboratuvar önlüğü, CS'te kulaklık.
   - Saldırılar: plandaki `bx` (✗) ve `bl` ("ÇIKMAZ" çizgisi) nesneleri görünmez başlar. Varıştan 1,9 sn önce şerit kırmızı kesik çizgiyle işaretlenir, 1,0 sn önce ✗ fırlatılıp yere çakılır. Saldırılar planın parçası olduğu için doğrulayıcının adillik kuralları (üç şerit birden kapanmaz) geçerlidir.
   - Faz geçişleri: %33 ve %66'da "EK SORU!" ve hız bir kademe (+0,08) artar. Kademe `SpeedCurve`'e dahildir, yani level süresi korunur.
   - Final sonu: son %15'te üç soru kapısı art arda gelir. Sayfa sonunda profesör notu görüp baş sallar (≥85), kaş kaldırır (≥60) ya da yüzünü avuçlar.
8. **Bariyerler** Kenney modeli yerine kırmızı-beyaz çizgili, uyarı lambalı özel modelle değiştirildi (uzaktan "zıpla" diye okunuyor).
9. **Denge botu:** `tools/soak.gd` bütün level'ları basit bir botla (kusursuz ya da `BOT=sloppy`) oynatır, çalışma hatalarını ve skorları raporlar.
10. **Faz 3'ten kalan bir hata düzeltildi:** Jolt'un `WorldBoundaryShape3D`'si ±1000 m ile sınırlı. Tüki her level'da ~50-60. saniyede zeminin içinden düşüyor, notlara ve kapılara temas edemiyordu (mesafe z'den ölçüldüğü için koşu sürüyordu). Denge botu bunu ortaya çıkardı. Zemin artık Tüki ile birlikte taşınıyor; `test_uzun_kosuda_zemin_hep_var` testi hatayı yakalıyor.
11. **Soru kapısında okuma süresi:** soru, kapıdan hıza göre 2,4 sn önce görünür (sabit satır sayısı finalin yüksek hızında ~0,5 sn'ye düşüyordu).
12. **Denge botu sonuçları:** kusursuz bot 15 level'ın hepsinde 100 aldı. Tepkisi gecikmeli ve arada yanlış şerit seçen bot A ile C- arasında kaldı, en düşük PHYS 101 Proje (71). Gerçek oyuncularla test yapılana kadar sayılar değiştirilmedi.
