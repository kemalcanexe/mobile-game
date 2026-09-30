/// Oyuncunun içinde bulunduğu dönem ve o dönem aldığı dersler.
class SemesterState {
  SemesterState({this.index = 1, List<String> enrolled = const []})
    : enrolled = List.unmodifiable(enrolled);

  factory SemesterState.fromJson(Map<String, dynamic> json) => SemesterState(
    index: json['index'] as int? ?? 1,
    enrolled: (json['enrolled'] as List? ?? const []).cast<String>(),
  );

  /// 1'den başlar.
  final int index;

  /// Bu dönem kayıt olunan ders kimlikleri. Boşsa ders seçimi bekleniyor.
  final List<String> enrolled;

  bool get needsEnrollment => enrolled.isEmpty;

  bool isEnrolled(String courseId) => enrolled.contains(courseId);

  SemesterState withEnrollment(List<String> courseIds) =>
      SemesterState(index: index, enrolled: courseIds);

  SemesterState next() => SemesterState(index: index + 1);

  Map<String, dynamic> toJson() => {'index': index, 'enrolled': enrolled};
}
