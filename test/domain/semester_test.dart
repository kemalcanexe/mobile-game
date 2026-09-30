import 'package:flutter_test/flutter_test.dart';
import 'package:tukenmez_gpa_run/domain/progression/course_record.dart';
import 'package:tukenmez_gpa_run/domain/progression/enrollment_rules.dart';
import 'package:tukenmez_gpa_run/domain/progression/semester_state.dart';
import 'package:tukenmez_gpa_run/domain/progression/transcript.dart';

import '../helpers/config_fixtures.dart';

void main() {
  final rules = loadGradingRules().enrollment;

  group('EnrollmentRules', () {
    test('config: 3-4 ders, probation\'da en fazla 3', () {
      expect(rules.minCourses, 3);
      expect(rules.maxFor(onProbation: false), 4);
      expect(rules.maxFor(onProbation: true), 3);
    });

    test('ders azsa alt sınır iner', () {
      expect(rules.minFor(available: 2, onProbation: false), 2);
      expect(rules.minFor(available: 6, onProbation: false), 3);
      expect(rules.minFor(available: 0, onProbation: false), 0);
    });

    List<EnrollmentIssue> check(
      List<String> selected, {
      List<String> available = const ['a', 'b', 'c', 'd', 'e'],
      List<String> retakes = const [],
      bool probation = false,
    }) => rules.validate(
      selected: selected,
      available: available,
      requiredRetakes: retakes,
      onProbation: probation,
    );

    test('geçerli seçim', () {
      expect(check(['a', 'b', 'c']), isEmpty);
      expect(check(['a', 'b', 'c', 'd']), isEmpty);
    });

    test('az, çok, tekrar, sunulmayan', () {
      expect(check(['a', 'b']), [EnrollmentIssue.tooFew]);
      expect(check(['a', 'b', 'c', 'd', 'e']), [EnrollmentIssue.tooMany]);
      expect(check(['a', 'a', 'b', 'c']), contains(EnrollmentIssue.duplicate));
      expect(check(['a', 'b', 'z']), contains(EnrollmentIssue.notOffered));
    });

    test('probation\'da 4 ders alınamaz', () {
      expect(check(['a', 'b', 'c', 'd'], probation: true), [
        EnrollmentIssue.tooMany,
      ]);
      expect(check(['a', 'b', 'c'], probation: true), isEmpty);
    });

    test('F alınan ders seçilmek zorunda', () {
      expect(check(['b', 'c', 'd'], retakes: ['a']), [
        EnrollmentIssue.missingRetake,
      ]);
      expect(check(['a', 'c', 'd'], retakes: ['a']), isEmpty);
    });
  });

  group('SemesterState', () {
    test('kayıt, sonraki dönem ve JSON', () {
      var s = SemesterState();
      expect(s.index, 1);
      expect(s.needsEnrollment, isTrue);
      s = s.withEnrollment(['calc101', 'cs101']);
      expect(s.isEnrolled('cs101'), isTrue);
      expect(s.isEnrolled('phys101'), isFalse);
      final back = SemesterState.fromJson(s.toJson());
      expect(back.enrolled, ['calc101', 'cs101']);
      s = s.next();
      expect(s.index, 2);
      expect(s.needsEnrollment, isTrue);
      expect(SemesterState.fromJson(const {}).index, 1);
    });
  });

  group('Transcript dönem yardımcıları', () {
    CourseRecord r(String id, int sem, double pts) => CourseRecord(
      courseId: id,
      courseCode: id,
      credits: 3,
      semester: sem,
      score: 0,
      letter: pts == 0 ? 'F' : 'B',
      gradePoints: pts,
    );

    test('dönemler, dönem kayıtları, kalınan dersler', () {
      final t = Transcript([r('a', 1, 3), r('b', 1, 0), r('c', 2, 3)]);
      expect(t.semesters, [1, 2]);
      expect(t.recordsIn(1).map((e) => e.courseId), ['a', 'b']);
      expect(t.failedCourseIds, ['b']);
      expect(t.hasRecordIn('b', 1), isTrue);
      expect(t.hasRecordIn('b', 2), isFalse);
    });
  });
}
