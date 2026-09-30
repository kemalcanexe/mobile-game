import 'dart:math';
import 'dart:ui';

import 'package:flutter/painting.dart'
    show TextPainter, TextSpan, TextStyle, TextDirection, FontWeight;

import '../../app/palette.dart';
import 'wobbly_pen.dart';

/// Nesnelerin programatik doodle çizimleri. Her fonksiyon [s]×[s] kutusuna
/// çizer. (+) nesneler yuvarlak ve mavi, (−) nesneler köşeli ve kırmızı/mor
/// konturludur (proposal §22).
typedef ArtPainter = void Function(
  Canvas c,
  double s,
  WobblyPen pen,
  ArtText text,
);

/// Çizimlerde geçen yerelleştirilmiş kısa metinler.
class ArtText {
  const ArtText({required this.friendBubble});
  final String friendBubble;
}

const _stroke = 2.2;

void _label(
  Canvas c,
  String text,
  Offset center,
  double size,
  Color color, {
  double rotation = 0,
}) {
  final tp = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        fontFamily: 'Caveat',
        fontSize: size,
        color: color,
        fontWeight: FontWeight.w700,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  c.save();
  c.translate(center.dx, center.dy);
  c.rotate(rotation);
  tp.paint(c, Offset(-tp.width / 2, -tp.height / 2));
  c.restore();
  tp.dispose();
}

void _airShadow(Canvas c, double s, Path shape) {
  c.save();
  c.translate(s * 0.10, s * 0.16);
  c.drawPath(shape, Paint()..color = const Color(0x22000000));
  c.restore();
}

void _flashcard(Canvas c, double s, WobblyPen p, ArtText t) {
  c.save();
  c.translate(s / 2, s / 2);
  c.rotate(-0.12);
  final r = Rect.fromCenter(
    center: Offset.zero,
    width: s * 0.72,
    height: s * 0.5,
  );
  final rr = RRect.fromRectAndRadius(r, Radius.circular(s * 0.1));
  final path = Path()..addRRect(rr);
  p.fill(c, path, const Color(0xFFE3ECFF));
  c.drawPath(path, strokePaint(Palette.ink, _stroke));
  final lp = strokePaint(Palette.inkLight, 1.4);
  p.line(c, Offset(-s * 0.24, -s * 0.07), Offset(s * 0.24, -s * 0.07), lp);
  p.line(c, Offset(-s * 0.24, s * 0.07), Offset(s * 0.12, s * 0.07), lp);
  c.restore();
}

void _note(Canvas c, double s, WobblyPen p, ArtText t) {
  final l = s * 0.2, r = s * 0.8, tp = s * 0.16, b = s * 0.84, fold = s * 0.18;
  final outline = p.polygonPath([
    Offset(l, tp),
    Offset(r - fold, tp),
    Offset(r, tp + fold),
    Offset(r, b),
    Offset(l, b),
  ]);
  p.fill(c, outline, const Color(0xFFF4F7FF));
  c.drawPath(outline, strokePaint(Palette.ink, _stroke));
  p.line(
    c,
    Offset(r - fold, tp),
    Offset(r - fold, tp + fold),
    strokePaint(Palette.ink, 1.6),
    segments: 1,
  );
  p.line(
    c,
    Offset(r - fold, tp + fold),
    Offset(r, tp + fold),
    strokePaint(Palette.ink, 1.6),
    segments: 1,
  );
  final lp = strokePaint(Palette.inkLight, 1.3);
  for (var i = 0; i < 3; i++) {
    final y = tp + fold + 6 + i * s * 0.12;
    p.line(c, Offset(l + 5, y), Offset(r - 6, y), lp, segments: 2);
  }
}

