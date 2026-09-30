# TÜKENMEZ: GPA Run

### Oyun Tasarım Önerisi (Game Proposal) · v1.0

> *"Mürekkebin bitebilir, hırsın bitmez."*

> **Not:** Bu dosya yüklenen tasarım dokümanının temizlenmiş halidir. Markdown dönüşümünde URL-decode edilerek bozulan yüzdelik değerler (`%10`, `%30`, `%50`…) orijinal hallerine geri çevrildi. Uygulama kararları için bkz. `docs/DECISIONS.md`.

---

## 1. Künye

| | |
|---|---|
| **Oyun adı** | TÜKENMEZ: GPA Run |
| **Tür** | 3 şeritli, dikey kayan sonsuz-olmayan koşu (lane runner) + akademik ilerleme meta oyunu |
| **Platform** | iOS ve Android (Flutter + Flame) |
| **Hedef kitle** | Üniversite öğrencileri (18-25), üniversite nostaljisi olan genç yetişkinler |
| **Ton** | Mizahi, kampüs esprili, vaaz vermeyen |
| **Görsel stil** | Defter sayfası doodle'ı: her şey tükenmez kalemle çizilmiş gibi |
| **Oturum süresi** | Level başına 60-90 saniye, ders (5 level) başına ~7 dakika |
| **Not sistemi** | Amerikan harf notu (A+ … F), 4.0 skalasında GPA |

---

## 2. Elevator Pitch

Bir tükenmez kalemsin. Adın **Tüki**. Sahibin olan öğrencinin 4 yıllık üniversite hayatı boyunca her ders, her quiz ve her final senin defter sayfalarında geçiyor.

Sayfa aşağı akıyor, sen yazıyorsun. Üç şeritte ders notları, kitaplar ve flashcard'lar geliyor, bunları topladıkça notun yükseliyor. Aynı şeritlerde oyun konsolları, "Cuma gecesi" şişeleri ve "Hadi kantine!" diyen arkadaşlar da var. Onlara çarparsan hem puanın hem mürekkebin gidiyor.

Her level bir sınav. Her 5 level bir ders. Her ders sonunda karnene bir **harf notu** düşüyor ve GPA'in canlı olarak değişiyor. Hedefin 8 dönemin sonunda kepini fırlatmak, mümkünse **Summa Cum Laude** ile.

**Tek cümleyle:** *Subway Surfers'ın refleks keyfi ile üniversite karnesinin "bir ders daha" bağımlılığı, bir defter sayfasının üzerinde.*

---

## 3. Hikaye ve Dünya

### 3.1 Tüki kimdir?

Tüki, kampüs kırtasiyesinden 7,5 liraya alınmış sıradan bir tükenmez kalem. Tek bir farkı var: **tükenmiyor.** Daha doğrusu, sahibi pes etmediği sürece tükenmiyor.

Sahibi, yüzü hiç gösterilmeyen bir birinci sınıf öğrencisi. Onu sadece defterinin kenarına çizdiği karalamalardan, sayfa köşelerindeki notlardan ("SINAV SALI!!!", "kahve al", "Mert'e para ver") ve Tüki'nin tuttuğu elden tanıyoruz. Oyun ilerledikçe bu kenar notları bir hikaye anlatıyor. Kaygılı bir çaylak ilk dönemde yavaş yavaş kendine güvenen bir mezuna dönüşüyor.

### 3.2 Dünya: Defter Evreni

- Her **level**, defterden bir **sayfa**.

- Her **ders**, defterin bir **bölümü**. Her ders bölümünün kendine özgü kağıdı, kenar süslemeleri ve karalamaları var.

- Her **dönem**, yeni bir **defter**. Kapağı dönem sonunda karne gibi damgalanır.

- **Kampüs**, sayfa kenarlarında akan doodle arka plandır: kantin, kütüphane, yurt, amfi. Tüki bunları geçerken gerçek hayat sayfanın kenarından içeri sızmaya çalışır.

### 3.3 Mürekkep İzi

Tüki nereye giderse arkasında bir **mürekkep izi** bırakır. Sayfa aşağı aktığı için iz, kalemin arkasında uzayıp giden bir el yazısı çizgisine dönüşür.

