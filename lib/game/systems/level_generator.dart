import 'dart:math';

import '../../data/models/level_definition.dart';
import '../config/game_config.dart';
import '../config/item_catalog.dart';
import 'speed_curve.dart';

/// Tek bir nesnenin ne zaman ve hangi şeritte geleceği.
/// [distance]: nesnenin Tüki'nin hizasına ulaştığı kaydırma mesafesi.
class SpawnEvent {
  const SpawnEvent(this.distance, this.lane, this.code);
  final double distance;
  final int lane;
  final String code;
}

class SpawnPlan {
  const SpawnPlan({required this.totalDistance, required this.events});

  final double totalDistance;

  /// Mesafeye göre sıralı.
  final List<SpawnEvent> events;
}

/// Level tanımı + desen kütüphanesinden seed'li, deterministik spawn planı.
class LevelGenerator {
  const LevelGenerator({required this.config, required this.catalog});

  final GameConfig config;
  final ItemCatalog catalog;

  SpawnPlan generate(
    LevelDefinition level,
    Map<String, PatternDef> patterns, {
    double semesterMultiplier = 1,
  }) {
    final curve = SpeedCurve(
      level.speed,
      semesterMultiplier: semesterMultiplier,
    );
    final total = curve.distanceFor(level.durationSeconds, config.baseSpeed);
    final rng = Random(level.seed);
    final events = <SpawnEvent>[];
    final end = total - config.endMarginRows * config.rowSpacing;
    var cursor =
        config.warmupSeconds * config.baseSpeed * curve.multiplierAt(0);
    var scriptIndex = 0;

    while (cursor < end) {
      final progress = cursor / total;
      PatternDef pattern;
      if (scriptIndex < level.script.length &&
          level.script[scriptIndex].atProgress <= progress) {
        pattern = patterns[level.script[scriptIndex++].pattern]!;
      } else {
        pattern = patterns[_pick(level.pool, progress, rng)]!;
      }
      final mirror = pattern.mirrorable && rng.nextBool();
      for (var row = 0; row < pattern.rows.length; row++) {
        final d = cursor + row * config.rowSpacing;
        if (d > end) break;
        final cells = pattern.rows[row];
        for (var lane = 0; lane < cells.length; lane++) {
          final code = cells[mirror ? cells.length - 1 - lane : lane];
          if (code != ItemCatalog.emptyCode) {
            events.add(SpawnEvent(d, lane, code));
          }
        }
      }
      final gap =
          level.gapRowsMin +
          rng.nextInt(level.gapRowsMax - level.gapRowsMin + 1);
      cursor += (pattern.rows.length + gap) * config.rowSpacing;
    }
    return SpawnPlan(totalDistance: total, events: List.unmodifiable(events));
  }

  String _pick(List<PoolEntry> pool, double progress, Random rng) {
    var eligible = pool
        .where((e) => progress >= e.fromProgress && progress < e.toProgress)
        .toList();
    if (eligible.isEmpty) eligible = pool;
    final totalWeight = eligible.fold<double>(0, (a, e) => a + e.weight);
    var roll = rng.nextDouble() * totalWeight;
    for (final e in eligible) {
      roll -= e.weight;
      if (roll <= 0) return e.pattern;
    }
    return eligible.last.pattern;
  }
}
