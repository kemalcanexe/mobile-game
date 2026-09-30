import 'package:flutter/material.dart';

import '../../app/paper_theme.dart';

/// Menü ekranlarının defter sayfası zemini (dersin kağıt temasıyla).
class PaperBackdrop extends StatelessWidget {
  const PaperBackdrop({super.key, required this.child, this.paper = 'lined'});

  final Widget child;
  final String paper;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _PaperPainter(PaperTheme.of(paper)), child: child);
}

class _PaperPainter extends CustomPainter {
  _PaperPainter(this.theme);
  final PaperTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = theme.background);
    final line = Paint()
      ..color = theme.line
      ..strokeWidth = 1;
    final strong = Paint()
      ..color = theme.lineStrong
      ..strokeWidth = 1.2;
    switch (theme.pattern) {
      case PaperPattern.lined:
        for (var y = 96.0; y < size.height; y += 32) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
        }
        canvas.drawLine(
          const Offset(44, 0),
          Offset(44, size.height),
          Paint()
            ..color = theme.margin ?? theme.line
            ..strokeWidth = 1.5,
        );
      case PaperPattern.grid:
      case PaperPattern.millimeter:
        final mm = theme.pattern == PaperPattern.millimeter;
        final step = mm ? 8.0 : 24.0;
        var i = 0;
        for (var y = 0.0; y < size.height; y += step, i++) {
          canvas.drawLine(
            Offset(0, y),
            Offset(size.width, y),
            mm && i % 5 == 0 ? strong : line,
          );
        }
        i = 0;
        for (var x = 0.0; x < size.width; x += step, i++) {
          canvas.drawLine(
            Offset(x, 0),
            Offset(x, size.height),
            mm && i % 5 == 0 ? strong : line,
          );
        }
    }
    final hole = Paint()..color = theme.hole;
    for (var y = 24.0; y < size.height; y += 44) {
      canvas.drawCircle(Offset(14, y), 6, hole);
    }
  }

  @override
  bool shouldRepaint(_PaperPainter old) => old.theme != theme;
}
