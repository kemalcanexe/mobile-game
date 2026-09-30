import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/painting.dart'
    show TextPainter, TextSpan, TextStyle, TextDirection;

import '../../app/paper_theme.dart';
import '../tukenmez_game.dart';

/// Sonsuz kayan defter sayfası: dersin kağıt dokusu, spiral delikleri,
/// şerit kılavuzları ve sayfa sonu (bitiş çizgisi).
class PaperBackground extends Component with HasGameReference<TukenmezGame> {
  static const _gridStep = 24.0;
  static const _mmStep = 8.0;
  static const _mmMajor = 5; // her 5 küçük karede bir kalın çizgi
  static const _lineStep = 32.0;
  static const _holeStep = 44.0;
  static const _dash = 14.0;
  static const _marginX = 28.0;

  late final PaperTheme theme = PaperTheme.of(game.setup.paper);
  late final Paint _paper = Paint()..color = theme.background;
  late final Paint _line = Paint()
    ..color = theme.line
    ..strokeWidth = 1;
  late final Paint _lineStrong = Paint()
    ..color = theme.lineStrong
    ..strokeWidth = 1.2;
  late final Paint _margin = Paint()
    ..color = theme.margin ?? theme.line
    ..strokeWidth = 1.4;
  late final Paint _hole = Paint()..color = theme.hole;
  late final Paint _holeRim = Paint()
    ..color = theme.laneGuide
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;
  late final Paint _lane = Paint()
    ..color = theme.laneGuide
    ..strokeWidth = 1.6
    ..strokeCap = StrokeCap.round;
  late final Paint _endShade = Paint()..color = theme.endShade;
  late final Paint _endLine = Paint()
    ..color = theme.endText
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

    switch (theme.pattern) {
      case PaperPattern.grid:
        _grid(canvas, left, right, h, d, w, _gridStep, 0);
      case PaperPattern.millimeter:
        _grid(canvas, left, right, h, d, w, _mmStep, _mmMajor);
      case PaperPattern.lined:
        final offset = d % _lineStep;
        for (var y = offset - _lineStep; y < h; y += _lineStep) {
          canvas.drawLine(Offset(left, y), Offset(right, y), _line);
        }
        canvas.drawLine(
          const Offset(_marginX, 0),
          Offset(_marginX, h),
          _margin,
        );
    }

    // spiral delikleri
    final holeOffset = d % _holeStep;
    for (var y = holeOffset - _holeStep; y < h; y += _holeStep) {
      canvas.drawCircle(Offset(left + 10, y), 5, _hole);
      canvas.drawCircle(Offset(left + 10, y), 5, _holeRim);
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
          style: TextStyle(
            fontFamily: 'Caveat',
            fontSize: 22,
            color: theme.endText,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      label.paint(canvas, Offset(w / 2 - label.width / 2, endY - 34));
    }
  }

  /// Kareli/milimetrik doku. [major] > 0 ise her [major] karede kalın çizgi.
  void _grid(
    Canvas canvas,
    double left,
    double right,
    double h,
    double d,
    double w,
    double step,
    int major,
  ) {
    final majorStep = major > 0 ? step * major : 0.0;
    final offset = d % step;
    // kalın çizgilerin sayfayla birlikte kayması için mesafeye göre indeks
    final firstIndex = (d / step).floor();
    var i = 0;
    for (var y = offset - step; y < h; y += step, i++) {
      final isMajor = major > 0 && (firstIndex - i + 1) % major == 0;
      canvas.drawLine(
        Offset(left, y),
        Offset(right, y),
        isMajor ? _lineStrong : _line,
      );
    }
    final startX = w / 2 - ((w / 2 - left) ~/ step + 1) * step;
    for (var x = startX; x < right; x += step) {
      final isMajor =
          majorStep > 0 && ((x - w / 2) / step).round() % major == 0;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, h),
        isMajor ? _lineStrong : _line,
      );
    }
  }

  @override
  void onRemove() {
    _endLabel?.dispose();
    super.onRemove();
  }
}
