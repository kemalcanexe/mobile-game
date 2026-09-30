import 'package:flutter/material.dart';

import '../../app/palette.dart';

/// Defterden koparılmış yaprak: üst kenarı tırtıklı beyaz kart.
class TornCard extends StatelessWidget {
  const TornCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(18, 22, 18, 16),
    this.tilt = 0,
    this.color = Colors.white,
  });

  final Widget child;
  final EdgeInsets padding;
  final double tilt;
  final Color color;

  @override
  Widget build(BuildContext context) => Transform.rotate(
    angle: tilt,
    child: DecoratedBox(
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 8,
            offset: Offset(2, 4),
          ),
        ],
      ),
      child: ClipPath(
        clipper: _TornClipper(),
        child: ColoredBox(
          color: color,
          child: CustomPaint(
            painter: _RulePainter(),
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    ),
  );
}

class _TornClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const tooth = 7.0;
    final path = Path()..moveTo(0, tooth);
    var x = 0.0;
    var up = true;
    while (x < size.width) {
      x += tooth;
      path.lineTo(x.clamp(0, size.width), up ? 0 : tooth);
      up = !up;
    }
    path
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _RulePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Palette.paperLine.withValues(alpha: 0.5)
      ..strokeWidth = 1;
    for (var y = 40.0; y < size.height; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(_RulePainter oldDelegate) => false;
}
