import '../../data/models/level_definition.dart';

/// Level içi hız çarpanı. İlerleme (0-1) mesafe üzerinden ölçülür; böylece
/// Kahve oyunu yavaşlattığında desenler ve hız eğrisi bozulmaz.
class SpeedCurve {
  const SpeedCurve(this.spec, {this.semesterMultiplier = 1});

  final SpeedSpec spec;

  /// Üst dönemlerde bütün hızları ölçekler (MVP'de 1).
  final double semesterMultiplier;

  double _ease(double p) => switch (spec.curve) {
    SpeedCurveType.linear => p,
    SpeedCurveType.easeIn => p * p,
    SpeedCurveType.easeInOut => p * p * (3 - 2 * p),
  };

  double multiplierAt(double progress) {
    final p = progress.clamp(0.0, 1.0);
    return (spec.start + (spec.end - spec.start) * _ease(p)) *
        semesterMultiplier;
  }

  /// [durationSeconds] sürede, bu eğriyle katedilecek toplam mesafe.
  /// T = D/v0 · ∫₀¹ dp / m(p)  ⇒  D = T · v0 / ∫₀¹ dp / m(p)
  double distanceFor(double durationSeconds, double baseSpeed) {
    const steps = 200; // Simpson için çift sayı
    const h = 1 / steps;
    var sum = 1 / multiplierAt(0) + 1 / multiplierAt(1);
    for (var i = 1; i < steps; i++) {
      sum += (i.isOdd ? 4 : 2) / multiplierAt(i * h);
    }
    final integral = sum * h / 3;
    return durationSeconds * baseSpeed / integral;
  }
}