void _formula(Canvas c, double s, WobblyPen p, ArtText t) {
  final r = Rect.fromCenter(
    center: Offset(s / 2, s / 2),
    width: s * 0.66,
    height: s * 0.66,
  );
  final path = Path()
    ..addRRect(RRect.fromRectAndRadius(r, Radius.circular(s * 0.16)));
  p.fill(c, path, const Color(0xFFDDE7FF));
  c.drawPath(path, strokePaint(Palette.ink, _stroke));
  // ∫ işareti (fonttan bağımsız)
  final cx = s * 0.44, top = s * 0.26, bot = s * 0.74;
  final integral = Path()
    ..moveTo(cx + s * 0.1, top + s * 0.03)
    ..quadraticBezierTo(cx + s * 0.04, top - s * 0.03, cx, top + s * 0.08)
    ..lineTo(cx, bot - s * 0.08)
    ..quadraticBezierTo(
      cx - s * 0.04,
      bot + s * 0.03,
      cx - s * 0.1,
      bot - s * 0.03,
    );
  c.drawPath(integral, strokePaint(Palette.ink, 2.6));
  _label(c, 'dx', Offset(s * 0.62, s * 0.56), s * 0.26, Palette.ink);
}

void _textCard(
  Canvas c,
  double s,
  WobblyPen p,
  String text,
  Color fill,
  double size,
) {
  final r = Rect.fromCenter(
    center: Offset(s / 2, s / 2),
    width: s * 0.74,
    height: s * 0.6,
  );
  final path = Path()
    ..addRRect(RRect.fromRectAndRadius(r, Radius.circular(s * 0.16)));
  p.fill(c, path, fill);
  c.drawPath(path, strokePaint(Palette.ink, _stroke));
  _label(c, text, Offset(s / 2, s / 2), s * size, Palette.ink, rotation: -0.08);
}

void _physics(Canvas c, double s, WobblyPen p, ArtText t) =>
    _textCard(c, s, p, 'F=ma', const Color(0xFFDDE7FF), 0.3);

void _code(Canvas c, double s, WobblyPen p, ArtText t) =>
    _textCard(c, s, p, '{ }', const Color(0xFFD8F5E3), 0.4);

void _book(Canvas c, double s, WobblyPen p, ArtText t) {
  final r = Rect.fromLTWH(s * 0.18, s * 0.1, s * 0.64, s * 0.8);
  final path = p.rectPath(r);
  p.fill(c, path, const Color(0xFFC7D7FF));
  c.drawPath(path, strokePaint(Palette.ink, _stroke + 0.4));
  p.line(
    c,
    Offset(r.left + s * 0.1, r.top),
    Offset(r.left + s * 0.1, r.bottom),
    strokePaint(Palette.ink, 1.8),
    segments: 2,
  );
  final lp = strokePaint(Palette.ink, 1.4);
  p.line(
    c,
    Offset(r.left + s * 0.2, r.top + s * 0.18),
    Offset(r.right - s * 0.08, r.top + s * 0.18),
    lp,
    segments: 2,
  );
  p.line(
    c,
    Offset(r.left + s * 0.2, r.top + s * 0.28),
    Offset(r.right - s * 0.16, r.top + s * 0.28),
    lp,
    segments: 2,
  );
  c.drawPath(
    p.circlePath(
      Offset(r.center.dx + s * 0.05, r.bottom - s * 0.2),
      s * 0.07,
      points: 8,
    ),
    strokePaint(Palette.ink, 1.4),
  );
}

void _bonus(Canvas c, double s, WobblyPen p, ArtText t) {
  final circle = p.circlePath(Offset(s / 2, s / 2), s * 0.34);
  p.fill(c, circle, Palette.highlighterYellow);
  c.drawPath(circle, strokePaint(Palette.ink, _stroke));
  _label(c, '?', Offset(s / 2, s / 2), s * 0.62, Palette.ink);
  _label(c, '+', Offset(s * 0.8, s * 0.2), s * 0.34, Palette.teacherRed);
}