Level bittiğinde kamera geri çekilir ve oyuncu o sayfanın tamamını görür: kıvrılan mürekkep çizgisi, topladığı notların yerinde kalan küçük yıldızlar, çarptığı dikkat dağıtıcıların yerinde kalan kahve lekeleri. **Bu sayfa, oyuncunun o sınavdaki "ders notudur".** Kaydedilir ve paylaşılabilir. Defter galerisinde bütün sayfalar birikir.

---

## 4. Temel Oyun Döngüsü

```

Ders seç ─► Level başla ─► Sayfa akar, hız artar ─► Topla / Kaç / Zıpla / Eğil

▲ │

│ ▼

GPA güncellenir ◄─ Ders harf notu ◄─ 5 level biter ◄─ Level skoru (0-100)

```

1. **Mikro döngü (saniyeler):** Şerit değiştir, iyi şeyi topla, kötüden kaç.

2. **Level döngüsü (60-90 sn):** Sayfa sonuna kadar dayan, skorunu 100'e yaklaştır, mürekkebini bitirme.

3. **Ders döngüsü (~7 dk):** Quiz 1, Midterm, Quiz 2, Proje ve Final'i bitirip ağırlıklı ortalamayla harf notu al.

4. **Meta döngü (günler/haftalar):** Dönemleri bitir, transkripti doldur, Dean's List'e gir, mezun ol.

---

## 5. Kamera, Harita ve Hareket

- **Kamera:** Portre mod, yukarıdan bakış (top-down).

- **Tüki:** Ekranın **alt ortasında sabit** durur, yatay konumu yalnızca şerit değişiminde kayar.

- **Harita:** Defter sayfası **yukarıdan aşağıya** akar. Nesneler ekranın üstünden doğar ve Tüki'ye doğru iner, bu da kalemin yukarı doğru yazarak ilerlediği hissini verir.

- **3 şerit:** Sayfanın çizgili kağıt dokusu üzerinde, hafif kurşun kalemle çizilmiş iki dikey kılavuz çizgiyle ayrılır.

- **Sayfa sonu:** Level'ın bitiş çizgisi, kağıdın alt kenar boşluğu ve spiral delikleridir. Tüki buraya ulaşınca sayfa çevrilme animasyonu oynar.

---

## 6. Kontroller

| Hareket | Aksiyon | Oyun içi adı | Ne işe yarar |
|---|---|---|---|
| Sola / sağa swipe | Şerit değiştir | **Satır atla** | İyi nesneye yaklaşır, kötüden kaçar |
| Yukarı swipe | Zıpla | **Kalem kaldır** | Tüki kağıttan kalkar ve yerdeki engelleri aşar (mürekkep izi bu sırada kesik çizgi olur) |
| Aşağı swipe | Eğil / yat | **Yatık yazı** | Tüki yan yatar ve havadaki engellerin altından geçer |

- Swipe'lar arka arkaya kuyruğa alınabilir (input buffering, ~120 ms).

- Zıplama ve eğilme süresi ~0,6 sn. Havadayken aşağı swipe atılırsa Tüki hızla yere iner (fast-fall).

- **Erişilebilirlik:** Ayarlardan "dokunma bölgeleri" moduna geçilebilir. Bu modda ekranın sol ve sağ yarısı şerit değiştirir, çift dokunuş zıplatır, uzun basış eğiltir.

---

## 7. Level Yapısı = Ders İzlencesi

Her ders bir **syllabus** gibi tasarlanmıştır. 5 level'ın her biri bir değerlendirme türüdür ve **gerçek bir izlencedeki gibi ağırlıklıdır**:

| # | Level | Ağırlık | Süre | Başlangıç hızı → Bitiş hızı | Karakter |
|---|---|---|---|---|---|
| 1 | **Quiz 1** | %10 | 60 sn | 1,00x → 1,25x | Isınma. Seyrek engel, bol not. Mekanikleri öğretir. |
| 2 | **Midterm** | %30 | 80 sn | 1,10x → 1,45x | İlk ciddi sınav. Soru kapıları ilk kez çıkar. |
| 3 | **Quiz 2** | %10 | 60 sn | 1,20x → 1,50x | Kısa ama yoğun. "Pop Quiz" olayı garantidir. |
| 4 | **Proje / Lab** | %20 | 75 sn | 1,15x → 1,50x | Grup ödevi olayı ve dersin tema mekaniği ön plandadır. |
| 5 | **Final** (Boss) | %30 | 90 sn | 1,30x → 1,75x | Kırmızı Kalemli Profesör. All-nighter atmosferi. |

