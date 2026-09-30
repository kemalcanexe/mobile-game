import '../grading/gpa_calculator.dart';

/// Transkriptte tek bir ders denemesi.
class CourseRecord implements GpaEntry {
  const CourseRecord({
    required this.courseId,
    required this.courseCode,
    required this.credits,
    required this.semester,
    required this.score,
    required this.letter,
    required this.gradePoints,
    this.attempt = 1,
    this.replaced = false,
    this.assessmentScores = const {},
  });

  factory CourseRecord.fromJson(Map<String, dynamic> json) => CourseRecord(
    courseId: json['courseId'] as String,
    courseCode: json['courseCode'] as String,
    credits: json['credits'] as int,
    semester: json['semester'] as int,
    score: (json['score'] as num).toDouble(),
    letter: json['letter'] as String,
    gradePoints: (json['gradePoints'] as num).toDouble(),
    attempt: json['attempt'] as int? ?? 1,
    replaced: json['replaced'] as bool? ?? false,
    assessmentScores: {
      for (final e
          in (json['assessmentScores'] as Map<String, dynamic>? ?? const {})
              .entries)
        e.key: (e.value as num).toDouble(),
    },
  );

  final String courseId;
  final String courseCode;
  @override
  final int credits;
  final int semester;
  final double score;
  final String letter;
  @override
  final double gradePoints;

  /// 1 = ilk alış, 2+ = retake.
  final int attempt;

  /// Retake ile yerine yenisi geçtiyse `true`. Transkriptte "R" ile gösterilir,
  /// CGPA'e girmez.
  final bool replaced;

  /// Sınav türü anahtarına göre level skorları (izlence dökümü için).
  final Map<String, double> assessmentScores;

  bool get isRetake => attempt > 1;

  CourseRecord markReplaced() => CourseRecord(
    courseId: courseId,
    courseCode: courseCode,
    credits: credits,
    semester: semester,
    score: score,
    letter: letter,
    gradePoints: gradePoints,
    attempt: attempt,
    replaced: true,
    assessmentScores: assessmentScores,
  );

  Map<String, dynamic> toJson() => {
    'courseId': courseId,
    'courseCode': courseCode,
    'credits': credits,
    'semester': semester,
    'score': score,
    'letter': letter,
    'gradePoints': gradePoints,
    'attempt': attempt,
    'replaced': replaced,
    'assessmentScores': assessmentScores,
  };
}
