import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/painting.dart'
    show TextPainter, TextSpan, TextStyle, TextDirection, FontWeight;

import '../../../app/palette.dart';

/// Sayfa kenarına vurulan kırmızı damga ("SON 5 DAKİKA").
class Stamp extends PositionComponent {
  Stamp(String text)
    : _painter = TextPainter(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            fontFamily: 'Caveat',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Palette.teacherRed,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(),
      super(anchor: Anchor.center, angle: -0.18);

  final TextPainter _painter;
  double _t = 0;
  final Paint _rim = Paint()
    ..color = Palette.teacherRed
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.5;
  final Paint _layer = Paint();

  static const _slam = 0.25;
  static const _hold = 1.8;
  static const _restAlpha = 0.35;

  @override
  void update(double dt) => _t += dt;

  @override
  void render(Canvas canvas) {
    final scale = _t < _slam ? 2.2 - (_t / _slam) * 1.2 : 1.0;
    final alpha = _t < _hold ? 1.0 : (1 - (_t - _hold)).clamp(_restAlpha, 1.0);
    _layer.color = Color.fromRGBO(0, 0, 0, alpha);
    canvas.saveLayer(null, _layer);
    canvas.scale(scale);
    final w = _painter.width + 16;
    final h = _painter.height + 6;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: w, height: h),
        const Radius.circular(6),
      ),
      _rim,
    );
    _painter.paint(canvas, Offset(-_painter.width / 2, -_painter.height / 2));
    canvas.restore();
  }

  @override
  void onRemove() {
    _painter.dispose();
    super.onRemove();
  }
}
