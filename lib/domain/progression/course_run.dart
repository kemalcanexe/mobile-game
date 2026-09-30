import '../grading/assessment.dart';

/// Devam eden bir ders denemesi: hangi sınavlar bitti, skorları ne.
class CourseRun {
  CourseRun({
    required this.courseId,
    this.attempt = 1,
    Map<AssessmentType, double> scores = const {},
  }) : scores = Map.unmodifiable(scores);

  factory CourseRun.fromJson(Map<String, dynamic> json) => CourseRun(
    courseId: json['courseId'] as String,
    attempt: json['attempt'] as int? ?? 1,
    scores: {
      for (final e in (json['scores'] as Map<String, dynamic>).entries)
        AssessmentType.fromKey(e.key): (e.value as num).toDouble(),
    },
  );

  final String courseId;
  final int attempt;
  final Map<AssessmentType, double> scores;

  /// Sıradaki sınav; hepsi bittiyse `null`.
  AssessmentType? get nextAssessment {
    for (final t in AssessmentType.values) {
      if (!scores.containsKey(t)) return t;
    }
    return null;
  }

  bool get isComplete => nextAssessment == null;

  CourseRun withScore(AssessmentType type, double score) {
    if (type != nextAssessment) {
      throw StateError('Sıradaki sınav ${nextAssessment?.key}, gelen ${type.key}.');
    }
    return CourseRun(
      courseId: courseId,
      attempt: attempt,
      scores: {...scores, type: score},
    );
  }

  Map<String, dynamic> toJson() => {
    'courseId': courseId,
    'attempt': attempt,
    'scores': {for (final e in scores.entries) e.key.key: e.value},
  };
}
