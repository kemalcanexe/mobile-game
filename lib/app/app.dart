import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ui/screens/main_menu_screen.dart';
import '../ui/widgets/paper_backdrop.dart';
import 'l10n/generated/app_localizations.dart';
import 'palette.dart';
import 'providers.dart';
import 'theme.dart';

class TukenmezApp extends StatelessWidget {
  const TukenmezApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    onGenerateTitle: (c) => AppLocalizations.of(c).appTitle,
    debugShowCheckedModeBanner: false,
    theme: AppTheme.build(),
    locale: const Locale('tr'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: const _Boot(),
  );
}

/// Oyun verisini yükler; hazır olunca ana menüyü açar.
class _Boot extends ConsumerWidget {
  const _Boot();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return ref
        .watch(contentProvider)
        .when(
          data: (_) => const MainMenuScreen(),
          loading: () => Scaffold(
            body: PaperBackdrop(
              child: Center(child: Text(l.loading, style: AppTheme.hand(32))),
            ),
          ),
          error: (e, _) => Scaffold(
            body: PaperBackdrop(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    l.loadError('$e'),
                    style: AppTheme.ui(16, color: Palette.teacherRed),
                  ),
                ),
              ),
            ),
          ),
        );
  }
}
