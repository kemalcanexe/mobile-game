import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n/generated/app_localizations.dart';
import '../../app/palette.dart';
import '../../app/progress_controller.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../domain/grading/assessment.dart';
import '../../domain/grading/gpa_calculator.dart';
import '../l10n_helpers.dart';
import '../widgets/grade_stamp.dart';
import '../widgets/paper_backdrop.dart';
import '../widgets/post_it_button.dart';
import '../widgets/torn_card.dart';

/// Ders sonu: izlence tablosu dolar, ağırlıklar toplanır, harf damgası vurulur
/// ve GPA sayacı değişir.
class CourseResultScreen extends ConsumerStatefulWidget {
  const CourseResultScreen({super.key, required this.completion});

  final CourseCompletion completion;

  @override
  ConsumerState<CourseResultScreen> createState() => _CourseResultScreenState();
}

class _CourseResultScreenState extends ConsumerState<CourseResultScreen>
    with SingleTickerProviderStateMixin {
  static const _rowsEnd = 0.55;
  static const _stampStart = 0.62;
  static const _stampEnd = 0.75;

  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  );
  bool _thudDone = false;

  @override
  void initState() {
    super.initState();
    _anim.addListener(() {
      if (!_thudDone && _anim.value >= _stampEnd) {
        _thudDone = true;
        HapticFeedback.heavyImpact();
      }
    });
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  double _interval(double begin, double end, {Curve curve = Curves.easeOut}) =>
      curve.transform(((_anim.value - begin) / (end - begin)).clamp(0.0, 1.0));

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = widget.completion;
    final grading = ref.read(contentProvider).requireValue.grading;
    final types = AssessmentType.values;

    return Scaffold(
      body: PaperBackdrop(
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _anim,
            builder: (context, _) {
              final rowStep = _rowsEnd / types.length;
              var runningTotal = 0.0;
              final rows = <Widget>[];
              for (var i = 0; i < types.length; i++) {
                final t = types[i];
                final appear = _interval(i * rowStep, (i + 1) * rowStep);
                final contribution = c.scores[t]! * grading.weights[t]!;
                runningTotal += contribution * appear;
                rows.add(
                  Opacity(
                    opacity: appear,
                    child: _row(
                      l.assessmentName(t),
                      '%${(grading.weights[t]! * 100).round()}',
                      formatScore(c.scores[t]!),
                      contribution.toStringAsFixed(1),
                      AppTheme.ui(17),
                    ),
                  ),
                );
              }
              final stamp = _interval(
                _stampStart,
                _stampEnd,
                curve: Curves.easeIn,
              );
              final gpa = _interval(_stampEnd, 1);
              final before = c.cgpaBefore;
              final after = c.cgpaAfter;
              final arrow = before == null || after == null || after == before
                  ? ''
                  : after > before
                  ? ' ▲'
                  : ' ▼';

              return ListView(
                padding: const EdgeInsets.fromLTRB(40, 16, 20, 32),
                children: [
                  Text(l.courseResult, style: AppTheme.hand(46)),
                  Text(
                    '${c.course.code} · "${c.course.nickname}"',
                    style: AppTheme.ui(17, color: Palette.pencil),
                  ),
                  const SizedBox(height: 16),
                  TornCard(
                    child: Column(
                      children: [
                        _row(
                          l.colAssessment,
                          l.colWeight,
                          l.colScore,
                          l.colContribution,
                          AppTheme.ui(14, color: Palette.pencil),
                        ),
                        ...rows,
                        const Divider(color: Palette.ink, thickness: 1.5),
                        _row(
                          l.total,
                          '',
                          '',
                          runningTotal.toStringAsFixed(1),
                          AppTheme.hand(28),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 150,
                    child: Center(
                      child: Opacity(
                        opacity: stamp,
                        child: Transform.scale(
                          scale: 3 - stamp * 2,
                          child: GradeStamp(letter: c.letter, size: 130),
                        ),
                      ),
                    ),
                  ),
                  Opacity(
                    opacity: gpa,
                    child: Column(
                      children: [
                        Text(
                          l.gpaLabel,
                          style: AppTheme.ui(16, color: Palette.pencil),
                        ),
                        Text(
                          '${GpaCalculator.format(before)} → ${GpaCalculator.format(after)}$arrow',
                          style: AppTheme.hand(
                            40,
                            color: arrow == ' ▼'
                                ? Palette.teacherRed
                                : Palette.ink,
                          ),
                        ),
                        if (c.failed) ...[
                          const SizedBox(height: 8),
                          Text(
                            l.retakeQuip,
                            textAlign: TextAlign.center,
                            style: AppTheme.hand(26, color: Palette.teacherRed),
                          ),
                        ],
                        const SizedBox(height: 22),
                        PostItButton(
                          label: l.backToCourse,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _row(String a, String b, String c, String d, TextStyle style) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(flex: 4, child: Text(a, style: style)),
            Expanded(flex: 2, child: Text(b, style: style)),
            Expanded(flex: 2, child: Text(c, style: style)),
            Expanded(
              flex: 2,
              child: Text(d, style: style, textAlign: TextAlign.right),
            ),
          ],
        ),
      );
}
