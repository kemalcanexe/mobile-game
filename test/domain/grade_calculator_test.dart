import 'package:flutter_test/flutter_test.dart';
import 'package:tukenmez_gpa_run/domain/grading/assessment.dart';
import 'package:tukenmez_gpa_run/domain/grading/grade_calculator.dart';
import 'package:tukenmez_gpa_run/domain/grading/grading_rules.dart';

import '../helpers/config_fixtures.dart';

void main() {
  final rules = loadGradingRules();
  final calc = GradeCalculator(rules);

  Map<AssessmentType, double> scores(
    double q1,
    double mid,
    double q2,
    double proj,
    double fin,
  ) => {
    AssessmentType.quiz1: q1,
    AssessmentType.midterm: mid,
    AssessmentType.quiz2: q2,
    AssessmentType.project: proj,
    AssessmentType.finalExam: fin,
  };

  test('ağırlıklar izlencedeki gibi 10/30/10/20/30', () {
    expect(rules.weights[AssessmentType.quiz1], 0.10);
    expect(rules.weights[AssessmentType.midterm], 0.30);
    expect(rules.weights[AssessmentType.quiz2], 0.10);
    expect(rules.weights[AssessmentType.project], 0.20);
    expect(rules.weights[AssessmentType.finalExam], 0.30);
  });

  test('ağırlıklı ders skoru', () {
    // 100×.1 + 80×.3 + 90×.1 + 70×.2 + 60×.3 = 10+24+9+14+18 = 75
    expect(calc.courseScore(scores(100, 80, 90, 70, 60)), closeTo(75, 1e-9));
    expect(calc.letterFor(75).symbol, 'C');
  });

  test('her level 97 ise ders A+', () {
    final s = calc.courseScore(scores(97, 97, 97, 97, 97));
    expect(calc.letterFor(s).symbol, 'A+');
  });

  test('Final ve Midterm ağırlığı Quiz\'lerden büyük', () {
    final badFinal = calc.courseScore(scores(100, 100, 100, 100, 0));
    final badQuiz = calc.courseScore(scores(0, 100, 100, 100, 100));
    expect(badFinal, closeTo(70, 1e-9));
    expect(badQuiz, closeTo(90, 1e-9));
  });

  test('katkı = skor × ağırlık', () {
    expect(calc.contribution(AssessmentType.finalExam, 80), closeTo(24, 1e-9));
  });

  test('eksik değerlendirme hata verir', () {
    expect(
      () => calc.courseScore({AssessmentType.quiz1: 100}),
      throwsArgumentError,
    );
  });

  test('ağırlık toplamı 1 değilse config reddedilir', () {
    final json = readJsonAsset('assets/config/grading.json');
    (json['assessments'] as List).first['weight'] = 0.5;
    expect(() => GradingRules.fromJson(json), throwsFormatException);
  });

  test('eksik değerlendirme ağırlığı config\'de reddedilir', () {
    final json = readJsonAsset('assets/config/grading.json');
    (json['assessments'] as List).removeLast();
    expect(() => GradingRules.fromJson(json), throwsFormatException);
  });

  test('AssessmentType anahtarları', () {
    expect(AssessmentType.fromKey('final'), AssessmentType.finalExam);
    expect(() => AssessmentType.fromKey('lab'), throwsFormatException);
  });
}