**Level içi hızlanma:** Hız, level boyunca yumuşak bir eğriyle artar ("sınav yaklaşıyor"). Son %15'lik bölümde sayfa kenarında bir "SON 5 DAKİKA" damgası belirir ve müzik tempo atlar.

**Ders içi hızlanma:** Her level'ın başlangıç hızı bir öncekinden yüksektir. Üst dönemlerde (2. sınıf ve sonrası) tüm hızlar dönem çarpanıyla ölçeklenir.

---

## 8. Nesneler

### 8.1 Toplanabilirler (+)

| Nesne | Puan | Sıklık | Not |
|---|---|---|---|
| **Flashcard** | +5 | Çok sık | Şeritlerde dizi halinde gelir, "coin" görevi görür. |
| **Ders notu** (katlanmış kağıt) | +10 | Sık | Ana puan kaynağı. |
| **Formül kağıdı** (temaya özgü) | +15 | Orta | Calculus'ta ∫, Chemistry'de H₂O, CS'te `{ }` gibi. |
| **Kitap** | +25 | Seyrek | Genelde riskli bir şeritte durur. |
| **Bonus Soru** | Ekstra kredi | Nadir | Level skoruna doğrudan +3 puan (tavan 100). |

### 8.2 Güçlendiriciler (Power-up)

| Nesne | Etki | Süre |
|---|---|---|
| **Fosforlu Kalem** | Tüm puanlar 2 kat | 6 sn |
| **Kahve** | "Odak modu": oyun %30 yavaşlar, Tüki'nin etrafında buhar halkası belirir | 4 sn |
| **Kütüphane Kartı** | Bir sonraki olumsuz çarpışmayı tamamen engeller (kalkan) | Tek kullanımlık |
| **Syllabus** | Yaklaşan engellerin gölgesi ekranın üstünde önceden görünür | 5 sn |
| **Çalışma Grubu** | Yan şeritlerdeki toplanabilirleri Tüki'ye çeker (mıknatıs) | 6 sn |
| **Mürekkep Kartuşu** | +25 mürekkep | Anlık |

### 8.3 Dikkat Dağıtıcılar (−)

Toplanabilir gibi durur ama zararlıdır. Her birinin puan cezası, mürekkep cezası ve **kendine özgü kısa bir debuff'ı** vardır:

| Nesne | Puan | Mürekkep | Debuff |
|---|---|---|---|
| **Telefon bildirimi** 🔔 | −5 | −10 | Ekranın bir köşesini 2 sn boyunca sahte bir bildirim balonu kaplar ("Ayşe hikaye paylaştı"). |
| **Oyun konsolu** 🎮 | −15 | −15 | *"Bir el daha"*: 3 sn boyunca sağ ve sol kontroller ters çalışır. |
| **"Cuma gecesi" şişesi** 🍾 | −20 | −20 | 3 sn ekran dalgalanır, şerit geçişleri gecikmeli çalışır. Sabah sayfada "baş ağrısı" doodle'ı kalır. |
| **Kötü arkadaş: "Hadi kantine!"** | −15 | −15 | Tüki'yi kolundan tutup bir şerit kenara çeker. |
| **Kötü arkadaş: "Derse girmeyelim"** | −15 | −15 | 2 sn yoklama kaçırma animasyonu oynar. Yakındaki Yoklama olayı otomatik kaçırılır. |
| **Dizi maratonu** 📺 | −10 | −10 | *"Sonraki bölüm 5 sn içinde"*: 3 sn tünel görüş (ekran kenarları kararır). |
| **Parti daveti** 🎉 | −10 | −10 | 3 sn ekrana konfeti yağar, nesneleri görmek zorlaşır. |
| **Yastık** 😴 | −5 | −5 | Tüki 1 sn uyuklar, input alınmaz. |

