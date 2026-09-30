import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/painting.dart'
    show TextPainter, TextSpan, TextStyle, TextDirection, FontWeight;

/// Toplama/çarpışmada yukarı süzülüp kaybolan el yazısı puan.
class FloatingText extends PositionComponent {
  FloatingText(String text, Color color, {required this.duration})
    : _painter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontFamily: 'Caveat',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(),
      super(anchor: Anchor.center);

  final TextPainter _painter;
  final double duration;
  double _t = 0;
  final Paint _layer = Paint();

  @override
  void update(double dt) {
    _t += dt;
    y -= 50 * dt;
    if (_t >= duration) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final alpha = (1 - _t / duration).clamp(0.0, 1.0);
    _layer.color = Color.fromRGBO(0, 0, 0, alpha);
    canvas.saveLayer(null, _layer);
    _painter.paint(canvas, Offset(-_painter.width / 2, -_painter.height / 2));
    canvas.restore();
  }

  @override
  void onRemove() {
    _painter.dispose();
    super.onRemove();
  }
}
