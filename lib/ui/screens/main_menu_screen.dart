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
import '../widgets/torn_card.dart';
import '../widgets/tuki_icon.dart';
import 'course_screen.dart';

class MainMenuScreen extends ConsumerWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final content = ref.watch(contentProvider).requireValue;
    final save = ref.watch(progressProvider);
    final controller = ref.read(progressProvider.notifier);

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
                        Text(l.appTitle, style: AppTheme.hand(56)),
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
              Align(
                alignment: Alignment.centerLeft,
                child: _GpaNote(
                  label: l.menuCgpa,
                  value: GpaCalculator.format(save.transcript.cgpa),
                ),
              ),
              const SizedBox(height: 26),
              Text(l.menuCourses, style: AppTheme.hand(34)),
              const SizedBox(height: 8),
              for (final course in content.courses)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _CourseCard(
                    course: course,
                    status: controller.statusOf(course),
                    completed: save.runs[course.id]?.scores.length ?? 0,
                    letter: save.transcript.activeRecordFor(course.id)?.letter,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => CourseScreen(courseId: course.id),
                      ),
                    ),
                  ),
                ),
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
              Text('→', style: AppTheme.hand(44)),
          ],
        ),
      ),
    );
  }
}
