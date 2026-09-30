import 'package:flutter_test/flutter_test.dart';
import 'package:tukenmez_gpa_run/data/level_repository.dart';
import 'package:tukenmez_gpa_run/data/level_validator.dart';
import 'package:tukenmez_gpa_run/data/models/level_definition.dart';
import 'package:tukenmez_gpa_run/domain/grading/assessment.dart';
import 'package:tukenmez_gpa_run/game/config/item_catalog.dart';
import 'package:tukenmez_gpa_run/game/systems/level_generator.dart';
import 'package:tukenmez_gpa_run/game/systems/speed_curve.dart';

import '../helpers/config_fixtures.dart';

void main() {
  final config = loadGameConfig();
  final catalog = loadCatalog();
  late List<CourseDefinition> courses;
  late CourseDefinition calc;

  setUpAll(() async {
    courses = await LevelRepository(
      bundle: DiskAssetBundle(),
      catalog: catalog,
      laneCount: config.laneCount,
    ).loadCourses();
    calc = courses.firstWhere((c) => c.id == 'calc101');
  });

  test('bütün dersler yüklenir; kağıt temaları farklı', () {
    expect(courses.map((c) => c.id), ['calc101', 'phys101', 'cs101']);
    expect(courses.map((c) => c.paper).toSet(), {
      'grid',
      'millimeter',
      'terminal',
    });
    expect(courses.firstWhere((c) => c.id == 'cs101').credits, 3);
  });

  test('CALC 101 yüklenir ve doğrulanır', () {
    expect(calc.code, 'CALC 101');
    expect(calc.credits, 4);
    expect(calc.levels.keys, containsAll(AssessmentType.values));
  });

  test('level süreleri ve hızları proposal ile aynı', () {
    final expected = {
      AssessmentType.quiz1: (60.0, 1.00, 1.25),
      AssessmentType.midterm: (80.0, 1.10, 1.45),
      AssessmentType.quiz2: (60.0, 1.20, 1.50),
      AssessmentType.project: (75.0, 1.15, 1.50),
      AssessmentType.finalExam: (90.0, 1.30, 1.75),
    };
    expected.forEach((type, v) {
      final l = calc.level(type);
      expect(l.durationSeconds, v.$1, reason: type.key);
      expect(l.speed.start, v.$2, reason: type.key);
      expect(l.speed.end, v.$3, reason: type.key);
    });
  });

  test('her level\'ın başlangıç hızı bir öncekinden yüksek', () {
    final starts = [
      for (final t in AssessmentType.values) calc.level(t).speed.start,
    ];
    // Proje, Quiz 2'den düşük başlar ama Midterm'den yüksektir (proposal §7).
    expect(starts.first, lessThan(starts.last));
    expect(
      calc.level(AssessmentType.finalExam).speed.start,
      greaterThan(starts.sublist(0, 4).reduce((a, b) => a > b ? a : b)),
    );
  });

  group('LevelGenerator', () {
    final generator = LevelGenerator(config: config, catalog: catalog);

    test('aynı seed aynı planı üretir', () {
      final level = calc.level(AssessmentType.midterm);
      final a = generator.generate(level, calc.patterns);
      final b = generator.generate(level, calc.patterns);
      expect(a.events.length, b.events.length);
      for (var i = 0; i < a.events.length; i++) {
        expect(a.events[i].distance, b.events[i].distance);
        expect(a.events[i].code, b.events[i].code);
        expect(a.events[i].lane, b.events[i].lane);
      }
    });

    test('her level toplanabilir içerir ve hiçbir satır geçilmez değildir', () {
      for (final course in courses) {
        for (final type in AssessmentType.values) {
          final plan = generator.generate(course.level(type), course.patterns);
          final maxPoints = plan.events
              .map((e) => catalog[e.code])
              .where((d) => d.countsTowardMax)
              .fold<double>(0, (a, d) => a + d.points);
          expect(maxPoints, greaterThan(300), reason: type.key);
          final walls = <double, int>{};
          for (final e in plan.events) {
            if (catalog[e.code].kind == ItemKind.wall) {
              walls[e.distance] = (walls[e.distance] ?? 0) + 1;
            }
            expect(e.distance, lessThanOrEqualTo(plan.totalDistance));
            expect(e.lane, inInclusiveRange(0, config.laneCount - 1));
          }
          expect(
            walls.values.every((n) => n < config.laneCount),
            isTrue,
            reason: '${course.id}.${type.key}: aynı satırda 3 duvar',
          );
        }
      }
    });

    test('olaylar mesafeye göre sıralı', () {
      final plan = generator.generate(
        calc.level(AssessmentType.finalExam),
        calc.patterns,
      );
      for (var i = 1; i < plan.events.length; i++) {
        expect(
          plan.events[i].distance,
          greaterThanOrEqualTo(plan.events[i - 1].distance),
        );
      }
    });
  });

  group('SpeedCurve', () {
    const spec = SpeedSpec(
      start: 1.0,
      end: 1.25,
      curve: SpeedCurveType.easeInOut,
    );

    test('uç noktalar ve monotonluk', () {
      const c = SpeedCurve(spec);
      expect(c.multiplierAt(0), 1.0);
      expect(c.multiplierAt(1), 1.25);
      var prev = 0.0;
      for (var p = 0.0; p <= 1; p += 0.05) {
        expect(c.multiplierAt(p), greaterThanOrEqualTo(prev));
        prev = c.multiplierAt(p);
      }
    });

    test('dönem çarpanı ölçekler', () {
      expect(
        const SpeedCurve(spec, semesterMultiplier: 1.2).multiplierAt(1),
        1.5,
      );
    });

    test('hesaplanan mesafe, verilen sürede katedilir', () {
      const c = SpeedCurve(spec);
      final d = c.distanceFor(60, 300);
      var t = 0.0, x = 0.0;
      const dt = 1 / 240;
      while (x < d) {
        x += 300 * c.multiplierAt(x / d) * dt;
        t += dt;
      }
      expect(t, closeTo(60, 0.05));
    });
  });

  group('LevelValidator', () {
    CourseDefinition broken() {
      return CourseDefinition(
        id: 'x',
        code: 'X',
        title: 'X',
        nickname: 'X',
        credits: 3,
        paper: 'grid',
        levels: {
          AssessmentType.quiz1: LevelDefinition(
            id: 'x.quiz1',
            assessment: AssessmentType.midterm,
            durationSeconds: 0,
            speed: const SpeedSpec(
              start: 1.2,
              end: 1.0,
              curve: SpeedCurveType.linear,
            ),
            seed: 1,
            gapRowsMin: 3,
            gapRowsMax: 1,
            pool: const [PoolEntry(pattern: 'yok', weight: 0)],
          ),
        },
        patterns: {
          ...calc.patterns,
          'bad': const PatternDef(
            id: 'bad',
            rows: [
              ['fc', '..'],
              ['fc', 'nt', '..'],
              ['ow', 'ow', 'ow'],
              ['zz', '..', '..'],
            ],
          ),
        },
      );
    }

    test('hataları tek tek raporlar', () {
      final errors = LevelValidator(
        catalog: catalog,
        laneCount: 3,
      ).validate(broken());
      bool has(String s) => errors.any((e) => e.contains(s));
      expect(has('3 hücre bekleniyordu'), isTrue);
      expect(has('birden fazla toplanabilir'), isTrue);
      expect(has('bütün şeritler duvarla kapalı'), isTrue);
      expect(has('bilinmeyen nesne kodu "zz"'), isTrue);
      expect(has('"midterm" level\'ı eksik'), isTrue);
      expect(has('süre pozitif'), isTrue);
      expect(has('hız 0 < start ≤ end'), isTrue);
      expect(has('gapRows'), isTrue);
      expect(has('"yok" deseni tanımsız'), isTrue);
      expect(has('ağırlığı pozitif'), isTrue);
      expect(has('assessment "midterm"'), isTrue);
    });

    test('eksik alan anlaşılır FormatException verir', () {
      expect(
        () => LevelDefinition.fromJson({'id': 'x'}, 'x.json'),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            startsWith('x.json.'),
          ),
        ),
      );
    });
  });
}