### 8.4 Fiziksel Engeller

Bunlar toplanmaz, **aşılır**. Çarpışmada −10 mürekkep ve −5 puan kesilir, kısa bir sendeleme animasyonu oynar.

| Engel | Nasıl aşılır |
|---|---|
| **Dökülmüş kahve lekesi**, **silgi tozu yığını**, **zımba teli** | Zıpla (yerde) |
| **Kağıt uçak**, **lastik sapan**, **buruşturulmuş kağıt topu** | Eğil (havada) |
| **Ciltli ansiklopedi** (şeridi tamamen kapatır) | Şerit değiştir |
| **Cetvel bariyeri** (iki şeridi kapatır) | Kalan tek şeride geç |

---

## 9. Mürekkep Barı (Can Sistemi)

- Tüki her level'a **100 mürekkep** ile başlar. Ekranın solunda dikey bir kalem haznesi olarak görünür.

- Dikkat dağıtıcılar ve engeller mürekkebi azaltır. Mürekkep Kartuşu +25 doldurur.

- Mürekkep %25'in altına düşünce iz silikleşir, çizgi kesik kesik çıkar ve cızırtı sesi duyulur.

- **Mürekkep biterse ("Mürekkep bitti!"):** Level anında sona erer ve o ana kadarki skor korunur, **ancak en fazla 50 olarak kaydedilir. Yani o level F sayılır.** Ekrana hocanın kırmızı kalemle yazdığı bir yorum düşer: *"Kağıdın yarısı boş?"*

- Sayfa sonuna ≥%50 mürekkeple ulaşan oyuncuya +2 **"Temiz Kağıt"** ekstra kredisi verilir (tavan 100).

---

## 10. Özel Olaylar

| Olay | Ne olur |
|---|---|
| **📢 Yoklama!** | Sayfanın üstünde profesör silüeti belirir ve bir şerit yeşil parlar ("Burada!"). Tüki 2 sn o şeritte kalırsa +10 alır. Kalmazsa "Devamsızlık" damgası vurulur (−5). |
| **⚡ Pop Quiz** | Uyarı vermeden 4 sn boyunca üç şeride not yağmuru başlar. Arada gizli telefon bildirimleri de vardır. |
| **👥 Grup Ödevi** | Tembel bir arkadaş Tüki'nin arkasına takılır ve 8 sn boyunca toplanan her puanın yarısını "kendi adına" yazar. Yol üstündeki "İş Bölümü" kapısından geçilirse arkadaş ayrılır. |
| **🌙 All-nighter** | Final'lere özgüdür. Sayfa kararır, sadece Tüki'nin etrafı ve Kahve'lerin yaydığı ışık görünür. |
| **🚪 Ofis Saati** | Nadir kapı. İçinden geçen Tüki 3 sn boyunca engelsiz, bol notlu bir "bonus koridor"a girer. |
| **📝 Soru Kapıları** | Midterm ve Final'de çıkar. Üç şeridin her birinde bir cevap şıkkı yazar ve tepede dersin konusundan kısa bir soru belirir (Calculus: *d/dx x² = ?* → `2x` · `x` · `x³`). Doğru şeritten geçen +20 alır, yanlıştan geçen −10 ile birlikte kırmızı bir ✗ damgası yer. |
| **📅 Ekle-Bırak Haftası** | Dönem başı olayı. İlk level'dan önce oyuncuya iki ders arasında seçim yapma şansı verilir. |

---

## 11. Final Boss: Kırmızı Kalemli Profesör

Her dersin Final level'ında sayfanın tepesinde **Prof. Kırmızı** belirir. Kendisi dev bir kırmızı kalemdir, gözlüklüdür ve dersin temasına göre kostüm giyer (Physics'te laboratuvar önlüğü, History'de peruk).

- **Telgraflı saldırılar:** Önce bir şeridi kırmızı kesik çizgiyle işaretler, ~0,8 sn sonra o şeride bir **✗** fırlatır.

- **"Bu sınavda çıkmaz dediğim konu":** İki şeridi aynı anda kapatan kırmızı bir çizgi çeker. Oyuncunun tek şeride sığması gerekir.

