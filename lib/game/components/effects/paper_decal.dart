import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../../../app/palette.dart';
import '../../page_map.dart';
import '../../tukenmez_game.dart';

/// Sayfaya yapışan iz: toplananların yerinde küçük yıldız, çarpılanların
/// yerinde kahve lekesi. Kağıtla birlikte kayar, ekrandan çıkınca silinir.
class PaperDecal extends PositionComponent with HasGameReference<TukenmezGame> {
  PaperDecal(this.kind, double x, this.pageDistance)
    : super(position: Vector2(x, 0));

  final MapMarkerKind kind;
  final double pageDistance;
  double _age = 0;

  static final Paint _star = Paint()
    ..color = Palette.highlighterYellow
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.4
    ..strokeCap = StrokeCap.round;
  static final Paint _stain = Paint()..color = Palette.coffeeStain;
  static final Paint _stainRim = Paint()
    ..color = const Color(0x668B5A2B)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;
  static final Path _starPath = _buildStar();

  static Path _buildStar() {
    final p = Path();
    for (var i = 0; i < 5; i++) {
      final a = -pi / 2 + i * 2 * pi / 5;
      p
        ..moveTo(cos(a) * 3, sin(a) * 3)
        ..lineTo(cos(a) * 9, sin(a) * 9);
    }
    return p;
  }

  @override
  void update(double dt) {
    _age += dt;
    y = game.yForDistance(pageDistance);
    if (y > game.viewBottom + 40) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    switch (kind) {
      case MapMarkerKind.star:
        // kısa bir "patlama" sonra küçük yıldız olarak kalır
        final s = _age < 0.2 ? 1.6 - _age * 3 : 1.0;
        canvas.save();
        canvas.scale(s);
        canvas.drawPath(_starPath, _star);
        canvas.restore();
      case MapMarkerKind.stain:
        final r = 16.0 + min(_age * 60, 6.0);
        canvas.drawCircle(Offset.zero, r, _stain);
        canvas.drawCircle(Offset.zero, r, _stainRim);
    }
  }
}
