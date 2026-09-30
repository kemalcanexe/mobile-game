import 'package:flutter_test/flutter_test.dart';
import 'package:tukenmez_gpa_run/domain/grading/assessment.dart';
import 'package:tukenmez_gpa_run/domain/progression/course_run.dart';
import 'package:tukenmez_gpa_run/domain/scoring/ink_state.dart';
import 'package:tukenmez_gpa_run/domain/scoring/level_score.dart';

import '../helpers/config_fixtures.dart';

void main() {
  final rules = loadGradingRules().levelScore;

  LevelScoreResult score({
    double max = 200,
    double collected = 0,
    double penalty = 0,
    double bonus = 0,
    double ink = 40,
    bool depleted = false,
  }) => LevelScoreResult.compute(
    rules: rules,
    maxPoints: max,
    collectedPoints: collected,
    penaltyPoints: penalty,
    bonusExtraCredit: bonus,
    inkRemaining: ink,
    inkDepleted: depleted,
  );

  group('Level skoru', () {
    test('ham / maks × 100', () {
      final r = score(collected: 170, penalty: 20);
      expect(r.rawPoints, 150);
      expect(r.baseScore, 75);
      expect(r.score, 75);
    });

    test('negatif ham puan 0\'a clamp edilir', () {
      expect(score(collected: 10, penalty: 50).score, 0);
    });

    test('Fosforlu ile 100\'ü aşan ham puan 100\'e clamp edilir', () {
      final r = score(collected: 300);
      expect(r.baseScore, 100);
      expect(r.score, 100);
    });

    test('Bonus Soru +3 adet başına, toplam tavan 100', () {
      expect(score(collected: 180, bonus: 6).score, 96);
      expect(score(collected: 198, bonus: 6).score, 100);
    });

    test('Temiz Kağıt: ≥ %50 mürekkeple bitirme +2', () {
      expect(score(collected: 100, ink: 50).cleanPaperCredit, 2);
      expect(score(collected: 100, ink: 50).score, 52);
      expect(score(collected: 100, ink: 49.9).cleanPaperCredit, 0);
    });

    test('ekstra krediler birlikte de 100\'ü aşamaz', () {
      expect(score(collected: 196, bonus: 3, ink: 100).score, 100);
    });

    test('mürekkep bitince skor en fazla 50 (F)', () {
      final r = score(collected: 180, bonus: 3, ink: 0, depleted: true);
      expect(r.score, 50);
      expect(r.inkOutCapped, isTrue);
      expect(r.cleanPaperCredit, 0);
    });

    test('mürekkep bitti ama skor zaten 50 altı ise değişmez', () {
      final r = score(collected: 60, ink: 0, depleted: true);
      expect(r.score, 30);
      expect(r.inkOutCapped, isFalse);
    });

    test('hiç (+) nesne spawn olmadıysa taban skor 0', () {
      expect(score(max: 0, collected: 0).baseScore, 0);
    });
  });

  group('LevelScoreTracker', () {
    test('çarpan yalnızca toplananlara uygulanır', () {
      final t = LevelScoreTracker()
        ..registerSpawn(10)
        ..registerSpawn(10)
        ..collect(10, multiplier: 2)
        ..penalize(-5);
      expect(t.maxPoints, 20);
      expect(t.collectedPoints, 20);
      expect(t.penaltyPoints, 5);
      expect(t.rawPoints, 15);
      expect(t.collectedCount, 1);
      expect(t.hitCount, 1);
      final r = t.finish(rules: rules, inkRemaining: 90, inkDepleted: false);
      expect(r.score, 77);
    });

    test('ekstra kredi sayılır', () {
      final t = LevelScoreTracker()..addExtraCredit(3)..addExtraCredit(3);
      expect(t.extraCredit, 6);
      expect(t.bonusCount, 2);
    });
  });

  group('InkState', () {
    test('0 ile max arasında kalır', () {
      final ink = InkState(max: 100, lowThreshold: 25);
      expect(ink.current, 100);
      ink.apply(25);
      expect(ink.current, 100);
      ink.apply(-80);
      expect(ink.current, 20);
      expect(ink.isLow, isTrue);
      expect(ink.fraction, closeTo(0.2, 1e-12));
      ink.apply(-50);
      expect(ink.current, 0);
      expect(ink.isEmpty, isTrue);
    });
  });

  group('CourseRun', () {
    test('sınavlar izlence sırasıyla ilerler', () {
      var run = CourseRun(courseId: 'calc101');
      expect(run.nextAssessment, AssessmentType.quiz1);
      run = run.withScore(AssessmentType.quiz1, 90);
      expect(run.nextAssessment, AssessmentType.midterm);
      expect(() => run.withScore(AssessmentType.finalExam, 90), throwsStateError);
      for (final t in AssessmentType.values.skip(1)) {
        run = run.withScore(t, 80);
      }
      expect(run.isComplete, isTrue);
      expect(run.nextAssessment, isNull);
    });

    test('JSON gidiş-dönüş', () {
      final run = CourseRun(courseId: 'calc101', attempt: 2)
          .withScore(AssessmentType.quiz1, 88.5);
      final back = CourseRun.fromJson(run.toJson());
      expect(back.attempt, 2);
      expect(back.scores[AssessmentType.quiz1], 88.5);
    });
  });
}
