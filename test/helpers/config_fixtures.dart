import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:tukenmez_gpa_run/game/config/game_config.dart';
import 'package:tukenmez_gpa_run/game/config/item_catalog.dart';

import 'package:tukenmez_gpa_run/domain/grading/grading_rules.dart';

/// Testler gerçek (oyunla birlikte gelen) config dosyasını kullanır; böylece
/// JSON'daki bir değişiklik testleri de etkiler.
Map<String, dynamic> readJsonAsset(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

GradingRules loadGradingRules() =>
    GradingRules.fromJson(readJsonAsset('assets/config/grading.json'));

class DiskAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    final bytes = await File(key).readAsBytes();
    return ByteData.sublistView(bytes);
  }
}

GameConfig loadGameConfig() =>
    GameConfig.fromJson(readJsonAsset('assets/config/game.json'));

ItemCatalog loadCatalog() =>
    ItemCatalog.fromJson(readJsonAsset('assets/config/items.json'));
