import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/painting.dart'
    show TextPainter, TextSpan, TextStyle, TextDirection;

import '../../app/palette.dart';
import '../tukenmez_game.dart';

/// Sonsuz kayan defter sayfası: kareli/çizgili doku, spiral delikleri,
/// şerit kılavuzları ve sayfa sonu (bitiş çizgisi).
class PaperBackground extends Component with HasGameReference<TukenmezGame> {
  static const _gridStep = 24.0;
  static const _lineStep = 32.0;
  static const _holeStep = 44.0;
  static const _dash = 14.0;

  final Paint _paper = Paint()..color = Palette.paper;
  final Paint _grid = Paint()
    ..color = Palette.gridLine
    ..strokeWidth = 1;
  final Paint _line = Paint()
    ..color = Palette.paperLine
    ..strokeWidth = 1.2;
  final Paint _margin = Paint()
    ..color = Palette.marginRed
    ..strokeWidth = 1.4;
  final Paint _hole = Paint()..color = Palette.hole;
  final Paint _holeRim = Paint()
    ..color = Palette.pencilLight
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;
  final Paint _lane = Paint()
    ..color = Palette.pencilLight
    ..strokeWidth = 1.6
    ..strokeCap = StrokeCap.round;
  final Paint _endShade = Paint()..color = Palette.paperShade;
  final Paint _endLine = Paint()
    ..color = Palette.pencil
    ..strokeWidth = 2;
  TextPainter? _endLabel;

  @override
  void render(Canvas canvas) {
    final g = game;
    final left = g.viewLeft;
    final right = g.viewLeft + g.viewWidth;
    final h = g.viewHeight;
    final d = g.distance;
    final w = g.config.worldWidth;

    canvas.drawRect(Rect.fromLTRB(left, 0, right, h), _paper);

    if (g.setup.paper == 'grid') {
      final offset = d % _gridStep;
      for (var y = offset - _gridStep; y < h; y += _gridStep) {
        canvas.drawLine(Offset(left, y), Offset(right, y), _grid);
      }
      final startX = w / 2 - ((w / 2 - left) ~/ _gridStep + 1) * _gridStep;
      for (var x = startX; x < right; x += _gridStep) {
        canvas.drawLine(Offset(x, 0), Offset(x, h), _grid);
      }
    } else {
      final offset = d % _lineStep;
      for (var y = offset - _lineStep; y < h; y += _lineStep) {
        canvas.drawLine(Offset(left, y), Offset(right, y), _line);
      }
      canvas.drawLine(const Offset(28, 0), Offset(28, h), _margin);
    }

    // spiral delikleri
    final holeOffset = d % _holeStep;
    for (var y = holeOffset - _holeStep; y < h; y += _holeStep) {
      canvas.drawCircle(Offset(10, y), 5, _hole);
      canvas.drawCircle(Offset(10, y), 5, _holeRim);
    }

    // şerit kılavuzları (hafif kurşun kalem, kesik)
    final dashOffset = d % (_dash * 2);
    for (final x in g.lanes.dividerXs) {
      for (var y = dashOffset - _dash * 2; y < h; y += _dash * 2) {
        canvas.drawLine(Offset(x, y), Offset(x, y + _dash), _lane);
      }
    }

    // sayfa sonu: alt kenar boşluğu, çift çizgi, spiral delik sırası
    final endY = g.yForDistance(g.totalDistance);
    if (endY > -60 && endY < h) {
      canvas.drawRect(Rect.fromLTRB(left, endY, right, h), _endShade);
      canvas.drawLine(Offset(left, endY), Offset(right, endY), _endLine);
      canvas.drawLine(
        Offset(left, endY - 5),
        Offset(right, endY - 5),
        _endLine,
      );
      for (var x = 20.0; x < w; x += 34) {
        canvas.drawCircle(Offset(x, endY + 22), 6, _hole);
        canvas.drawCircle(Offset(x, endY + 22), 6, _holeRim);
      }
      final label = _endLabel ??= TextPainter(
        text: TextSpan(
          text: g.setup.strings.pageEnd,
          style: const TextStyle(
            fontFamily: 'Caveat',
            fontSize: 22,
            color: Palette.pencil,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      label.paint(canvas, Offset(w / 2 - label.width / 2, endY - 34));
    }
  }

  @override
  void onRemove() {
    _endLabel?.dispose();
    super.onRemove();
  }
}
