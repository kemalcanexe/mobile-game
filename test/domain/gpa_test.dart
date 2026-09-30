import 'package:flutter_test/flutter_test.dart';
import 'package:tukenmez_gpa_run/domain/grading/gpa_calculator.dart';
import 'package:tukenmez_gpa_run/domain/progression/academic_standing.dart';
import 'package:tukenmez_gpa_run/domain/progression/course_record.dart';
import 'package:tukenmez_gpa_run/domain/progression/retake_policy.dart';
import 'package:tukenmez_gpa_run/domain/progression/transcript.dart';

import '../helpers/config_fixtures.dart';

CourseRecord rec(
  String id,
  String letter,
  double points, {
  int credits = 3,
  int semester = 1,
  int attempt = 1,
}) => CourseRecord(
  courseId: id,
  courseCode: id.toUpperCase(),
  credits: credits,
  semester: semester,
  score: 0,
  letter: letter,
  gradePoints: points,
  attempt: attempt,
);

void main() {
  final rules = loadGradingRules();
  final policy = RetakePolicy(rules.retakeableLetters);
  final standing = AcademicStanding(rules.standing);
  const gpa = GpaCalculator();

  group('GPA', () {
    test('kredi ağırlıklı', () {
      // (4.0×4 + 3.0×3) / 7 = 25/7
      final t = Transcript([
        rec('calc101', 'A', 4.0, credits: 4),
        rec('phys101', 'B', 3.0, credits: 3),
      ]);
      expect(t.cgpa, closeTo(25 / 7, 1e-12));
      expect(GpaCalculator.format(t.cgpa), '3.57');
    });

    test('hesapta yuvarlama yok, gösterimde 2 basamak', () {
      final v = gpa.gpa([rec('a', 'A-', 3.7), rec('b', 'B+', 3.3), rec('c', 'B', 3.0)]);
      expect(v, closeTo(10 / 3, 1e-12));
      expect(GpaCalculator.format(v), '3.33');
    });

    test('ders yoksa GPA tanımsız', () {
      expect(Transcript().cgpa, isNull);
      expect(GpaCalculator.format(null), '—');
    });

    test('dönem GPA\'i yalnızca o dönemin dersleri', () {
      final t = Transcript([
        rec('a', 'A', 4.0, semester: 1),
        rec('b', 'C', 2.0, semester: 2),
      ]);
      expect(t.semesterGpa(1), 4.0);
      expect(t.semesterGpa(2), 2.0);
      expect(t.cgpa, 3.0);
      expect(t.semesterGpa(3), isNull);
    });
  });

  group('Retake', () {
    test('F yerine yeni not geçer, CGPA\'e yalnızca yeni not girer', () {
      var t = Transcript([
        rec('calc101', 'F', 0, credits: 4),
        rec('phys101', 'B', 3.0, credits: 3),
      ]);
      expect(t.cgpa, closeTo(9 / 7, 1e-12));
      expect(t.hasUnresolvedFailure, isTrue);

      t = t.addResult(
        rec('calc101', 'B+', 3.3, credits: 4, semester: 2, attempt: 2),
        policy,
      );
      expect(t.records, hasLength(3));
      expect(t.records.first.replaced, isTrue, reason: 'eski kayıt R ile saklanır');
      expect(t.activeRecordFor('calc101')!.letter, 'B+');
      expect(t.cgpa, closeTo((3.3 * 4 + 3.0 * 3) / 7, 1e-12));
      expect(t.hasUnresolvedFailure, isFalse);
      expect(t.attemptsFor('calc101'), 2);
    });

    test('ilk dönemin GPA\'i tarihsel olarak değişmez', () {
      var t = Transcript([rec('calc101', 'F', 0, semester: 1)]);
      t = t.addResult(rec('calc101', 'A', 4.0, semester: 2, attempt: 2), policy);
      expect(t.semesterGpa(1), 0.0);
      expect(t.semesterGpa(2), 4.0);
      expect(t.cgpa, 4.0);
    });

    test('geçilen ders tekrar alınamaz', () {
      final t = Transcript([rec('calc101', 'D-', 0.7)]);
      expect(() => t.addResult(rec('calc101', 'A', 4.0), policy), throwsStateError);
    });

    test('ikinci F de tekrar alınabilir', () {
      var t = Transcript([rec('calc101', 'F', 0)]);
      t = t.addResult(rec('calc101', 'F', 0, attempt: 2), policy);
      t = t.addResult(rec('calc101', 'C', 2.0, attempt: 3), policy);
      expect(t.records.where((r) => r.replaced), hasLength(2));
      expect(t.cgpa, 2.0);
    });

    test('yeni ders doğrudan eklenir', () {
      final t = Transcript().addResult(rec('calc101', 'A', 4.0), policy);
      expect(t.records.single.replaced, isFalse);
    });

    test('JSON gidiş-dönüş', () {
      var t = Transcript([rec('calc101', 'F', 0)]);
      t = t.addResult(rec('calc101', 'A', 4.0, attempt: 2), policy);
      final back = Transcript.fromJson(t.toJson());
      expect(back.records.first.replaced, isTrue);
      expect(back.records.last.isRetake, isTrue);
      expect(back.cgpa, t.cgpa);
    });
  });

  group('Akademik durum', () {
    test('Dean\'s List: dönem GPA ≥ 3.50', () {
      expect(standing.isDeansList(3.50), isTrue);
      expect(standing.isDeansList(3.49), isFalse);
      expect(standing.isDeansList(null), isFalse);
    });

    test('Probation: CGPA < 2.00', () {
      expect(standing.isOnProbation(1.99), isTrue);
      expect(standing.isOnProbation(2.00), isFalse);
      expect(standing.isOnProbation(null), isFalse);
    });

    test('onur dereceleri', () {
      expect(standing.honorFor(3.49), isNull);
      expect(standing.honorFor(3.50)!.id, 'cum_laude');
      expect(standing.honorFor(3.70)!.id, 'magna_cum_laude');
      expect(standing.honorFor(3.90)!.id, 'summa_cum_laude');
      expect(standing.honorFor(null), isNull);
    });

    test('mezuniyet: dönemler bitti, düzeltilmemiş F yok, CGPA ≥ 2.00', () {
      final ok = Transcript([rec('a', 'B', 3.0)]);
      expect(
        standing.canGraduate(ok, completedSemesters: 8, requiredSemesters: 8),
        isTrue,
      );
      expect(
        standing.canGraduate(ok, completedSemesters: 7, requiredSemesters: 8),
        isFalse,
      );
      final withF = Transcript([rec('a', 'A', 4.0), rec('b', 'F', 0)]);
      expect(
        standing.canGraduate(withF, completedSemesters: 8, requiredSemesters: 8),
        isFalse,
      );
      final low = Transcript([rec('a', 'D', 1.0)]);
      expect(
        standing.canGraduate(low, completedSemesters: 8, requiredSemesters: 8),
        isFalse,
      );
    });
  });
}
