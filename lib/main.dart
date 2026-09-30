import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/progress_controller.dart';
import 'data/save_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final prefs = await SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(
      allowList: {SaveRepository.key},
    ),
  );
  runApp(
    ProviderScope(
      overrides: [
        saveRepositoryProvider.overrideWithValue(
          SaveRepository(PrefsStore(prefs)),
        ),
      ],
      child: const TukenmezApp(),
    ),
  );
}
