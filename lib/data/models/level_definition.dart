import '../../domain/grading/assessment.dart';
import '../../game/config/json_read.dart';

enum SpeedCurveType {
  linear,
  easeIn,
  easeInOut;

  static SpeedCurveType parse(String s) => SpeedCurveType.values.firstWhere(
    (c) => c.name == s,
    orElse: () => throw FormatException('Bilinmeyen hız eğrisi: $s'),
  );
}

class SpeedSpec {
  const SpeedSpec({
    required this.start,
    required this.end,
    required this.curve,
  });

  factory SpeedSpec.fromJson(JsonReader r) => SpeedSpec(
    start: r.number('start'),
    end: r.number('end'),
    curve: SpeedCurveType.parse(r.string('curve', orElse: 'easeInOut')),
  );

  final double start;
  final double end;
  final SpeedCurveType curve;
}

/// Bir spawn deseni. [rows] geliş sırasındadır: ilk satır Tüki'ye ilk ulaşır.
/// Her satır şerit sayısı kadar boşlukla ayrılmış nesne kodu içerir.
class PatternDef {
  const PatternDef({
    required this.id,
    required this.rows,
    this.mirrorable = true,
  });

  factory PatternDef.fromJson(String id, JsonReader r) => PatternDef(
    id: id,
    mirrorable: r.boolean('mirror', orElse: true),
    rows: [
      for (final row in r.list('rows'))
        if (row is String)
          row.trim().split(RegExp(r'\s+'))
        else
          throw FormatException('${r.path}.rows: metin satırları bekleniyordu'),
    ],
  );

  final String id;
  final List<List<String>> rows;
  final bool mirrorable;
}

class PoolEntry {
  const PoolEntry({
    required this.pattern,
    required this.weight,
    this.fromProgress = 0,
    this.toProgress = 1,
  });

  factory PoolEntry.fromJson(JsonReader r) => PoolEntry(
    pattern: r.string('pattern'),
    weight: r.number('weight'),
    fromProgress: r.number('from', orElse: 0),
    toProgress: r.number('to', orElse: 1),
  );

  final String pattern;
  final double weight;
  final double fromProgress;
  final double toProgress;
}

class ScriptEntry {
  const ScriptEntry({required this.atProgress, required this.pattern});

  factory ScriptEntry.fromJson(JsonReader r) =>
      ScriptEntry(atProgress: r.number('at'), pattern: r.string('pattern'));

  final double atProgress;
  final String pattern;
}

/// Tek bir level (sınav) tanımı.
class LevelDefinition {
  const LevelDefinition({
    required this.id,
    required this.assessment,
    required this.durationSeconds,
    required this.speed,
    required this.seed,
    required this.gapRowsMin,
    required this.gapRowsMax,
    required this.pool,
    this.script = const [],
  });

  factory LevelDefinition.fromJson(Map<String, dynamic> json, String path) {
    final r = JsonReader(json, path);
    final gap = r.object('gapRows');
    return LevelDefinition(
      id: r.string('id'),
      assessment: AssessmentType.fromKey(r.string('assessment')),
      durationSeconds: r.number('durationSeconds'),
      speed: SpeedSpec.fromJson(r.object('speed')),
      seed: r.integer('seed'),
      gapRowsMin: gap.integer('min'),
      gapRowsMax: gap.integer('max'),
      pool: r.objects('pool').map(PoolEntry.fromJson).toList(),
      script:
          r.objects('script', optional: true).map(ScriptEntry.fromJson).toList()
            ..sort((a, b) => a.atProgress.compareTo(b.atProgress)),
    );
  }

  final String id;
  final AssessmentType assessment;
  final double durationSeconds;
  final SpeedSpec speed;
  final int seed;
  final int gapRowsMin;
  final int gapRowsMax;
  final List<PoolEntry> pool;
  final List<ScriptEntry> script;
}

/// Bir ders: kimlik, kredi, kağıt teması ve 5 level'ı.
class CourseDefinition {
  const CourseDefinition({
    required this.id,
    required this.code,
    required this.title,
    required this.nickname,
    required this.credits,
    required this.paper,
    required this.levels,
    required this.patterns,
  });

  final String id;
  final String code;
  final String title;
  final String nickname;
  final int credits;
  final String paper;
  final Map<AssessmentType, LevelDefinition> levels;
  final Map<String, PatternDef> patterns;

  LevelDefinition level(AssessmentType type) => levels[type]!;
}
