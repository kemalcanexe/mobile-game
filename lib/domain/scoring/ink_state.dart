/// Mürekkep barı (can sistemi). Oyun döngüsünde her karede okunur, bu yüzden
/// değişken ve allocation'sız tutulur.
class InkState {
  InkState({required this.max, required this.lowThreshold}) : _current = max;

  final double max;
  final double lowThreshold;
  double _current;

  double get current => _current;
  double get fraction => _current / max;
  bool get isEmpty => _current <= 0;
  bool get isLow => _current < lowThreshold;

  /// Pozitif: doldur (tavan [max]); negatif: azalt (taban 0).
  void apply(double delta) {
    _current = (_current + delta).clamp(0, max).toDouble();
  }
}
