import 'package:flutter/foundation.dart';

/// HUD'un dinlediği değerler. Yalnızca görünür bir değişiklik olduğunda
/// bildirim yapılır; Flutter widget'ları her karede yeniden kurulmaz.
class HudState {
  final score = ValueNotifier<int>(0);
  final livePercent = ValueNotifier<int>(0);
  final ink = ValueNotifier<double>(1);
  final inkLow = ValueNotifier<bool>(false);
  final progress = ValueNotifier<double>(0);
  final multiplierActive = ValueNotifier<bool>(false);
  final slowActive = ValueNotifier<bool>(false);
  final reversed = ValueNotifier<bool>(false);

  static const _step = 0.005;

  void update({
    required double rawPoints,
    required double maxPoints,
    required double inkFraction,
    required bool isInkLow,
    required double progressValue,
    required bool multiplier,
    required bool slow,
    required bool reverse,
  }) {
    score.value = rawPoints.round();
    livePercent.value = maxPoints <= 0
        ? 0
        : (rawPoints / maxPoints * 100).clamp(0, 100).round();
    if ((ink.value - inkFraction).abs() >= _step || inkFraction == 0) {
      ink.value = inkFraction;
    }
    inkLow.value = isInkLow;
    if ((progress.value - progressValue).abs() >= _step || progressValue >= 1) {
      progress.value = progressValue;
    }
    multiplierActive.value = multiplier;
    slowActive.value = slow;
    reversed.value = reverse;
  }

  void dispose() {
    for (final n in <ChangeNotifier>[
      score,
      livePercent,
      ink,
      inkLow,
      progress,
      multiplierActive,
      slowActive,
      reversed,
    ]) {
      n.dispose();
    }
  }
}
