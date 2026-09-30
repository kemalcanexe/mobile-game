import 'dart:math';
import 'dart:ui';

/// El çizimi hissi veren titrek kontur yardımcıları. Rastgelelik seed'lidir;
/// aynı seed her zaman aynı çizimi üretir (testler deterministik kalır).
class WobblyPen {
  WobblyPen(int seed, {this.wobble = 1.3}) : _rng = Random(seed);

  final Random _rng;
  final double wobble;

  double _j() => (_rng.nextDouble() * 2 - 1) * wobble;

  Offset jitter(Offset p) => Offset(p.dx + _j(), p.dy + _j());

  /// İki nokta arasında hafif kıvrımlı çizgi.
  Path linePath(Offset a, Offset b, {int segments = 3}) {
    final path = Path()..moveTo(a.dx + _j(), a.dy + _j());
    for (var i = 1; i <= segments; i++) {
      final t = i / segments;
      final p = Offset.lerp(a, b, t)!;
      path.lineTo(p.dx + _j(), p.dy + _j());
    }
    return path;
  }

  void line(Canvas c, Offset a, Offset b, Paint paint, {int segments = 3}) =>
      c.drawPath(linePath(a, b, segments: segments), paint);

  /// Kapalı çokgen; kontur ucu hafifçe taşar (kalemle çizilmiş gibi).
  Path polygonPath(List<Offset> points, {bool overshoot = true}) {
    final path = Path();
    final first = jitter(points.first);
    path.moveTo(first.dx, first.dy);
    for (var i = 1; i < points.length; i++) {
      final a = points[i - 1];
      final b = points[i];
      final mid = Offset.lerp(a, b, 0.5)!;
      final m = jitter(mid);
      final e = jitter(b);
      path.lineTo(m.dx, m.dy);
      path.lineTo(e.dx, e.dy);
    }
    final m = jitter(Offset.lerp(points.last, points.first, 0.5)!);
    path.lineTo(m.dx, m.dy);
    if (overshoot) {
      final o = Offset.lerp(points.first, points[1], 0.12)!;
      final oj = jitter(o);
      path.lineTo(first.dx, first.dy);
      path.lineTo(oj.dx, oj.dy);
    } else {
      path.close();
    }
    return path;
  }

  Path rectPath(Rect r) =>
      polygonPath([r.topLeft, r.topRight, r.bottomRight, r.bottomLeft]);

  Path circlePath(Offset center, double radius, {int points = 14}) {
    final path = Path();
    final start = _rng.nextDouble() * pi * 2;
    for (var i = 0; i <= points; i++) {
      final a = start + i / points * pi * 2.08; // hafif taşma
      final r = radius + _j() * 0.8;
      final p = center + Offset(cos(a) * r, sin(a) * r);
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    return path;
  }

  /// Çokgenin içini boşluklarla doldurulmuş gibi boyar (dolgu hafif kayık).
  void fill(Canvas c, Path path, Color color) {
    c.save();
    c.translate(_j() * 0.8, _j() * 0.8);
    c.drawPath(path, Paint()..color = color);
    c.restore();
  }
}

Paint strokePaint(Color color, double width) => Paint()
  ..color = color
  ..style = PaintingStyle.stroke
  ..strokeWidth = width
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round;
