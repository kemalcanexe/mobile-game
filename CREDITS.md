# Credits

## Fontlar

| Font | Lisans | Kaynak | Dosya |
|---|---|---|---|
| **Caveat** (değişken ağırlık) | SIL Open Font License 1.1 | https://github.com/googlefonts/caveat · google/fonts `ofl/caveat` | `assets/fonts/Caveat-Variable.ttf`, lisans: `assets/fonts/OFL-Caveat.txt` |
| **Patrick Hand** | SIL Open Font License 1.1 | google/fonts `ofl/patrickhand` | `assets/fonts/PatrickHand-Regular.ttf`, lisans: `assets/fonts/OFL-PatrickHand.txt` |

## 3D sürüm (godot/)

| Varlık | Lisans | Kaynak |
|---|---|---|
| City Kit (Roads), Furniture Kit, Food Kit, Fantasy Town Kit, Mini Forest, Mini Characters | CC0 1.0 | Kenney, https://kenney.nl (`godot/assets/models/`) |
| KayKit Furniture Bits, KayKit Restaurant Bits | CC0 1.0 | Kay Lousberg, https://kaylousberg.com (`godot/assets/models/kk_*`) |
| **Baloo 2** (değişken ağırlık; Latin/Türkçe alt kümesi) | SIL OFL 1.1 | google/fonts `ofl/baloo2` (`godot/assets/fonts/Baloo2.ttf`) |
| **Noto Sans Symbols 2** (sembol yedeği; ok, şekil, yıldız, işaret blokları alt kümesi) | SIL OFL 1.1 | google/fonts `ofl/notosanssymbols2` |
| Godot Engine 4.7.2 | MIT | https://godotengine.org |

Tüki'nin 3D modeli ve animasyonları `godot/tools/blender/tuki.py` ile Blender'da (bpy, GPL araç;
çıktı model projeye aittir) kodla üretilir. Mekânların çoğu, nesneler, zemin shader'ları ve efektler
`godot/scripts/game/` ve `godot/assets/shaders/` altında kodla üretilir.

**Ses ve müzik:** Bütün efektler ve lo-fi müzik döngüleri `godot/tools/gen_audio.py` ile
sentezlenir (numpy). Harici ses örneği ya da kayıt kullanılmaz; çıktılar
`godot/assets/audio/` altındadır ve projeyle aynı koşullarda kullanılabilir.

## 2D sürüm (Flutter, eski)

Bütün çizimler (Tüki, nesneler, kağıt dokusu, damgalar) `lib/game/doodle/` altında
programatik olarak üretilir. Harici görsel asset kullanılmaz.

## Paketler

| Paket | Lisans |
|---|---|
| flame, flame_test | MIT |
| flutter_riverpod | MIT |
| shared_preferences | BSD-3-Clause |
| intl | BSD-3-Clause |