void _highlighter(Canvas c, double s, WobblyPen p, ArtText t) {
  c.drawCircle(
    Offset(s / 2, s / 2),
    s * 0.42,
    Paint()..color = const Color(0x55FFE94D),
  );
  c.save();
  c.translate(s / 2, s / 2);
  c.rotate(-pi / 4);
  final body = p.rectPath(
    Rect.fromCenter(
      center: Offset(0, s * 0.06),
      width: s * 0.26,
      height: s * 0.5,
    ),
  );
  p.fill(c, body, Palette.highlighterYellow);
  c.drawPath(body, strokePaint(Palette.ink, _stroke));
  final tip = p.polygonPath([
    Offset(-s * 0.13, -s * 0.19),
    Offset(s * 0.13, -s * 0.19),
    Offset(s * 0.06, -s * 0.34),
    Offset(-s * 0.06, -s * 0.34),
  ]);
  p.fill(c, tip, const Color(0xFFF2C200));
  c.drawPath(tip, strokePaint(Palette.ink, 1.8));
  c.restore();
}

void _coffee(Canvas c, double s, WobblyPen p, ArtText t) {
  final cup = p.polygonPath([
    Offset(s * 0.24, s * 0.36),
    Offset(s * 0.7, s * 0.36),
    Offset(s * 0.64, s * 0.84),
    Offset(s * 0.3, s * 0.84),
  ]);
  p.fill(c, cup, const Color(0xFFF1E3D3));
  c.drawPath(cup, strokePaint(Palette.coffee, _stroke));
  c.drawPath(
    p.circlePath(Offset(s * 0.74, s * 0.55), s * 0.09, points: 9),
    strokePaint(Palette.coffee, 2),
  );
  final sp = strokePaint(Palette.pencil, 1.6);
  for (var i = 0; i < 2; i++) {
    final x = s * (0.38 + i * 0.18);
    final steam = Path()
      ..moveTo(x, s * 0.3)
      ..quadraticBezierTo(x - s * 0.07, s * 0.22, x, s * 0.16)
      ..quadraticBezierTo(x + s * 0.07, s * 0.1, x, s * 0.04);
    c.drawPath(steam, sp);
  }
  p.line(
    c,
    Offset(s * 0.27, s * 0.46),
    Offset(s * 0.67, s * 0.46),
    strokePaint(Palette.coffee, 1.4),
    segments: 2,
  );
}

void _cartridge(Canvas c, double s, WobblyPen p, ArtText t) {
  c.save();
  c.translate(s / 2, s / 2);
  c.rotate(0.3);
  final body = Path()
    ..addRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: s * 0.3, height: s * 0.72),
        Radius.circular(s * 0.15),
      ),
    );
  p.fill(c, body, const Color(0xFFB9CBFF));
  final ink = Path()
    ..addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-s * 0.15, 0, s * 0.3, s * 0.36),
        Radius.circular(s * 0.15),
      ),
    );
  c.drawPath(ink, Paint()..color = Palette.ink);
  c.drawPath(body, strokePaint(Palette.ink, _stroke));
  c.restore();
  _label(c, '+', Offset(s * 0.2, s * 0.22), s * 0.4, Palette.ink);
}

void _phone(Canvas c, double s, WobblyPen p, ArtText t) {
  final r = Rect.fromLTWH(s * 0.28, s * 0.12, s * 0.44, s * 0.76);
  final body = p.rectPath(r);
  p.fill(c, body, const Color(0xFFFFE3E6));
  c.drawPath(body, strokePaint(Palette.teacherRed, _stroke + 0.3));
  p.line(
    c,
    Offset(r.left + s * 0.06, r.top + s * 0.1),
    Offset(r.right - s * 0.06, r.top + s * 0.1),
    strokePaint(Palette.teacherRed, 1.4),
    segments: 1,
  );
  // zil
  final bell = p.polygonPath([
    Offset(s * 0.5, s * 0.32),
    Offset(s * 0.6, s * 0.46),
    Offset(s * 0.62, s * 0.6),
    Offset(s * 0.38, s * 0.6),
    Offset(s * 0.4, s * 0.46),
  ]);
  c.drawPath(bell, strokePaint(Palette.teacherRed, 1.8));
  c.drawCircle(
    Offset(s * 0.74, s * 0.16),
    s * 0.1,
    Paint()..color = Palette.teacherRed,
  );
  _label(c, '1', Offset(s * 0.74, s * 0.16), s * 0.18, Palette.paper);
}

