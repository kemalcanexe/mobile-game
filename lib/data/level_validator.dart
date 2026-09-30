import '../domain/grading/assessment.dart';
import '../game/config/item_catalog.dart';
import 'models/level_definition.dart';

/// Yüklenen ders verisinin şema dışı mantık kontrolleri.
class LevelValidator {
  const LevelValidator({required this.catalog, required this.laneCount});

  final ItemCatalog catalog;
  final int laneCount;

  /// Hataların listesini döner; boşsa veri geçerlidir.
  List<String> validate(CourseDefinition course) {
    final errors = <String>[];
    course.patterns.forEach((id, p) {
      if (p.rows.isEmpty) errors.add('desen "$id": satır yok');
      for (var i = 0; i < p.rows.length; i++) {
        final row = p.rows[i];
        if (row.length != laneCount) {
          errors.add(
            'desen "$id" satır $i: $laneCount hücre bekleniyordu, ${row.length} geldi',
          );
        }
        for (final code in row) {
          if (code != ItemCatalog.emptyCode && !catalog.contains(code)) {
            errors.add('desen "$id" satır $i: bilinmeyen nesne kodu "$code"');
          }
        }
        final walls = row.where(
          (c) => catalog.contains(c) && catalog[c].kind == ItemKind.wall,
        );
        final collectibles = row.where(
          (c) => catalog.contains(c) && catalog[c].countsTowardMax,
        );
        if (collectibles.length > 1) {
          errors.add(
            'desen "$id" satır $i: aynı satırda birden fazla toplanabilir '
            '(hepsi toplanamaz, %100 imkânsızlaşır)',
          );
        }
        if (walls.length >= laneCount) {
          errors.add(
            'desen "$id" satır $i: bütün şeritler duvarla kapalı (geçilemez)',
          );
        }
      }
    });

    for (final type in AssessmentType.values) {
      final level = course.levels[type];
      if (level == null) {
        errors.add('${course.id}: "${type.key}" level\'ı eksik');
        continue;
      }
      final where = level.id;
      if (level.assessment != type) {
        errors.add(
          '$where: assessment "${level.assessment.key}" ama "${type.key}" olarak bağlandı',
        );
      }
      if (level.durationSeconds <= 0) {
        errors.add('$where: süre pozitif olmalı');
      }
      if (level.speed.start <= 0 || level.speed.end < level.speed.start) {
        errors.add('$where: hız 0 < start ≤ end olmalı');
      }
      if (level.gapRowsMin < 0 || level.gapRowsMax < level.gapRowsMin) {
        errors.add('$where: gapRows 0 ≤ min ≤ max olmalı');
      }
      if (level.pool.isEmpty) errors.add('$where: desen havuzu boş');
      for (final e in level.pool) {
        if (!course.patterns.containsKey(e.pattern)) {
          errors.add('$where: havuzdaki "${e.pattern}" deseni tanımsız');
        }
        if (e.weight <= 0) {
          errors.add('$where: "${e.pattern}" ağırlığı pozitif olmalı');
        }
        if (e.fromProgress < 0 ||
            e.toProgress > 1 ||
            e.fromProgress >= e.toProgress) {
          errors.add('$where: "${e.pattern}" için 0 ≤ from < to ≤ 1 olmalı');
        }
      }
      for (final s in level.script) {
        if (!course.patterns.containsKey(s.pattern)) {
          errors.add('$where: senaryodaki "${s.pattern}" deseni tanımsız');
        }
        if (s.atProgress < 0 || s.atProgress > 1) {
          errors.add('$where: senaryo "at" değeri 0-1 arasında olmalı');
        }
      }
    }
    return errors;
  }
}

class LevelFormatException implements Exception {
  LevelFormatException(this.errors);
  final List<String> errors;

  @override
  String toString() => 'Geçersiz level verisi:\n- ${errors.join('\n- ')}';
}
