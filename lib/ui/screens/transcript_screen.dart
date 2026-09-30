import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n/generated/app_localizations.dart';
import '../../app/palette.dart';
import '../../app/progress_controller.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../domain/grading/gpa_calculator.dart';
import '../../domain/progression/academic_standing.dart';
import '../../domain/progression/course_record.dart';
import '../l10n_helpers.dart';
import '../widgets/paper_backdrop.dart';
import '../widgets/torn_card.dart';

/// Resmi belge parodisi: dönem dönem bütün dersler, retake'ler, GPA'ler.
class TranscriptScreen extends ConsumerWidget {
  const TranscriptScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final content = ref.watch(contentProvider).requireValue;
    final save = ref.watch(progressProvider);
    final t = save.transcript;
    final standing = AcademicStanding(content.grading.standing);
    final honor = standing.honorFor(t.cgpa);
    final completedSemesters = t.semesters
        .where((s) => s < save.semester.index)
        .length;

    String honorName(String id) => switch (id) {
      'summa_cum_laude' => l.honorSumma,
      'magna_cum_laude' => l.honorMagna,
      _ => l.honorCum,
    };

    return Scaffold(
      body: PaperBackdrop(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(56, 8, 20, 32),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Palette.ink),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              Text(l.transcriptTitle, style: AppTheme.hand(48)),
              Text(
                l.requiredSemesters(
                  completedSemesters,
                  content.curriculum.requiredSemesters,
                ),
                style: AppTheme.ui(17, color: Palette.pencil),
              ),
              const SizedBox(height: 16),
              if (t.records.isEmpty)
                Text(l.transcriptEmpty, style: AppTheme.hand(26)),
              for (final sem in t.semesters) ...[
                TornCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l.menuSemester(sem),
                              style: AppTheme.hand(28),
                            ),
                          ),
                          if (standing.isDeansList(t.semesterGpa(sem)))
                            const Icon(
                              Icons.star_rounded,
                              color: Color(0xFFE6B800),
                            ),
                        ],
                      ),
                      for (final r in t.recordsIn(sem)) _RecordRow(record: r),
                      const Divider(color: Palette.pencilLight),
                      Row(
                        children: [
                          Expanded(
                            child: Text(l.semesterGpa, style: AppTheme.ui(16)),
                          ),
                          Text(
                            GpaCalculator.format(t.semesterGpa(sem)),
                            style: AppTheme.hand(26),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],
              if (t.records.isNotEmpty) ...[
                Row(
                  children: [
                    Expanded(child: Text(l.menuCgpa, style: AppTheme.hand(30))),
                    Text(
                      GpaCalculator.format(t.cgpa),
                      style: AppTheme.hand(40),
                    ),
                  ],
                ),
                if (standing.isOnProbation(t.cgpa))
                  Text(
                    l.probationBadge,
                    style: AppTheme.ui(16, color: Palette.teacherRed),
                  ),
                if (honor != null)
                  Text(
                    l.honorCandidate(honorName(honor.id)),
                    style: AppTheme.ui(16, color: const Color(0xFFB38F00)),
                  ),
                if (t.records.any((r) => r.replaced))
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      l.transcriptReplaced,
                      style: AppTheme.ui(14, color: Palette.pencil),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RecordRow extends StatelessWidget {
  const _RecordRow({required this.record});
  final CourseRecord record;

  @override
  Widget build(BuildContext context) {
    final r = record;
    final style = AppTheme.ui(
      17,
      color: r.replaced
          ? Palette.pencil
          : (r.gradePoints == 0 ? Palette.teacherRed : Palette.darkText),
    ).copyWith(decoration: r.replaced ? TextDecoration.lineThrough : null);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(flex: 5, child: Text(r.courseCode, style: style)),
          Expanded(flex: 2, child: Text('${r.credits}', style: style)),
          Expanded(flex: 2, child: Text(formatScore(r.score), style: style)),
          Expanded(
            flex: 2,
            child: Text(
              r.letter.replaceAll('-', '−') + (r.replaced ? ' R' : ''),
              style: style,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
