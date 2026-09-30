import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n/generated/app_localizations.dart';
import '../../app/palette.dart';
import '../../app/progress_controller.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../domain/grading/gpa_calculator.dart';
import '../widgets/paper_backdrop.dart';
import '../widgets/post_it_button.dart';
import '../widgets/torn_card.dart';

/// Dönem sonu karnesi: dersler, dönem GPA'i, CGPA, Dean's List / Probation.
class SemesterResultScreen extends ConsumerStatefulWidget {
  const SemesterResultScreen({super.key, required this.semester});

  final int semester;

  @override
  ConsumerState<SemesterResultScreen> createState() =>
      _SemesterResultScreenState();
}

class _SemesterResultScreenState extends ConsumerState<SemesterResultScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _stamp = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      _stamp.forward().whenComplete(HapticFeedback.heavyImpact);
    });
  }

  @override
  void dispose() {
    _stamp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final content = ref.watch(contentProvider).requireValue;
    ref.watch(progressProvider);
    final controller = ref.read(progressProvider.notifier);
    final report = controller.reportFor(widget.semester, content.grading);
    final canAdvance =
        controller.semesterIndex == widget.semester &&
        controller.isSemesterComplete;

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
              Text(l.termReportTitle, style: AppTheme.hand(48)),
              Text(
                l.termReportSubtitle(widget.semester),
                style: AppTheme.ui(17, color: Palette.pencil),
              ),
              const SizedBox(height: 16),
              TornCard(
                child: Column(
                  children: [
                    _row(
                      l.colCourse,
                      l.colCredits,
                      l.colLetter,
                      AppTheme.ui(14, color: Palette.pencil),
                    ),
                    for (final r in report.records)
                      _row(
                        r.courseCode + (r.isRetake ? ' (R)' : ''),
                        '${r.credits}',
                        r.letter.replaceAll('-', '−'),
                        AppTheme.ui(
                          18,
                          color: r.gradePoints == 0
                              ? Palette.teacherRed
                              : Palette.darkText,
                        ),
                      ),
                    const Divider(color: Palette.ink, thickness: 1.5),
                    _row(
                      l.semesterGpa,
                      '',
                      GpaCalculator.format(report.semesterGpa),
                      AppTheme.hand(28),
                    ),
                    _row(
                      l.menuCgpa,
                      '',
                      GpaCalculator.format(report.cgpa),
                      AppTheme.hand(28),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (report.deansList || report.probation)
                Center(
                  child: AnimatedBuilder(
                    animation: _stamp,
                    builder: (_, child) => Opacity(
                      opacity: _stamp.value,
                      child: Transform.scale(
                        scale: 2.5 - _stamp.value * 1.5,
                        child: child,
                      ),
                    ),
                    child: report.deansList
                        ? const _DeansListStar()
                        : const _ProbationStamp(),
                  ),
                ),
              if (report.deansList || report.probation)
                const SizedBox(height: 20),
              if (report.deansList)
                Text(
                  l.deansListHint,
                  textAlign: TextAlign.center,
                  style: AppTheme.hand(24),
                ),
              if (report.probation)
                Text(
                  l.probationHint(
                    content.grading.enrollment.probationMaxCourses,
                  ),
                  textAlign: TextAlign.center,
                  style: AppTheme.hand(24, color: Palette.teacherRed),
                ),
              const SizedBox(height: 22),
              if (canAdvance)
                Center(
                  child: PostItButton(
                    label: l.nextTerm,
                    onPressed: () async {
                      await controller.advanceSemester();
                      if (context.mounted) Navigator.of(context).pop();
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String a, String b, String c, TextStyle style) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(flex: 5, child: Text(a, style: style)),
        Expanded(flex: 2, child: Text(b, style: style)),
        Expanded(
          flex: 2,
          child: Text(c, style: style, textAlign: TextAlign.right),
        ),
      ],
    ),
  );
}

class _DeansListStar extends StatelessWidget {
  const _DeansListStar();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Transform.rotate(
      angle: -0.12,
      child: Column(
        children: [
          const Icon(Icons.star_rounded, size: 96, color: Color(0xFFE6B800)),
          Text(
            l.deansList,
            style: AppTheme.hand(34, color: const Color(0xFFB38F00)),
          ),
        ],
      ),
    );
  }
}

class _ProbationStamp extends StatelessWidget {
  const _ProbationStamp();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Transform.rotate(
      angle: -0.15,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: Palette.teacherRed, width: 4),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          l.probationStamp,
          style: AppTheme.hand(40, color: Palette.teacherRed),
        ),
      ),
    );
  }
}
