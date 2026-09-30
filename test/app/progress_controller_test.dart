import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tukenmez_gpa_run/app/game_content.dart';
import 'package:tukenmez_gpa_run/app/progress_controller.dart';
import 'package:tukenmez_gpa_run/data/save_repository.dart';
import 'package:tukenmez_gpa_run/domain/grading/assessment.dart';
import 'package:tukenmez_gpa_run/domain/progression/enrollment_rules.dart';

import '../helpers/config_fixtures.dart';

void main() {
  late GameContent content;
  const all = ['calc101', 'phys101', 'cs101'];

  setUpAll(() async {
    content = await GameContent.load(DiskAssetBundle());
  });

  (ProviderContainer, MemoryStore) make([MemoryStore? store]) {
    final s = store ?? MemoryStore();
    final c = ProviderContainer(
      overrides: [saveRepositoryProvider.overrideWithValue(SaveRepository(s))],
    );
    addTearDown(c.dispose);
    return (c, s);
  }

  Future<void> enroll(ProgressController p, List<String> ids) =>
      p.enroll(ids, content.curriculum, content.grading);

  Future<CourseCompletion?> playCourse(
    ProgressController p,
    String id,
    double score,
  ) async {
    CourseCompletion? done;
    for (final t in AssessmentType.values) {
      done = await p.recordLevel(content.course(id), t, score, content.grading);
    }
    return done;
  }

  test('içerik: 3 ders, 1. dönemde hepsi sunuluyor', () {
    expect(content.courses.map((c) => c.id), containsAll(all));
    expect(content.curriculum.offeredIn(1), all);
    expect(content.curriculum.offeredIn(2), isEmpty);
    expect(content.curriculum.requiredSemesters, 8);
  });

  test('ders seçimi olmadan oynanamaz; seçim doğrulanır', () async {
    final (c, _) = make();
    final p = c.read(progressProvider.notifier);
    final calc = content.course('calc101');
    expect(c.read(progressProvider).semester.needsEnrollment, isTrue);
    expect(p.runFor(calc), isNull);
    expect(p.statusOf(calc), CourseStatus.notEnrolled);

    final offer = p.offerFor(content.curriculum, content.grading);
    expect(offer.available, all);
    expect(offer.min, 3);
    expect(
      p.checkEnrollment(['calc101'], content.curriculum, content.grading),
      [EnrollmentIssue.tooFew],
    );
    expect(() => enroll(p, ['calc101']), throwsStateError);

    await enroll(p, all);
    expect(p.statusOf(calc), CourseStatus.notStarted);
    expect(p.runFor(calc), isNotNull);
    expect(
      () => enroll(p, all),
      throwsStateError,
      reason: 'ikinci kez seçilemez',
    );
  });

  test('sınavlar kalıcıdır, ders bitince dönem kaydına işlenir', () async {
    final (c, store) = make();
    final p = c.read(progressProvider.notifier);
    await enroll(p, all);
    await p.recordLevel(
      content.course('calc101'),
      AssessmentType.quiz1,
      88,
      content.grading,
    );

    final (c2, _) = make(store);
    final p2 = c2.read(progressProvider.notifier);
    expect(
      p2.runFor(content.course('calc101'))!.scores[AssessmentType.quiz1],
      88,
    );
    expect(jsonDecode(store.data[SaveRepository.key]!)['version'], 2);

    final done = await playCourse(p2, 'phys101', 90);
    expect(done!.letter, 'A-');
    expect(done.semesterComplete, isFalse);
    expect(p2.statusOf(content.course('phys101')), CourseStatus.passed);
    expect(c2.read(progressProvider).transcript.records.single.semester, 1);
  });

  test('tam dönem: karne, Dean\'s List, sonraki dönem', () async {
    final (c, _) = make();
    final p = c.read(progressProvider.notifier);
    await enroll(p, all);
    await playCourse(p, 'calc101', 95);
    await playCourse(p, 'phys101', 90);
    expect(p.isSemesterComplete, isFalse);
    expect(() => p.advanceSemester(), throwsStateError);
    final last = await playCourse(p, 'cs101', 85);
    expect(last!.semesterComplete, isTrue);

    final report = p.reportFor(1, content.grading);
    // (4.0×4 + 3.7×4 + 3.0×3) / 11
    expect(report.semesterGpa, closeTo((16 + 14.8 + 9) / 11, 1e-12));
    expect(report.deansList, isTrue);
    expect(report.probation, isFalse);
    expect(report.records, hasLength(3));

    await p.advanceSemester();
    final save = c.read(progressProvider);
    expect(save.semester.index, 2);
    expect(save.semester.needsEnrollment, isTrue);
    expect(p.offerFor(content.curriculum, content.grading).available, isEmpty);
  });

  test(
    'F → Probation → sonraki dönem zorunlu retake, en fazla 3 ders',
    () async {
      final (c, _) = make();
      final p = c.read(progressProvider.notifier);
      await enroll(p, all);
      await playCourse(p, 'calc101', 40);
      await playCourse(p, 'phys101', 45);
      await playCourse(p, 'cs101', 75);
      final report = p.reportFor(1, content.grading);
      expect(report.probation, isTrue, reason: 'CGPA = 2.0×3/11 < 2.00');
      expect(report.deansList, isFalse);

      await p.advanceSemester();
      final offer = p.offerFor(content.curriculum, content.grading);
      expect(offer.available, ['calc101', 'phys101']);
      expect(offer.requiredRetakes, ['calc101', 'phys101']);
      expect(offer.onProbation, isTrue);
      expect(offer.max, 3);
      expect(
        p.checkEnrollment(['calc101'], content.curriculum, content.grading),
        contains(EnrollmentIssue.missingRetake),
      );
      await enroll(p, ['calc101', 'phys101']);
      expect(p.runFor(content.course('calc101'))!.attempt, 2);
      expect(p.statusOf(content.course('cs101')), CourseStatus.notEnrolled);

      final retake = await playCourse(p, 'calc101', 85);
      expect(retake!.cgpaBefore, closeTo(2.0 * 3 / 11, 1e-12));
      expect(retake.attempt, 2);
      final t = c.read(progressProvider).transcript;
      expect(t.records.where((r) => r.replaced).single.courseId, 'calc101');
      expect(t.activeRecordFor('calc101')!.semester, 2);
      expect(
        t.semesterGpa(1),
        closeTo(2.0 * 3 / 11, 1e-12),
        reason: 'tarihsel',
      );
    },
  );

  test('v1 kaydı taşınır; sıfırlama ve bozuk kayıt', () async {
    final store = MemoryStore()
      ..data[SaveRepository.key] = jsonEncode({
        'version': 1,
        'transcript': [],
        'runs': {
          'calc101': {
            'courseId': 'calc101',
            'attempt': 1,
            'scores': {'quiz1': 70},
          },
        },
      });
    final (c, _) = make(store);
    final p = c.read(progressProvider.notifier);
    expect(c.read(progressProvider).semester.enrolled, ['calc101']);
    expect(p.statusOf(content.course('calc101')), CourseStatus.inProgress);

    await p.reset();
    expect(store.data, isEmpty);
    expect(c.read(progressProvider).semester.index, 1);

    store.data[SaveRepository.key] = '{bozuk json';
    final (c2, _) = make(store);
    expect(c2.read(progressProvider).transcript.records, isEmpty);
  });
}
