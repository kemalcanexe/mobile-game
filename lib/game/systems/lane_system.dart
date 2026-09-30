/// 3 şeridin x koordinatları. Oyun alanı [worldWidth] genişliğinde ortalanır.
class LaneSystem {
  const LaneSystem({
    required this.laneCount,
    required this.laneWidth,
    required this.worldWidth,
  });

  final int laneCount;
  final double laneWidth;
  final double worldWidth;

  int get centerLane => laneCount ~/ 2;

  double laneX(int lane) =>
      worldWidth / 2 + (lane - (laneCount - 1) / 2) * laneWidth;

  /// Şeritler arasındaki kılavuz çizgilerin x koordinatları.
  Iterable<double> get dividerXs sync* {
    for (var i = 1; i < laneCount; i++) {
      yield laneX(i) - laneWidth / 2;
    }
  }

  int clamp(int lane) => lane.clamp(0, laneCount - 1);
}