- **Soru kapısı yağmuru:** Finalin son bölümünde üç soru kapısı art arda gelir.

- **Faz geçişleri:** Profesör %33 ve %66'da "Ek soru!" diye bağırır ve hızı bir kademe artırır.

- **Level sonu:** Tüki sayfa sonuna ulaşınca profesör kağıda bakar. Aldığı nota göre kısa bir tepki verir: onaylayan bir baş sallama, şaşkın bir kaş kaldırma ya da dramatik bir yüz avuçlama.

Boss'un "canı" yoktur, yenilmez. Oyuncunun işi hayatta kalıp puanını korumaktır. Final, bir dövüş değil bir **dayanıklılık sınavıdır**.

---

## 12. Puanlama → Harf Notu → GPA

### 12.1 Level skoru (0-100)

```

ham_puan = toplanan puanlar − ceza puanları (fosforlu çarpanı dahil)

maks_puan = o level'da spawn olan tüm (+) nesnelerin çarpansız toplam değeri

level_skoru = clamp( ham_puan / maks_puan × 100 , 0 , 100 )

+ ekstra kredi (Bonus Soru +3, Temiz Kağıt +2) → tavan 100

mürekkep bittiyse: level_skoru = min(level_skoru, 50)

```

*Not:* Fosforlu çarpanı sayesinde ham puan `maks_puan`'ı aşabilir. Clamp bu yüzden vardır ve 100'e ulaşmanın gerçekçi yolu budur.

### 12.2 Ders notu (ağırlıklı ortalama)

```

ders_skoru = Quiz1×0.10 + Midterm×0.30 + Quiz2×0.10 + Proje×0.20 + Final×0.30

```

### 12.3 Harf notu tablosu (Amerikan sistemi)

| Harf | Skor aralığı | Puan |
|---|---|---|
| **A+** | ≥ 97 | 4.0 |
| **A** | 93 – 96.99 | 4.0 |
| **A−** | 90 – 92.99 | 3.7 |
| **B+** | 87 – 89.99 | 3.3 |
| **B** | 83 – 86.99 | 3.0 |
| **B−** | 80 – 82.99 | 2.7 |
| **C+** | 77 – 79.99 | 2.3 |
| **C** | 73 – 76.99 | 2.0 |
| **C−** | 70 – 72.99 | 1.7 |
| **D+** | 67 – 69.99 | 1.3 |
| **D** | 63 – 66.99 | 1.0 |
| **D−** | 60 – 62.99 | 0.7 |
| **F** | < 60 | 0.0 |

### 12.4 GPA

- Her dersin bir **kredisi** vardır (3 veya 4).

- **Dönem GPA** = Σ(harf puanı × kredi) / Σ(kredi)

- **Kümülatif GPA (CGPA)** = tüm dönemler üzerinden aynı formül.

- **F alınan ders tekrar alınır (Retake).** Yeni not eskisinin **yerine geçer** (grade replacement). Transkriptte eski not üstü çizili olarak ve "R" işaretiyle görünmeye devam eder. Retake'in hızı orijinal dersle aynıdır. Ancak kötü arkadaşlar oyuncuyu "tanır" ve biraz daha sık çıkar.

### 12.5 Akademik durumlar

| Durum | Koşul | Oyun içi karşılığı |
|---|---|---|
| **Dean's List** 🏅 | Dönem GPA ≥ 3.50 | Defter kapağına altın yıldız + Kampüs Kredisi bonusu |
| **Academic Probation** ⚠️ | CGPA < 2.00 | Bir sonraki dönem en fazla 3 ders alınabilir. Kenar notlarında endişeli bir ton belirir. |
| **Mezuniyet** 🎓 | 8 dönem bitti, F'siz ve CGPA ≥ 2.00 | Cüppe ve kep animasyonu, diploma ekranı |
| **Cum Laude** | CGPA ≥ 3.50 | Bronz mühür |
| **Magna Cum Laude** | CGPA ≥ 3.70 | Gümüş mühür |
| **Summa Cum Laude** | CGPA ≥ 3.90 | Altın mühür + gizli kalem skini: **"Mezuniyet Dolma Kalemi"** |

### 12.6 Sonuç ekranları

