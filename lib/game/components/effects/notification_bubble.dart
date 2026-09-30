import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/painting.dart'
    show TextPainter, TextSpan, TextStyle, TextDirection, FontWeight;

import '../../../app/palette.dart';
import '../../tukenmez_game.dart';

/// Telefon bildirimi debuff'ı: ekranın üst köşesini sahte bir bildirim
/// balonu kaplar ve arkasındaki nesneleri gizler.
class NotificationBubble extends PositionComponent
    with HasGameReference<TukenmezGame> {
  bool _left = true;
  TextPainter? _title;
  TextPainter? _body;

  static const _width = 196.0;
  static const _height = 64.0;

  final Paint _bg = Paint()..color = const Color(0xFFFFFFFF);
  final Paint _shadow = Paint()..color = const Color(0x33000000);
  final Paint _rim = Paint()
    ..color = Palette.teacherRed
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;
  final Paint _icon = Paint()..color = Palette.teacherRed;

  void show(bool left) => _left = left;

  @override
  void render(Canvas canvas) {
    final g = game;
    final left = g.effects.notificationLeft;
    if (left <= 0) return;
    final t = g.effects.notificationVisible ? (left * 6).clamp(0.0, 1.0) : 0.0;
    final x = _left ? 8.0 : g.config.worldWidth - _width - 8;
    final y = 56 - (1 - t) * 30;
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, _width, _height),
      const Radius.circular(14),
    );
    canvas.drawRRect(r.shift(const Offset(2, 4)), _shadow);
    canvas.drawRRect(r, _bg);
    canvas.drawRRect(r, _rim);
    canvas.drawCircle(Offset(x + 24, y + _height / 2), 12, _icon);
    final title = _title ??= _text(
      g.setup.strings.notificationTitle,
      15,
      FontWeight.w700,
    );
    final body = _body ??= _text(
      g.setup.strings.notificationBody,
      14,
      FontWeight.w400,
    );
    title.paint(canvas, Offset(x + 44, y + 10));
    body.paint(canvas, Offset(x + 44, y + 32));
  }

  TextPainter _text(String s, double size, FontWeight weight) => TextPainter(
    text: TextSpan(
      text: s,
      style: TextStyle(
        fontFamily: 'PatrickHand',
        fontSize: size,
        fontWeight: weight,
        color: Palette.darkText,
      ),
    ),
    textDirection: TextDirection.ltr,
    maxLines: 1,
    ellipsis: '…',
  )..layout(maxWidth: _width - 52);

  @override
  void onRemove() {
    _title?.dispose();
    _body?.dispose();
    super.onRemove();
  }
}
