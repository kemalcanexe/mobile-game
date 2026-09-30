import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tukenmez_gpa_run/app/game_content.dart';
import 'package:tukenmez_gpa_run/app/progress_controller.dart';
import 'package:tukenmez_gpa_run/data/save_repository.dart';
import 'package:tukenmez_gpa_run/domain/grading/assessment.dart';

import '../helpers/config_fixtures.dart';

void main() {
  late GameContent content;

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

  Future<CourseCompletion?> playCourse(
    ProgressController p,
    List<double> scores,
  ) async {
    final calc = content.course('calc101');
    CourseCompletion? done;
    for (var i = 0; i < AssessmentType.values.length; i++) {
      done = await p.recordLevel(
        calc,
        AssessmentType.values[i],
        scores[i],
        content.grading,
      );
    }
    return done;
  }

  test('sınavlar sırayla kaydedilir ve kalıcıdır', () async {
    final (c, store) = make();
    final p = c.read(progressProvider.notifier);
    final calc = content.course('calc101');
    expect(p.statusOf(calc), CourseStatus.notStarted);

    await p.recordLevel(calc, AssessmentType.quiz1, 88, content.grading);
    expect(p.statusOf(calc), CourseStatus.inProgress);
    expect(p.runFor(calc)!.nextAssessment, AssessmentType.midterm);

    // yeni oturum aynı depodan okur
    final (c2, _) = make(store);
    final p2 = c2.read(progressProvider.notifier);
    expect(p2.runFor(calc)!.scores[AssessmentType.quiz1], 88);
    expect(jsonDecode(store.data[SaveRepository.key]!)['version'], 1);
  });

  test('ders bitince transkripte harf ve GPA işlenir', () async {
    final (c, _) = make();
    final p = c.read(progressProvider.notifier);
    final done = await playCourse(p, [90, 90, 90, 90, 90]);
    expect(done, isNotNull);
    expect(done!.courseScore, closeTo(90, 1e-9));
    expect(done.letter, 'A-');
    expect(done.cgpaBefore, isNull);
    expect(done.cgpaAfter, closeTo(3.7, 1e-12));
    final calc = content.course('calc101');
    expect(p.statusOf(calc), CourseStatus.passed);
    expect(p.runFor(calc), isNull, reason: 'geçilen ders tekrar oynanmaz');
    expect(() => p.retake(calc, content.grading), throwsStateError);
  });

  test('F → retake → yeni not eskisinin yerine geçer', () async {
    final (c, _) = make();
    final p = c.read(progressProvider.notifier);
    final calc = content.course('calc101');
    final fail = await playCourse(p, [50, 40, 50, 50, 40]);
    expect(fail!.failed, isTrue);
    expect(p.statusOf(calc), CourseStatus.failed);
    expect(p.runFor(calc), isNull, reason: 'F sonrası açık retake gerekir');

    await p.retake(calc, content.grading);
    expect(p.runFor(calc)!.attempt, 2);
    final pass = await playCourse(p, [85, 85, 85, 85, 85]);
    expect(pass!.letter, 'B');
    expect(pass.attempt, 2);
    expect(pass.cgpaBefore, 0);
    expect(pass.cgpaAfter, 3.0);
    expect(
      c
          .read(progressProvider)
          .transcript
          .records
          .last
          .assessmentScores['final'],
      85,
    );
    final transcript = c.read(progressProvider).transcript;
    expect(transcript.records.first.replaced, isTrue);
    expect(transcript.records.last.isRetake, isTrue);
  });

  test('sıfırlama her şeyi siler; bozuk kayıt boş başlar', () async {
    final (c, store) = make();
    final p = c.read(progressProvider.notifier);
    await playCourse(p, [90, 90, 90, 90, 90]);
    await p.reset();
    expect(c.read(progressProvider).transcript.records, isEmpty);
    expect(store.data, isEmpty);

    store.data[SaveRepository.key] = '{bozuk json';
    final (c2, _) = make(store);
    expect(c2.read(progressProvider).transcript.records, isEmpty);
  });
}
