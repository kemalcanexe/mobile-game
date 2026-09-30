enum SwipeDirection { left, right, up, down }

/// Baskın eksene göre swipe sınıflandırma. Parmak eşik mesafesini geçtiği anda
/// (sürükleme bitmeden) swipe üretir; kısa ama hızlı fırlatmalar sürükleme
/// sonunda hız eşiğiyle yakalanır. Her sürükleme en fazla bir swipe üretir.
class SwipeDetector {
  SwipeDetector({required this.minDistance, required this.minFlingVelocity});

  final double minDistance;
  final double minFlingVelocity;

  double _dx = 0;
  double _dy = 0;
  bool _active = false;
  bool _fired = false;

  void start() {
    _dx = 0;
    _dy = 0;
    _active = true;
    _fired = false;
  }

  /// Sürükleme yer değiştirmesini ekler; eşik geçildiyse yönü döner.
  SwipeDirection? update(double dx, double dy) {
    if (!_active || _fired) return null;
    _dx += dx;
    _dy += dy;
    if (_dx * _dx + _dy * _dy < minDistance * minDistance) return null;
    _fired = true;
    return classify(_dx, _dy);
  }

  /// Sürükleme bitti. Henüz swipe üretilmediyse hıza bakar.
  SwipeDirection? end(double vx, double vy) {
    if (!_active) return null;
    _active = false;
    if (_fired) return null;
    if (vx * vx + vy * vy < minFlingVelocity * minFlingVelocity) return null;
    return classify(vx, vy);
  }

  static SwipeDirection classify(double dx, double dy) {
    if (dx.abs() > dy.abs()) {
      return dx < 0 ? SwipeDirection.left : SwipeDirection.right;
    }
    return dy < 0 ? SwipeDirection.up : SwipeDirection.down;
  }
}
