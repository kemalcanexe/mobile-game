import 'dart:typed_data';
import 'dart:ui';

import 'package:flame/components.dart';

import '../../app/palette.dart';
import '../systems/collision_rules.dart';
import '../tukenmez_game.dart';

/// Kalemin arkasında uzayan mürekkep izi. Noktalar kaydırma mesafesinde
/// saklanır (her karede kaydırılmaz), sabit boyutlu halka tamponda tutulur,
/// belirli aralıkla seyreltilir ve ekran dışına çıkanlar atılır.
class InkTrail extends Component with HasGameReference<TukenmezGame> {
  late final int _cap;
  late final Float64List _x;
  late final Float64List _d;
  late final Uint8List _flags; // 1 = kalem havada
  int _head = 0; // bir sonraki yazılacak indeks
  int _count = 0;
  double _lastD = double.negativeInfinity;

  static const _lowInk = Color(0x731F3A93);

  final Path _path = Path();
  final Path _dashPath = Path();
  late final Paint _paint;
  late final Paint _dashPaint;

  int get pointCount => _count;

  @override
  void onLoad() {
    final c = game.config;
    _cap = c.trailMaxPoints;
    _x = Float64List(_cap);
    _d = Float64List(_cap);
    _flags = Uint8List(_cap);
    _paint = Paint()
      ..color = Palette.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = c.trailStrokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    _dashPaint = Paint()
      ..color = Palette.inkLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = c.trailStrokeWidth * 0.7
      ..strokeCap = StrokeCap.round;
  }

  @override
  void update(double dt) {
    final g = game;
    if (g.state != RunState.running) return;
    final c = g.config;
    // ekranın altına düşen en eski noktaları at
    final bottomD = g.distance - (g.viewBottom + 20 - g.penY);
    while (_count > 0 && _d[_oldest] < bottomD) {
      _count--;
    }
    if (g.distance - _lastD < c.trailSampleDistance) return;
    _lastD = g.distance;
    _x[_head] = g.pen.x;
    _d[_head] = g.distance;
    _flags[_head] = g.pen.pose == PenPose.airborne ? 1 : 0;
    _head = (_head + 1) % _cap;
    if (_count < _cap) _count++;
  }

  int get _oldest => (_head - _count + _cap) % _cap;

  @override
  void render(Canvas canvas) {
    if (_count < 2) return;
    final g = game;
    final low = g.ink.isLow;
    _paint.color = low ? _lowInk : Palette.ink;
    _path.reset();
    _dashPath.reset();
    var penDown = false;
    // en yeniden en eskiye; ilk nokta kalemin ucu
    var px = g.pen.x;
    var py = g.penY;
    _path.moveTo(px, py);
    penDown = true;
    for (var i = 0; i < _count; i++) {
      final idx = (_head - 1 - i + _cap) % _cap;
      final x = _x[idx];
      final y = g.yForDistance(_d[idx]);
      final airborne = _flags[idx] == 1;
      // mürekkep azsa çizgi kesik kesik çıkar
      final skip = low && (idx % 3 == 0);
      if (airborne) {
        if (i.isEven) {
          _dashPath
            ..moveTo(px, py)
            ..lineTo(x, y);
        }
        penDown = false;
      } else if (skip) {
        penDown = false;
      } else {
        if (!penDown) {
          _path.moveTo(px, py);
          penDown = true;
        }
        _path.lineTo(x, y);
      }
      px = x;
      py = y;
    }
    canvas.drawPath(_dashPath, _dashPaint);
    canvas.drawPath(_path, _paint);
  }
}
