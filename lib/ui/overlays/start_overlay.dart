import 'package:flutter/material.dart';

import '../../app/l10n/generated/app_localizations.dart';
import '../../app/palette.dart';
import '../../app/theme.dart';
import '../../game/tukenmez_game.dart';
import '../widgets/post_it_button.dart';
import '../widgets/torn_card.dart';

class StartOverlay extends StatelessWidget {
  const StartOverlay({
    super.key,
    required this.game,
    required this.title,
    required this.onBack,
  });

  final TukenmezGame game;
  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final hints = [l.readyHintLanes, l.readyHintJump, l.readyHintDuck];
    return ColoredBox(
      color: const Color(0x55FBF8EF),
      child: SafeArea(
        child: Stack(
          children: [
            Positioned(
              left: 4,
              top: 4,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Palette.ink),
                onPressed: onBack,
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: TornCard(
                  tilt: -0.015,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTheme.hand(44)),
                      const SizedBox(height: 10),
                      for (final h in hints)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Text(h, style: AppTheme.ui(17)),
                        ),
                      const SizedBox(height: 6),
                      Text(
                        l.readyHintInk,
                        style: AppTheme.ui(16, color: Palette.teacherRed),
                      ),
                      const SizedBox(height: 18),
                      Center(
                        child: PostItButton(
                          label: l.start,
                          onPressed: game.start,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
