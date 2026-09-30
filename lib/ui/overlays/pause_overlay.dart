import 'package:flutter/material.dart';

import '../../app/l10n/generated/app_localizations.dart';
import '../../app/palette.dart';
import '../../app/theme.dart';
import '../../game/tukenmez_game.dart';
import '../widgets/post_it_button.dart';
import '../widgets/torn_card.dart';

class PauseOverlay extends StatelessWidget {
  const PauseOverlay({super.key, required this.game, required this.onQuit});

  final TukenmezGame game;
  final VoidCallback onQuit;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ColoredBox(
      color: const Color(0x88000000),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: TornCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l.pauseTitle, style: AppTheme.hand(48)),
                const SizedBox(height: 16),
                PostItButton(label: l.resume, onPressed: game.resumeGame),
                const SizedBox(height: 18),
                PostItButton(
                  label: l.quitAssessment,
                  color: Palette.postItPink,
                  fontSize: 24,
                  tilt: 0.02,
                  onPressed: onQuit,
                ),
                const SizedBox(height: 10),
                Text(
                  l.quitWarning,
                  textAlign: TextAlign.center,
                  style: AppTheme.ui(15, color: Palette.pencil),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
