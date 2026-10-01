# Kullanıcı Geri Bildirimi

## 2026-09-30 · Faz 4 sonrası: tasarım ve animasyon

> "Oyun mekanikleri harika, ama tasarım çok amatör ve çirkin duruyor… Şehirdeyiz şu an, şehirde değil kampüste olmak istiyorum, her dönem farklı tema olsun: kütüphane, spor salonu… kalem falan da, çevre, menüler. Senden bu fazda aşırı kaliteli bir animasyon ve tasarım update'i istiyorum."

**Durum:** Faz 5'te ele alındı. Önce CC0 kitler ve teknikler tarandı, öneri sunuldu. Kullanıcının seçimleri:
- her sınav ayrı mekân;
- Tüki bacaksız, insan özellikleri kalsın, kayarak gitsin;
- ana menü kampüs maketi.

Ayrıntılar: [`DECISIONS.md` → Faz 5](DECISIONS.md).

## 2026-09-30 · Faz 1 sonrası: görsel yön

> "Bu tasarımı hiç beğenmedim, 3 boyutlu ve eğlenceli bir şey istiyorum."

**Durum:** Faz 3'te ele alındı. Kullanıcının seçimleri: motor **Godot 4**, dünya **kampüste koşan 3D Tüki**.
Oyun `godot/` altında sıfırdan 3D olarak yeniden yazıldı; Flutter sürümü eski (referans) olarak duruyor.

**Etkisi:**
- Proposal §16'daki (2D defter doodle'ı, tükenmez çizgisi) görsel yönle **çelişiyor**. Kullanıcının sözü esas alınır; §16 yeniden yazılmalı.
- Oyun mantığı (`domain/`, `data/`, `game/systems/`, `game/input/`) render'dan ayrı olduğu için korunur. Değişecek olan `game/components/`, `game/doodle/` ve UI katmanıdır.

**Görsel yenileme fazında değerlendirilecek seçenekler:**
1. **2.5D perspektif (Flame içinde):** Kamera arkadan ve eğik bakar, şeritler ufka doğru daralır (Subway Surfers hissi). Nesneler hazır 3D render sprite'ları ya da derinliğe göre ölçeklenen modellerden oluşur. Mevcut koda en az müdahale gerektiren yol budur.
2. **Gerçek 3D (Flutter içinde):** `flame_3d` / `flutter_scene` (deneysel). glTF modelleri, ışık ve gölge kullanılır. Olgunluk riski var.
3. **Motor değişikliği:** Unity veya Godot ile 3D runner. En zengin görsel sonucu verir ama Flutter kodunun büyük kısmı yeniden yazılır. `domain/` kuralları ve JSON level formatı taşınabilir.

**"Eğlenceli"** için de ele alınacaklar: daha hızlı geri bildirim (ses, parçacık, kamera hareketi), karakter animasyonu, renkli ve canlı palet, combo/seri ödülleri.

Karar, o fazın başında kullanıcıya sorulacak.
