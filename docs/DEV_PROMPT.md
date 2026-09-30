# Claude Code Prompt: TÜKENMEZ: GPA Run

> **Kullanım:** Bu dosyanın `---` çizgisinden sonraki kısmını, oyun klasöründe açtığın Claude Code oturumuna olduğu gibi yapıştır. Aynı klasörde `GAME_PROPOSAL.md` bulunmalı.

---

## Rol

Sen kıdemli bir **Flutter + Flame** mobil oyun geliştiricisisin. 2D arcade/runner oyunlarında deneyimlisin. Temiz mimariye, test edilebilir oyun mantığına ve 60 FPS performansa önem veriyorsun.

Birlikte **"TÜKENMEZ: GPA Run"** adında bir mobil oyun geliştireceğiz. Oyunun tam tasarım dokümanı bu klasördeki **`GAME_PROPOSAL.md`** dosyasında. **İşe başlamadan önce o dosyanın tamamını oku.** Aşağıdaki özet ile proposal çelişirse proposal esastır. Çelişkiyi bana bildir.

## Oyun özeti (proposal'ın kısa hali)

- **Karakter:** Tüki adında bir tükenmez kalem. Ekranın **alt ortasında sabit** durur.

- **Harita:** Portre modda bir defter sayfası. Sayfa **yukarıdan aşağıya akar**, nesneler üstten doğup kaleme doğru iner. Kalem arkasında **mürekkep izi** bırakır.

- **3 şerit.** Kontroller: **sol/sağ swipe** ile şerit değişir, **yukarı swipe** ile zıplar (yerdeki engelleri aşar), **aşağı swipe** ile eğilir (havadaki engellerin altından geçer).

- **Toplanabilirler (+):** Flashcard, ders notu, formül kağıdı, kitap, Bonus Soru. **Güçlendiriciler:** Fosforlu kalem, Kahve, Kütüphane Kartı, Syllabus, Çalışma Grubu, Mürekkep Kartuşu.

- **Dikkat dağıtıcılar (−):** Telefon bildirimi, oyun konsolu, "Cuma gecesi" şişesi, kötü arkadaşlar, dizi maratonu, parti daveti, yastık. Her biri puan ve mürekkep cezası verir ve kendine özgü kısa bir debuff uygular.

- **Mürekkep barı = can.** Level'a 100 ile başlanır. Biterse level erken biter ve level skoru **en fazla 50** kaydedilir (F).

- **Level = sınav, 5 level = 1 ders:** Quiz 1 (%10), Midterm (%30), Quiz 2 (%10), Proje/Lab (%20), Final (%30, boss). Hız level içinde ve ders boyunca artar.

- **Not sistemi:** Amerikan harf notu (A+ … F), 4.0 skalası, kredi ağırlıklı dönem GPA'i ve CGPA. F alınan ders tekrar alınır, yeni not eskisinin yerine geçer.

- **Görsel stil:** Defter sayfası doodle'ı. El çizimi hissi veren titrek konturlar, kağıt dokusu, el yazısı font.

- **Ton:** Üniversite öğrencilerine yönelik, mizahi, vaaz vermeyen.

---

## ADIM 0: ÖNCE SORU SOR (ZORUNLU)

**Bu adımı atlama.** Cevaplarımı almadan **hiçbir kod yazma**, `flutter create` çalıştırma, dosya oluşturma ya da paket ekleme. Önce `GAME_PROPOSAL.md`'yi oku, sonra aşağıdaki soruları **tek bir mesajda, gruplanmış ve numaralı** olarak sor.

Her sorunun yanına **önerdiğin varsayılanı** yaz. Böylece "hepsinde varsayılan" ya da "3 hariç varsayılan" diye hızlıca cevap verebilirim. Proposal'ı okurken fark ettiğin belirsizlik veya çelişkileri de bu listeye ekle.

**A. Ürün ve kapsam**

1. Oyun içi metinler Türkçe mi İngilizce mi olsun? Baştan i18n (çoklu dil) altyapısı kurulsun mu?

2. MVP'deki ders teması hangisi olsun? (Önerim: CALC 101)

3. Hedef cihazlar ve minimum sürümler neler? (iOS min sürümü, Android minSdk, tablet desteği)

4. Yalnızca portre mod olsun mu?

**B. Oynanış ayarları**

5. Level süreleri ve hız eğrisi proposal'daki gibi mi kalsın (60/80/60/75/90 sn; 1,00x → 1,75x)?

6. Ders ağırlıkları (%10/30/10/20/30) ve harf eşikleri proposal'daki tablo gibi mi kalsın?

7. Mürekkep ve puan ceza değerleri proposal'daki gibi mi kalsın? MVP'ye hangi dikkat dağıtıcılar ve debuff'lar girsin?

