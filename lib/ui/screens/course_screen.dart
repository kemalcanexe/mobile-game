import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n/generated/app_localizations.dart';
import '../../app/palette.dart';
import '../../app/paper_theme.dart';
import '../../app/progress_controller.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../domain/grading/assessment.dart';
import '../l10n_helpers.dart';
import '../widgets/grade_stamp.dart';
import '../widgets/paper_backdrop.dart';
import '../widgets/post_it_button.dart';
import '../widgets/torn_card.dart';
import 'game_screen.dart';

/// Dersin izlencesi: 5 sınav, ağırlıkları, skorlar ve sıradaki sınav.
class CourseScreen extends ConsumerWidget {
  const CourseScreen({super.key, required this.courseId});

  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final content = ref.watch(contentProvider).requireValue;
    final course = content.course(courseId);
    ref.watch(progressProvider);
    final controller = ref.read(progressProvider.notifier);
    final status = controller.statusOf(course);
    final run = controller.runFor(course);
    final record = ref
        .read(progressProvider)
        .transcript
        .activeRecordFor(course.id);
    final next = run?.nextAssessment;
    // Devam eden denemede o denemenin, biten derste transkriptin skorları.
    double? scoreOf(AssessmentType t) =>
        run != null ? run.scores[t] : record?.assessmentScores[t.key];
    final paper = PaperTheme.of(course.paper);
    // koyu kağıtta (CS 101 terminali) başlıklar açık renkli
    final headColor = paper.isDark ? paper.trail : Palette.ink;
    final subColor = paper.isDark ? paper.endText : Palette.pencil;
    final weights = content.grading.weights;
    final scale = content.grading.scale;

    return Scaffold(
      body: PaperBackdrop(
        paper: course.paper,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(40, 8, 20, 32),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: headColor),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              Text(course.code, style: AppTheme.hand(52, color: headColor)),
              Text(
                '"${course.nickname}" · ${course.title}',
                style: AppTheme.ui(17, color: subColor),
              ),
              Text(
                [
                  l.credits(course.credits),
                  if (run != null && run.attempt > 1) l.attempt(run.attempt),
                ].join(' · '),
                style: AppTheme.ui(
                  16,
                  color: paper.isDark ? subColor : Palette.darkText,
                ),
              ),
              const SizedBox(height: 18),
              TornCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.syllabus, style: AppTheme.hand(30)),
                    const SizedBox(height: 6),
                    _row([
                      l.colAssessment,
                      l.colWeight,
                      l.colDuration,
                      l.colScore,
                    ], style: AppTheme.ui(14, color: Palette.pencil)),
                    for (final t in AssessmentType.values)
                      _row(
                        [
                          l.assessmentName(t),
                          '%${(weights[t]! * 100).round()}',
                          l.seconds(course.level(t).durationSeconds.round()),
                          switch (scoreOf(t)) {
                            final s? =>
                              '${formatScore(s)} ${scale.gradeFor(s).symbol}',
                            null => '—',
                          },
                        ],
                        style: AppTheme.ui(
                          17,
                          color: t == next ? Palette.ink : Palette.darkText,
                          weight: t == next ? FontWeight.w700 : FontWeight.w400,
                        ),
                        marker: t == next,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              if (next != null)
                Center(
                  child: PostItButton(
                    label: l.startAssessment(l.assessmentName(next)),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            GameScreen(courseId: course.id, assessment: next),
                      ),
                    ),
                  ),
                )
              else if (status == CourseStatus.failed) ...[
                Center(child: GradeStamp(letter: record!.letter, size: 110)),
                const SizedBox(height: 12),
                Text(
                  l.retakeQuip,
                  textAlign: TextAlign.center,
                  style: AppTheme.hand(26, color: Palette.teacherRed),
                ),
                const SizedBox(height: 8),
                Text(
                  l.failedNextTerm,
                  textAlign: TextAlign.center,
                  style: AppTheme.ui(16, color: subColor),
                ),
              ] else if (status == CourseStatus.notEnrolled &&
                  record == null) ...[
                Center(
                  child: Text(
                    l.statusNotEnrolled,
                    style: AppTheme.hand(28, color: headColor),
                  ),
                ),
              ] else if (record != null) ...[
                Center(child: GradeStamp(letter: record.letter, size: 120)),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    l.courseDone,
                    style: AppTheme.hand(30, color: headColor),
                  ),
                ),
                Center(
                  child: Text(
                    formatScore(record.score),
                    style: AppTheme.ui(18, color: subColor),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(
    List<String> cells, {
    required TextStyle style,
    bool marker = false,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        SizedBox(
          width: 20,
          child: marker
              ? const Icon(
                  Icons.play_arrow_rounded,
                  color: Palette.ink,
                  size: 18,
                )
              : null,
        ),
        Expanded(flex: 4, child: Text(cells[0], style: style)),
        Expanded(flex: 2, child: Text(cells[1], style: style)),
        Expanded(flex: 2, child: Text(cells[2], style: style)),
        Expanded(
          flex: 3,
          child: Text(cells[3], style: style, textAlign: TextAlign.right),
        ),
      ],
    ),
  );
}
