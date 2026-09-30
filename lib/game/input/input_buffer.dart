import 'swipe_detector.dart';

/// O an uygulanamayan bir swipe'ı (ör. havadayken zıpla) kısa bir süre
/// saklar; süre içinde uygulanabilir olursa çalıştırılır.
class InputBuffer {
  InputBuffer(this.window);

  /// Saniye (config: input.bufferSeconds).
  final double window;

  SwipeDirection? _pending;
  double _age = 0;

  SwipeDirection? get pending => _pending;

  void push(SwipeDirection direction) {
    _pending = direction;
    _age = 0;
  }

  /// [tryExecute] true dönerse bekleyen swipe tüketilir.
  void update(double dt, bool Function(SwipeDirection) tryExecute) {
    final p = _pending;
    if (p == null) return;
    if (tryExecute(p)) {
      _pending = null;
      return;
    }
    _age += dt;
    if (_age > window) _pending = null;
  }

  void clear() => _pending = null;
}