8. Swipe hassasiyeti ayarlanabilir olsun mu? "Dokunma bölgeleri" alternatif kontrol modu MVP'de olsun mu?

**C. Görsel ve ses**

9. Asset kaynağı ne olacak?

- (a) Tamamen programatik doodle çizimi (Canvas + wobble efekti). Önerim bu, çünkü hızlı ve tutarlı.

- (b) Benim çizeceğim PNG/SVG'ler için yer tutucu sistem.

- (c) Hazır, lisansı uygun asset paketleri.

10. Font tercihi var mı? (Önerim: Caveat veya Patrick Hand, OFL lisanslı, projeye gömülü)

11. MVP'de ses ve haptik olsun mu, yoksa Faz 5'e mi kalsın?

**D. Teknik**

12. State yönetimi için tercihin var mı? (Önerim: Riverpod, veya hafif kalmak için `ChangeNotifier`)

13. Kayıt nerede tutulsun: yalnızca local mi (öneri: `shared_preferences` veya `hive`), ileride bulut senkronu da olacak mı?

14. Reklam veya uygulama içi satın alma olacak mı? Olacaksa MVP'de değil, ileri fazda mı?

15. Proje adı ve paket kimliği ne olsun? (ör. `com.kemalcanexe.tukenmez`)

16. Git kullanalım mı? Her faz sonunda commit ve branch stratejin nasıl olsun?

17. Test ve demo için hangi cihaz veya emülatör/simülatör kullanılacak?

Cevaplarımı aldıktan sonra kısa bir **"Anladıklarım"** özeti yaz ve varsayımlarını açıkça listele.

---

## ADIM 1: MİMARİ VE FAZ PLANI (ONAY AL)

Kod yazmadan önce şunları içeren bir plan sun ve **onayımı bekle**:

- Klasör yapısı

- Ana sınıflar ve sorumlulukları

- Level JSON şeması