- **Level sonu:** Sayfanın tamamı (mürekkep izi haritası), puan dökümü, level skoru, harf, ve hocanın kırmızı kalemle yazdığı bir yorum. Yorum havuzu harfe göre seçilir: A için *"Mükemmel, ama el yazın berbat."*, C için *"Ders dinlerken uyumuşsun, belli."*, F için *"Görüşelim."*

- **Ders sonu:** İzlence tablosu dolar, ağırlıklar tek tek toplanır ve kağıda harf notu **damga gibi vurulur**. Altında GPA sayacı animasyonla değişir: `3.12 → 3.27 ▲`.

- **Dönem sonu:** Karne veya transkript sayfası, Dean's List veya Probation damgası, sonraki dönemin defter kapağı.

---

## 13. Dersler (Temalar) ve Tema Mekanikleri

Her ders, 5 level boyunca geçerli bir **imza mekaniği** ile gelir. Mekanik Quiz 1'de hafifçe tanıtılır, Proje/Lab'da ana karakter olur, Final'de boss'un saldırılarıyla birleşir.

| Ders | Takma adı | Kağıt | İmza mekaniği |
|---|---|---|---|
| **CALC 101** | *Limitsiz Acı* | Kareli | **Asimptot duvarları:** Şeride yaklaşan ama asla tam kapatmayan eğri çizgiler, aradan geçmek cesaret ister. **Türev rampaları:** Kısa süre hızlandırıp ikiye katlanmış notlar verir. |
| **PHYS 101** | *Yerçekimine Karşı* | Milimetrik | **Yerçekimi terslenmesi:** Belirli bölgelerde zıplama ve eğilme yer değiştirir. **Sürtünmesiz buz bölgesi:** Şerit değişimi kayarak olur (momentum). |
| **CHEM 101** | *Tehlikeli Reaksiyonlar* | Periyodik tablo kenarlı | **Bileşik kombosu:** Elementleri doğru sırayla toplayınca bileşik oluşur (H + H + O = H₂O → +50). Yanlış sırada toplayınca küçük bir patlama olur (−10 mürekkep). |
| **CS 101** | *Hello, Bug* | Koyu tema "terminal" sayfası | **Bug'lar** şerit değiştiren böceklerdir. **Infinite loop** bölümü, çıkış şeridi bulunana kadar aynı deseni tekrar eder. **Stack Overflow kartı** kalkan görevi görür. |
| **ECON 101** | *Arz, Talep ve Kantin* | Hesap defteri | **Piyasa çarpanı:** Sayfa kenarındaki canlı grafik puan çarpanını belirler (0,5x – 2x). **Enflasyon** nesnesi sonraki notların değerini düşürür. Boğa ve ayı fazları vardır. |
| **PSYC 101** | *Bilinçaltı* | Pastel | **Pavlov zili:** Zil çaldıktan sonra gelen ilk nesne her zaman bonustur. **İllüzyonlar:** Bazı notlar sahtedir, yaklaşınca dikkat dağıtıcıya dönüşür. |
| **LIT 201** | *Satır Arası* | Eski sarı kağıt | **Dize toplama:** Şeritlerde kelimeler akar. Doğru sırayla toplanan kelimeler bir dizeyi tamamlar ve bonus verir. |
| **HIST 101** | *Tarih Tekerrürden İbarettir* | Sepya parşömen | **Tekerrür:** Önceki level'ların engel desenleri sepya "hayaletler" olarak tekrar eder. **Kronoloji kapıları:** Olayları doğru sırayla dizmek gerekir. |
| **BIO 101** | *Hücre Bölünmesi* | Mikroskop lamı | **Mitoz:** Toplanan bazı notlar ikiye bölünüp yan şeride sıçrar. **Virüsler** yavaşça yayılır. |

**Dönem yapısı (öneri):** 8 dönem × 3-4 ders. Giriş dersleri (101) ilk yıl, ileri dersler (201, 301…) sonraki yıllarda gelir. İleri seviyeli dersler aynı mekaniği daha hızlı ve katmanlı sunar (ör. CALC 201: *"Çok Değişkenli Kaos"*).

---

## 14. Meta İlerleme

