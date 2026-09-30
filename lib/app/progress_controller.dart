import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/curriculum.dart';
import '../data/models/level_definition.dart';
import '../data/save_repository.dart';
import '../domain/grading/assessment.dart';
import '../domain/grading/grade_calculator.dart';
import '../domain/grading/grading_rules.dart';
import '../domain/progression/academic_standing.dart';
import '../domain/progression/course_record.dart';
import '../domain/progression/course_run.dart';
import '../domain/progression/enrollment_rules.dart';
import '../domain/progression/retake_policy.dart';

final saveRepositoryProvider = Provider<SaveRepository>(
  (ref) => throw UnimplementedError('main() içinde override edilmeli'),
);

final progressProvider = NotifierProvider<ProgressController, SaveData>(
  ProgressController.new,
);

/// Bu dönemdeki bir dersin durumu.
enum CourseStatus { notEnrolled, notStarted, inProgress, passed, failed }

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
    required this.semesterComplete,
  });

  final CourseDefinition course;
  final Map<AssessmentType, double> scores;
  final double courseScore;
  final String letter;
  final double gradePoints;
  final double? cgpaBefore;
  final double? cgpaAfter;
  final int attempt;

  /// Bu dersle birlikte dönemin bütün dersleri bitti mi?
  final bool semesterComplete;

  bool get failed => gradePoints == 0;
}

/// Ders seçimi ekranı için dönem teklifi.
class EnrollmentOffer {
  const EnrollmentOffer({
    required this.available,
    required this.requiredRetakes,
    required this.onProbation,
    required this.min,
    required this.max,
  });

  /// Seçilebilecek bütün dersler: retake'ler başta.
  final List<String> available;
  final List<String> requiredRetakes;
  final bool onProbation;
  final int min;
  final int max;
}

/// Dönem sonu karnesi.
class SemesterReport {
  const SemesterReport({
    required this.semester,
    required this.records,
    required this.semesterGpa,
    required this.cgpa,
    required this.deansList,
    required this.probation,
  });

  final int semester;
  final List<CourseRecord> records;
  final double? semesterGpa;
  final double? cgpa;
  final bool deansList;
  final bool probation;
}

class ProgressController extends Notifier<SaveData> {
  @override
  SaveData build() => ref.read(saveRepositoryProvider).load();

  Future<void> _commit(SaveData data) async {
    state = data;
    await ref.read(saveRepositoryProvider).save(data);
  }

  int get semesterIndex => state.semester.index;

  // ---------------------------------------------------------- ders seçimi

  EnrollmentOffer offerFor(Curriculum curriculum, GradingRules rules) {
    final retakes = state.transcript.failedCourseIds;
    final fresh = curriculum
        .offeredIn(semesterIndex)
        .where((id) => state.transcript.activeRecordFor(id) == null)
        .where((id) => !retakes.contains(id));
    final available = [...retakes, ...fresh];
    final onProbation = AcademicStanding(rules.standing)
        .isOnProbation(state.transcript.cgpa);
    final er = rules.enrollment;
    return EnrollmentOffer(
      available: available,
      requiredRetakes: retakes,
      onProbation: onProbation,
      min: er.minFor(available: available.length, onProbation: onProbation),
      max: er.maxFor(onProbation: onProbation),
    );
  }

  List<EnrollmentIssue> checkEnrollment(
    List<String> selected,
    Curriculum curriculum,
    GradingRules rules,
  ) {
    final offer = offerFor(curriculum, rules);
    return rules.enrollment.validate(
      selected: selected,
      available: offer.available,
      requiredRetakes: offer.requiredRetakes,
      onProbation: offer.onProbation,
    );
  }

  Future<void> enroll(
    List<String> selected,
    Curriculum curriculum,
    GradingRules rules,
  ) async {
    if (!state.semester.needsEnrollment) {
      throw StateError('Bu dönem için ders seçimi zaten yapıldı');
    }
    final issues = checkEnrollment(selected, curriculum, rules);
    if (issues.isNotEmpty) throw StateError('Geçersiz ders seçimi: $issues');
    await _commit(
      state.copyWith(semester: state.semester.withEnrollment(selected)),
    );
  }

  // ---------------------------------------------------------- dersler

  CourseStatus statusOf(CourseDefinition course) {
    if (!state.semester.isEnrolled(course.id)) return CourseStatus.notEnrolled;
    if (state.runs.containsKey(course.id)) return CourseStatus.inProgress;
    if (!state.transcript.hasRecordIn(course.id, semesterIndex)) {
      return CourseStatus.notStarted;
    }
    final record = state.transcript.activeRecordFor(course.id);
    return record == null || record.gradePoints == 0
        ? CourseStatus.failed
        : CourseStatus.passed;
  }

  /// Oynanabilir deneme: dersin bu dönem kaydı olmalı ve henüz bitmemiş olmalı.
  CourseRun? runFor(CourseDefinition course) {
    if (!state.semester.isEnrolled(course.id)) return null;
    final existing = state.runs[course.id];
    if (existing != null) return existing;
    if (state.transcript.hasRecordIn(course.id, semesterIndex)) return null;
    return CourseRun(
      courseId: course.id,
      attempt: state.transcript.attemptsFor(course.id) + 1,
    );
  }

  bool get isSemesterComplete =>
      !state.semester.needsEnrollment &&
      state.semester.enrolled.every(
        (id) => state.transcript.hasRecordIn(id, semesterIndex),
      );

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
        semester: semesterIndex,
        score: courseScore,
        letter: letter.symbol,
        gradePoints: letter.points,
        attempt: run.attempt,
        assessmentScores: {
          for (final e in run.scores.entries) e.key.key: e.value,
        },
      ),
      RetakePolicy(rules.retakeableLetters),
    );
    await _commit(
      state.copyWith(
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
      semesterComplete: isSemesterComplete,
    );
  }

  // ---------------------------------------------------------- dönem sonu

  SemesterReport reportFor(int semester, GradingRules rules) {
    final standing = AcademicStanding(rules.standing);
    final gpa = state.transcript.semesterGpa(semester);
    final cgpa = state.transcript.cgpa;
    return SemesterReport(
      semester: semester,
      records: state.transcript.recordsIn(semester),
      semesterGpa: gpa,
      cgpa: cgpa,
      deansList: standing.isDeansList(gpa),
      probation: standing.isOnProbation(cgpa),
    );
  }

  Future<void> advanceSemester() async {
    if (!isSemesterComplete) throw StateError('Dönem henüz bitmedi');
    await _commit(
      state.copyWith(semester: state.semester.next(), runs: const {}),
    );
  }

  Future<void> reset() async {
    await ref.read(saveRepositoryProvider).clear();
    state = SaveData();
  }
}
