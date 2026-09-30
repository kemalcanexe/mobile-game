import 'dart:ui';

import '../../app/palette.dart';
import 'wobbly_pen.dart';

/// Tüki'nin çizimi: ucu yukarıda, gövdesi aşağı doğru uzanan bir tükenmez.
/// Kutu: [penArtWidth]×[penArtHeight]; uç (0 noktası) üst ortadadır.
const double penArtWidth = 30;
const double penArtHeight = 88;

void paintPen(Canvas c, WobblyPen p, {Color body = Palette.ink}) {
  const w = penArtWidth;
  const cx = w / 2;
  // uç
  final tip = p.polygonPath(const [
    Offset(cx, 0),
    Offset(cx + 5, 13),
    Offset(cx - 5, 13),
  ], overshoot: false);
  c.drawPath(tip, Paint()..color = Palette.darkText);
  // tutma yeri
  final grip = p.rectPath(const Rect.fromLTWH(cx - 7, 13, 14, 20));
  p.fill(c, grip, const Color(0xFFCFDCFF));
  c.drawPath(grip, strokePaint(body, 2));
  final rp = strokePaint(Palette.inkLight, 1.2);
  for (var i = 0; i < 3; i++) {
    p.line(
      c,
      Offset(cx - 6, 18.0 + i * 5),
      Offset(cx + 6, 18.0 + i * 5),
      rp,
      segments: 1,
    );
  }
  // gövde
  final bodyPath = p.rectPath(const Rect.fromLTWH(cx - 7, 33, 14, 44));
  p.fill(c, bodyPath, const Color(0xFFF7F9FF));
  c.drawPath(
    Path()
      ..moveTo(cx, 34)
      ..lineTo(cx, 75),
    strokePaint(const Color(0x881F3A93), 3),
  );
  c.drawPath(bodyPath, strokePaint(body, 2));
  // arka kapak ve klips
  final cap = p.rectPath(const Rect.fromLTWH(cx - 7, 77, 14, 10));
  p.fill(c, cap, body);
  c.drawPath(cap, strokePaint(body, 2));
  p.line(
    c,
    const Offset(cx + 9, 44),
    const Offset(cx + 9, 70),
    strokePaint(body, 2),
    segments: 2,
  );
  // yüz
  final eye = Paint()..color = Palette.darkText;
  c.drawCircle(const Offset(cx - 3.2, 45), 1.7, eye);
  c.drawCircle(const Offset(cx + 3.2, 45), 1.7, eye);
  c.drawPath(
    Path()
      ..moveTo(cx - 3, 50)
      ..quadraticBezierTo(cx, 53, cx + 3, 50),
    strokePaint(Palette.darkText, 1.3),
  );
}