- Kullanacağın paketler ve sürümleri (pub.dev'den güncel sürümleri doğrula, hafızadan tahmin etme)

- Faz 1'in iş kırılımı

### Önerilen mimari (başlangıç noktası, gerekirse gerekçesiyle değiştir)

```

lib/

main.dart

app/ # routing, tema, font, i18n

domain/ # SAF DART: Flutter/Flame bağımlılığı YOK

grading/ # LetterGrade, GradeCalculator, GpaCalculator

progression/ # Course, Assessment, Semester, Transcript, RetakePolicy

scoring/ # LevelScore, InkState

game/

tukenmez_game.dart # FlameGame + HasCollisionDetection

components/

pen.dart # Tüki: şerit pozisyonu, zıplama/eğilme durumları, hitbox

paper_background.dart# sonsuz kayan, tile'lanan kağıt dokusu

ink_trail.dart # mürekkep izi (nokta listesi, seyreltme, üst sınır)

lane_system.dart # 3 şeridin x koordinatları, geçiş animasyonu

spawner.dart # JSON desenlerinden nesne üretimi + object pool

items/ # collectible, power_up, distraction

obstacles/ # ground (zıpla), air (eğil), wall (şerit değiştir)

effects/ # debuff'lar: ters kontrol, bulanıklık, tünel görüş...

systems/

speed_curve.dart # level içi ve level'lar arası hız

input/swipe_detector.dart

doodle/ # wobble'lı el çizimi render yardımcıları

data/

level_repository.dart # assets/levels/*.json yükleme ve doğrulama

save_repository.dart # ilerleme ve transkript kaydı

ui/

overlays/ # HUD, pause, level_summary, course_result

screens/ # ana menü, ders seçimi, transkript

assets/

levels/calc101/{quiz1,midterm,quiz2,project,final}.json

fonts/

test/

domain/ # grade, gpa, retake, level score testleri

game/ # flame_test ile bileşen testleri

```

### Temel teknik ilkeler

- **Oyun mantığı ile render'ı ayır.** Notlandırma, GPA, retake ve level skoru `domain/` altında saf Dart olarak yazılır ve %100 unit test ile kapsanır.

- **Data-driven level'lar.** Her level bir JSON dosyasıdır ve şunları içerir: süre, başlangıç/bitiş hızı, hız eğrisi, spawn desenleri (şerit, zaman/mesafe, nesne tipi), özel olaylar, nesne ağırlıkları. Yeni ders eklemek kod değil **veri** eklemek olmalı. JSON yüklenirken şema doğrulaması yapılır.

- **Flame yapısı:** `FlameGame` + `HasCollisionDetection`, component tabanlı. Kamera ve world sabit, **kayan olan içeriktir**. Kalem y ekseninde sabit kalır, nesneler ve kağıt aşağı hareket eder.

- **Swipe algılama:** Baskın eksene göre sınıflandırma, minimum mesafe ve hız eşikleri, ~120 ms input buffer. Havadayken aşağı swipe fast-fall yapar. Flame'in güncel gesture API'sini kullan ve sürümünü doğrula.

- **Çarpışma kuralları:**

- Yer engeli: kalem havadaysa çarpışmaz.

- Hava engeli: kalem eğikse çarpışmaz.

- Duvar: her durumda çarpışır.

- Toplanabilirler: zıplarken de toplanır.

- **Performans:** Object pooling kullan. Mürekkep izi nokta sayısı sınırlı olsun (ekran dışındakiler atılır, noktalar seyreltilir). Her karede allocation'dan kaçın. Hedef orta segment cihazda **60 FPS**.

- **Overlay'ler:** Flame `overlayBuilderMap` ile Flutter widget'ları kullanılır: HUD, pause ve sonuç ekranları.

- **Doodle render:** Konturlar hafif rastgele sapmayla çizilir. Nesneler 3-4 fps'lik "boil" ile titrer. Rastgelelik seed'li olsun ki testler deterministik kalsın.

---

## OYUN KURALLARI SPESİFİKASYONU (bunu birebir uygula)

### Level skoru

```

ham_puan = toplanan puanlar (fosforlu çarpanı dahil) − ceza puanları

maks_puan = o level'da SPAWN OLAN tüm (+) nesnelerin çarpansız toplam değeri

level_skoru = clamp(ham_puan / maks_puan × 100, 0, 100)

+ ekstra kredi (Bonus Soru +3 adet başına, ≥%50 mürekkeple bitirme +2)

→ sonuç 100 ile sınırlanır

mürekkep 0'a düştüyse: level erken biter ve level_skoru = min(level_skoru, 50)

```

### Ders skoru

```

ders_skoru = Quiz1×0.10 + Midterm×0.30 + Quiz2×0.10 + Proje×0.20 + Final×0.30

```

### Harf notu (alt sınır dahil, üst sınır hariç)

| Harf | Alt sınır | Puan |
|---|---|---|
| A+ | 97 | 4.0 |
| A | 93 | 4.0 |
| A− | 90 | 3.7 |
| B+ | 87 | 3.3 |
| B | 83 | 3.0 |
| B− | 80 | 2.7 |
| C+ | 77 | 2.3 |
| C | 73 | 2.0 |
| C− | 70 | 1.7 |
| D+ | 67 | 1.3 |
| D | 63 | 1.0 |
| D− | 60 | 0.7 |
| F | 0 | 0.0 |

### GPA ve akademik durumlar

- **Dönem GPA** = Σ(puan × kredi) / Σ(kredi). **CGPA** tüm dönemler üzerinden hesaplanır. Gösterimde 2 ondalık basamak kullanılır, hesapta yuvarlama yapılmaz.

- **Retake:** F alınan ders tekrar alınabilir. Yeni not eskisinin yerine geçer ve CGPA'e yalnızca yeni not girer. Eski kayıt transkriptte "R" işaretiyle saklanır.

- **Dean's List:** Dönem GPA ≥ 3.50.

- **Probation:** CGPA < 2.00.

- **Onur dereceleri:** Cum Laude ≥ 3.50, Magna ≥ 3.70, Summa ≥ 3.90.

### Mürekkep ve ceza değerleri (varsayılan)

| Nesne | Puan | Mürekkep | Debuff |
|---|---|---|---|
| Telefon bildirimi | −5 | −10 | Ekran köşesinde sahte bildirim, 2 sn |
| Oyun konsolu | −15 | −15 | Ters kontrol, 3 sn |
| "Cuma gecesi" şişesi | −20 | −20 | Ekran dalgalanması + gecikmeli şerit geçişi, 3 sn |
| Kötü arkadaş | −15 | −15 | Bir şerit kenara çekilme |
| Dizi maratonu | −10 | −10 | Tünel görüş, 3 sn |
| Parti daveti | −10 | −10 | Konfeti perdesi, 3 sn |
| Yastık | −5 | −5 | 1 sn input yok |
| Fiziksel engel | −5 | −10 | Sendeleme |

Tüm değerler bir **config/JSON** dosyasında tutulur, kodda sabit yazılmaz.

---

## FAZLAR VE KABUL KRİTERLERİ

Her fazın sonunda dur. Bana ne yaptığını, nasıl test ettiğini ve bilinen eksikleri anlatan **kısa bir demo notu** yaz, sonra bir sonraki faz için **onayımı iste**.

### Faz 1: Oynanabilir MVP

- [ ] Proje iskeleti, paketler, font, portre kilidi

- [ ] Kayan defter sayfası, 3 şerit, alt ortada sabit kalem, mürekkep izi

- [ ] 4 yönlü swipe: şerit değiştirme, zıplama, eğilme, fast-fall

- [ ] JSON'dan yüklenen spawn desenleri. En az: flashcard, ders notu, kitap, Fosforlu Kalem, Kahve, Mürekkep Kartuşu, 3 dikkat dağıtıcı, yer/hava/duvar engelleri

- [ ] Level içi hız eğrisi ve level'lar arası hız artışı

- [ ] Mürekkep barı. Mürekkep bitince level erken biter ve skor en fazla 50 olur

- [ ] HUD: skor, mürekkep, level ilerleme çubuğu, pause

- [ ] Level sonu ekranı: puan dökümü, level skoru, harf, hocanın yorumu

- [ ] CALC 101'in 5 level'ı ve ders sonu ekranı: ağırlıklı tablo, harf damgası, GPA değişimi

- [ ] İlerlemenin local olarak kaydedilmesi

- [ ] `domain/` için unit testler: harf sınırları (96.99 → A, 97 → A+, 59.99 → F), ağırlıklı ders skoru, kredi ağırlıklı GPA, retake değişimi, mürekkep bitince 50 tavanı, clamp ve ekstra kredi tavanı

- [ ] `flame_test` ile: şerit değişimi, zıplarken yer engeline çarpmama, eğikken hava engeline çarpmama, toplama ile skor artışı

- [ ] `flutter analyze` temiz, `flutter test` yeşil. Emülatör veya simülatörde çalışır ve ekran görüntüleriyle doğrulanır

### Faz 2: Akademik yapı

- [ ] Dönem modeli (3-4 ders, kredili), ders seçimi ekranı

- [ ] Transkript ekranı: dönem GPA'i, CGPA, retake "R" işareti

- [ ] F sonrası retake akışı, Dean's List ve Probation durumları ile kuralları

- [ ] En az 2 yeni ders (JSON ve tema kağıdı)

### Faz 3: Derinlik

- [ ] Ders tema mekanikleri (önce CALC, PHYS ve CS)

- [ ] Özel olaylar: Yoklama, Pop Quiz, Grup Ödevi, All-nighter, Ofis Saati, Soru Kapıları (soru bankası JSON'da)

- [ ] Final boss: Prof. Kırmızı (telgraflı saldırılar, faz geçişleri)

- [ ] Kalan güçlendiriciler ve dikkat dağıtıcılar

### Faz 4: Meta

- [ ] Kampüs Kredisi, skin ve kağıt teması mağazası (yalnızca kozmetik)

- [ ] Defter galerisi ve sayfa görselini paylaşma

- [ ] Başarımlar, günlük Ofis Saati mücadelesi, kenar notu hikayesi

### Faz 5: Cila ve yayın

- [ ] Müzik, SFX, haptik

- [ ] Erişilebilirlik: dokunma bölgeleri modu, renk körlüğü dostu silüetler, hassasiyet ayarı

- [ ] Aile Modu (alkol → enerji içeceği, parti → grup sohbeti)

- [ ] Performans profili, 8 dönemlik tam içerik ve mezuniyet sekansı

- [ ] Mağaza hazırlığı: ikonlar, ekran görüntüleri, yaş derecelendirmesi notları

---

## ÇALIŞMA KURALLARI

1. **Belirsizlikte sor, varsayma.** Tasarımı etkileyen her kararda kısa bir soru sor. Küçük teknik kararlarda en makul seçeneği uygula ve demo notunda belirt.

2. **Küçük ve doğrulanabilir adımlar.** Her anlamlı adımdan sonra `flutter analyze` ve ilgili testleri çalıştır.

3. **Önce domain testleri.** Notlandırma mantığını oyun bileşenlerinden önce ve test öncelikli yaz.

4. **Magic number yok.** Hız, ceza, süre, ağırlık ve eşik değerleri config veya JSON'dan gelir.

5. **Proposal'a sadık kal.** Proposal'dan sapman gerekirse gerekçesini yaz ve onay iste.

6. **Güncel API'leri doğrula.** Flame ve Flutter paketlerinin güncel sürüm ve API'lerini dokümantasyondan kontrol et. Deprecated API kullanma.

7. **Lisans.** Yalnızca lisansı uygun (OFL, MIT, CC0 vb.) font ve asset kullan. Kaynağını `CREDITS.md` dosyasına yaz.

8. **Git.** Adım 0'daki cevabıma göre her faz sonunda anlamlı commit mesajlarıyla commit at. Ben istemeden push yapma.

9. **Rapor.** Her faz sonunda şunları raporla: ne bitti, nasıl doğrulandı (test çıktısı, ekran görüntüsü), bilinen sorunlar, bir sonraki faz önerisi.

**Şimdi başla: `GAME_PROPOSAL.md`'yi oku ve ADIM 0'daki sorularını sor.**
