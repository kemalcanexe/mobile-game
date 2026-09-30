/// Bir dersin izlencesindeki değerlendirme türleri. Her biri bir level'dır.
enum AssessmentType {
  quiz1('quiz1'),
  midterm('midterm'),
  quiz2('quiz2'),
  project('project'),
  finalExam('final');

  const AssessmentType(this.key);

  /// JSON ve kayıt dosyalarında kullanılan anahtar.
  final String key;

  static AssessmentType fromKey(String key) => AssessmentType.values.firstWhere(
    (t) => t.key == key,
    orElse: () => throw FormatException('Bilinmeyen değerlendirme türü: $key'),
  );
}
