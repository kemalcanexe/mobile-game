import 'package:flutter/material.dart';

import '../../game/doodle/pen_art.dart';
import '../../game/doodle/wobbly_pen.dart';

/// Menülerde Tüki çizimi.
class TukiIcon extends StatelessWidget {
  const TukiIcon({super.key, this.height = 120, this.tilt = 0.35});

  final double height;
  final double tilt;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: height * penArtWidth / penArtHeight * 2,
    height: height,
    child: CustomPaint(painter: _TukiPainter(tilt)),
  );
}

class _TukiPainter extends CustomPainter {
  _TukiPainter(this.tilt);
  final double tilt;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.height / penArtHeight;
    canvas.translate(size.width / 2, 0);
    canvas.rotate(tilt);
    canvas.scale(scale * 0.95);
    canvas.translate(-penArtWidth / 2, 0);
    paintPen(canvas, WobblyPen(7));
  }

  @override
  bool shouldRepaint(_TukiPainter old) => old.tilt != tilt;
}
