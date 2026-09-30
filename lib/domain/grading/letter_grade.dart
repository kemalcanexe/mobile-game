/// Amerikan harf notu: alt sınır dahil, üst sınır hariç.
class LetterGrade {
  const LetterGrade({
    required this.symbol,
    required this.minScore,
    required this.points,
  });

  factory LetterGrade.fromJson(Map<String, dynamic> json) => LetterGrade(
    symbol: json['letter'] as String,
    minScore: (json['min'] as num).toDouble(),
    points: (json['points'] as num).toDouble(),
  );

  final String symbol;
  final double minScore;
  final double points;

  bool get isFailing => points == 0;

  @override
  bool operator ==(Object other) =>
      other is LetterGrade && other.symbol == symbol;

  @override
  int get hashCode => symbol.hashCode;

  @override
  String toString() => symbol;
}

/// Skoru harfe çeviren tablo.
class GradeScale {
  GradeScale(List<LetterGrade> grades)
    : grades = List.unmodifiable(
        [...grades]..sort((a, b) => b.minScore.compareTo(a.minScore)),
      ) {
    if (this.grades.isEmpty || this.grades.last.minScore > 0) {
      throw ArgumentError('Harf tablosu 0 alt sınırlı bir harf içermeli.');
    }
  }

  factory GradeScale.fromJson(List<dynamic> json) => GradeScale(
    json.map((e) => LetterGrade.fromJson(e as Map<String, dynamic>)).toList(),
  );

  /// Kayan nokta toplamlarından gelen (ör. 96.99999999999999) hataları
  /// sınırda yutmak için tolerans. Gösterilen hiçbir skoru değiştirmez.
  static const double _epsilon = 1e-9;

  /// Yüksekten düşüğe sıralı.
  final List<LetterGrade> grades;

  LetterGrade gradeFor(double score) => grades.firstWhere(
    (g) => score + _epsilon >= g.minScore,
    orElse: () => grades.last,
  );

  LetterGrade bySymbol(String symbol) => grades.firstWhere(
    (g) => g.symbol == symbol,
    orElse: () => throw FormatException('Bilinmeyen harf notu: $symbol'),
  );
}
