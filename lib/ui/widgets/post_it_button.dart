import 'package:flutter/material.dart';

import '../../app/palette.dart';
import '../../app/theme.dart';

/// Yapışkan not görünümlü buton.
class PostItButton extends StatelessWidget {
  const PostItButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = Palette.postIt,
    this.tilt = -0.02,
    this.fontSize = 30,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final double tilt;
  final double fontSize;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Transform.rotate(
      angle: tilt,
      child: Semantics(
        button: true,
        label: label,
        child: GestureDetector(
          onTap: onPressed,
          child: Opacity(
            opacity: enabled ? 1 : 0.5,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(18),
                  topLeft: Radius.circular(2),
                  topRight: Radius.circular(2),
                  bottomLeft: Radius.circular(2),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 6,
                    offset: Offset(2, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: Palette.ink, size: fontSize * 0.8),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: AppTheme.hand(fontSize),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
