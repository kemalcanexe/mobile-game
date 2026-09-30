import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../../app/palette.dart';
import '../doodle/pen_art.dart';
import '../systems/collision_rules.dart';
import '../tukenmez_game.dart';
import 'lane_object.dart';

/// Tüki. Ekranın alt ortasında sabit durur; yalnızca şerit değiştirirken
/// yatayda kayar. Konumu kalemin ucudur.
class Pen extends PositionComponent
    with HasGameReference<TukenmezGame>, CollisionCallbacks {
  Pen() : super(anchor: Anchor.topCenter);

  int lane = 1;
  int targetLane = 1;
  double _fromX = 0;
  double _laneT = 1;

  PenPose pose = PenPose.running;
  double _poseT = 0;
  double _stumbleLeft = 0;

  static const _tilt = 0.22;
  static const _duckAngle = 1.25;

  final Paint _shadow = Paint()..color = const Color(0x26000000);
  final Paint _glow = Paint()..color = const Color(0x66FFE94D);
  final Paint _steam = Paint()
    ..color = const Color(0x99A0A0A0)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;
  final Paint _reverse = Paint()
    ..color = Palette.distraction
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.4
    ..strokeCap = StrokeCap.round;

  @override
  void onLoad() {
    final c = game.config;
    size = Vector2(c.penHitboxWidth, c.penHitboxHeight);
    lane = targetLane = game.lanes.centerLane;
    x = _fromX = game.lanes.laneX(lane);
    y = game.penY;
    add(RectangleHitbox());
  }

  bool get isAirborne => pose == PenPose.airborne;
  bool get isDucking => pose == PenPose.ducking;

  /// Bir sonraki şeride kay. Hızlı çift swipe iki şerit atlatır.
  bool changeLane(int delta) {
    final next = game.lanes.clamp(targetLane + delta);
    if (next != targetLane) _moveTo(next);
    return true;
  }

  /// Debuff: dışarıdan bir şeride çekilme.
  void forceLane(int newLane) => _moveTo(game.lanes.clamp(newLane));

  void _moveTo(int newLane) {
    _fromX = x;
    targetLane = newLane;
    _laneT = 0;
  }

  /// Havadaysa false döner (input buffer inişte tekrar dener).
  bool tryJump() {
    if (isAirborne) return false;
    pose = PenPose.airborne;
    _poseT = 0;
    return true;
  }

  /// Yerdeyse eğilir; havadaysa hızla iner ve eğilir (fast-fall).
  bool duckOrFastFall() {
    pose = PenPose.ducking;
    _poseT = 0;
    return true;
  }

  void stumble() => _stumbleLeft = game.config.stumbleSeconds;

  @override
  void update(double dt) {
    super.update(dt);
    final c = game.config;
    y = game.penY;

    if (_laneT < 1) {
      _laneT = min(1, _laneT + dt / c.laneChangeSeconds);
      final t = 1 - pow(1 - _laneT, 3).toDouble();
      x = lerpDouble(_fromX, game.lanes.laneX(targetLane), t)!;
      if (_laneT >= 1) lane = targetLane;
    } else {
      x = game.lanes.laneX(targetLane);
    }

    if (pose != PenPose.running) {
      _poseT += dt;
      final limit = pose == PenPose.airborne ? c.jumpSeconds : c.duckSeconds;
      if (_poseT >= limit) {
        pose = PenPose.running;
        _poseT = 0;
      }
    }
    if (_stumbleLeft > 0) _stumbleLeft -= dt;
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is LaneObject) game.handleContact(other);
  }

  @override
  void render(Canvas canvas) {
    final c = game.config;
    final effects = game.effects;
    final cx = size.x / 2;

    var scale = 1.0;
    var angle = _tilt;
    var shadowOffset = 3.0;
    if (pose == PenPose.airborne) {
      final t = (_poseT / c.jumpSeconds).clamp(0.0, 1.0);
      final lift = sin(pi * t);
      scale = 1 + (c.jumpScale - 1) * lift;
      shadowOffset = 3 + 14 * lift;
    } else if (pose == PenPose.ducking) {
      angle = _duckAngle;
    }
    final wobbleX = _stumbleLeft > 0 ? sin(_stumbleLeft * 60) * 3 : 0.0;

    canvas.save();
    canvas.translate(cx + wobbleX, 0);

    if (effects.scoreMultiplier > 1) {
      canvas.drawCircle(const Offset(0, 24), 34, _glow);
    }
    if (effects.timeScale < 1) {
      final r = 36 + sin(game.animTime * 6) * 2;
      canvas.drawCircle(const Offset(0, 24), r, _steam);
    }

    // gölge (yükseklik hissi)
    canvas.save();
    canvas.translate(shadowOffset, shadowOffset);
    canvas.rotate(angle);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          -penArtWidth * 0.3 * scale,
          6,
          penArtWidth * 0.6 * scale,
          penArtHeight * 0.8 * scale,
        ),
        const Radius.circular(8),
      ),
      _shadow,
    );
    canvas.restore();

    canvas.rotate(angle);
    canvas.scale(scale, pose == PenPose.ducking ? scale * 0.9 : scale);
    canvas.translate(-penArtWidth / 2, 0);
    canvas.drawPicture(game.art.pen(game.boilFrame));
    canvas.restore();

    if (effects.controlsReversed) {
      final p = Path()
        ..moveTo(cx - 14, -22)
        ..lineTo(cx + 14, -22)
        ..moveTo(cx + 8, -28)
        ..lineTo(cx + 14, -22)
        ..lineTo(cx + 8, -16)
        ..moveTo(cx + 14, -10)
        ..lineTo(cx - 14, -10)
        ..moveTo(cx - 8, -16)
        ..lineTo(cx - 14, -10)
        ..lineTo(cx - 8, -4);
      canvas.drawPath(p, _reverse);
    }
  }
}
