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
