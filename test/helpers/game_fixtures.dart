import 'package:flutter/widgets.dart';
import 'package:tukenmez_gpa_run/data/models/level_definition.dart';
import 'package:tukenmez_gpa_run/domain/grading/assessment.dart';
import 'package:tukenmez_gpa_run/game/level_setup.dart';
import 'package:tukenmez_gpa_run/game/systems/level_generator.dart';
import 'package:tukenmez_gpa_run/game/tukenmez_game.dart';

import 'config_fixtures.dart';

const testStrings = GameStrings(
  finalStretch: 'SON 5 DAKİKA',
  notificationTitle: 'Ayşe',
  notificationBody: 'hikaye paylaştı',
  friendBubble: 'Kantin?',
  extraCredit: '+{n} ekstra kredi',
  doublePoints: 'x2!',
  focusMode: 'Odak!',
  inkRefill: '+{n} mürekkep',
  pageEnd: 'sayfa sonu',
);

/// Sabit hızlı (1.0x), elle yazılmış spawn planıyla bir test level'ı.
TukenmezGame buildTestGame(
  List<SpawnEvent> events, {
  double totalDistance = 3000,
}) {
  final config = loadGameConfig();
  final setup = LevelSetup(
    config: config,
    catalog: loadCatalog(),
    scoreRules: loadGradingRules().levelScore,
    level: const LevelDefinition(
      id: 'test',
      assessment: AssessmentType.quiz1,
      durationSeconds: 10,
      speed: SpeedSpec(start: 1, end: 1, curve: SpeedCurveType.linear),
      seed: 42,
      gapRowsMin: 1,
      gapRowsMax: 1,
      pool: [],
    ),
    plan: SpawnPlan(totalDistance: totalDistance, events: events),
    paper: 'grid',
    strings: testStrings,
  );
  final game = TukenmezGame(setup);
  // Testlerde GameWidget yok; overlay adlarını boş builder'larla kaydet.
  for (final name in [
    TukenmezGame.overlayStart,
    TukenmezGame.overlayHud,
    TukenmezGame.overlayPause,
    TukenmezGame.overlaySummary,
  ]) {
    game.overlays.addEntry(name, (_, _) => const SizedBox());
  }
  return game;
}

extension GameStepping on TukenmezGame {
  static const dt = 1 / 60;

  void runFor(double seconds) {
    final frames = (seconds / dt).round();
    for (var i = 0; i < frames; i++) {
      update(dt);
    }
  }

  /// Oyunu, [d] mesafesindeki nesne Tüki'ye [pixelsAway] kala durdurur.
  void runUntilDistance(double d, {double pixelsAway = 0}) {
    while (distance < d - pixelsAway && state == RunState.running) {
      update(dt);
    }
  }
}
