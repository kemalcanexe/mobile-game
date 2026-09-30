import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/level_definition.dart';
import '../data/save_repository.dart';
import '../domain/grading/assessment.dart';
import '../domain/grading/grade_calculator.dart';
import '../domain/grading/grading_rules.dart';
import '../domain/progression/course_record.dart';
import '../domain/progression/course_run.dart';
import '../domain/progression/retake_policy.dart';

final saveRepositoryProvider = Provider<SaveRepository>(
  (ref) => throw UnimplementedError('main() içinde override edilmeli'),
);

final progressProvider = NotifierProvider<ProgressController, SaveData>(
  ProgressController.new,
);

enum CourseStatus { notStarted, inProgress, passed, failed }

/// Bir ders bittiğinde sonuç ekranına giden özet.
class CourseCompletion {
  const CourseCompletion({
    required this.course,
    required this.scores,
    required this.courseScore,
    required this.letter,
    required this.gradePoints,
    required this.cgpaBefore,
    required this.cgpaAfter,
    required this.attempt,
  });

  final CourseDefinition course;
  final Map<AssessmentType, double> scores;
  final double courseScore;
  final String letter;
  final double gradePoints;
  final double? cgpaBefore;
  final double? cgpaAfter;
  final int attempt;

  bool get failed => gradePoints == 0;
}

class ProgressController extends Notifier<SaveData> {
  @override
  SaveData build() => ref.read(saveRepositoryProvider).load();

  Future<void> _commit(SaveData data) async {
    state = data;
    await ref.read(saveRepositoryProvider).save(data);
  }

  CourseStatus statusOf(CourseDefinition course) {
    if (state.runs.containsKey(course.id)) return CourseStatus.inProgress;
    final record = state.transcript.activeRecordFor(course.id);
    if (record == null) return CourseStatus.notStarted;
    return record.gradePoints == 0 ? CourseStatus.failed : CourseStatus.passed;
  }

  /// Oynanabilir deneme: devam eden ya da hiç alınmamış ders için yenisi.
  /// Geçilmiş ya da retake bekleyen derslerde `null`.
  CourseRun? runFor(CourseDefinition course) {
    final existing = state.runs[course.id];
    if (existing != null) return existing;
    if (state.transcript.activeRecordFor(course.id) != null) return null;
    return CourseRun(courseId: course.id);
  }

  Future<void> retake(CourseDefinition course, GradingRules rules) async {
    final record = state.transcript.activeRecordFor(course.id);
    if (record == null ||
        !RetakePolicy(rules.retakeableLetters).canRetake(record)) {
      throw StateError('${course.code} tekrar alınamaz');
    }
    await _commit(
      state.copyWith(
        runs: {
          ...state.runs,
          course.id: CourseRun(
            courseId: course.id,
            attempt: state.transcript.attemptsFor(course.id) + 1,
          ),
        },
      ),
    );
  }

  /// Level skorunu kaydeder. Ders tamamlandıysa transkripte işler ve özeti döner.
  Future<CourseCompletion?> recordLevel(
    CourseDefinition course,
    AssessmentType type,
    double score,
    GradingRules rules,
  ) async {
    final run = (runFor(course) ?? (throw StateError('Oynanabilir deneme yok')))
        .withScore(type, score);
    if (!run.isComplete) {
      await _commit(state.copyWith(runs: {...state.runs, course.id: run}));
      return null;
    }
    final calc = GradeCalculator(rules);
    final courseScore = calc.courseScore(run.scores);
    final letter = calc.letterFor(courseScore);
    final before = state.transcript.cgpa;
    final transcript = state.transcript.addResult(
      CourseRecord(
        courseId: course.id,
        courseCode: course.code,
        credits: course.credits,
        semester: course.semester,
        score: courseScore,
        letter: letter.symbol,
        gradePoints: letter.points,
        attempt: run.attempt,
      ),
      RetakePolicy(rules.retakeableLetters),
    );
    await _commit(
      SaveData(
        transcript: transcript,
        runs: {...state.runs}..remove(course.id),
      ),
    );
    return CourseCompletion(
      course: course,
      scores: run.scores,
      courseScore: courseScore,
      letter: letter.symbol,
      gradePoints: letter.points,
      cgpaBefore: before,
      cgpaAfter: transcript.cgpa,
      attempt: run.attempt,
    );
  }

  Future<void> reset() async {
    await ref.read(saveRepositoryProvider).clear();
    state = SaveData();
  }
}
