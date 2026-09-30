import 'assessment.dart';
import 'letter_grade.dart';

/// Level skoru hesabındaki sabitler (grading.json → levelScore).
class LevelScoreRules {
  const LevelScoreRules({
    required this.max,
    required this.cleanPaperCredit,
    required this.cleanPaperMinInk,
    required this.inkOutCap,
  });

  factory LevelScoreRules.fromJson(Map<String, dynamic> json) =>
      LevelScoreRules(
        max: (json['max'] as num).toDouble(),
        cleanPaperCredit: (json['cleanPaperCredit'] as num).toDouble(),
        cleanPaperMinInk: (json['cleanPaperMinInk'] as num).toDouble(),
        inkOutCap: (json['inkOutCap'] as num).toDouble(),
      );

  final double max;
  final double cleanPaperCredit;
  final double cleanPaperMinInk;
  final double inkOutCap;
}

class HonorRule {
  const HonorRule(this.id, this.minCgpa);
  final String id;
  final double minCgpa;
}

/// Akademik durum eşikleri (grading.json → standing).
class StandingRules {
  StandingRules({
    required this.deansListMinSemesterGpa,
    required this.probationBelowCgpa,
    required List<HonorRule> honors,
  }) : honors = List.unmodifiable(
         [...honors]..sort((a, b) => b.minCgpa.compareTo(a.minCgpa)),
       );

  factory StandingRules.fromJson(Map<String, dynamic> json) => StandingRules(
    deansListMinSemesterGpa: (json['deansListMinSemesterGpa'] as num)
        .toDouble(),
    probationBelowCgpa: (json['probationBelowCgpa'] as num).toDouble(),
    honors: (json['honors'] as List)
        .cast<Map<String, dynamic>>()
        .map(
          (h) => HonorRule(h['id'] as String, (h['minCgpa'] as num).toDouble()),
        )
        .toList(),
  );

  final double deansListMinSemesterGpa;
  final double probationBelowCgpa;

  /// Yüksekten düşüğe sıralı.
  final List<HonorRule> honors;
}

/// grading.json'un tamamı.
class GradingRules {
  GradingRules({
    required Map<AssessmentType, double> weights,
    required this.scale,
    required this.levelScore,
    required this.standing,
    required Set<String> retakeableLetters,
  }) : weights = Map.unmodifiable(weights),
       retakeableLetters = Set.unmodifiable(retakeableLetters) {
    final missing = AssessmentType.values.where((t) => !weights.containsKey(t));
    if (missing.isNotEmpty) {
      throw FormatException('Ağırlığı eksik değerlendirmeler: $missing');
    }
    final sum = weights.values.fold<double>(0, (a, b) => a + b);
    if ((sum - 1).abs() > 1e-6) {
      throw FormatException(
        'Değerlendirme ağırlıklarının toplamı 1 olmalı: $sum',
      );
    }
  }

  factory GradingRules.fromJson(Map<String, dynamic> json) => GradingRules(
    weights: {
      for (final a
          in (json['assessments'] as List).cast<Map<String, dynamic>>())
        AssessmentType.fromKey(a['type'] as String): (a['weight'] as num)
            .toDouble(),
    },
    scale: GradeScale.fromJson(json['scale'] as List),
    levelScore: LevelScoreRules.fromJson(
      json['levelScore'] as Map<String, dynamic>,
    ),
    standing: StandingRules.fromJson(json['standing'] as Map<String, dynamic>),
    retakeableLetters: {
      ...((json['retake'] as Map<String, dynamic>)['retakeableLetters'] as List)
          .cast<String>(),
    },
  );

  final Map<AssessmentType, double> weights;
  final GradeScale scale;
  final LevelScoreRules levelScore;
  final StandingRules standing;
  final Set<String> retakeableLetters;
}