void _console(Canvas c, double s, WobblyPen p, ArtText t) {
  final body = p.polygonPath([
    Offset(s * 0.12, s * 0.38),
    Offset(s * 0.3, s * 0.28),
    Offset(s * 0.7, s * 0.28),
    Offset(s * 0.88, s * 0.38),
    Offset(s * 0.82, s * 0.72),
    Offset(s * 0.62, s * 0.62),
    Offset(s * 0.38, s * 0.62),
    Offset(s * 0.18, s * 0.72),
  ]);
  p.fill(c, body, const Color(0xFFEBDDF8));
  c.drawPath(body, strokePaint(Palette.distraction, _stroke + 0.3));
  final dp = strokePaint(Palette.distraction, 2.2);
  p.line(
    c,
    Offset(s * 0.24, s * 0.46),
    Offset(s * 0.4, s * 0.46),
    dp,
    segments: 1,
  );
  p.line(
    c,
    Offset(s * 0.32, s * 0.38),
    Offset(s * 0.32, s * 0.54),
    dp,
    segments: 1,
  );
  c.drawCircle(
    Offset(s * 0.66, s * 0.42),
    s * 0.045,
    Paint()..color = Palette.teacherRed,
  );
  c.drawCircle(
    Offset(s * 0.74, s * 0.5),
    s * 0.045,
    Paint()..color = Palette.distraction,
  );
}

void _friend(Canvas c, double s, WobblyPen p, ArtText t) {
  final sp = strokePaint(Palette.distraction, _stroke);
  final head = p.polygonPath([
    Offset(s * 0.2, s * 0.34),
    Offset(s * 0.36, s * 0.34),
    Offset(s * 0.36, s * 0.5),
    Offset(s * 0.2, s * 0.5),
  ]);
  c.drawPath(head, sp);
  p.line(
    c,
    Offset(s * 0.28, s * 0.5),
    Offset(s * 0.28, s * 0.74),
    sp,
    segments: 2,
  );
  p.line(
    c,
    Offset(s * 0.28, s * 0.58),
    Offset(s * 0.5, s * 0.5),
    sp,
    segments: 1,
  );
  p.line(
    c,
    Offset(s * 0.28, s * 0.58),
    Offset(s * 0.12, s * 0.66),
    sp,
    segments: 1,
  );
  p.line(
    c,
    Offset(s * 0.28, s * 0.74),
    Offset(s * 0.18, s * 0.92),
    sp,
    segments: 1,
  );
  p.line(
    c,
    Offset(s * 0.28, s * 0.74),
    Offset(s * 0.38, s * 0.92),
    sp,
    segments: 1,
  );
  final bubble = p.polygonPath([
    Offset(s * 0.4, s * 0.04),
    Offset(s * 1.0, s * 0.04),
    Offset(s * 1.0, s * 0.3),
    Offset(s * 0.56, s * 0.3),
    Offset(s * 0.44, s * 0.4),
    Offset(s * 0.46, s * 0.3),
    Offset(s * 0.4, s * 0.3),
  ]);
  p.fill(c, bubble, Palette.paper);
  c.drawPath(bubble, strokePaint(Palette.distraction, 1.6));
  _label(
    c,
    t.friendBubble,
    Offset(s * 0.7, s * 0.17),
    s * 0.22,
    Palette.distraction,
  );
}

void _spill(Canvas c, double s, WobblyPen p, ArtText t) {
  final blob = p.circlePath(Offset(s / 2, s / 2), s * 0.36, points: 11);
  c.drawPath(blob, Paint()..color = const Color(0x998B5A2B));
  c.drawPath(blob, strokePaint(Palette.coffee, 1.8));
  c.drawPath(
    p.circlePath(Offset(s * 0.82, s * 0.24), s * 0.07, points: 7),
    Paint()..color = const Color(0x998B5A2B),
  );
  c.drawPath(
    p.circlePath(Offset(s * 0.2, s * 0.8), s * 0.05, points: 7),
    Paint()..color = const Color(0x998B5A2B),
  );
}

