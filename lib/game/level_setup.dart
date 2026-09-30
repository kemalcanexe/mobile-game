import '../data/models/level_definition.dart';
import '../domain/grading/grading_rules.dart';
import '../domain/scoring/level_score.dart';
import 'config/game_config.dart';
import 'config/item_catalog.dart';
import 'page_map.dart';
import 'systems/level_generator.dart';

/// Oyun içinde canvas'a çizilen yerelleştirilmiş metinler.
class GameStrings {
  const GameStrings({
    required this.finalStretch,
    required this.notificationTitle,
    required this.notificationBody,
    required this.friendBubble,
    required this.extraCredit,
    required this.doublePoints,
    required this.focusMode,
    required this.inkRefill,
    required this.pageEnd,
  });

  final String finalStretch;
  final String notificationTitle;
  final String notificationBody;
  final String friendBubble;
  final String extraCredit;
  final String doublePoints;
  final String focusMode;
  final String inkRefill;
  final String pageEnd;
}

/// Bir level'ı oynatmak için gereken her şey. Oyun asset yüklemez; böylece
/// testlerde doğrudan kurulabilir.
class LevelSetup {
  const LevelSetup({
    required this.config,
    required this.catalog,
    required this.scoreRules,
    required this.level,
    required this.plan,
    required this.paper,
    required this.strings,
    this.semesterMultiplier = 1,
  });

  final GameConfig config;
  final ItemCatalog catalog;
  final LevelScoreRules scoreRules;
  final LevelDefinition level;
  final SpawnPlan plan;

  /// Kağıt teması: grid (kareli), lined (çizgili)…
  final String paper;
  final GameStrings strings;
  final double semesterMultiplier;
}

/// Level sonucu: skor dökümü ve mürekkep izi haritası.
class LevelOutcome {
  const LevelOutcome({
    required this.score,
    required this.inkRemaining,
    required this.collectedCount,
    required this.hitCount,
    required this.bonusCount,
    required this.map,
  });

  final LevelScoreResult score;
  final double inkRemaining;
  final int collectedCount;
  final int hitCount;
  final int bonusCount;
  final PageMap map;
}
