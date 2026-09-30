import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../../app/palette.dart';
import '../config/item_catalog.dart';
import '../tukenmez_game.dart';

/// Şeritte akan her şey: toplanabilir, güçlendirici, dikkat dağıtıcı, engel.
/// Havuzdan (object pool) yeniden kullanılır; konumu her karede global
/// kaydırma mesafesinden hesaplanır.
class LaneObject extends PositionComponent with HasGameReference<TukenmezGame> {
  LaneObject() : super(anchor: Anchor.center);

  late ItemDef def;
  int lane = 0;
  double eventDistance = 0;
  bool resolved = false;
  bool _hit = false;
  int _variantOffset = 0;
  void Function(LaneObject)? onRecycle;

  final RectangleHitbox hitbox = RectangleHitbox(
    collisionType: CollisionType.passive,
  );

  final Paint _cross = Paint()
    ..color = Palette.teacherRed
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3
    ..strokeCap = StrokeCap.round;

  void reset(ItemDef def, int lane, double eventDistance, int variantOffset) {
    this.def = def;
    this.lane = lane;
    this.eventDistance = eventDistance;
    _variantOffset = variantOffset;
    resolved = false;
    _hit = false;
    final c = game.config;
    final s = def.kind == ItemKind.wall ? c.wallSize : c.objectSize;
    size = Vector2.all(s);
    hitbox
      ..size = Vector2.all(s - c.objectHitboxInset * 2)
      ..position = Vector2.all(c.objectHitboxInset);
  }

  /// Engel çarpıldı: yerinde kalır, üzeri kırmızıyla çizilir.
  void markHit() => _hit = true;

  @override
  void onLoad() => add(hitbox);

  @override
  void render(Canvas canvas) {
    canvas.drawPicture(
      game.art.item(def.art, size.x, game.boilFrame + _variantOffset),
    );
    if (_hit) {
      final s = size.x;
      canvas.drawLine(
        Offset(s * 0.2, s * 0.2),
        Offset(s * 0.8, s * 0.8),
        _cross,
      );
      canvas.drawLine(
        Offset(s * 0.8, s * 0.2),
        Offset(s * 0.2, s * 0.8),
        _cross,
      );
    }
  }

  @override
  void onRemove() {
    super.onRemove();
    onRecycle?.call(this);
  }
}