- **Transkript ekranı:** Tüm dersler, harfler, krediler, retake'ler, dönem ve kümülatif GPA'ler bu ekranda. Tasarımı resmi bir üniversite belgesinin doodle parodisidir.

- **Defter Galerisi:** Her level'ın mürekkep izi sayfası burada saklanır. Oyuncu en iyi sayfalarını tek dokunuşla görsel olarak paylaşabilir.

- **Kenar notu hikayesi:** Her dönem sonunda defter kenarlarına sahibin hayatından yeni bir parça eklenir: ilk arkadaş, ilk kaygı krizi, staj, mezuniyet planları.

- **Başarımlar:**

- *"Sıfır Devamsızlık"*: Bir derste tüm Yoklama'ları yakala.

- *"Kahvesiz Final"*: Final'i hiç Kahve almadan A ile bitir.

- *"Tek Kalem, Dört Yıl"*: Hiç skin değiştirmeden mezun ol.

- *"Bir El Daha"*: Bir level'da 5 oyun konsoluna çarp (utanç başarımı).

- *"Ekstra Krediye Doymayan"*: 10 Bonus Soru topla.

- **Günlük Ofis Saati:** Her gün değişen tek bir mücadele level'ı (ör. "Sadece zıplayarak geç"). Ödülü Kampüs Kredisidir.

---

## 15. Ekonomi ve Kozmetik

- **Para birimi: Kampüs Kredisi (KK).** Her level sonunda `level_skoru / 10` KK kazanılır. Başarımlar ve Dean's List ekstra KK verir.

- **Kalem skinleri (yalnızca görsel):** Dolma kalem, kurşun kalem (izi gri çıkar), fosforlu kalem, 4 renkli kalem (iz renk değiştirir), tükenmez "kırmızı" (hocaya saygısızlık başarımı), Mezuniyet Dolma Kalemi (gizli).

- **Kağıt temaları:** Kareli, çizgili, milimetrik, noktalı bullet journal.

- **Mürekkep izi efektleri:** Parıltılı, gökkuşağı, kaligrafi.

- **İlke:** **Pay-to-win yok.** Satın alınan hiçbir şey notu doğrudan etkilemez.

---

## 16. Görsel Yön

