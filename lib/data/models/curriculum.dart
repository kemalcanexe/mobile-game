import '../../game/config/json_read.dart';

/// Hangi dönemde hangi derslerin sunulduğu (assets/levels/curriculum.json).
class Curriculum {
  Curriculum({
    required this.requiredSemesters,
    required Map<int, List<String>> offered,
  }) : _offered = Map.unmodifiable(offered);

  factory Curriculum.fromJson(Map<String, dynamic> json) {
    final r = JsonReader(json, 'curriculum.json');
    return Curriculum(
      requiredSemesters: r.integer('requiredSemesters'),
      offered: {
        for (final s in r.objects('semesters'))
          s.integer('index'): s.list('offered').cast<String>(),
      },
    );
  }

  final int requiredSemesters;
  final Map<int, List<String>> _offered;

  /// Dönemde yeni alınabilecek dersler (retake'ler hariç).
  List<String> offeredIn(int semester) => _offered[semester] ?? const [];

  Iterable<String> get allCourseIds => _offered.values.expand((e) => e);
}
