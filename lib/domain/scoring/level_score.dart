import '../grading/grading_rules.dart';

/// Level boyunca puan olaylarını biriktirir.
class LevelScoreTracker {
  /// Spawn olan tüm (+) nesnelerin çarpansız toplamı.
  double maxPoints = 0;

  /// Toplanan puanlar (Fosforlu çarpanı dahil).
  double collectedPoints = 0;

  /// Ceza puanları (pozitif sayı olarak tutulur, çarpan uygulanmaz).
  double penaltyPoints = 0;

  /// Bonus Soru vb. ekstra kredi toplamı.
  double extraCredit = 0;

  int collectedCount = 0;
  int hitCount = 0;
  int bonusCount = 0;

  double get rawPoints => collectedPoints - penaltyPoints;

  void registerSpawn(double basePoints) => maxPoints += basePoints;

  void collect(double basePoints, {double multiplier = 1}) {
    collectedPoints += basePoints * multiplier;
    collectedCount++;
  }

  void penalize(double points) {
    penaltyPoints += points.abs();
    hitCount++;
  }

  void addExtraCredit(double credit) {
    extraCredit += credit;
    bonusCount++;
  }

  LevelScoreResult finish({
    required LevelScoreRules rules,
    required double inkRemaining,
    required bool inkDepleted,
  }) => LevelScoreResult.compute(
    rules: rules,
    maxPoints: maxPoints,
    collectedPoints: collectedPoints,
    penaltyPoints: penaltyPoints,
    bonusExtraCredit: extraCredit,
    inkRemaining: inkRemaining,
    inkDepleted: inkDepleted,
  );
}

/// Level sonu skoru ve şeffaf döküm.
class LevelScoreResult {
  const LevelScoreResult({
    required this.maxPoints,
    required this.collectedPoints,
    required this.penaltyPoints,
    required this.baseScore,
    required this.bonusExtraCredit,
    required this.cleanPaperCredit,
    required this.inkDepleted,
    required this.inkOutCapped,
    required this.score,
  });

  /// level_skoru = clamp(ham/maks × 100, 0, 100) + ekstra kredi → tavan 100;
  /// mürekkep bittiyse min(skor, 50).
  factory LevelScoreResult.compute({
    required LevelScoreRules rules,
    required double maxPoints,
    required double collectedPoints,
    required double penaltyPoints,
    required double bonusExtraCredit,
    required double inkRemaining,
    required bool inkDepleted,
  }) {
    final raw = collectedPoints - penaltyPoints;
    final base = maxPoints <= 0
        ? 0.0
        : (raw / maxPoints * rules.max).clamp(0, rules.max).toDouble();
    final clean = !inkDepleted && inkRemaining >= rules.cleanPaperMinInk
        ? rules.cleanPaperCredit
        : 0.0;
    var score = (base + bonusExtraCredit + clean)
        .clamp(0, rules.max)
        .toDouble();
    var capped = false;
    if (inkDepleted && score > rules.inkOutCap) {
      score = rules.inkOutCap;
      capped = true;
    }
    return LevelScoreResult(
      maxPoints: maxPoints,
      collectedPoints: collectedPoints,
      penaltyPoints: penaltyPoints,
      baseScore: base,
      bonusExtraCredit: bonusExtraCredit,
      cleanPaperCredit: clean,
      inkDepleted: inkDepleted,
      inkOutCapped: capped,
      score: score,
    );
  }

  final double maxPoints;
  final double collectedPoints;
  final double penaltyPoints;
  final double baseScore;
  final double bonusExtraCredit;
  final double cleanPaperCredit;
  final bool inkDepleted;
  final bool inkOutCapped;
  final double score;

  double get rawPoints => collectedPoints - penaltyPoints;
}
