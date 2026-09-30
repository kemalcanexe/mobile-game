import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/grading/assessment.dart';
import '../game/config/item_catalog.dart';
import '../game/config/json_read.dart';
import 'level_validator.dart';
import 'models/level_definition.dart';

/// assets/levels altındaki ders ve level JSON'larını yükler ve doğrular.
class LevelRepository {
  LevelRepository({
    required this.bundle,
    required this.catalog,
    required this.laneCount,
    this.root = 'assets/levels',
  });

  final AssetBundle bundle;
  final ItemCatalog catalog;
  final int laneCount;
  final String root;

  Future<Map<String, dynamic>> _json(String path) async =>
      jsonDecode(await bundle.loadString('$root/$path'))
          as Map<String, dynamic>;

  Future<List<CourseDefinition>> loadCourses() async {
    final index = JsonReader(await _json('courses.json'), 'courses.json');
    return [
      for (final path in index.list('courses').cast<String>())
        await loadCourse(path),
    ];
  }

  Future<CourseDefinition> loadCourse(String path) async {
    final r = JsonReader(await _json(path), path);
    final patterns = <String, PatternDef>{};
    for (final file in r.list('patternFiles').cast<String>()) {
      final pr = JsonReader(await _json(file), file).object('patterns');
      for (final id in pr.json.keys) {
        if (patterns.containsKey(id)) {
          throw LevelFormatException([
            '$file: "$id" deseni tekrar tanımlanmış',
          ]);
        }
        patterns[id] = PatternDef.fromJson(id, pr.object(id));
      }
    }
    final levelPaths = r.object('levels');
    final levels = <AssessmentType, LevelDefinition>{
      for (final key in levelPaths.json.keys)
        AssessmentType.fromKey(key): LevelDefinition.fromJson(
          await _json(levelPaths.string(key)),
          levelPaths.string(key),
        ),
    };
    final course = CourseDefinition(
      id: r.string('id'),
      code: r.string('code'),
      title: r.string('title'),
      nickname: r.string('nickname'),
      credits: r.integer('credits'),
      semester: r.integer('semester'),
      paper: r.string('paper'),
      levels: levels,
      patterns: patterns,
    );
    final errors = LevelValidator(
      catalog: catalog,
      laneCount: laneCount,
    ).validate(course);
    if (errors.isNotEmpty) throw LevelFormatException(errors);
    return course;
  }
}
