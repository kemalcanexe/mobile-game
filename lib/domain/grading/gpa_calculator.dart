/// GPA hesabına giren tek bir ders girdisi.
abstract interface class GpaEntry {
  double get gradePoints;
  int get credits;
}

/// Kredi ağırlıklı GPA: Σ(puan × kredi) / Σ(kredi). Hesapta yuvarlama yok.
class GpaCalculator {
  const GpaCalculator();

  /// Hiç kredi yoksa `null` döner (GPA tanımsız).
  double? gpa(Iterable<GpaEntry> entries) {
    var weighted = 0.0;
    var credits = 0;
    for (final e in entries) {
      weighted += e.gradePoints * e.credits;
      credits += e.credits;
    }
    if (credits == 0) return null;
    return weighted / credits;
  }

  /// Gösterim: 2 ondalık basamak. GPA tanımsızsa "—".
  static String format(double? gpa) => gpa == null ? '—' : gpa.toStringAsFixed(2);
}
