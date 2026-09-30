/// Süreli güçlendirici ve debuff'ların kalan süreleri. Her karede okunur;
/// allocation yapmaz.
class EffectState {
  double _multiplierLeft = 0;
  double _multiplier = 1;
  double _slowLeft = 0;
  double _slowFraction = 0;
  double _reverseLeft = 0;
  double _notificationLeft = 0;

  double get scoreMultiplier => _multiplierLeft > 0 ? _multiplier : 1;

  /// Oyun hızına uygulanacak çarpan (Kahve: 1 - 0.3 = 0.7).
  double get timeScale => _slowLeft > 0 ? 1 - _slowFraction : 1;

  bool get controlsReversed => _reverseLeft > 0;
  bool get notificationVisible => _notificationLeft > 0;

  double get multiplierLeft => _multiplierLeft;
  double get slowLeft => _slowLeft;
  double get reverseLeft => _reverseLeft;
  double get notificationLeft => _notificationLeft;

  void startMultiplier(double value, double duration) {
    _multiplier = value;
    _multiplierLeft = duration;
  }

  void startSlow(double fraction, double duration) {
    _slowFraction = fraction;
    _slowLeft = duration;
  }

  void startReverse(double duration) => _reverseLeft = duration;

  void startNotification(double duration) => _notificationLeft = duration;

  /// Süreler gerçek zamanla akar (Kahve onları uzatmaz).
  void update(double dt) {
    if (_multiplierLeft > 0) _multiplierLeft -= dt;
    if (_slowLeft > 0) _slowLeft -= dt;
    if (_reverseLeft > 0) _reverseLeft -= dt;
    if (_notificationLeft > 0) _notificationLeft -= dt;
  }
}
