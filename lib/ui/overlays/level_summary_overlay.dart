import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n/generated/app_localizations.dart';
import '../../app/palette.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../domain/scoring/level_score.dart';
import '../../game/tukenmez_game.dart';
import '../l10n_helpers.dart';
import '../widgets/grade_stamp.dart';
import '../widgets/page_map_view.dart';
import '../widgets/post_it_button.dart';
import '../widgets/torn_card.dart';

/// Level sonu: sayfanın tamamı, şeffaf puan dökümü, skor, harf ve hoca yorumu.
class LevelSummaryOverlay extends ConsumerStatefulWidget {
  const LevelSummaryOverlay({
    super.key,
    required this.game,
    required this.comment,
    required this.isLastAssessment,
    required this.onContinue,
  });

  final TukenmezGame game;
  final String comment;
  final bool isLastAssessment;
  final VoidCallback onContinue;

  @override
  ConsumerState<LevelSummaryOverlay> createState() =>
      _LevelSummaryOverlayState();
}

class _LevelSummaryOverlayState extends ConsumerState<LevelSummaryOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final outcome = widget.game.outcome!;
    final r = outcome.score;
    final letter = ref
        .read(contentProvider)
        .requireValue
        .grading
        .scale
        .gradeFor(r.score)
        .symbol;

    // sayfa çevirme hissi: kart alttan dönerek gelir
    final turn = CurvedAnimation(
      parent: _anim,
      curve: const Interval(0, 0.5, curve: Curves.easeOutBack),
    );
    final stamp = CurvedAnimation(
      parent: _anim,
      curve: const Interval(0.55, 0.8, curve: Curves.easeIn),
    );

    return ColoredBox(
      color: const Color(0x66000000),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: AnimatedBuilder(
              animation: _anim,
              builder: (_, child) => Transform(
                alignment: Alignment.bottomCenter,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0015)
                  ..rotateX((1 - turn.value) * 1.2),
                child: Opacity(opacity: turn.value.clamp(0, 1), child: child),
              ),
              child: TornCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.inkDepleted ? l.summaryInkOut : l.summaryPageEnd,
                      style: AppTheme.hand(
                        40,
                        color: r.inkDepleted ? Palette.teacherRed : Palette.ink,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PageMapView(map: outcome.map, width: 96, height: 210),
                        const SizedBox(width: 14),
                        Expanded(child: _Breakdown(result: r)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l.rowLevelScore,
                                style: AppTheme.ui(15, color: Palette.pencil),
                              ),
                              Text(
                                formatScore(r.score),
                                style: AppTheme.hand(54),
                              ),
                            ],
                          ),
                        ),
                        AnimatedBuilder(
                          animation: stamp,
                          builder: (_, child) => Opacity(
                            opacity: stamp.value,
                            child: Transform.scale(
                              scale: 2.2 - stamp.value * 1.2,
                              child: child,
                            ),
                          ),
                          child: GradeStamp(letter: letter, size: 88),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.comment,
                      style: AppTheme.hand(28, color: Palette.teacherRed),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: PostItButton(
                        label: widget.isLastAssessment
                            ? l.seeCourseResult
                            : l.continueButton,
                        onPressed: widget.onContinue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Breakdown extends StatelessWidget {
  const _Breakdown({required this.result});
  final LevelScoreResult result;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final r = result;
    final rows = <(String, String, Color)>[
      (l.rowCollected, '+${formatScore(r.collectedPoints)}', Palette.ink),
      (l.rowPenalty, '−${formatScore(r.penaltyPoints)}', Palette.teacherRed),
      (l.rowMax, formatScore(r.maxPoints), Palette.darkText),
      (l.rowBase, formatScore(r.baseScore), Palette.darkText),
      if (r.bonusExtraCredit > 0)
        (l.rowBonus, '+${formatScore(r.bonusExtraCredit)}', Palette.ink),
      if (r.cleanPaperCredit > 0)
        (l.rowCleanPaper, '+${formatScore(r.cleanPaperCredit)}', Palette.ink),
      if (r.inkOutCapped) (l.rowInkCap, '≤ 50', Palette.teacherRed),
    ];
    return Column(
      children: [
        for (final (label, value, color) in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                Expanded(child: Text(label, style: AppTheme.ui(15))),
                Text(value, style: AppTheme.hand(24, color: color)),
              ],
            ),
          ),
      ],
    );
  }
}
