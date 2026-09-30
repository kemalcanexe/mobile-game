/// Ders seçimi kuralları (grading.json → enrollment).
class EnrollmentRules {
  const EnrollmentRules({
    required this.minCourses,
    required this.maxCourses,
    required this.probationMaxCourses,
  });

  factory EnrollmentRules.fromJson(Map<String, dynamic> json) =>
      EnrollmentRules(
        minCourses: json['minCourses'] as int,
        maxCourses: json['maxCourses'] as int,
        probationMaxCourses: json['probationMaxCourses'] as int,
      );

  final int minCourses;
  final int maxCourses;

  /// Academic Probation'da bir dönemde alınabilecek en fazla ders.
  final int probationMaxCourses;

  int maxFor({required bool onProbation}) =>
      onProbation ? probationMaxCourses : maxCourses;

  /// Seçilebilecek ders sayısı azsa alt sınır ona iner.
  int minFor({required int available, required bool onProbation}) {
    final max = maxFor(onProbation: onProbation);
    final min = minCourses < available ? minCourses : available;
    return min < max ? min : max;
  }

  /// Seçimi doğrular. Boş liste = geçerli.
  List<EnrollmentIssue> validate({
    required List<String> selected,
    required List<String> available,
    required List<String> requiredRetakes,
    required bool onProbation,
  }) {
    final issues = <EnrollmentIssue>[];
    final unique = selected.toSet();
    if (unique.length != selected.length) issues.add(EnrollmentIssue.duplicate);
    if (unique.any((c) => !available.contains(c))) {
      issues.add(EnrollmentIssue.notOffered);
    }
    final max = maxFor(onProbation: onProbation);
    final min = minFor(available: available.length, onProbation: onProbation);
    if (unique.length < min) issues.add(EnrollmentIssue.tooFew);
    if (unique.length > max) issues.add(EnrollmentIssue.tooMany);
    // Tekrar alınması gereken dersler, yer olduğu sürece seçilmek zorunda.
    final mustTake = requiredRetakes.take(max);
    if (mustTake.any((c) => !unique.contains(c))) {
      issues.add(EnrollmentIssue.missingRetake);
    }
    return issues;
  }
}

enum EnrollmentIssue { duplicate, notOffered, tooFew, tooMany, missingRetake }