- **Palet:** Kırık beyaz kağıt, mavi tükenmez mürekkebi (#1F3A93 civarı), kurşun kalem grisi, fosforlu sarı ve pembe vurgular, hoca kırmızısı.

- **Çizgi:** Hafif titrek ve el yapımı hissi veren (wobble) konturlar. Nesneler her karede değil, düşük frekansla "boil" eder (3-4 fps çizgi titreşimi). Bu, çizgi film defteri hissini verir.

- **Kağıt dokusu:** İnce lif dokusu, sayfa kenarında spiral delikler, köşelerde hafif kıvrılma.

- **Tipografi:** El yazısı font (ör. *Caveat*, *Patrick Hand*; OFL lisanslı). Sayılar kalın ve hafif eğik yazılır.

- **UI:** Butonlar yapışkan not (post-it), pencereler koparılmış defter yaprağı, damgalar mürekkep lekeli.

- **Juice:** Toplamada küçük yıldız doodle patlaması, çarpışmada mürekkep sıçraması ve hafif ekran sarsıntısı. Harf damgası vurulurken kağıt titrer.

## 17. Ses Yönü

- **SFX:** Kalem cızırtısı (hızla pitch'i artar), sayfa çevirme, flashcard "tık"ı, konsol "bip"i, şişe tıngırtısı, kantin uğultusu (kötü arkadaş yaklaşırken), damga "tak"ı.

- **Müzik:** Lo-fi "study beats" tabanı. Level ilerledikçe katmanlar eklenir, Final'de tempo ve gerilim artar. All-nighter'da müzik gece versiyonuna geçer.

- **Haptik:** Toplamada hafif, çarpışmada orta, harf damgasında güçlü bir titreşim.

---

## 18. Ton Rehberi

- Oyun **ahlak dersi vermez**. Dikkat dağıtıcılar kötü insanlar değil, üniversite hayatının komik gerçekleridir. "Kötü arkadaş" bile level sonunda bazen kenar notunda *"yine de iyi çocuk"* diye anılır.

- Alkol ve parti öğeleri **karikatürize** edilir: şişe gözlüklü, parti daveti dans eden bir zarf. Gerçekçi içme tasviri yoktur.

- **Aile Modu (ayar):** Alkol şişesi enerji içeceğine, parti daveti "grup sohbeti"ne dönüşür. Böylece daha geniş kitleye ve farklı mağaza bölgelerine uyum sağlanır.

- **Yaş derecelendirmesi:** Alkol referansları mağazaların derecelendirme anketlerinde (App Store yaş derecelendirmesi, Google Play IARC) doğru şekilde beyan edilmelidir. Nihai derece anket sonucuna göre belirlenir.

- F almak utandırıcı değil, komiktir. Retake ekranı *"Herkes bir dersi iki kere alır. Bazıları üç."* der.

---

## 19. Monetizasyon (Opsiyonel)

| Model | Açıklama |
|---|---|
| **Premium (önerilen başlangıç)** | Tek seferlik düşük fiyat, reklamsız, tüm içerik açık. |
| **Free + kozmetik IAP** | Skin ve kağıt paketleri. |
| **Ödüllü reklam** | Yalnızca ekstra Kampüs Kredisi için. **Asla not, retry veya mürekkep için değil.** Akademik dürüstlük esprisi bunu gerektirir. |

---

## 20. Yol Haritası

| Faz | İçerik | Çıktı |
|---|---|---|
| **1. MVP** | Tek ders (CALC 101) × 5 level, 3 şerit, swipe 4 yön, toplanabilir ve dikkat dağıtıcılar, mürekkep barı, level ve ders skoru, harf notu, GPA ekranı, local kayıt | Test cihazında oynanabilir build |
| **2. Akademik yapı** | Dönem ve transkript, 3-4 ders, F'de retake, Dean's List ve Probation | Tam bir dönem |
| **3. Derinlik** | Tema mekanikleri, özel olaylar, Soru Kapıları, Prof. Kırmızı boss | "Eğlenceli" build |
| **4. Meta** | Kampüs Kredisi, skinler, galeri, başarımlar, günlük Ofis Saati | Tutundurma (retention) sistemleri |
| **5. Cila ve yayın** | Ses ve müzik, haptik, erişilebilirlik, Aile Modu, mağaza sayfası, performans | Mağaza adayı |

---

## 21. Başarı Metrikleri

- **D1 / D7 tutundurma:** Hedef ≥ %40 / ≥ %15.

- **İlk ders tamamlama oranı:** ≥ %70. İlk 7 dakika her şeydir.

- **Oturum başına level:** ≥ 4.

- **Retake oranı:** %10-25 aralığı. Daha düşükse oyun fazla kolay, daha yüksekse sinir bozucudur.

- **Paylaşılan defter sayfası sayısı:** Organik büyümenin göstergesidir.

## 22. Riskler ve Önlemler

| Risk | Önlem |
|---|---|
| Swipe tanıma hataları (özellikle çapraz swipe) | Baskın eksene göre sınıflandırma, ayarlanabilir eşik, input buffer, erken playtest |
| Level skorunun "adil" hissettirmemesi | Skor, spawn olan maksimum puana göre normalize edilir. Level sonunda şeffaf puan dökümü gösterilir. |
| Dikkat dağıtıcıların iyi nesnelerden ayırt edilememesi | Belirgin silüet dili: (+) nesneler yuvarlak ve mavi, (−) nesneler köşeli ve kırmızı ya da mor konturlu |
| Alkol teması nedeniyle mağaza sorunları | Aile Modu, doğru yaş derecelendirmesi beyanı, karikatürize tasvir |
| İçerik üretim yükü (9 ders) | Data-driven level tanımları (JSON) ve prosedürel desen üretici. Yeni ders ≈ yeni tema + yeni mekanik bileşeni. |
| Performans (çok nesne + mürekkep izi) | Object pooling, iz noktalarının sınırlanması ve seyreltilmesi, 60 FPS bütçesi |

---

*TÜKENMEZ: GPA Run · "Kağıt biter, kalem biter, dönem biter. Sen bitme."*
