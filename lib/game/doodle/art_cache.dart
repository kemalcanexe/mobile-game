import 'dart:ui';

import 'item_art.dart';
import 'pen_art.dart';
import 'wobbly_pen.dart';

/// Her çizimin [variants] adet titrek versiyonunu bir kez `Picture` olarak
/// kaydeder. Render sırasında path üretilmez; "boil" efekti versiyonlar
/// arasında düşük frekansla geçişle elde edilir.
class ArtCache {
  ArtCache({required this.variants, required this.wobble, required this.text});

  final int variants;
  final double wobble;
  final ArtText text;
  final Map<String, List<Picture>> _cache = {};

  static int _seed(String key, int variant) =>
      Object.hash(key, variant) & 0x7fffffff;

  List<Picture> _build(String key, void Function(Canvas, WobblyPen) paint) =>
      _cache.putIfAbsent(key, () {
        return List.generate(variants, (v) {
          final recorder = PictureRecorder();
          final canvas = Canvas(recorder);
          paint(canvas, WobblyPen(_seed(key, v), wobble: wobble));
          return recorder.endRecording();
        });
      });

  Picture item(String art, double size, int variant) {
    final painter = itemArt[art];
    if (painter == null) throw ArgumentError('Çizimi olmayan nesne: $art');
    return _build('$art@$size', (c, p) => painter(c, size, p, text))[variant %
        variants];
  }

  Picture pen(int variant) =>
      _build('pen', (c, p) => paintPen(c, p))[variant % variants];

  void dispose() {
    for (final list in _cache.values) {
      for (final p in list) {
        p.dispose();
      }
    }
    _cache.clear();
  }
}
