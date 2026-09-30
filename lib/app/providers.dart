import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'game_content.dart';

final contentProvider = FutureProvider<GameContent>(
  (ref) => GameContent.load(rootBundle),
);
