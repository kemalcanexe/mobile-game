enum MapMarkerKind { star, stain }

class TrailSample {
  const TrailSample(this.x, this.distance, this.airborne);
  final double x;
  final double distance;
  final bool airborne;
}

class MapMarker {
  const MapMarker(this.x, this.distance, this.kind);
  final double x;
  final double distance;
  final MapMarkerKind kind;
}

/// Level sonunda gösterilen "ders notu" sayfası: kıvrılan mürekkep çizgisi,
/// toplananların yerindeki yıldızlar, çarpılanların yerindeki lekeler.
class PageMap {
  PageMap({
    required this.width,
    required this.totalDistance,
    required this.sampleDistance,
    required this.maxSamples,
  });

  final double width;
  final double totalDistance;
  final double sampleDistance;
  final int maxSamples;
  final List<TrailSample> trail = [];
  final List<MapMarker> markers = [];
  double _lastSample = double.negativeInfinity;

  /// Ne kadar yol alındı (erken biten level'larda < totalDistance).
  double reachedDistance = 0;

  void sample(double x, double distance, bool airborne) {
    reachedDistance = distance;
    if (distance - _lastSample < sampleDistance || trail.length >= maxSamples) {
      return;
    }
    _lastSample = distance;
    trail.add(TrailSample(x, distance, airborne));
  }

  void mark(double x, double distance, MapMarkerKind kind) {
    if (markers.length < maxSamples) markers.add(MapMarker(x, distance, kind));
  }
}
