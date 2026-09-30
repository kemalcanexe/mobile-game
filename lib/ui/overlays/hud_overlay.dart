import 'package:flutter/material.dart';

import '../../app/l10n/generated/app_localizations.dart';
import '../../app/palette.dart';
import '../../app/theme.dart';
import '../../game/tukenmez_game.dart';
import '../widgets/ink_meter.dart';

/// Skor, mürekkep haznesi, sayfa ilerlemesi ve duraklatma.
class HudOverlay extends StatelessWidget {
  const HudOverlay({super.key, required this.game});

  final TukenmezGame game;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final hud = game.hud;
    return SafeArea(
      child: Stack(
        children: [
          // ilerleme çubuğu
          Positioned(
            left: 110,
            right: 60,
            top: 18,
            child: ValueListenableBuilder<double>(
              valueListenable: hud.progress,
              builder: (_, p, _) => _ProgressBar(progress: p),
            ),
          ),
          // skor
          Positioned(
            left: 12,
            top: 4,
            child: ValueListenableBuilder<int>(
              valueListenable: hud.score,
              builder: (_, s, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$s', style: AppTheme.hand(36)),
                  ValueListenableBuilder<int>(
                    valueListenable: hud.livePercent,
                    builder: (_, pct, _) => Text(
                      '%$pct',
                      style: AppTheme.ui(14, color: Palette.pencil),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // duraklat
          Positioned(
            right: 4,
            top: 0,
            child: IconButton(
              tooltip: l.hudPause,
              iconSize: 32,
              icon: const Icon(Icons.pause_circle_outline, color: Palette.ink),
              onPressed: game.pauseGame,
            ),
          ),
          // mürekkep haznesi
          Positioned(
            left: 8,
            top: 90,
            child: ValueListenableBuilder<double>(
              valueListenable: hud.ink,
              builder: (_, ink, _) => ValueListenableBuilder<bool>(
                valueListenable: hud.inkLow,
                builder: (_, low, _) => InkMeter(fraction: ink, low: low),
              ),
            ),
          ),
          // aktif efektler
          Positioned(
            right: 10,
            top: 56,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _EffectChip(
                  hud.multiplierActive,
                  l.effectDouble,
                  Palette.highlighterYellow,
                ),
                _EffectChip(
                  hud.slowActive,
                  l.effectFocus,
                  const Color(0xFFE8D5C0),
                ),
                _EffectChip(
                  hud.reversed,
                  l.effectReversed,
                  const Color(0xFFE3D0F5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 14,
    child: LayoutBuilder(
      builder: (_, c) => Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Palette.ink, width: 1.6),
              borderRadius: BorderRadius.circular(7),
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          Container(
            width: c.maxWidth * progress,
            decoration: BoxDecoration(
              color: Palette.highlighterYellow,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: Palette.ink, width: 1.6),
            ),
          ),
        ],
      ),
    ),
  );
}

class _EffectChip extends StatelessWidget {
  const _EffectChip(this.active, this.label, this.color);
  final ValueNotifier<bool> active;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<bool>(
    valueListenable: active,
    builder: (_, on, _) => on
        ? Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            color: color,
            child: Text(label, style: AppTheme.hand(22)),
          )
        : const SizedBox.shrink(),
  );
}
