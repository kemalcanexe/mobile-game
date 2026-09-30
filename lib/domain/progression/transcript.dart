import '../grading/gpa_calculator.dart';
import 'course_record.dart';
import 'retake_policy.dart';

/// Tüm ders denemelerinin değişmez listesi.
class Transcript {
  Transcript([List<CourseRecord> records = const []])
    : records = List.unmodifiable(records);

  factory Transcript.fromJson(List<dynamic> json) => Transcript(
    json.map((e) => CourseRecord.fromJson(e as Map<String, dynamic>)).toList(),
  );

  static const _gpa = GpaCalculator();

  final List<CourseRecord> records;

  /// CGPA'e giren kayıtlar (yerine yenisi geçmemiş olanlar).
  Iterable<CourseRecord> get active => records.where((r) => !r.replaced);

  CourseRecord? activeRecordFor(String courseId) {
    for (final r in active) {
      if (r.courseId == courseId) return r;
    }
    return null;
  }

  int attemptsFor(String courseId) =>
      records.where((r) => r.courseId == courseId).length;

  /// Yeni bir ders sonucunu ekler. Dersin aktif bir kaydı varsa yalnızca
  /// [policy] izin veriyorsa (retake) eklenir ve eski kayıt "R" olur.
  Transcript addResult(CourseRecord record, RetakePolicy policy) {
    final existing = activeRecordFor(record.courseId);
    if (existing == null) return Transcript([...records, record]);
    if (!policy.canRetake(existing)) {
      throw StateError(
        '${record.courseCode} zaten ${existing.letter} ile geçildi; tekrar alınamaz.',
      );
    }
    return Transcript([
      for (final r in records) identical(r, existing) ? r.markReplaced() : r,
      record,
    ]);
  }

  /// Dönem GPA'i tarihseldir: o dönem alınan bütün dersleri (sonradan yerine
  /// yenisi geçenler dahil) içerir.
  double? semesterGpa(int semester) =>
      _gpa.gpa(records.where((r) => r.semester == semester));

  /// Kümülatif GPA: yalnızca aktif kayıtlar.
  double? get cgpa => _gpa.gpa(active);

  bool get hasUnresolvedFailure => active.any((r) => r.gradePoints == 0);

  List<Map<String, dynamic>> toJson() => [for (final r in records) r.toJson()];
}
