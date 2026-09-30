import 'dart:convert';

import 'package:flutter/services.dart';

import '../data/comment_bank.dart';
import '../data/level_repository.dart';
import '../data/models/curriculum.dart';
import '../data/models/level_definition.dart';
import '../domain/grading/grading_rules.dart';
import '../game/config/game_config.dart';
import '../game/config/item_catalog.dart';

/// Açılışta bir kez yüklenen bütün oyun verisi.
class GameContent {
  const GameContent({
    required this.config,
    required this.catalog,
    required this.grading,
    required this.courses,
    required this.curriculum,
    required this.comments,
  });

  final GameConfig config;
  final ItemCatalog catalog;
  final GradingRules grading;
  final List<CourseDefinition> courses;
  final Curriculum curriculum;
  final CommentBank comments;

  CourseDefinition course(String id) => courses.firstWhere((c) => c.id == id);

  static Future<GameContent> load(
    AssetBundle bundle, {
    String locale = 'tr',
  }) async {
    Future<Map<String, dynamic>> json(String path) async =>
        jsonDecode(await bundle.loadString(path)) as Map<String, dynamic>;

    final config = GameConfig.fromJson(await json('assets/config/game.json'));
    final catalog = ItemCatalog.fromJson(
      await json('assets/config/items.json'),
    );
    final grading = GradingRules.fromJson(
      await json('assets/config/grading.json'),
    );
    final comments = CommentBank.fromJson(
      await json('assets/config/comments.json'),
      locale,
    );
    final repo = LevelRepository(
      bundle: bundle,
      catalog: catalog,
      laneCount: config.laneCount,
    );
    final courses = await repo.loadCourses();
    final curriculum = await repo.loadCurriculum(courses.map((c) => c.id));
    return GameContent(
      config: config,
      catalog: catalog,
      grading: grading,
      courses: courses,
      curriculum: curriculum,
      comments: comments,
    );
  }
}
