import '../config/item_catalog.dart';

enum PenPose { running, airborne, ducking }

enum ContactOutcome { collect, hit, ignore }

/// Çarpışma kuralları (DEV_PROMPT §Çarpışma kuralları):
/// - Yer engeli: kalem havadaysa çarpışmaz.
/// - Hava engeli: kalem eğikse çarpışmaz.
/// - Duvar: her durumda çarpışır.
/// - Toplanabilirler: zıplarken ve eğilirken de toplanır.
/// - Dikkat dağıtıcılar: toplanabilirler gibi her pozda temas eder.
class CollisionRules {
  const CollisionRules._();

  static ContactOutcome resolve(ItemKind kind, PenPose pose) => switch (kind) {
    ItemKind.collectible ||
    ItemKind.bonus ||
    ItemKind.powerUp => ContactOutcome.collect,
    ItemKind.distraction || ItemKind.wall => ContactOutcome.hit,
    ItemKind.groundObstacle =>
      pose == PenPose.airborne ? ContactOutcome.ignore : ContactOutcome.hit,
    ItemKind.airObstacle =>
      pose == PenPose.ducking ? ContactOutcome.ignore : ContactOutcome.hit,
  };
}
