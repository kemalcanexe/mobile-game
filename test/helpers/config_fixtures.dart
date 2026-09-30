import 'dart:convert';
import 'dart:io';

import 'package:tukenmez_gpa_run/domain/grading/grading_rules.dart';

/// Testler gerçek (oyunla birlikte gelen) config dosyasını kullanır; böylece
/// JSON'daki bir değişiklik testleri de etkiler.
Map<String, dynamic> readJsonAsset(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

GradingRules loadGradingRules() =>
    GradingRules.fromJson(readJsonAsset('assets/config/grading.json'));
