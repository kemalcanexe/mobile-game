import 'package:flutter/material.dart';

import '../../app/palette.dart';

/// Menü ekranlarının çizgili defter sayfası zemini.
class PaperBackdrop extends StatelessWidget {
  const PaperBackdrop({super.key, required this.child, this.grid = false});

  final Widget child;
  final bool grid;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _PaperPainter(grid: grid),
    child: child,
  );
}

class _PaperPainter extends CustomPainter {
  _PaperPainter({required this.grid});
  final bool grid;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Palette.paper);
    final line = Paint()
      ..color = grid ? Palette.gridLine : Palette.paperLine
      ..strokeWidth = 1;
    final step = grid ? 24.0 : 32.0;
    for (var y = 96.0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
    }
    if (grid) {
      for (var x = 0.0; x < size.width; x += step) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), line);
      }
    } else {
      canvas.drawLine(
        const Offset(44, 0),
        Offset(44, size.height),
        Paint()
          ..color = Palette.marginRed
          ..strokeWidth = 1.5,
      );
    }
    final hole = Paint()..color = Palette.hole;
    for (var y = 24.0; y < size.height; y += 44) {
      canvas.drawCircle(Offset(14, y), 6, hole);
    }
  }

  @override
  bool shouldRepaint(_PaperPainter old) => old.grid != grid;
}
