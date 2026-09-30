import 'json_read.dart';

enum ItemKind {
  collectible,
  bonus,
  powerUp,
  distraction,
  groundObstacle,
  airObstacle,
  wall;

  static ItemKind parse(String s) => ItemKind.values.firstWhere(
    (k) => k.name == s,
    orElse: () => throw FormatException('Bilinmeyen nesne türü: $s'),
  );

  bool get isObstacle =>
      this == groundObstacle || this == airObstacle || this == wall;
}

enum EffectType {
  scoreMultiplier,
  slowMotion,
  ink,
  notification,
  reverseControls,
  pullLane,
  stumble;

  static EffectType parse(String s) => EffectType.values.firstWhere(
    (k) => k.name == s,
    orElse: () => throw FormatException('Bilinmeyen efekt: $s'),
  );
}

class EffectDef {
  const EffectDef({required this.type, this.value = 0, this.duration = 0});

  factory EffectDef.fromJson(JsonReader r) => EffectDef(
    type: EffectType.parse(r.string('type')),
    value: r.number('value', orElse: 0),
    duration: r.number('duration', orElse: 0),
  );

  final EffectType type;
  final double value;
  final double duration;
}

/// items.json'daki tek bir nesne tanımı.
class ItemDef {
  const ItemDef({
    required this.code,
    required this.id,
    required this.kind,
    required this.art,
    this.points = 0,
    this.ink = 0,
    this.extraCredit = 0,
    this.effect,
  });

  factory ItemDef.fromJson(JsonReader r) => ItemDef(
    code: r.string('code'),
    id: r.string('id'),
    kind: ItemKind.parse(r.string('kind')),
    art: r.string('art'),
    points: r.number('points', orElse: 0),
    ink: r.number('ink', orElse: 0),
    extraCredit: r.number('extraCredit', orElse: 0),
    effect: r.optionalObject('effect') == null
        ? null
        : EffectDef.fromJson(r.object('effect')),
  );

  final String code;
  final String id;
  final ItemKind kind;
  final String art;
  final double points;
  final double ink;
  final double extraCredit;
  final EffectDef? effect;

  /// Level skorunun paydasına (maks_puan) giren nesneler.
  bool get countsTowardMax => kind == ItemKind.collectible && points > 0;
}

class ItemCatalog {
  ItemCatalog(Iterable<ItemDef> items) : _byCode = {} {
    for (final item in items) {
      if (_byCode.containsKey(item.code)) {
        throw FormatException('items.json: "${item.code}" kodu tekrar ediyor');
      }
      _byCode[item.code] = item;
    }
  }

  factory ItemCatalog.fromJson(Map<String, dynamic> json) => ItemCatalog(
    JsonReader(json, 'items.json').objects('items').map(ItemDef.fromJson),
  );

  /// Desenlerde boş hücre.
  static const String emptyCode = '..';

  final Map<String, ItemDef> _byCode;

  Iterable<ItemDef> get all => _byCode.values;

  bool contains(String code) => _byCode.containsKey(code);

  ItemDef operator [](String code) =>
      _byCode[code] ?? (throw FormatException('Bilinmeyen nesne kodu: $code'));
}
