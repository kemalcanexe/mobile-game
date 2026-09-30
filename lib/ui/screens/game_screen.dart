import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n/generated/app_localizations.dart';
import '../../app/progress_controller.dart';
import '../../app/providers.dart';
import '../../domain/grading/assessment.dart';
import '../../game/level_setup.dart';
import '../../game/systems/level_generator.dart';
import '../../game/tukenmez_game.dart';
import '../l10n_helpers.dart';
import '../overlays/hud_overlay.dart';
import '../overlays/level_summary_overlay.dart';
import '../overlays/pause_overlay.dart';
import '../overlays/start_overlay.dart';
import 'course_result_screen.dart';

/// Tek bir sınavı (level) oynatır.
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({
    super.key,
    required this.courseId,
    required this.assessment,
  });

  final String courseId;
  final AssessmentType assessment;

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with WidgetsBindingObserver {
  TukenmezGame? _game;
  Future<CourseCompletion?>? _completion;
  String _comment = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _game ??= _buildGame(AppLocalizations.of(context));
  }

  TukenmezGame _buildGame(AppLocalizations l) {
    final content = ref.read(contentProvider).requireValue;
    final course = content.course(widget.courseId);
    final level = course.level(widget.assessment);
    final plan = LevelGenerator(
      config: content.config,
      catalog: content.catalog,
    ).generate(level, course.patterns);
    final setup = LevelSetup(
      config: content.config,
      catalog: content.catalog,
      scoreRules: content.grading.levelScore,
      level: level,
      plan: plan,
      paper: course.paper,
      strings: l.gameStrings,
    );
    return TukenmezGame(setup)
      ..onFinished = _onFinished
      ..onFeedback = (f) => switch (f) {
        GameFeedback.collect => HapticFeedback.selectionClick(),
        GameFeedback.hit => HapticFeedback.mediumImpact(),
      };
  }

  void _onFinished(LevelOutcome outcome) {
    final content = ref.read(contentProvider).requireValue;
    final course = content.course(widget.courseId);
    final controller = ref.read(progressProvider.notifier);
    final attempt = controller.runFor(course)?.attempt ?? 1;
    final letter = content.grading.scale.gradeFor(outcome.score.score).symbol;
    _comment = content.comments.pick(
      letter: letter,
      inkOut: outcome.score.inkDepleted,
      seed:
          course.level(widget.assessment).seed +
          attempt +
          outcome.collectedCount,
    );
    // Sonuç hemen kaydedilir; özet ekranında uygulama kapansa da kaybolmaz.
    _completion = controller.recordLevel(
      course,
      widget.assessment,
      outcome.score.score,
      content.grading,
    );
    HapticFeedback.heavyImpact();
    setState(() {});
  }

  Future<void> _continue() async {
    final completion = await _completion;
    if (!mounted) return;
    final nav = Navigator.of(context);
    if (completion != null) {
      nav.pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => CourseResultScreen(completion: completion),
        ),
      );
    } else {
      nav.pop();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) _game?.pauseGame();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = _game!;
    final l = AppLocalizations.of(context);
    final isLast = widget.assessment == AssessmentType.values.last;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        switch (game.state) {
          case RunState.running:
            game.paused ? game.resumeGame() : game.pauseGame();
          case RunState.ready:
            Navigator.of(context).pop();
          case RunState.finished:
            _continue();
        }
      },
      child: Scaffold(
        body: GameWidget<TukenmezGame>(
          game: game,
          initialActiveOverlays: const [TukenmezGame.overlayStart],
          overlayBuilderMap: {
            TukenmezGame.overlayStart: (_, g) => StartOverlay(
              game: g,
              title: l.readyTitle(l.assessmentName(widget.assessment)),
              onBack: () => Navigator.of(context).pop(),
            ),
            TukenmezGame.overlayHud: (_, g) => HudOverlay(game: g),
            TukenmezGame.overlayPause: (_, g) => PauseOverlay(
              game: g,
              onQuit: () => Navigator.of(context).pop(),
            ),
            TukenmezGame.overlaySummary: (_, g) => LevelSummaryOverlay(
              game: g,
              comment: _comment,
              isLastAssessment: isLast,
              onContinue: _continue,
            ),
          },
        ),
      ),
    );
  }
}
