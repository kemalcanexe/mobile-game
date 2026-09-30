import 'package:flutter/material.dart';

import '../../app/palette.dart';
import '../../game/page_map.dart';

/// Level sonunda sayfanın tamamı: mürekkep izi, yıldızlar ve lekeler.
class PageMapView extends StatelessWidget {
  const PageMapView({
    super.key,
    required this.map,
    this.width = 110,
    this.height = 240,
  });

  final PageMap map;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Palette.paper,
      border: Border.all(color: Palette.pencilLight),
      boxShadow: const [
        BoxShadow(
          color: Color(0x22000000),
          blurRadius: 4,
          offset: Offset(1, 2),
        ),
      ],
    ),
    child: CustomPaint(painter: _MapPainter(map)),
  );
}

class _MapPainter extends CustomPainter {
  _MapPainter(this.map);
  final PageMap map;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = Palette.gridLine
      ..strokeWidth = 0.6;
    for (var y = 0.0; y < size.height; y += 8) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final sx = size.width / map.width;
    final total = map.totalDistance <= 0 ? 1 : map.totalDistance;
    // yazı yukarı doğru ilerler: sayfanın başı altta
    double y(double d) => size.height - d / total * size.height;

    final ink = Paint()
      ..color = Palette.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    final dashed = Paint()
      ..color = Palette.inkLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final t = map.trail;
    for (var i = 1; i < t.length; i++) {
      final a = Offset(t[i - 1].x * sx, y(t[i - 1].distance));
      final b = Offset(t[i].x * sx, y(t[i].distance));
      if (t[i].airborne) {
        if (i.isEven) canvas.drawLine(a, b, dashed);
      } else {
        canvas.drawLine(a, b, ink);
      }
    }
    final star = Paint()..color = const Color(0xFFE6C700);
    final stain = Paint()..color = Palette.coffeeStain;
    for (final m in map.markers) {
      final p = Offset(m.x * sx, y(m.distance));
      if (m.kind == MapMarkerKind.star) {
        canvas.drawCircle(p, 1.8, star);
      } else {
        canvas.drawCircle(p, 4, stain);
      }
    }
    if (map.reachedDistance < map.totalDistance) {
      final cut = y(map.reachedDistance);
      canvas.drawRect(
        Rect.fromLTRB(0, 0, size.width, cut),
        Paint()..color = Palette.paperShade.withValues(alpha: 0.7),
      );
    }
  }

  @override
  bool shouldRepaint(_MapPainter old) => old.map != map;
}
