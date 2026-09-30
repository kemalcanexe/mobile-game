import 'package:flutter/material.dart';

import '../../app/palette.dart';

/// Ekranın solunda dikey kalem haznesi olarak mürekkep barı.
class InkMeter extends StatelessWidget {
  const InkMeter({super.key, required this.fraction, required this.low});

  final double fraction;
  final bool low;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 26,
    height: 170,
    child: CustomPaint(painter: _InkPainter(fraction, low)),
  );
}

class _InkPainter extends CustomPainter {
  _InkPainter(this.fraction, this.low);
  final double fraction;
  final bool low;

  @override
  void paint(Canvas canvas, Size size) {
    final tube = RRect.fromRectAndRadius(
      Rect.fromLTWH(4, 18, size.width - 8, size.height - 30),
      const Radius.circular(8),
    );
    canvas.drawRRect(
      tube,
      Paint()..color = Colors.white.withValues(alpha: 0.85),
    );
    final inner = tube.outerRect.deflate(3);
    final h = inner.height * fraction.clamp(0, 1);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(inner.left, inner.bottom - h, inner.width, h),
        const Radius.circular(6),
      ),
      Paint()..color = low ? Palette.teacherRed : Palette.ink,
    );
    final stroke = Paint()
      ..color = Palette.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(tube, stroke);
    // kalem ucu ve kapak
    final tip = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(size.width / 2 + 6, size.height - 12)
      ..lineTo(size.width / 2 - 6, size.height - 12)
      ..close();
    canvas.drawPath(tip, Paint()..color = Palette.darkText);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(6, 4, size.width - 12, 14),
        const Radius.circular(4),
      ),
      Paint()..color = Palette.ink,
    );
  }

  @override
  bool shouldRepaint(_InkPainter old) =>
      old.fraction != fraction || old.low != low;
}
