/// Hocanın level sonu yorumları (assets/config/comments.json).
class CommentBank {
  CommentBank(this._groups);

  factory CommentBank.fromJson(Map<String, dynamic> json, String locale) {
    final lang = (json[locale] ?? json['tr']) as Map<String, dynamic>;
    return CommentBank({
      for (final e in lang.entries) e.key: (e.value as List).cast<String>(),
    });
  }

  final Map<String, List<String>> _groups;

  /// Harfin ilk karakterine göre (A+, A- → A) seed'li seçim.
  String pick({
    required String letter,
    required bool inkOut,
    required int seed,
  }) {
    final key = inkOut ? 'inkOut' : letter.substring(0, 1);
    final list = _groups[key] ?? _groups['C'] ?? const ['…'];
    return list[seed.abs() % list.length];
  }
}