void _staples(Canvas c, double s, WobblyPen p, ArtText t) {
  final sp = strokePaint(const Color(0xFF6D6D6D), 2.2);
  for (var i = 0; i < 4; i++) {
    final y = s * (0.24 + i * 0.16);
    final x = s * (0.2 + (i.isOdd ? 0.12 : 0));
    final staple = Path()
      ..moveTo(x, y + s * 0.08)
      ..lineTo(x, y)
      ..lineTo(x + s * 0.4, y)
      ..lineTo(x + s * 0.4, y + s * 0.08);
    c.drawPath(staple, sp);
  }
  p.line(
    c,
    Offset(s * 0.12, s * 0.9),
    Offset(s * 0.88, s * 0.9),
    strokePaint(Palette.teacherRed, 1.4),
    segments: 4,
  );
}

void _plane(Canvas c, double s, WobblyPen p, ArtText t) {
  final shape = p.polygonPath([
    Offset(s * 0.5, s * 0.06),
    Offset(s * 0.86, s * 0.78),
    Offset(s * 0.5, s * 0.62),
    Offset(s * 0.14, s * 0.78),
  ]);
  _airShadow(c, s, shape);
  p.fill(c, shape, Palette.paper);
  c.drawPath(shape, strokePaint(Palette.teacherRed, _stroke));
  p.line(
    c,
    Offset(s * 0.5, s * 0.06),
    Offset(s * 0.5, s * 0.62),
    strokePaint(Palette.teacherRed, 1.4),
    segments: 2,
  );
}

void _paperBall(Canvas c, double s, WobblyPen p, ArtText t) {
  final ball = p.polygonPath([
    for (var i = 0; i < 9; i++)
      Offset(
        s / 2 + cos(i / 9 * pi * 2) * s * (i.isEven ? 0.32 : 0.26),
        s / 2 + sin(i / 9 * pi * 2) * s * (i.isEven ? 0.32 : 0.26),
      ),
  ], overshoot: false);
  _airShadow(c, s, ball);
  p.fill(c, ball, Palette.paper);
  c.drawPath(ball, strokePaint(Palette.teacherRed, _stroke));
  final cp = strokePaint(Palette.pencil, 1.2);
  p.line(
    c,
    Offset(s * 0.34, s * 0.36),
    Offset(s * 0.56, s * 0.52),
    cp,
    segments: 2,
  );
  p.line(
    c,
    Offset(s * 0.56, s * 0.52),
    Offset(s * 0.5, s * 0.72),
    cp,
    segments: 1,
  );
  p.line(
    c,
    Offset(s * 0.56, s * 0.52),
    Offset(s * 0.72, s * 0.42),
    cp,
    segments: 1,
  );
}

void _encyclopedia(Canvas c, double s, WobblyPen p, ArtText t) {
  final r = Rect.fromLTWH(s * 0.06, s * 0.14, s * 0.88, s * 0.72);
  final cover = p.rectPath(r);
  p.fill(c, cover, const Color(0xFFF3C9C9));
  c.drawPath(cover, strokePaint(Palette.teacherRed, _stroke + 0.8));
  final sp = strokePaint(Palette.teacherRed, 1.6);
  p.line(
    c,
    Offset(r.left, r.top + s * 0.12),
    Offset(r.right, r.top + s * 0.12),
    sp,
    segments: 3,
  );
  p.line(
    c,
    Offset(r.left, r.bottom - s * 0.12),
    Offset(r.right, r.bottom - s * 0.12),
    sp,
    segments: 3,
  );
  _label(c, 'A–Z', r.center, s * 0.3, Palette.teacherRed);
}

const Map<String, ArtPainter> itemArt = {
  'flashcard': _flashcard,
  'note': _note,
  'formula': _formula,
  'physics': _physics,
  'code': _code,
  'book': _book,
  'bonus': _bonus,
  'highlighter': _highlighter,
  'coffee': _coffee,
  'cartridge': _cartridge,
  'phone': _phone,
  'console': _console,
  'friend': _friend,
  'spill': _spill,
  'staples': _staples,
  'plane': _plane,
  'paperBall': _paperBall,
  'encyclopedia': _encyclopedia,
};
