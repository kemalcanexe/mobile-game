import 'assessment.dart';
import 'grading_rules.dart';
import 'letter_grade.dart';

/// Level skorlarından ağırlıklı ders skoru ve harf notu üretir.
class GradeCalculator {
  const GradeCalculator(this.rules);

  final GradingRules rules;

  /// ders_skoru = Σ(level_skoru × ağırlık). Tüm değerlendirmeler gerekli.
  double courseScore(Map<AssessmentType, double> levelScores) {
    var total = 0.0;
    for (final type in AssessmentType.values) {
      final score = levelScores[type];
      if (score == null) {
        throw ArgumentError('Eksik değerlendirme skoru: ${type.key}');
      }
      total += score * rules.weights[type]!;
    }
    return total;
  }

  /// Tek bir değerlendirmenin ders skoruna katkısı.
  double contribution(AssessmentType type, double levelScore) =>
      levelScore * rules.weights[type]!;

  LetterGrade letterFor(double score) => rules.scale.gradeFor(score);
}
