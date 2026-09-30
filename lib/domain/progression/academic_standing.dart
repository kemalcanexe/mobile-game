import '../grading/grading_rules.dart';
import 'transcript.dart';

/// Dean's List, Probation ve onur derecelerini değerlendirir.
class AcademicStanding {
  const AcademicStanding(this.rules);

  final StandingRules rules;

  bool isDeansList(double? semesterGpa) =>
      semesterGpa != null && semesterGpa >= rules.deansListMinSemesterGpa;

  bool isOnProbation(double? cgpa) =>
      cgpa != null && cgpa < rules.probationBelowCgpa;

  /// Mezuniyet koşulu: gerekli dönemler bitti, düzeltilmemiş F yok ve
  /// CGPA probation eşiğinin üstünde.
  bool canGraduate(
    Transcript transcript, {
    required int completedSemesters,
    required int requiredSemesters,
  }) {
    final cgpa = transcript.cgpa;
    return completedSemesters >= requiredSemesters &&
        !transcript.hasUnresolvedFailure &&
        cgpa != null &&
        !isOnProbation(cgpa);
  }

  /// En yüksek uygun onur derecesi; yoksa `null`.
  HonorRule? honorFor(double? cgpa) {
    if (cgpa == null) return null;
    for (final h in rules.honors) {
      if (cgpa >= h.minCgpa) return h;
    }
    return null;
  }
}
