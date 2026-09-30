import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n/generated/app_localizations.dart';
import '../../app/palette.dart';
import '../../app/progress_controller.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../data/models/level_definition.dart';
import '../../domain/grading/assessment.dart';
import '../../domain/grading/gpa_calculator.dart';
import '../widgets/grade_stamp.dart';
import '../widgets/paper_backdrop.dart';
import '../widgets/post_it_button.dart';
import '../widgets/torn_card.dart';
import '../widgets/tuki_icon.dart';
import 'course_screen.dart';
import 'enrollment_screen.dart';
import 'semester_result_screen.dart';
import 'transcript_screen.dart';

class MainMenuScreen extends ConsumerWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final content = ref.watch(contentProvider).requireValue;
    final save = ref.watch(progressProvider);
    final controller = ref.read(progressProvider.notifier);
    final semester = save.semester;
    final offer = controller.offerFor(content.curriculum, content.grading);
    final enrolled = [for (final id in semester.enrolled) content.course(id)];

    void push(Widget screen) =>
        Navigator.of(context)
            .push(MaterialPageRoute<void>(builder: (_) => screen));

    return Scaffold(
      body: PaperBackdrop(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(56, 20, 20, 32),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(l.appTitle, style: AppTheme.hand(56)),
                        ),
                        Text(
                          l.appSubtitle,
                          style: AppTheme.hand(34, color: Palette.teacherRed),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l.tagline,
                          style: AppTheme.ui(16, color: Palette.pencil),
                        ),
                      ],
                    ),
                  ),
                  const TukiIcon(height: 130),
                ],
              ),
              const SizedBox(height: 22),
              Wrap(
                spacing: 16,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _GpaNote(
                    label: l.menuCgpa,
                    value: GpaCalculator.format(save.transcript.cgpa),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.menuSemester(semester.index),
                        style: AppTheme.hand(30),
                      ),
                      TextButton.icon(
                        onPressed: () => push(const TranscriptScreen()),
                        icon: const Icon(
                          Icons.description_outlined,
                          color: Palette.ink,
                        ),
                        label: Text(
                          l.menuTranscript,
                          style: AppTheme.ui(17, color: Palette.ink),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (offer.onProbation) ...[
                const SizedBox(height: 14),
                _ProbationNote(max: offer.max),
              ],
              const SizedBox(height: 24),
              if (semester.needsEnrollment) ...[
                Text(
                  offer.available.isEmpty
                      ? l.menuNoCourses
                      : l.menuEnrollHint(semester.index),
                  style: AppTheme.hand(26),
                ),
                const SizedBox(height: 14),
                if (offer.available.isNotEmpty)
                  Center(
                    child: PostItButton(
                      label: l.menuEnrollCta,
                      onPressed: () => push(const EnrollmentScreen()),
                    ),
                  ),
              ] else ...[
                Text(l.menuThisTerm, style: AppTheme.hand(34)),
                const SizedBox(height: 8),
                for (final course in enrolled)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _CourseCard(
                      course: course,
                      status: controller.statusOf(course),
                      completed: save.runs[course.id]?.scores.length ?? 0,
                      letter: save.transcript
                          .recordsIn(semester.index)
                          .where((r) => r.courseId == course.id)
                          .firstOrNull
                          ?.letter,
                      onTap: () => push(CourseScreen(courseId: course.id)),
                    ),
                  ),
                if (controller.isSemesterComplete) ...[
                  const SizedBox(height: 8),
                  Center(
                    child: PostItButton(
                      label: l.menuTermReport,
                      color: Palette.postItBlue,
                      onPressed: () =>
                          push(SemesterResultScreen(semester: semester.index)),
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 24),
              Center(
                child: TextButton(
                  onPressed: () => _confirmReset(context, ref, l),
                  child: Text(
                    l.menuReset,
                    style: AppTheme.ui(16, color: Palette.pencil),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmReset(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: Palette.paper,
        title: Text(l.resetTitle, style: AppTheme.hand(30)),
        content: Text(l.resetBody, style: AppTheme.ui(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(
              l.resetConfirm,
              style: const TextStyle(color: Palette.teacherRed),
            ),
          ),
        ],
      ),
    );
    if (ok ?? false) await ref.read(progressProvider.notifier).reset();
  }
}

class _GpaNote extends StatelessWidget {
  const _GpaNote({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Transform.rotate(
    angle: -0.03,
    child: Container(
      padding: const EdgeInsets.fromLTRB(18, 10, 22, 12),
      decoration: const BoxDecoration(
        color: Palette.postItBlue,
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 6,
            offset: Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTheme.ui(15)),
          Text(value, style: AppTheme.hand(46)),
        ],
      ),
    ),
  );
}

class _ProbationNote extends StatelessWidget {
  const _ProbationNote({required this.max});
  final int max;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Palette.teacherRed, width: 2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Palette.teacherRed),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${l.probationBadge}. ${l.probationHint(max)}',
              style: AppTheme.ui(15, color: Palette.teacherRed),
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({
    required this.course,
    required this.status,
    required this.completed,
    required this.letter,
    required this.onTap,
  });

  final CourseDefinition course;
  final CourseStatus status;
  final int completed;
  final String? letter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final statusText = switch (status) {
      CourseStatus.notEnrolled => l.statusNotEnrolled,
      CourseStatus.notStarted => l.statusNotStarted,
      CourseStatus.inProgress => l.statusInProgress(
        completed,
        AssessmentType.values.length,
      ),
      CourseStatus.passed => l.statusPassed,
      CourseStatus.failed => l.statusFailed,
    };
    return GestureDetector(
      onTap: onTap,
      child: TornCard(
        tilt: 0.01,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(course.code, style: AppTheme.hand(32)),
                  Text(
                    '"${course.nickname}"',
                    style: AppTheme.ui(16, color: Palette.pencil),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${l.credits(course.credits)} · $statusText',
                    style: AppTheme.ui(15),
                  ),
                ],
              ),
            ),
            if (letter != null)
              GradeStamp(letter: letter!, size: 64)
            else
              const Icon(
                Icons.arrow_forward_rounded,
                color: Palette.ink,
                size: 40,
              ),
          ],
        ),
      ),
    );
  }
}
